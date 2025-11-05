FROM odoo:18.0
USER root
RUN apt-get update && apt-get install -y \
    geoip-bin \
    libgeoip1 \
    && rm -rf /var/lib/apt/lists/*

USER odoo
    
# Copy config and addons
COPY ./config/odoo.conf /etc/odoo/odoo.conf
COPY ./addons /mnt/extra-addons