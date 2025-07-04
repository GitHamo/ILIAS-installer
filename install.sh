#!/bin/bash

PROJECT_NAME=$1
WEB_PORT=$2
DB_PORT=$3

if [ -z "$PROJECT_NAME" ]; then
  echo "Error: Missing required project name as first argument."
  echo "Usage: ./install.sh <project_name>"
  exit 1
fi

WEB_PORT=${WEB_PORT:-80}
DB_PORT=${DB_PORT:-3306}

if echo "$PROJECT_NAME" | grep -q ' '; then
  echo "Error: Project name must not contain spaces. Got: '$1'"
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: 'docker' command not found. Please install Docker."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Error: 'docker compose' (Docker Compose v2) not found. Please install Docker Compose."
  exit 1
fi

echo "Building project: $PROJECT_NAME"
echo "Web Port: $WEB_PORT"
echo "DB Port: $DB_PORT"

cat > .env <<EOF
COMPOSE_PROJECT_NAME=$PROJECT_NAME
WEB_PORT=$WEB_PORT
DB_PORT=$DB_PORT
EOF

docker compose down
docker compose --env-file .env -p "$PROJECT_NAME" build
docker compose --env-file .env -p "$PROJECT_NAME" up -d

container_id=$(docker ps -q -f name=${PROJECT_NAME}-web)

docker exec $container_id composer install --no-dev --classmap-authoritative

if ! docker exec $container_id php setup/cli.php build-artifacts --yes; then
  echo "Artifact build failed."
  exit 1
fi

if ! docker exec $container_id php setup/setup.php install --yes /var/www/configs.json; then
  echo "Setup script failed."
  exit 1
fi

echo "Installation complete! Run ILIAS at http://localhost:${WEB_PORT}"