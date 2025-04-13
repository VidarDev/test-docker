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
	COMPOSE_FILE := $(COMPOSE_FILE):compose.$(ENV).yml
endif
ifneq ("$(wildcard infra/compose.override.yml)","")
	COMPOSE_FILE := $(COMPOSE_FILE):infra/compose.override.yml
endif

DOCKER_COMPOSE ?= docker compose # docker compose or docker-compose
export DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 COMPOSE_FILE

# --- Variables ---
TERMINAL_WIDTH := $(shell tput cols)
HELP_SCRIPT := makefile_help.awk

# --- Environment variables export ---
# export ENV

# --- Utils ---
SUCCESS := \033[0;32m[✓]\033[0m
ERROR := \033[0;31m[✗]\033[0m
WARNING := \033[0;33m[!]\033[0m

define run_command
	bash -c "source makefile_tools.sh && \
		start_spinner --type=dot --color=yellow && \
		$(1) && \
		stop_spinner"
endef

# --- Commandes ---
.DEFAULT_GOAL := help

### Docker:

.PHONY: test
test: ## [bebug] Lance les tests
test:	
	@$(call run_command, $(MAKE) _test)
_test:
	@echo -e "$(SUCCESS) Flutter (Channel stable, 3.29.2, on macOS 15.4 24E248 darwin-arm64, locale fr-FR)"
	@sleep 1
	@echo -e "$(WARNING) Xcode - develop for iOS and macOS (Xcode 16.3)"
	@sleep 1
	@echo -e "$(ERROR) Android Studio (version 2023.1.1) - develop for Android"
	@sleep 1
	@echo -e "$(ERROR) Android Studio (version 2023.1.1) - develop for Android"

.PHONY: help
help: ## Affiche cette aide
	@awk -v width=$(TERMINAL_WIDTH) \
		-v tab_width=2 \
		-v cmd_width=5 \
		-v args_width=6 \
		-v desc_width=30 \
		-v description="Défini et exécute les commandes de l'application avec Docker." \
		-F ':.*?##' \
		-f $(HELP_SCRIPT) \
		$(MAKEFILE_LIST)
