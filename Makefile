-include infra/.env infra/.env.local

# --- Makefile ---
SHELL := bash
MAKEFLAGS += --no-print-directory
TAG    := $(shell git describe --tags --abbrev=0 2> /dev/null || echo 'latest')
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

# --- Docker ---
COMPOSE_FILE ?= infra/compose.yml
ifneq ("$(wildcard infra/compose.$(ENV).yml)","")
	COMPOSE_FILE := $(COMPOSE_FILE):infra/compose.$(ENV).yml
endif
ifneq ("$(wildcard infra/compose.override.yml)","")
	COMPOSE_FILE := $(COMPOSE_FILE):infra/compose.override.yml
endif

DOCKER_COMPOSE ?= docker compose # docker compose or docker-compose
export DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 COMPOSE_FILE

# --- Variables ---
TERMINAL_WIDTH := $(shell tput cols)
HELP_SCRIPT := makefile-docs.awk
TOOLS_SCRIPT := makefile-tools.sh

# --- Environment variables export ---
# export ENV

# --- Utils ---
SUCCESS := \033[0;32m[✓]\033[0m
ERROR := \033[0;31m[✗]\033[0m
WARNING := \033[0;33m[!]\033[0m

SPINNER_TYPE ?= dot
SPINNER_COLOR ?= yellow
define run_command
	bash -c "source $(TOOLS_SCRIPT) && \
		start_spinner --type=$(SPINNER_TYPE) --color=$(SPINNER_COLOR) && \
		$(1) && \
		stop_spinner"
endef

# --- Commandes ---
.DEFAULT_GOAL := help

### Docker:

.PHONY: up
up: ## Démarre les conteneurs Docker
up:
	@$(call run_command, $(MAKE) _up)
_up:
	$(DOCKER_COMPOSE) up -d

.PHONY: help
help:
	@awk -v width=$(TERMINAL_WIDTH) \
		-v tab_width=2 \
		-v command_width=5 \
		-v arguments_width=6 \
		-v description_min_width=30 \
		-v usage="Utilisation:" \
		-v description="Défini et exécute les commandes de l'application avec Docker." \
		-v help="Utilisez %s pour afficher cette aide." \
		-F ':.*?##' \
		-f $(HELP_SCRIPT) \
		$(MAKEFILE_LIST)
