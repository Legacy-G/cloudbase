#!/bin/bash
psql -U postgres <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'odoo') THEN
      CREATE ROLE odoo WITH LOGIN PASSWORD 'odoo' CREATEDB INHERIT;
   END IF;
END
\$\$;
EOF
