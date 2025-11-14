#!/bin/bash
set -e

echo "Waiting for PostgreSQL to be ready..."
until pg_isready -U postgres; do
  sleep 2
done
echo "PostgreSQL is ready."

# Create role 'odoo' if it doesn't exist
echo "Creating role 'odoo' if missing..."
psql -U postgres <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'odoo') THEN
      CREATE ROLE odoo WITH LOGIN PASSWORD 'odoo' CREATEDB INHERIT;
   END IF;
END
\$\$;
EOF

# Create database 'it2025' if it doesn't exist
echo "Creating database 'it2025' if missing..."
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'it2025'" | grep -q 1 || \
  psql -U postgres -c "CREATE DATABASE it2025 OWNER odoo"

# Restore the dump
echo "Restoring dump into 'it2025'..."
pg_restore -U postgres -d it2025 /docker-entrypoint-initdb.d/it2025.dump || {
  echo "pg_restore failed!"
  exit 1
}

echo "Database restore complete."
