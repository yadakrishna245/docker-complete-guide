# PHP Laravel Production Dockerfile
# With PHP-FPM, OPcache, and Nginx

# Stage 1: Composer dependencies
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist
COPY . .
RUN composer dump-autoload --optimize

# Stage 2: Frontend build
FROM node:20-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Production
FROM php:8.3-fpm-alpine
RUN apk add --no-cache nginx supervisor && \
    docker-php-ext-install pdo_mysql opcache
COPY docker/php.ini /usr/local/etc/php/conf.d/app.ini
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf
WORKDIR /var/www/html
COPY --from=vendor /app .
COPY --from=frontend /app/public/build public/build
RUN chown -R www-data:www-data storage bootstrap/cache
USER www-data
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost/health || exit 1
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
