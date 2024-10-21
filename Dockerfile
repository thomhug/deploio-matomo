# Base image: PHP with Apache
FROM php:8.1-apache

# Install required PHP extensions and tools (including OpenSSL for generating certificates)
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    mariadb-client \
    openssl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql zip

# Generate SSL Certificates
RUN mkdir -p /etc/mysql/certs \
    && openssl genrsa 2048 > /etc/mysql/certs/ca-key.pem \
    && openssl req -new -x509 -nodes -days 365 -key /etc/mysql/certs/ca-key.pem -out /etc/mysql/certs/ca-cert.pem -subj "/C=US/ST=State/L=City/O=Company/OU=Org/CN=ca" \
    && openssl req -newkey rsa:2048 -days 365 -nodes -keyout /etc/mysql/certs/client-key.pem -out /etc/mysql/certs/client-req.pem -subj "/C=US/ST=State/L=City/O=Company/OU=Org/CN=client" \
    && openssl rsa -in /etc/mysql/certs/client-key.pem -out /etc/mysql/certs/client-key.pem \
    && openssl x509 -req -in /etc/mysql/certs/client-req.pem -days 365 -CA /etc/mysql/certs/ca-cert.pem -CAkey /etc/mysql/certs/ca-key.pem -set_serial 01 -out /etc/mysql/certs/client-cert.pem \
    && chmod 600 /etc/mysql/certs/client-key.pem /etc/mysql/certs/client-cert.pem /etc/mysql/certs/ca-cert.pem

# Download and extract Matomo
RUN curl -o matomo.tar.gz -SL https://builds.matomo.org/matomo-latest.tar.gz \
    && tar -xzf matomo.tar.gz -C /var/www/html --strip-components=1 \
    && rm matomo.tar.gz \
    && chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Set environment variables for database configuration
ENV MATOMO_DATABASE_HOST=localhost
ENV MATOMO_DATABASE_USERNAME=matomo
ENV MATOMO_DATABASE_PASSWORD=secret
ENV MATOMO_DATABASE_DBNAME=matomo_db
ENV MATOMO_DATABASE_PORT=3306
ENV MATOMO_SSL_KEY=/etc/mysql/certs/client-key.pem
ENV MATOMO_SSL_CERT=/etc/mysql/certs/client-cert.pem
ENV MATOMO_SSL_CA=/etc/mysql/certs/ca-cert.pem

# Generate a random salt for Matomo
RUN MATOMO_SALT=$(openssl rand -hex 32) \
    && echo "[database]\n\
host = \"${MATOMO_DATABASE_HOST}\"\n\
username = \"${MATOMO_DATABASE_USERNAME}\"\n\
password = \"${MATOMO_DATABASE_PASSWORD}\"\n\
dbname = \"${MATOMO_DATABASE_DBNAME}\"\n\
port = \"${MATOMO_DATABASE_PORT}\"\n\
tables_prefix = \"matomo_\"\n\
ssl_key = \"${MATOMO_SSL_KEY}\"\n\
ssl_cert = \"${MATOMO_SSL_CERT}\"\n\
ssl_ca = \"${MATOMO_SSL_CA}\"\n\
\n\
[General]\n\
salt = \"${MATOMO_SALT}\"" \
> /var/www/html/config/config.ini.php

# Start Apache server
CMD ["apache2-foreground"]
