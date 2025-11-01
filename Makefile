# ==========================================================
# 🧰 DevOps Microservices Makefile
# Author: Shuja Akbar
# Description: Automation commands for Docker, Kubernetes, and CI/CD
# ==========================================================

# Load environment variables from .env if it exists
ifneq (,$(wildcard ./.env))
	include .env
	export
endif

# Colors for output
GREEN  := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BLUE   := $(shell tput setaf 4)
RESET  := $(shell tput sgr0)

# ==========================================================
# Docker Commands
# ==========================================================

build:
	@echo "$(YELLOW)📦 Building Docker images...$(RESET)"
	docker compose build

up:
	@echo "$(GREEN)🚀 Starting all services with Docker Compose...$(RESET)"
	docker compose up -d

down:
	@echo "$(BLUE)🧹 Stopping and removing containers...$(RESET)"
	docker compose down

logs:
	@echo "$(YELLOW)📜 Viewing container logs...$(RESET)"
	docker compose logs -f

restart: down up

setup:
	@echo "$(BLUE)🧹 Stopping and removing containers...$(RESET)"
	docker compose exec -T postgres psql -U devops -d container -f /docker-entrypoint-initdb.d/init.sql

# ==========================================================
# Testing
# ==========================================================

test:
	@echo "$(GREEN)🧪 Running backend tests...$(RESET)"
	docker compose run --rm service-api pytest -v

lint:
	@echo "$(YELLOW)🔍 Running code lint checks...$(RESET)"
	docker compose run --rm service-api flake8 .

# ==========================================================
# Kubernetes Commands
# ==========================================================

k8s-start:
	@echo "$(GREEN)☸️  Starting Minikube...$(RESET)"
	minikube start

k8s-deploy:
	@echo "$(YELLOW)🚀 Deploying all Kubernetes manifests...$(RESET)"
	kubectl apply -f k8s/

k8s-delete:
	@echo "$(BLUE)🧹 Deleting all Kubernetes resources...$(RESET)"
	kubectl delete -f k8s/ --ignore-not-found=true

k8s-status:
	@echo "$(GREEN)📊 Checking Kubernetes status...$(RESET)"
	kubectl get pods,svc

k8s-restart: k8s-delete k8s-deploy

# ==========================================================
# Utility Commands
# ==========================================================

ps:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

clean:
	@echo "$(BLUE)🧽 Removing unused Docker data...$(RESET)"
	docker system prune -af
	docker volume prune -f

help:
	@echo ""
	@echo "$(BLUE)💡 Available Commands$(RESET)"
	@echo "  make build         - Build Docker images"
	@echo "  make up            - Start all containers"
	@echo "  make down          - Stop and remove containers"
	@echo "  make logs          - View Docker logs"
	@echo "  make test          - Run pytest in service-api"
	@echo "  make lint          - Lint Flask code with flake8"
	@echo "  make k8s-start     - Start Minikube cluster"
	@echo "  make k8s-deploy    - Deploy Kubernetes manifests"
	@echo "  make k8s-delete    - Delete Kubernetes resources"
	@echo "  make k8s-status    - Show pods and services"
	@echo "  make clean         - Clean up Docker data"
	@echo ""

# Default command
.DEFAULT_GOAL := help
