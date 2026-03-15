FROM php:8.2-fpm

# Installer les extensions système requises
RUN apt-get update && apt-get install -y \
    libpng-dev libonig-dev libxml2-dev zip unzip git curl \
    && docker-php-ext-install pdo_mysql mbstring exif bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Dossier de travail
WORKDIR /var/www/html

# Copier les fichiers de dépendances en premier pour profiter du cache Docker
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts

# Copier le reste du code
COPY . .

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Render passe le port à l'application via la variable d'environnement PORT
ENV PORT=8000

# Démarrer l'application (le port est fourni par Render via $PORT)
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT}"]
