# Get AKS credentials for kubectl access in the current shell session
az aks get-credentials \
  --resource-group cloudtrackit2025 \
  --name cloudtrack

# Get Nodes
kubectl get nodes

# Get Pods
kubectl get pods --all-namespaces

# Connect to the Azure Database for PostgreSQL using psql
export PGHOST=cloudtrack-db.postgres.database.azure.com
export PGUSER=postgres export PGPORT=5432
export PGDATABASE=postgres
export PGPASSWORD="Cloudtrack2025!"
psql

# Alternatively, connect in a single command
PGUSER="odoo" PGPASSWORD="Cloudtrack2025!" PGHOST="cloudt rack-db.postgres.database.azure.com" PGPORT=5432 PGDATABASE=postgres p sql "sslmode=require" psql

# To Apply Changes (Create Configurations)
kubectl apply -f dbms-aks.yaml
# or
kubectl apply -f dbms-postgres.yaml
# or
kubectl apply -f manifest.yaml
# or
kubectl apply -f deployment-manifest.yaml

# List all resources in the 'odoo-prod' namespace
kubectl -n odoo-prod get all

# Check logs of the PostgreSQL pod and the wait-for-postgres init container
kubectl -n odoo-prod logs -f pod/db-856ffbd5df-fv6gr
kubectl -n odoo-prod logs -f pod/odoo-54f6dfcd87-rxlst -c wait-for-postgres

# INITDB SCRIPTS CONFIGMAP CREATION AND USAGE

# LOCAL PREPARATION OF INITDB SCRIPT
# After creating initdb.sh file localll.........
# Convert the script locally to Unix format On your machine (before uploading to Cloud Shell):
dos2unix initdb.sh
chmod +x initdb.sh

# UPLOAD AND CREATE CONFIGMAP IN AZURE CLOUD SHELL
# Open Azure Cloud Shell in your browser.
# After that, upload the initdb.sh file to Azure Cloud Shell using the upload button in the Cloud Shell interface.

# Then Create initdb-scripts ConfigMap
kubectl -n odoo-prod create configmap initdb-scripts \
  --from-file=initdb.sh=initdb.sh

# Once done, Describe the initdb-scripts ConfigMap to verify its creation:
kubectl -n odoo-prod describe configmap initdb-scripts

# Restart the PostgreSQL pod to apply the initdb scripts
kubectl -n odoo-prod delete pod -l app=db

# Wait for the PostgreSQL pod to be Running again, then check roles and database
kubectl -n odoo-prod exec -it deploy/db -- psql -U postgres -c "\du"

# Delete initdb-scripts ConfigMap if needed or found something wrong with it
kubectl -n odoo-prod delete configmap initdb-scripts

# CHECKING THE DEPLOYMENT AND LOGS

# List all resources in the 'odoo-prod' namespace again
kubectl -n odoo-prod get all
# if not running, wait a bit and recheck or debug

# if yes, Confirm the odoo role exists in Postgres Exec into the Postgres pod:
kubectl -n odoo-prod exec -it deploy/db -- psql -U postgres

# Restart the Odoo deployment to apply any changes
kubectl -n odoo-prod rollout restart deploy/odoo
# All pods in the deployment will be restarted
kubectl -n odoo-prod rollout restart deployment


# Check the status of the Odoo deployment
kubectl -n odoo-prod rollout status deploy/odoo

# Logs from Postgres
kubectl -n odoo-prod logs deploy/db

# Logs from Odoo
kubectl -n odoo-prod logs deploy/odoo

# VERIFYING THE IMAGE BAKED SETUP
# Exec into the Odoo pod to check the odoo.conf file for admin_passwd
kubectl -n odoo-prod exec -it deploy/odoo -- cat /etc/odoo/odoo.conf | grep admin_passwd
# It should show: admin_passwd = adm

# Check port forwarding to access Odoo web interface locally
kubectl -n odoo-prod port-forward deploy/odoo 8069:8069
# Now access Odoo at http://localhost:8069 in your web browser

# Aceess Odoo Web Interface
http://4.253.40.132:8069/web/database/manager
http://4.253.40.132:8069

# TO DELETE OLD RESOURCES

# Delete PVC
kubectl delete pvc postgres-pvc -n odoo-prod

# To Delete All Pods in the Namespace
kubectl delete namespace odoo-prod

kubectl delete pods --all -n odoo-prod

# To Delete All services in the Namespace
kubectl delete svc --all -n odoo-prod

# To Delete All replicaset in the Namespace
kubectl delete rs --all -n odoo-prod
# To Delete All deployments in the Namespace
kubectl delete deploy --all -n odoo-prod

# before applying a new manifest... delete the below resources if exists
kubectl delete pvc postgres-pvc -n odoo-prod
kubectl -n odoo-prod delete configmap initdb-scripts
kubectl delete svc --all -n odoo-prod
kubectl delete rs --all -n odoo-prod
kubectl delete deploy --all -n odoo-prod

# To Delete Resources
kubectl delete -f dbms-aks.yaml
kubectl delete -f dbms-postgres.yaml

# Delete the old PostgreSQL deployment
kubectl -n odoo-prod delete deployment postgres
# Delete the old PostgreSQL service
kubectl -n odoo-prod delete service postgres-svc

# Delete the old Odoo deployment
kubectl -n odoo-prod delete deployment odoo
# Delete the old Odoo service
kubectl -n odoo-prod delete service odoo-svc

# hased admin password for odoo.conf: admin_passwd = admin
kk6j-4ffd-az87
qaey-vgwe-ax5w 


# 
k6 run login-test.js

#
$env:K6_PROMETHEUS_RW_SERVER_URL="http://prometheus-server.monitoring.svc.cluster.local:80/api/v1/write"
k6 run .\odoo-login-test.js

#
http://4.253.12.150:3000/d/7f02cc8e-dc66-46ab-b573-a753857be97c/kubernetes-cluster-monitoring-via-prometheus?orgId=1&from=2025-11-12T09:04:34.798Z&to=2025-11-12T09:14:34.798Z&timezone=browser&var-Node=$__all&refresh=10s&var-query0=&var-namespace=&editPanel=46