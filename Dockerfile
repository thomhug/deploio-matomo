# Base image: PHP with Apache
FROM php:8.1-apache

# Install required PHP extensions
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

# Generate a random salt using openssl
RUN MATOMO_SALT=$(openssl rand -hex 32) \
    && echo "[database]\n\
host = \"${MATOMO_DATABASE_HOST}\"\n\
username = \"${MATOMO_DATABASE_USERNAME}\"\n\
password = \"${MATOMO_DATABASE_PASSWORD}\"\n\
dbname = \"${MATOMO_DATABASE_DBNAME}\"\n\
port = \"${MATOMO_DATABASE_PORT}\"\n\
tables_prefix = \"matomo_\"\n\
\n\
[General]\n\
salt = \"${MATOMO_SALT}\"" \
> /var/www/html/config/config.ini.php

# Start Apache server
CMD ["apache2-foreground"]
