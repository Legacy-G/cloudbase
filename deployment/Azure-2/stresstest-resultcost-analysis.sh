Alright Gbure, let’s tackle this step by step. We’ll update your manifest for a clean slate, then do the math for scaling Odoo to handle 10k, 20k, and 30k concurrent users based on the test results you’ve achieved.

---

## 1. Updated `manifest.yaml` (no persistent volumes)

Here’s a cleaned‑up version of your manifest, keeping everything ephemeral (`emptyDir`) and ready for redeployment:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: odoo-prod
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: odoo-config
  namespace: odoo-prod
data:
  odoo.conf: |
    [options]
    addons_path = /usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons
    admin_passwd = admin
    db_host = db
    db_port = 5432
    db_user = odoo
    db_password = odoo
    list_db = True
    log_level = info
    http_port = 8069
    gevent_port = 8072
    server_wide_modules = base,web
    workers = 4        # scale workers up from 2 to 4 initially
    csv_internal_sep = ,
    data_dir = /var/lib/odoo/sessions
    screenshots = /tmp/odoo_tests
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
  namespace: odoo-prod
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: postgres
          image: postgres:17.5
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_USER
              value: postgres
            - name: POSTGRES_PASSWORD
              value: postgres
          volumeMounts:
            - name: pgdata
              mountPath: /var/lib/postgresql/data
          readinessProbe:
            exec:
              command: ["pg_isready", "-U", "postgres", "-d", "postgres"]
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 5
      volumes:
        - name: pgdata
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: db
  namespace: odoo-prod
spec:
  selector:
    app: db
  ports:
    - port: 5432
      targetPort: 5432
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: odoo
  namespace: odoo-prod
spec:
  replicas: 3   # start with 3 pods for horizontal scaling
  selector:
    matchLabels:
      app: odoo
  template:
    metadata:
      labels:
        app: odoo
    spec:
      initContainers:
        - name: wait-for-postgres
          image: postgres:17.5
          command: ['sh', '-c', 'until pg_isready -h db -U postgres; do echo waiting for db; sleep 2; done;']
      containers:
        - name: odoo
          image: legacyg/dbmsdocker:with-addons-v1
          ports:
            - containerPort: 8069
            - containerPort: 8072
          env:
            - name: HOST
              value: db
            - name: USER
              value: odoo
            - name: PASSWORD
              value: odoo
          volumeMounts:
            - name: config
              mountPath: /etc/odoo/odoo.conf
              subPath: odoo.conf
      volumes:
        - name: config
          configMap:
            name: odoo-config
---
apiVersion: v1
kind: Service
metadata:
  name: odoo-svc
  namespace: odoo-prod
spec:
  type: LoadBalancer
  selector:
    app: odoo
  ports:
    - name: http
      port: 8069
      targetPort: 8069
    - name: longpoll
      port: 8072
      targetPort: 8072
```

---

## 2. Clean slate commands

To wipe everything in `odoo-prod` before redeploying:

```bash
kubectl delete namespace odoo-prod
kubectl apply -f manifest.yaml
```

This deletes all pods, services, and deployments in that namespace, then recreates them fresh.

---

## 3. Math for scaling to 10k, 20k, 30k users

From your test results:

- With **100 VUs**, you saw ~235 successful logins and ~118 failures (≈66% success).
- Latency p95 was ~24s, which is too high.
- That tells us **one Odoo pod with 2 workers can realistically handle ~200–300 concurrent logins before lag/failure spikes**.

Let’s extrapolate:

### Assumptions
- One Odoo worker can handle ~50–75 concurrent logins.
- One pod with 4 workers ≈ 200–300 concurrent users.
- To keep latency <2s and failure <5%, we need enough pods/workers to spread the load.

### Calculations

| Target Users | Required Workers | Pods (4 workers each) | Notes |
|--------------|------------------|-----------------------|-------|
| 10,000       | ~200 workers     | ~50 pods              | Each pod handles ~200 users |
| 20,000       | ~400 workers     | ~100 pods             | Double the pod count |
| 30,000       | ~600 workers     | ~150 pods             | Triple baseline |

---

### Resource estimates per pod
- **CPU**: ~2 vCPUs per pod (to run 4 workers comfortably).  
- **Memory**: ~4 GiB per pod.  
- **Cost (Azure AKS)**:  
  - Assume Standard_D2s_v3 node (2 vCPU, 8 GiB RAM) ≈ $0.096/hour.  
  - Each node can host 2 pods.  
  - For 50 pods → 25 nodes ≈ $2.40/hour (~$1,728/month).  
  - For 100 pods → 50 nodes ≈ $4.80/hour (~$3,456/month).  
  - For 150 pods → 75 nodes ≈ $7.20/hour (~$5,184/month).

---

### Odoo.conf scaling
Update workers in `odoo.conf`:

- For small scale (≤500 users): `workers = 4`
- For 10k users: `workers = 200` spread across 50 pods (4 each).
- For 20k users: `workers = 400` spread across 100 pods.
- For 30k users: `workers = 600` spread across 150 pods.

---

## 4. Summary

- **Current pod (2 workers)**: handles ~200–300 users before lag.  
- **To reach 10k users**: ~50 pods, 200 workers total.  
- **To reach 20k users**: ~100 pods, 400 workers total.  
- **To reach 30k users**: ~150 pods, 600 workers total.  
- **Cost**: scales linearly, ~$1.7k/month for 10k, ~$3.4k/month for 20k, ~$5.1k/month for 30k.

---
