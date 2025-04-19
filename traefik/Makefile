-include .env .env.local

# --- Makefile ---
SHELL := bash
MAKEFLAGS += --no-print-directory
TAG    := $(shell git describe --tags --abbrev=0 2> /dev/null || echo 'latest')
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

# --- Docker ---
COMPOSE_FILE ?= compose.yml
ifneq ("$(wildcard compose.$(ENV).yml)","")
	COMPOSE_FILE := $(COMPOSE_FILE):compose.$(ENV).yml
endif
ifneq ("$(wildcard compose.override.yml)","")
	COMPOSE_FILE := $(COMPOSE_FILE):compose.override.yml
endif

DOCKER_COMPOSE ?= docker compose # docker compose or docker-compose
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export COMPOSE_FILE

network-create:
	@docker network create ${TRAEFIK_NETWORK} 2>/dev/null || true
	
up: network-create
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) stop

down:
	$(DOCKER_COMPOSE) down

build:
	$(DOCKER_COMPOSE) build