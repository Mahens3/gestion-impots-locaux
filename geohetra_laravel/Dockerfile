FROM php:8.2-cli

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev \
    && docker-php-ext-install pdo_mysql gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --prefer-dist

# On utilise la variable $PORT fournie par Railway
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
