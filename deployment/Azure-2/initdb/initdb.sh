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

echo "Database role created."