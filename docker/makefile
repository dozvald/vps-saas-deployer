# ===== Variables =====
# Charger les variables d'environnement depuis le fichier .env (ignore commentaires et lignes vides)
ifneq (,$(wildcard .env))
include .env
export $(shell grep -vE '^(#|$$)' .env | sed 's/=.*//')
endif

# Docker Compose files
COMPOSE_DEV      = docker-compose.dev.yml
COMPOSE_STAGING  = docker-compose.staging.yml
COMPOSE_PROD     = docker-compose.production.yml

# Docker Compose project names
PROJECT_DEV      = $(PROJECT_NAME)-dev
PROJECT_STAGING  = $(PROJECT_NAME)-staging
PROJECT_PROD     = $(PROJECT_NAME)-prod

# ===== HELP =====
help:
	$(info )
	$(info Commandes disponibles :)
	$(info -----------------------)
	$(info => Environnements Docker Compose :)
	$(info   make up-dev           -> Lance la stack de développement)
	$(info   make up-staging       -> Lance la stack de staging)
	$(info   make up-prod          -> Lance la stack de production)
	$(info )
	$(info => Build / Pull / Down :)
	$(info   make build-dev        -> Rebuild les images du mode dev)
	$(info   make pull-dev         -> Pull les images distantes pour dev)
	$(info   make pull-staging     -> Pull les images distantes pour staging)
	$(info   make pull-prod        -> Pull les images distantes pour prod)
	$(info   make down-dev         -> Stoppe et supprime les containers dev)
	$(info   make down-staging     -> Stoppe et supprime les containers staging)
	$(info   make down-prod        -> Stoppe et supprime les containers prod)
	$(info )
	$(info 🔹 Déploiement one-shot :)
	$(info   make deploy-dev         -> Pull + restart de la stack de développement)
	$(info   make deploy-staging     -> Pull + restart de la stack staging)
	$(info   make deploy-prod        -> Pull + restart de la stack production)
	$(info => Aide :)
	$(info   make help             -> Affiche cette aide)
	$(info )

# ===== BUILD =====
build-dev:
	docker compose -p $(PROJECT_DEV) -f $(COMPOSE_DEV) build

# ===== UP (run stacks) =====
up-dev:
	docker compose -p $(PROJECT_DEV) -f $(COMPOSE_DEV) up -d

up-staging:
	docker compose -p $(PROJECT_STAGING) -f $(COMPOSE_STAGING) up -d

up-prod:
	docker compose -p $(PROJECT_PROD) -f $(COMPOSE_PROD) up -d

# ===== PULL =====
pull-dev:
	docker compose -p $(PROJECT_DEV) -f $(COMPOSE_DEV) pull

pull-staging:
	docker compose -p $(PROJECT_STAGING) -f $(COMPOSE_STAGING) pull

pull-prod:
	docker compose -p $(PROJECT_PROD) -f $(COMPOSE_PROD) pull

# ===== DOWN =====
down-dev:
	docker compose -p $(PROJECT_DEV) -f $(COMPOSE_DEV) down

down-staging:
	docker compose -p $(PROJECT_STAGING) -f $(COMPOSE_STAGING) down

down-prod:
	docker compose -p $(PROJECT_PROD) -f $(COMPOSE_PROD) down
	
# ===== DEPLOY (one-shot) =====
deploy-dev: pull-dev down-dev up-dev

deploy-staging: pull-staging down-staging up-staging

deploy-prod: pull-prod down-prod up-prod