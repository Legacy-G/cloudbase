# CloudTrack-DBMS Deployment on Azure Kubernetes Service (AKS)

## 📌 Project Overview
This project provisions and deploys **CloudTrack-DBMS** with a **PostgreSQL backend** on **Azure Kubernetes Service (AKS)**.  
It includes:

- Kubernetes manifests for **CloudTrack-DBMS** and **PostgreSQL** deployments.
- Automated **database initialization scripts** via ConfigMaps.
- **Azure LoadBalancer Service** exposing CloudTrack-DBMS externally.
- **Monitoring stack** (Prometheus + Grafana) for live metrics.
- **Stress testing scripts** (k6, Locust) to validate performance under **10,000+ concurrent logins**.
- Documentation for **deployment, debugging, and scaling**.

---

## 📂 Repository Structure

```
Azure-ActualDeployment/
│
├── initdb/                          # Database initialization scripts
├── cloudtrack.xml                   # Cluster state, pod metrics, services
├── code-doc.md                      # Deployment commands & operational notes
├── live-stresstesting-documentation.md  # Stress testing methodology
├── login-test.js                    # k6 script for load testing
├── login-test1.js                   # Alternate k6 script with metrics
├── manifest.yaml                    # Kubernetes manifests (CloudTrack-DBMS + Postgres)
├── stresstest-result-analysis.md    # Analysis of stress test results
└── usergroup-reset.py               # Utility script for user group reset
```

---

## ⚙️ Architecture

- **Azure Kubernetes Service (AKS)**  
  - 2 worker nodes (Ubuntu 22.04, containerd runtime).  
  - Each node: 2 vCPUs, 7 GB RAM.  

- **PostgreSQL**  
  - Runs as a Kubernetes Deployment.  
  - Initialized with `initdb` scripts via ConfigMap.  
  - Exposed internally via ClusterIP service.  

- **CloudTrack-DBMS**  
  - Runs as a Kubernetes Deployment.  
  - Waits for PostgreSQL readiness via initContainer.  
  - Exposed externally via Azure LoadBalancer (`odoo-svc`).  
  - Accessible at:  
    - `http://<EXTERNAL-IP>:8069` (main web UI)  
    - `http://<EXTERNAL-IP>:8072` (longpolling)  

- **Monitoring**  
  - Prometheus + Grafana stack deployed in `monitoring` namespace.  
  - Tracks CPU, memory, pod restarts, DB connections, and request latency.  

- **Stress Testing**  
  - k6 scripts simulate **10,000+ concurrent logins**.  
  - Locust alternative for realistic user journeys.  
  - Metrics analyzed in `stresstest-result-analysis.md`.  

---

## 🚀 Deployment Guide

### 1. Connect to AKS
```bash
az aks get-credentials \
  --resource-group cloudtrackit2025 \
  --name cloudtrack
```

### 2. Apply Kubernetes Manifests
```bash
kubectl apply -f manifest.yaml
```

### 3. Verify Deployments
```bash
kubectl -n odoo-prod get all
kubectl -n odoo-prod logs deploy/db
kubectl -n odoo-prod logs deploy/odoo
```

### 4. Access Odoo
```bash
kubectl -n odoo-prod get svc odoo-svc
```
- External IP will be shown (e.g., `4.253.33.191`).  
- Access via:  
  - `http://4.253.33.191:8069`  
  - `http://4.253.33.191:8069/web/database/manager`  

### 5. Database Initialization
```bash
kubectl -n odoo-prod create configmap initdb-scripts \
  --from-file=initdb.sh=initdb/initdb.sh
kubectl -n odoo-prod delete pod -l app=db
```

### 6. Stress Testing
Run **10k login simulation**:
```bash
k6 run login-test.js
```

---

## 📊 Scaling & Cost Analysis

| Scenario | Node Size | Node Count | vCPU Total | Memory Total | Estimated Monthly Cost (USD) | Notes |
|----------|-----------|------------|------------|--------------|------------------------------|-------|
| Baseline | Standard_B2s (2 vCPU, 7 GB) | 2 | 4 vCPU | 14 GB | ~$90 | Handles ~2k concurrent logins |
| Medium   | Standard_B4ms (4 vCPU, 16 GB) | 3 | 12 vCPU | 48 GB | ~$400 | Handles ~5k concurrent logins |
| Large    | Standard_B8ms (8 vCPU, 32 GB) | 4 | 32 vCPU | 128 GB | ~$1200 | Handles ~10k+ concurrent logins |
| Optimized| Standard_D8s_v5 (8 vCPU, 32 GB) | 3 | 24 vCPU | 96 GB | ~$900 | Balanced CPU/memory, better IOPS |

> 💡 Costs are approximate Azure PAYG estimates (excluding storage, bandwidth, monitoring).  
> Scaling should be tuned based on **stress test results** and **real-world traffic patterns**.  

---

## 📈 Monitoring

- **Prometheus + Grafana**:  
  - Latency, throughput, error rates.  
  - Pod CPU/memory usage.  
  - DB connection pool metrics.  

- **Azure Monitor**:  
  - Node-level CPU/memory/network.  
  - Pod restarts and scaling events.  

---

## ✅ Key Outcomes
- Successfully deployed **CloudTrack-DBMS + PostgreSQL** on AKS.  
- Exposed via Azure LoadBalancer with external access.  
- Stress-tested with **10,000+ concurrent logins**.  
- Identified scaling strategies for production readiness.  

---

## 📌 Next Steps
- Implement **pgbouncer** for Postgres connection pooling.  
- Configure **HPA** for Odoo workers.  
- Add **CI/CD pipeline** for automated deployments.  
- Harden security (TLS, secrets management, RBAC).  
```

--- Built, Debloyed And Tested By Gbure Thomas In Respect with IT-2025 CLOUDTRACK PROJECT