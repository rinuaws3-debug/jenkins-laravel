# Stage 1: Build PHP dependencies
FROM composer:2 AS build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-progress --prefer-dist
COPY . .
RUN composer dump-autoload --optimize

# Stage 2: Run PHP + Nginx
FROM php:8.2-fpm-alpine AS app

# Install system deps, extensions
RUN docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/html

# Copy Laravel from build stage
COPY --from=build /app ./

# Copy Nginx config
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf

# Permissions for Laravel storage/bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Use supervisor or run php-fpm + nginx together (simplest: use docker-compose or separate containers)

