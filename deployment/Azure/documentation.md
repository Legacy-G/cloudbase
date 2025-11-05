
## Deployment Strategy on Azure

## 🛠️ Step 1: Prepare Azure Resources

1. **Create a Resource Group**
   ```bash
   az group create --name futminna-odoo-rg --location westus
   ```

2. **Create an AKS Cluster**
   ```bash
   az aks create \
     --resource-group futminna-odoo-rg \
     --name futminna-odoo-cluster \
     --node-count 2 \
     --enable-addons monitoring \
     --generate-ssh-keys
   ```

3. **Get AKS Credentials**
   ```bash
   az aks get-credentials --resource-group futminna-odoo-rg --name futminna-odoo-cluster
   ```

## 🛠️ Step 2: Use Azure Database for PostgreSQL (Recommended)

**Azure Database for PostgreSQL Flexible Server**:

```bash
az postgres flexible-server create \
  --resource-group futminna-odoo-rg \
  --name futminna-postgres \
  --admin-user postgres \
  --admin-password StrongPassword123! \
  --sku-name Standard_B1ms
```

## 🛠️ Step 3: Containerize Odoo for Azure

If You already have a `Dockerfile`. Push it to **Azure Container Registry (ACR):**

1. Create ACR:
   ```bash
   az acr create --resource-group futminna-odoo-rg --name futminnaacr --sku Basic
   ```

2. Build & Push Image:
   ```bash
   az acr login --name futminnaacr
   docker build -t futminnaacr.azurecr.io/odoo18-educate:v1 .
   docker push futminnaacr.azurecr.io/odoo18-educate:v1
   ```
Or Pull from Docker Hub in your deployment manifest


## 🛠️ Step 4: Deploy Odoo on AKS

Create a **Kubernetes Deployment + Service** for Odoo:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: odoo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: odoo
  template:
    metadata:
      labels:
        app: odoo
    spec:
      containers:
      - name: odoo
        image: futminnaacr.azurecr.io/odoo18-educate:v1
        ports:
        - containerPort: 8069
        env:
        - name: HOST
          value: futminna-postgres.postgres.database.azure.com
        - name: USER
          value: odoo
        - name: PASSWORD
          value: odoo
---
apiVersion: v1
kind: Service
metadata:
  name: odoo-service
spec:
  type: LoadBalancer
  selector:
    app: odoo
  ports:
  - port: 80
    targetPort: 8069
```

Apply it:
```bash
kubectl apply -f odoo-deployment.yaml
```

---

## 🛠️ Step 5: Database Initialization

if you plan creating database role from your automation code like `setup.sh` for role + restore, you’ll adapt it for Azure Postgres:

- Run it **once** from your local machine or a Kubernetes Job.
- Example Job:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-init
spec:
  template:
    spec:
      containers:
      - name: db-init
        image: postgres:17.5
        command: ["/bin/bash", "-c", "/scripts/setup.sh"]
        env:
        - name: PGPASSWORD
          value: StrongPassword123!
      restartPolicy: Never
```

Mount your `setup.sh` + dump file into this job, run it, and it will create the role + restore your `it2025` DB.

---

## 🛠️ Step 6: Verify & Expose

- Get external IP:
  ```bash
  kubectl get svc odoo-service
  ```
- Access Odoo at `http://<EXTERNAL-IP>`.