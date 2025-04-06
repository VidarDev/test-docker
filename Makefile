-include infra/.env

MAKEFLAGS += --no-print-directory
TAG    := $(shell git describe --tags --abbrev=0 2> /dev/null || echo 'latest')
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

COMPOSE_FILE ?= infra/compose.yml
ifneq ("$(wildcard infra/compose.$(ENV).yml)","")
	COMPOSE_FILE := infra/compose.yml:infra/compose.$(ENV).yml
endif

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export COMPOSE_FILE

.DEFAULT_GOAL := help
.PHONY: up stop down build restart db prestashop help health-check

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  up         Start the containers"
	@echo "  stop       Stop the containers"
	@echo "  down       Stop and remove the containers"
	@echo "  build      Build the images"
	@echo "  restart    Restart the containers"
	@echo "  db         Connect to the database"
	@echo "  prestashop Connect to the prestashop"
	@echo "  health-check Run health check on the infrastructure"

up:
	docker compose up -d

stop:
	docker compose stop

down:
	docker compose down

build:
	docker compose build

restart:
	docker compose stop
	docker compose up -d

db:
	docker compose exec database mysql -u $(DB_USER) -p$(DB_PASSWORD) $(DB_NAME) -h $(COMPOSE_PROJECT_NAME)-database

prestashop:
	docker compose exec prestashop bash

health-check:
	@bash infra/scripts/health-check.sh
