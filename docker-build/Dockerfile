# Base Odoo 18 image
FROM odoo:18.0

# Switch to root for package installs and file ownership changes
USER root

# Install GeoIP databases (optional, per your config)
RUN apt-get update && apt-get install -y \
    geoip-bin \
    geoip-database \
    && rm -rf /var/lib/apt/lists/*

# Create target directories (in case they don't exist)
RUN mkdir -p /etc/odoo \
    && mkdir -p /mnt/extra-addons

# Copy config and addons from build context
# Make sure ./config/odoo.conf and ./addons/ exist in the build context
COPY ./config/odoo.conf /etc/odoo/odoo.conf
COPY ./addons /mnt/extra-addons

# Ensure correct permissions for Odoo runtime user
RUN chown -R odoo:odoo /etc/odoo /mnt/extra-addons

# Switch back to the Odoo user
USER odoo

