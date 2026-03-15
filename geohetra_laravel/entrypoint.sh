#!/bin/sh
# Attendre que la base de données soit disponible
echo "⏳ Waiting for database..."
until php artisan migrate:status > /dev/null 2>&1; do
  sleep 2
done

# Lancer les migrations Laravel
echo "🚀 Running migrations..."
php artisan migrate --force

# Démarrer le serveur Laravel
echo "🌐 Starting Laravel server..."
php artisan serve --host=0.0.0.0 --port=${PORT}