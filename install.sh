#!/bin/bash

PROJECT_NAME=$1
BRANCH_NAME=$2
WEB_PORT=$3
DB_PORT=$4

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

if [ -z "$PROJECT_NAME" ]; then
  echo "Error: Missing required project name as first argument."
  echo "Usage: ./install.sh <project_name> <branch_name> [web_port] [db_port]"
  exit 1
fi

if [ -z "$BRANCH_NAME" ]; then
  echo "Error: Missing required branch name as second argument."
  echo "Usage: ./install.sh <project_name> <branch_name> [web_port] [db_port]"
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

if ! getent group www-data >/dev/null 2>&1; then
    echo "Group 'www-data' not found. Please create it."
    exit 1
fi

if ! id -u www-data >/dev/null 2>&1; then
    echo "User 'www-data' not found. Please create it."
    exit 1
fi

if ! ./clone.sh "$BRANCH_NAME"; then
  echo "Error: Failed to clone the ILIAS repository."
  exit 1
fi

if [ -d "versions/shared" ]; then
    echo "Copying shared files..."
    cp -rf versions/shared/* .
fi

if [ -d "versions/$BRANCH_NAME" ]; then
    echo "Copying branch-specific files for $BRANCH_NAME..."
    cp -rf "versions/$BRANCH_NAME/"* .
fi

echo "Preparing 'files' and 'logs' directories..."
for dir in files logs; do
    if [ -d "$dir" ]; then
        echo "Cleaning up existing '$dir' directory..."
        rm -rf "$dir"/*
    fi
    mkdir -p "$dir"
done

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

echo "Setting ownership and permissions for mount directories..."
chown -R www-data:www-data files logs src
chmod -R 777 files logs
find src -type d -exec chmod 755 {} \;
find src -type f -exec chmod 644 {} \;

echo "Installation complete! Run ILIAS at http://localhost:${WEB_PORT}"
