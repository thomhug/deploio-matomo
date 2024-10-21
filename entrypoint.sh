#!/bin/bash

# Generate a random salt for Matomo
MATOMO_SALT=$(openssl rand -hex 32)

# Create the config.ini.php file using environment variables
cat << EOF > /var/www/html/config/config.ini.php
[database]
host = "${MATOMO_DATABASE_HOST}"
username = "${MATOMO_DATABASE_USERNAME}"
password = "${MATOMO_DATABASE_PASSWORD}"
dbname = "${MATOMO_DATABASE_DBNAME}"
port = "${MATOMO_DATABASE_PORT}"
tables_prefix = "matomo_"
ssl_key = "/etc/mysql/certs/client-key.pem"
ssl_cert = "/etc/mysql/certs/client-cert.pem"
ssl_ca = "/etc/mysql/certs/ca-cert.pem"

[General]
salt = "${MATOMO_SALT}"

EOF

# Run Apache in the foreground
apache2-foreground
