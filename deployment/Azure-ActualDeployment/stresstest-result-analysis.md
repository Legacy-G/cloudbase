## Math for scaling to 10k, 20k, 30k users

From stress test results:

- With **100 VUs**, we saw ~235 successful logins and ~118 failures (≈66% success).
- Latency p95 was ~24s, which is too high.
- That tells us **one CloudTrack-DBMS pod with 2 workers can realistically handle ~200–300 concurrent logins before lag/failure spikes**.

---

Let’s extrapolate:

### Assumptions
- One CloudTrack-DBMS worker can handle ~50–75 concurrent logins.
- One pod with 4 workers ≈ 200–300 concurrent users.
- To keep latency <2s and failure <5%, we need enough pods/workers to spread the load.

---

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

### CloudTrack-DBMS.conf scaling
Update workers in `odoo.conf`:

- For small scale (≤500 users): `workers = 4`
- For 10k users: `workers = 200` spread across 50 pods (4 each).
- For 20k users: `workers = 400` spread across 100 pods.
- For 30k users: `workers = 600` spread across 150 pods.

---

### Summary

- **Current pod (2 workers)**: handles ~200–300 users before lag.  
- **To reach 10k users**: ~50 pods, 200 workers total.  
- **To reach 20k users**: ~100 pods, 400 workers total.  
- **To reach 30k users**: ~150 pods, 600 workers total.  
- **Cost**: scales linearly, ~$1.7k/month for 10k, ~$3.4k/month for 20k, ~$5.1k/month for 30k.

---
