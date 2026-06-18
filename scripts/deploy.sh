#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <serveur> [compose_file]"
  echo "  serveur     : user@host (ex: ubuntu@192.168.1.10)"
  echo "  compose_file: chemin vers docker-compose.yml (defaut: deploy/docker-compose.yml)"
  exit 1
fi

SERVER=$1
COMPOSE_FILE=${2:-deploy/docker-compose.yml}
REMOTE_DIR="/opt/$(basename "$(git rev-parse --show-toplevel)")"

echo "=== Deploiement sur $SERVER ==="

# Copier les fichiers de déploiement
rsync -avz --delete \
  "$COMPOSE_FILE" \
  deploy/.env \
  "$SERVER:$REMOTE_DIR/"

# Déployer sur le serveur
ssh "$SERVER" "
  cd $REMOTE_DIR
  docker compose pull
  docker compose up -d --remove-orphans
"

echo "=== Deploiement termine ==="
