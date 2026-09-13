FROM php:8.4-apache-bookworm
ARG LOCAL_UID=1000
ARG LOCAL_GID=1000
RUN apt-get update && apt-get install -y --no-install-recommends     git unzip curl libpq-dev libicu-dev libzip-dev libonig-dev libsqlite3-dev     && docker-php-ext-install pdo_pgsql pdo_sqlite mbstring intl zip bcmath pcntl opcache     && a2enmod rewrite     && groupmod -o -g "$LOCAL_GID" www-data     && usermod -o -u "$LOCAL_UID" -g "$LOCAL_GID" www-data     && mkdir -p /var/www/.composer     && chown -R www-data:www-data /var/www     && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/php/development.ini /usr/local/etc/php/conf.d/development.ini
WORKDIR /var/www/html
