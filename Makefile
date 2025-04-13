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

DOCKER_COMPOSE ?= docker compose
export DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 COMPOSE_FILE

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

# --- Variables ---
# 

# --- Commandes ---
.DEFAULT_GOAL := help

### Docker

.PHONY: test
test: ## [test, test2] Déploie sur l'environnement spécifié
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

### Help

.PHONY: help
HELP_CMD_WIDTH := 19
HELP_ARGS_WIDTH := 25
help: ## Affiche cette aide
help:
	@awk 'BEGIN {FS = ":.*?##"; printf "\n\033[1mUsage:\033[0m\n  make \033[33mCOMMAND\033[0m \033[36m[OPTIONS]\033[0m\n"} \
	/^[a-zA-Z_-]+:.*?##/ { \
		cmd = $$1; \
		desc = $$2; \
		args = ""; \
		gsub(/:/, "", cmd); \
		while (match(desc, /\[([^]]*)\]/)) { \
			if (args != "") args = args " "; \
			args = args substr(desc, RSTART+1, RLENGTH-2); \
			desc = substr(desc, 1, RSTART-1) " " substr(desc, RSTART+RLENGTH); \
		} \
		gsub(/^[ \t]+|[ \t]+$$/, "", desc); \
		printf "  \033[33m%-$(HELP_CMD_WIDTH)s\033[36m%-$(HELP_ARGS_WIDTH)s\033[0m%s\n", cmd, args, desc; \
	} \
	/^###/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)