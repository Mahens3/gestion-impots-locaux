#!/bin/sh

echo "⏳ Waiting for database..."

until php artisan migrate:status > /dev/null 2>&1
do
  sleep 3
done

echo "🚀 Running migrations..."
php artisan migrate --force

echo "⚡ Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "🌐 Starting services..."

php-fpm -D
nginx -g "daemon off;"