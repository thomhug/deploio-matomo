#!/bin/bash

# Generate a random salt for Matomo
MATOMO_SALT=$(openssl rand -hex 32)

MATOMO_ENABLE_DATABASE_SSL=yes
MATOMO_DATABASE_SSL_CA_FILE="${MATOMO_SSL_CA}"

# Create the config.ini.php file using environment variables
cat << EOF > /var/www/html/config/config.ini.php
[database]
host = "${MATOMO_DATABASE_HOST}"
username = "${MATOMO_DATABASE_USERNAME}"
password = "${MATOMO_DATABASE_PASSWORD}"
dbname = "${MATOMO_DATABASE_DBNAME}"
port = "${MATOMO_DATABASE_PORT}"
tables_prefix = "matomo_"
ssl_key = "${MATOMO_SSL_KEY}"
ssl_cert = "${MATOMO_SSL_CERT}"
ssl_ca = "${MATOMO_SSL_CA}"

[General]
salt = "${MATOMO_SALT}"

EOF

# Run Apache in the foreground
apache2-foreground