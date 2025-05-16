DOCKER_COMPOSE ?= docker compose
export DOCKER_COMPOSE

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

init: down build up

restart: down up