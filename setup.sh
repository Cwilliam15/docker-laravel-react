#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [ ! -f .env ]; then cp .env.example .env; fi
export LOCAL_UID="$(id -u)" LOCAL_GID="$(id -g)"
docker compose config --quiet
docker compose build app
docker compose run --rm --no-deps --user www-data app bash /opt/scripts/init.sh
docker compose run --rm --no-deps node sh -c 'if [ -f package-lock.json ]; then npm ci; else npm install; fi'
docker compose run --rm --no-deps node npm run build
docker compose up -d --wait db
docker compose run --rm --no-deps --user www-data app php artisan migrate --force
docker compose up -d --wait app
docker compose up -d node
echo 'Entorno iniciado. Consulta APP_PORT en .env (por defecto http://localhost:8080).'
