# ISB-CICD

Infrastructure CI/CD complète et auto-hébergée pour projets multi-langage, basée sur **Woodpecker CI**, **Docker Compose**, et déployée sur des serveurs **Ubuntu/Debian**.

---

## Architecture

```
┌──────────────────────────────┐     ┌──────────────────────────────┐
│       Serveur Dev/CI         │     │      Serveur Production      │
│                              │     │                              │
│  ┌──────────────────────┐    │     │  ┌──────────────────────┐    │
│  │  Woodpecker Server   │    │     │  │  Backend (8000)      │    │
│  │  Web UI + API        │    │     │  │  API (8001)          │    │
│  │  port 80 / 9000      │    │     │  │  Frontend (80)       │    │
│  └──────────┬───────────┘    │     │  └──────────────────────┘    │
│             │                │     │                              │
│  ┌──────────▼───────────┐    │     │                              │
│  │  Woodpecker Agent    │    │     │                              │
│  │  (exécute pipelines) │    │     │                              │
│  └──────────────────────┘    │     │                              │
│                              │     │                              │
│  Apps en mode test           │     │                              │
│  Backend / API / Frontend    │     │                              │
└──────────────────────────────┘     └──────────────────────────────┘
```

### Flux CI/CD

```
Git Push ──► GitHub ──► Webhook ──► Woodpecker Server
                                         │
                                    ┌────▼────┐
                                    │ Pipeline │
                                    │ 1. Tests │
                                    │ 2. Docker│
                                    │ 3. Deploy│
                                    └─────────┘
                                         │
                              ┌──────────┴──────────┐
                              ▼                     ▼
                        Serveur Dev           Serveur Prod
                     (docker compose)       (docker compose)
```

---

## Prérequis

- Un serveur **Ubuntu 22.04+ / Debian 12+**
- Un nom de domaine ou IP publique pour Woodpecker
- Un compte GitHub (pour créer une OAuth App)
- (Optionnel) Un second serveur pour la prod

---

## Installation rapide

### 1. Préparer le serveur

```bash
# Télécharger le projet
git clone https://github.com/votre-org/isb-cicd.git
cd isb-cicd

# Lancer le script d'installation
chmod +x scripts/setup-ubuntu.sh
./scripts/setup-ubuntu.sh
```

### 2. Configurer GitHub OAuth

1. Aller sur **GitHub.com → Settings → Developer settings → OAuth Apps → New OAuth App**
2. Remplir :
   - **Application name** : `ISB-CICD`
   - **Homepage URL** : `http://IP_DU_SERVEUR`
   - **Authorization callback URL** : `http://IP_DU_SERVEUR/authorize`
3. Copier le **Client ID** et **Client Secret**

### 3. Lancer Woodpecker

```bash
# Copier et remplir la config
cp woodpecker/.env.example woodpecker/.env
nano woodpecker/.env

# Générer un secret pour l'agent
openssl rand -hex 32

# Démarrer Woodpecker
docker compose -f woodpecker/docker-compose.yml up -d
```

Woodpecker est accessible sur `http://IP_DU_SERVEUR`.

### 4. Ajouter un dépôt

1. Aller sur l'interface Woodpecker
2. Cliquer sur **Repos** → **Activate**
3. Sélectionner le dépôt GitHub à CI/CD
4. Woodpecker détecte automatiquement le `.woodpecker.yml` à la racine

---

## Pipeline CI

Fichier : `.woodpecker.yml`

| Étape | Déclencheur | Action |
|-------|-------------|--------|
| Tests | push, PR | Tests unitaires (Python avec pytest, Node.js avec npm test) |
| Build Docker | push sur main | Build et push vers GitHub Container Registry (ghcr.io) |
| Déploiement | push sur main | SSH sur le serveur dev et `docker compose up -d` |

### Variables secrètes à configurer dans Woodpecker

| Variable | Description |
|----------|-------------|
| `DOCKER_USERNAME` | Login GitHub pour ghcr.io |
| `DOCKER_PASSWORD` | Token GitHub (classic, scope `write:packages`) |
| `DEV_SERVER_HOST` | IP du serveur dev |
| `DEV_SERVER_USER` | Utilisateur SSH (ex: `ubuntu`) |
| `DEV_SERVER_SSH_KEY` | Clé privée SSH pour la connexion |

---

## Structure du projet

```
ISB-CICD/
├── .woodpecker.yml              # Pipeline CI (tests, build, déploiement)
├── woodpecker/
│   ├── docker-compose.yml       # Woodpecker Server + Agent
│   └── .env.example             # Configuration Woodpecker
├── apps/
│   ├── backend/                 # Service Python (FastAPI, port 8000)
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── src/main.py
│   │   └── tests/test_main.py
│   ├── api/                     # Service Python (FastAPI, port 8001)
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── src/main.py
│   │   └── tests/test_main.py
│   └── frontend/                # Service Node.js (React, port 80)
│       ├── Dockerfile
│       ├── package.json
│       └── src/
├── deploy/
│   ├── docker-compose.yml       # Déploiement production
│   └── .env.example
├── scripts/
│   ├── setup-ubuntu.sh          # Installation Docker + Git
│   └── deploy.sh                # Déploiement manuel
└── README.md
```

---

## Déploiement manuel

```bash
# Copier la config
cp deploy/.env.example deploy/.env
nano deploy/.env

# Lancer le déploiement
./scripts/deploy.sh ubuntu@192.168.1.10
```

---

## Questions fréquentes

### Woodpecker agent sur le même serveur que les applis ?

Oui, c'est recommandé pour commencer. L'agent utilise le socket Docker de l'hôte (`/var/run/docker.sock`) pour exécuter les pipelines. Les pipelines tournent dans des conteneurs isolés, sans risque pour les applis.

### Woodpecker ne voit pas mon dépôt ?

Vérifier que :
- L'URL publique `WOODPECKER_HOST` est correcte dans `woodpecker/.env`
- L'OAuth App GitHub est bien configurée (callback URL)
- Le dépôt est activé dans l'UI Woodpecker (Repos → Activate)

### Comment ajouter un nouveau service ?

1. Créer un dossier dans `apps/` avec son `Dockerfile`
2. Ajouter l'étape de test dans `.woodpecker.yml`
3. Ajouter le service dans `deploy/docker-compose.yml`
4. Commit et push
