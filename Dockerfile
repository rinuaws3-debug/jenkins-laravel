# Stage 1: Build PHP dependencies
FROM composer:2 AS build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-progress --prefer-dist
COPY . .
RUN composer dump-autoload --optimize

# Stage 2: PHP-FPM + Nginx
FROM php:8.2-fpm-alpine AS app

# Install Nginx, Supervisor, and PHP extensions
RUN apk add --no-cache nginx supervisor bash \
    && docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/html

# Copy Laravel from build stage
COPY --from=build /app ./

# Copy Nginx config
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copy Supervisor config to run both php-fpm & nginx
COPY ./docker/supervisord.conf /etc/supervisord.conf

# Laravel storage/bootstrap/cache permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisord.conf"]

