#!/bin/sh

echo "Configuration Laravel..."

php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Migration base de données..."

php artisan migrate --force

echo "Démarrage serveur Laravel..."

php artisan serve --host=0.0.0.0 --port=8000