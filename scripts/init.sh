#!/usr/bin/env bash
set -euo pipefail
cd /var/www/html
if [ ! -f artisan ]; then
  if [ -n "$(find . -mindepth 1 -maxdepth 1 ! -name .gitkeep -print -quit)" ]; then
    echo 'www no esta vacia. No se sobrescribira su contenido.' >&2
    exit 1
  fi
  temp_dir=$(mktemp -d)
  trap 'rm -rf "$temp_dir"' EXIT
  composer create-project laravel/laravel "$temp_dir/app" '^13.0' --no-interaction --no-scripts
  cp -R "$temp_dir/app/." .
  cp -R /opt/scaffold/. .
  rm -f .gitkeep
fi
composer install --no-interaction
if [ ! -f .env ]; then
  cp .env.example .env
fi
php /opt/scripts/configure-env.php
php artisan optimize:clear
if ! grep -Eq '^APP_KEY=.+$' .env; then
  php artisan key:generate
fi
mkdir -p storage/framework/{cache/data,sessions,views} storage/logs bootstrap/cache
