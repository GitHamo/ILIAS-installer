FROM php:8.0-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    gnupg \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libfreetype6-dev \
    libxml2-dev \
    libonig-dev \
    libzip-dev \
    libicu-dev \
    libcurl4-openssl-dev \
    libldap2-dev \
    libxslt1-dev \
    imagemagick \
    ghostscript \
    wkhtmltopdf \
    ffmpeg \
    mimetex \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP core and optional extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
       pdo \
       pdo_mysql \
       gd \
       xml \
       xsl \
       mysqli \
       mbstring \
       intl \
       zip \
       curl \
       soap \
       ldap \
    && a2enmod rewrite

# Install Composer v2
RUN curl -sS https://getcomposer.org/installer | php -- --2 \
    && mv composer.phar /usr/local/bin/composer

# Install Node.js 16 LTS (match ILIAS test server)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Copy application files
COPY src/ /var/www/html/