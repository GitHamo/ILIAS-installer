FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev \
    libldap2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libxslt-dev \
    libmagickwand-dev \
    libonig-dev \
    ffmpeg \
    unzip \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure and install GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install \
    curl \
    soap \
    ldap \
    pdo \
    pdo_mysql \
    mysqli \
    zip \
    gd \
    mbstring \
    xml \
    xsl \
    && a2enmod rewrite

# Install Composer v2
RUN curl -sS https://getcomposer.org/installer | php -- --2 \
    && mv composer.phar /usr/local/bin/composer

# Install Node.js 20 LTS (match ILIAS test server)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
    
# Install imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Copy application files
COPY src/ /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Prepare essential directories & permissions
RUN mkdir -p /var/www/files /var/www/logs \
    && chown -R www-data:www-data /var/www/html /var/www/files /var/www/logs \
    && chmod -R 777 /var/www/files /var/www/logs

# Set permissions for all files and directories to ensure security
RUN find /var/www/html -type d -exec chmod 755 {} \;
RUN find /var/www/html -type f -exec chmod 644 {} \;