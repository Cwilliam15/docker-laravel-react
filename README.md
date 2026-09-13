# Docker Laravel + React + Tailwind + PostgreSQL

Plantilla de desarrollo inspirada en la organización de [jersonmartinez/docker-lamp](https://github.com/jersonmartinez/docker-lamp). Configuración nueva: conserva Apache y `www/`, incorpora PostgreSQL y Node/Vite. No incluye código copiado del repositorio original.

## Componentes

| Servicio | Base | Propósito |
|---|---|---|
| app | PHP 8.4 + Apache + Composer 2 | Laravel 13 y servidor HTTP |
| node | Node.js 22 | React 19, Vite 7 y Tailwind CSS 4 |
| db | PostgreSQL 16 | Datos persistentes |
| pgadmin | pgAdmin 4, rama 9 | Administración opcional |

React se monta en una vista Blade y se compila con Vite. Laravel sirve las rutas del backend. No incluye autenticación, Inertia ni una API separada: es una base mínima para incorporar los módulos que necesite cada proyecto. El contador inicial permite verificar React y los estilos permiten comprobar Tailwind.

Las versiones mayores están acotadas. Al instalar se resuelven versiones menores/parches y se generan `www/composer.lock` y `www/package-lock.json`. Ambos deben versionarse en el repositorio de cada proyecto. Las imágenes usan etiquetas de rama, no digests inmutables.

## Requisitos

- Docker Engine/Docker Desktop con contenedores Linux y Docker Compose v2 actualizado (soporte de `up --wait`).
- Internet para descargar imágenes y dependencias.
- Git para publicar y reutilizar el repositorio.
- No hace falta instalar PHP, Composer, Node ni PostgreSQL directamente en tu PC.

En Windows utiliza Docker Desktop con WSL2. Puedes ejecutar el script PowerShell desde Windows; para mayor rendimiento, también puedes mantener el proyecto dentro del sistema de archivos de WSL y usar `setup.sh`.

## Primer inicio en Windows

Descomprime el archivo y abre PowerShell dentro de `docker-laravel-react`:

```powershell
Copy-Item .env.example .env
notepad .env
.\setup.ps1
```

Configura `COMPOSE_PROJECT_NAME` con un nombre único y cambia las contraseñas de ejemplo antes de iniciar. Si ya existe `.env`, no lo reemplaces. Si Windows bloquea scripts por una política corporativa, usa los comandos individuales de `setup.ps1` en la terminal o consulta al administrador; no es necesario cambiar la política global.

El script construye PHP, descarga Laravel en `www`, agrega React/Tailwind, instala dependencias, compila el frontend, inicia PostgreSQL, ejecuta las migraciones y arranca Apache/Vite. La primera descarga puede tardar varios minutos. Si un paso falla, se detiene y muestra el error.

Abre http://localhost:8080 (o el `APP_PORT` elegido). Mantén `localhost` como nombre de acceso para coincidir con Vite/HMR.

## Primer inicio en Linux / WSL / macOS

```bash
cp .env.example .env
# Edita .env: nombre del proyecto, contraseñas y puertos.
# En Linux/WSL coloca también los valores de id -u e id -g
# en LOCAL_UID y LOCAL_GID para que coincidan con tu usuario.
bash setup.sh
```

El script exporta el UID/GID del usuario durante su ejecución. Conserva los mismos valores en `.env` para comandos posteriores. En Docker Desktop para macOS puedes usar los valores de tu usuario; Docker gestiona la traducción de permisos del montaje.

## Estructura

| Ruta | Contenido |
|---|---|
| `compose.yaml` | Servicios, puertos, volúmenes y comprobaciones de salud |
| `docker/php/` | Imagen PHP y configuración de desarrollo |
| `docker/apache/` | VirtualHost apuntando a `www/public` |
| `scripts/` | Instalación inicial y configuración de Laravel |
| `scaffold/` | Archivos de React/Tailwind copiados solo al crear Laravel |
| `www/` | Proyecto Laravel real, creado durante el primer inicio |
| `dump/` | Lugar para respaldos locales; excluidos de Git |
| `.env` | Configuración privada de Docker Compose |
| `www/.env` | Configuración privada de Laravel |

Después del primer inicio edita `www`, no `scaffold`. El instalador rechaza una carpeta `www` con contenido ajeno y nunca vuelve a copiar el scaffold sobre un proyecto Laravel existente. Si una descarga inicial se interrumpe dejando un proyecto incompleto, conserva cualquier trabajo y revisa el error antes de limpiar manualmente esa carpeta.

## Comprobación inicial

```powershell
docker compose ps
docker compose exec app php artisan migrate:status
docker compose exec app php artisan db:show
docker compose run --rm --no-deps node npm run build
docker compose logs --tail 50 app node db
```

Verifica que `app` y `db` estén `healthy`, que las migraciones estén aplicadas y que `db:show` indique PostgreSQL. En el navegador, pulsa el contador y edita un texto en `www/resources/js/app.jsx`: debería reflejarse sin reiniciar Docker. Estas comprobaciones cubren backend, conexión a base de datos, React, Tailwind y Vite.

Validación: se revisaron estáticamente YAML, JSON, Bash y la configuración de Vite. El usuario verificó el arranque en Windows con Docker: app y db saludables, pantalla React con contador y estilos, tres migraciones aplicadas y conexión de Laravel a PostgreSQL 16.15 con nueve tablas. La actualización automática de Vite aún no se ha confirmado. El script incluye la corrección de copia con cp -R para montajes de Windows.

## Trabajo diario

```powershell
docker compose up -d
docker compose logs -f app node
docker compose exec --user www-data app php artisan make:model Producto -m
docker compose exec --user www-data app php artisan migrate
docker compose exec --user www-data app composer require vendor/paquete
docker compose run --rm --no-deps node npm install nombre-paquete
docker compose stop
```

Sustituye los nombres de paquetes de ejemplo por paquetes reales. Para reiniciar desde cero los contenedores conservando datos:

```powershell
docker compose down
docker compose up -d
```

`down` conserva los volúmenes. **`down -v` elimina los volúmenes y los datos de PostgreSQL/pgAdmin**. No lo uses para resolver un error de arranque sin respaldar los datos.

No ejecutes `npm` desde Windows sobre los mismos `node_modules` que usa el contenedor Linux; mantén la instalación dentro de Docker.

## pgAdmin opcional

```powershell
docker compose --profile tools up -d pgadmin
```

Abre http://localhost:5050 e ingresa con los valores `PGADMIN_DEFAULT_EMAIL` y `PGADMIN_DEFAULT_PASSWORD` de `.env`.

Registra un servidor con:

| Campo | Valor |
|---|---|
| Name | Nombre libre, por ejemplo Laravel local |
| Host | `db` |
| Port | `5432` |
| Maintenance database | Valor de `POSTGRES_DB` |
| Username | Valor de `POSTGRES_USER` |
| Password | Valor de `POSTGRES_PASSWORD` |

Desde una herramienta instalada en tu PC, el host es `localhost` y el puerto predeterminado es `5433`. Desde Laravel y pgAdmin se utiliza `db:5432`.

## Reutilizar para otros proyectos

La plantilla publicada debe conservar `www/.gitkeep` y no incluir una aplicación de negocio. Crea una copia de la plantilla para cada proyecto antes de ejecutar el instalador. Cada copia tendrá su código, `.env`, red y volúmenes.

Para ejecutar dos proyectos a la vez:

| Variable | Proyecto A | Proyecto B |
|---|---|---|
| COMPOSE_PROJECT_NAME | proyecto_a | proyecto_b |
| APP_PORT | 8080 | 8081 |
| VITE_PORT | 5173 | 5174 |
| DB_PORT | 5433 | 5434 |
| PGADMIN_PORT | 5050 | 5051 |

No uses el mismo `COMPOSE_PROJECT_NAME` para dos copias: compartirían el mismo ámbito de recursos. Las bases pueden tener el mismo nombre interno porque cada proyecto usa un volumen independiente. Usa nombres con letras minúsculas, números y guiones.

Si cambias puertos, vuelve a ejecutar el script para sincronizar `www/.env`. No uses cache de configuración en desarrollo. Cambiar `POSTGRES_PASSWORD`, `POSTGRES_USER` o `POSTGRES_DB` después de inicializar un volumen no modifica las credenciales/datos existentes: PostgreSQL usa esas variables en la primera inicialización. Para cambios posteriores realiza una modificación explícita en PostgreSQL y actualiza `.env`.

## Publicar la plantilla en GitHub

Publica la copia limpia de este ZIP, antes de generar una aplicación dentro de `www`. Crea un repositorio vacío llamado, por ejemplo, `docker-laravel-react`. No agregues README remoto al crearlo.

```powershell
git init
git add .
git status
# Revisa que no haya .env, credenciales, respaldos o dependencias.
git commit -m "Add Laravel React PostgreSQL development environment"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/docker-laravel-react.git
git push -u origin main
```

Reemplaza `TU_USUARIO`. Si ya existe un remoto, revisa `git remote -v` antes de cambiarlo. No se necesita forzar ningún push.

En GitHub puedes activar **Settings → General → Template repository**. Para proyectos futuros usa **Use this template**, clona el nuevo repositorio, configura `.env` y ejecuta el instalador. En el repositorio del proyecto sí debes guardar el código generado dentro de `www`, incluyendo los archivos lock y `.env.example`, pero nunca los `.env` reales.

## Alcance y resolución de problemas

- Es un entorno local de desarrollo; no es una receta de producción. Publica puertos solo en `127.0.0.1` y usa depuración local.
- El usuario de PostgreSQL creado por la imagen tiene privilegios administrativos; para producción deben diseñarse usuarios y permisos separados.
- Las colas se ejecutan sincrónicamente y sesiones/cache usan archivos. Agrega workers, scheduler o Redis cuando un proyecto lo requiera.
- Para actualizar PHP o extensiones, cambia el Dockerfile y ejecuta `docker compose build app` seguido de `docker compose up -d app`.
- Si Vite no refleja cambios en Docker Desktop, deja `VITE_USE_POLLING=true`; en Linux puedes ponerlo en `false` para reducir trabajo del sistema de archivos.
- Si ves un error de puerto ocupado, cambia el puerto correspondiente en `.env` y repite el script.
- Un estado `node` iniciado no garantiza que Vite ya esté listo: consulta sus logs.
- Si detienes Vite para comprobar la compilación estática, elimina `www/public/hot` (archivo temporal) después de detener `node`. Laravel entonces utilizará `public/build/manifest.json`.
- Para desplegar en un servidor sin Docker, el código está en `www`, pero deberás instalar versiones/extensiones compatibles, dependencias, configurar variables, servidor web, permisos y migraciones.

Referencias: [Laravel 13](https://laravel.com/docs/13.x/releases), [Vite](https://vite.dev/guide/), [Tailwind con Vite](https://tailwindcss.com/docs/installation/using-vite).
