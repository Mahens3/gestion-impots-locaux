#!/bin/sh
# Attendre que la base de données soit disponible
echo "⏳ Waiting for database..."
until php artisan migrate:status > /dev/null 2>&1; do
  sleep 2
done

# Lancer les migrations Laravel
echo "🚀 Running migrations..."
php artisan migrate --force

# Démarrer le serveur Laravel sur le port fixe 8000
echo "🌐 Starting Laravel server on port 8000..."
php artisan serve --host=0.0.0.0 --port=8000