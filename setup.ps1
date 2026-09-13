$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
function Invoke-Docker {
    & docker @args
    if ($LASTEXITCODE -ne 0) { throw "Docker fallo con codigo $LASTEXITCODE. Revisa el mensaje anterior." }
}
if (!(Test-Path .env)) { Copy-Item .env.example .env }
Invoke-Docker compose config --quiet
Invoke-Docker compose build app
Invoke-Docker compose run --rm --no-deps --user www-data app bash /opt/scripts/init.sh
Invoke-Docker compose run --rm --no-deps node sh -c 'if [ -f package-lock.json ]; then npm ci; else npm install; fi'
Invoke-Docker compose run --rm --no-deps node npm run build
Invoke-Docker compose up -d --wait db
Invoke-Docker compose run --rm --no-deps --user www-data app php artisan migrate --force
Invoke-Docker compose up -d --wait app
Invoke-Docker compose up -d node
Write-Host 'Entorno iniciado. Consulta APP_PORT en .env (por defecto http://localhost:8080).'
