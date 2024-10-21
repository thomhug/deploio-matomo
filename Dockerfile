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

# Copy the entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint to the shell script
ENTRYPOINT ["/entrypoint.sh"]
