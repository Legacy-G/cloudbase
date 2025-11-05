# 🛠️ Odoo 18 Docker Build — FUTMinna Stack

This folder documents the full process of building, configuring, and testing a custom Odoo 18 Docker image for FUTMinna, including:

- PostgreSQL 17.5 with automated database restore
- Odoo 18 with custom modules and configuration
- Docker Compose setup for local development
- Final image build and push to Docker Hub

---

## 📁 Folder Structure

```bash
docker-build/
├── addons/              # All custom and OpenEduCat modules
├── config/              # Odoo configuration file
├── data/                # PostgreSQL volume (auto-created)
├── initdb/              # Database restore script and dump
│   ├── setup.sh
│   └── it2025.dump
├── bdej-mcym-bssm.txt   # Master password for Odoo DB creation
├── Dockerfile           # Odoo image build instructions
└── docker-compose.yaml  # Local stack configuration
```

---

## 🚀 Step-by-Step Build Process

### 1. Clone the Repository

```bash
git clone https://github.com/Legacy-G/Cloud-Track-IT-2025-Database-Management-System.git
cd Cloud-Track-IT-2025-Database-Management-System/docker-build
```

---

### 2. Prepared Your Addons

I Created and Placed all custom modules inside `addons/`. This includes:

```bash
addons/
├── futminna/
├── openeducat_core/
├── openeducat_exam/
├── theme_web_openeducat/
└── ... (other OpenEduCat modules)
```

> ✅ These will be copied into the image and mounted at `/mnt/extra-addons`.

---

### 3. Configure Odoo

I Created and Edited my `config/odoo.conf` with the following key settings:

```ini
[options]
addons_path = /mnt/extra-addons
admin_passwd = $pbkdf2-sha512$600000$S4kxhrB2rlXqXYtRCkEoBQ$czp/3OMssJsLjxYSprTFC9AC0K2BAlR1XRDcRNNWYpHUc7v4U4VSQNJM13JD6Wk4Qs2GooM0OLZ99SM7YeE8iA
db_host = db
db_port = 5432
db_user = odoo
db_password = odoo
list_db = True
log_level = info
http_port = 8069
gevent_port = 8072
server_wide_modules = base,web
workers = 2
csv_internal_sep = ,
data_dir = /var/lib/odoo/sessions
geoip_city_db = /usr/share/geoip/GeoLite2-City.mmdb
geoip_country_db = /usr/share/geoip/GeoLite2-Country.mmdb
screenshots = /tmp/odoo_tests
```

> ✅ This config will be copied into the image and used at runtime.

---

### 4. Automate PostgreSQL Restore

Inside `initdb/`, I include:

- `setup.sh`: creates role, database, and restores `it2025.dump`
- `it2025.dump`: my preloaded database with dummy student/faculty data

Make sure `setup.sh` is executable:

```bash
chmod +x initdb/setup.sh
```

---

### 5. Define Your Docker Compose Stack

Your `docker-compose.yaml` should look like:

```yaml
version: '3.8'

services:
  db:
    image: postgres:17.5
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
      - ./initdb:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"

  odoo:
    build: .
    restart: always
    depends_on:
      - db
    ports:
      - "8069:8069"
      - "8072:8072"
    volumes:
      - ./addons:/mnt/extra-addons
      - ./config/odoo.conf:/etc/odoo/odoo.conf
    environment:
      - HOST=db
      - USER=odoo
      - PASSWORD=odoo
```

---

### 6. Run and Test Locally

Build the stack Using:

```bash
docker-compose build --no-cache
```

Start the stack Using:

```bash
docker-compose up -d
```

Stop the stack Using:

```bash
docker-compose down -v
rm -rf ./data/postgres
```

Watch logs:

```bash
docker logs <db_container_name>
```

Visit [http://localhost:8069](http://localhost:8069)  
Select database: `it2025`  
Login: `admin`
Password: `admin`

---

### 7. Build the Final Image

Once I ensured everything works locally, I build the image Using:

```bash
docker build --no-cache -t legacyg/dbms-itcloud-image:odoo18-futminna .
```

---

### 8. Push to Docker Hub

```bash
docker push legacyg/dbms-itcloud-image:odoo18-futminna
```

> ✅ This image now contains My addons, config, and is ready for deployment.

---

## 🧼 .gitignore Recommendation

Create a `.gitignore` file to exclude runtime folders:

```gitignore
data/postgres/
__pycache__/
*.pyc
.env
```

---

## 📬 Contact

For questions or support, reach out to Gbure or open an issue in this repo.

