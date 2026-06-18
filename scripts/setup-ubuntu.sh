#!/usr/bin/env bash
set -euo pipefail

echo "=== Installation des prerequis Ubuntu/Debian ==="

# Docker
if ! command -v docker &>/dev/null; then
  echo "Installation de Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
  echo "Docker installe. Deconnecte/reconnecte-toi pour utiliser docker sans sudo."
else
  echo "Docker deja installe."
fi

# Docker Compose (plugin)
if ! docker compose version &>/dev/null; then
  echo "Installation de Docker Compose plugin..."
  sudo apt-get update
  sudo apt-get install -y docker-compose-plugin
fi

# Git
if ! command -v git &>/dev/null; then
  echo "Installation de Git..."
  sudo apt-get install -y git
fi

# Vérifications
echo ""
echo "=== Verifications ==="
docker --version
docker compose version
git --version

echo ""
echo "=== Pret ! ==="
echo "1. Copie woodpecker/.env.example -> woodpecker/.env et remplis les variables"
echo "2. Lance: docker compose -f woodpecker/docker-compose.yml up -d"
echo "3. Configure GitHub OAuth App (Settings > Developer > OAuth Apps)"
echo "   - Homepage URL: http://IP_DU_SERVEUR"
echo "   - Callback URL: http://IP_DU_SERVEUR/authorize"
