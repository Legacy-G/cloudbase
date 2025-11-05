## ✅ Step-by-Step: Enable Required GCP APIs

You can enable these APIs using the **Google Cloud Console** or the **gcloud CLI**. Since you’re on Windows and just getting `gcloud` set up, I’ll show both methods.

---

### 🔹 Option A: Enable via Google Cloud Console (Recommended for Now)

1. Go to [GCP API Library](https://console.cloud.google.com/apis/library)
2. At the top, make sure your project is set to `cloudtrack-dbms`
3. Search and enable each of the following APIs:

| API Name             | Console Link |
|----------------------|--------------|
| Cloud Run API        | [Enable Cloud Run](https://console.cloud.google.com/apis/library/run.googleapis.com)  
| Artifact Registry API| [Enable Artifact Registry](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com)  
| Cloud SQL Admin API  | [Enable Cloud SQL](https://console.cloud.google.com/apis/library/sqladmin.googleapis.com)  
| Compute Engine API   | [Enable Compute Engine](https://console.cloud.google.com/apis/library/compute.googleapis.com)  
| Kubernetes Engine API| [Enable Kubernetes Engine](https://console.cloud.google.com/apis/library/container.googleapis.com)  

Click **“Enable”** on each page.

### 🔹 Option B: Enable via `gcloud` CLI (Once Installed)

Once your `gcloud` CLI is working, you can run:

```bash
gcloud config set project cloudtrack-dbms

gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```

## 🧠 Why This Matters

These APIs unlock the core services you’ll need:
- **Cloud Run** → Deploy your Odoo container with autoscaling
- **Artifact Registry** → Store and manage your Docker image
- **Cloud SQL** → Host your PostgreSQL database
- **Compute Engine** → Underlying infrastructure for VMs and networking
- **Kubernetes Engine** → Optional for advanced container orchestration

docker tag legacyg/dbms-itcloud-image:odoo18-futminna \
  us-central1-docker.pkg.dev/cloudtrack-dbms/dbms-repo/odoo18-futminna

docker push us-central1-docker.pkg.dev/cloudtrack-dbms/dbms-repo/odoo18-futminna
