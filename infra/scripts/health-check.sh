#!/bin/bash
set -e

echo "PrestaShop DevOps Infrastructure Health Check"
echo "============================================="
echo

COMPOSE_PROJECT_NAME=$1

check_docker() {
  if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running or accessible!"
    exit 1
  fi
  echo "✅ Docker is running"
}

check_containers() {
  local containers=("${COMPOSE_PROJECT_NAME}-prestashop" "${COMPOSE_PROJECT_NAME}-mariadb" "${COMPOSE_PROJECT_NAME}-phpmyadmin" "${COMPOSE_PROJECT_NAME}-smtp" "${COMPOSE_PROJECT_NAME}-restic" "${COMPOSE_PROJECT_NAME}-traefik" "${COMPOSE_PROJECT_NAME}-prometheus" "${COMPOSE_PROJECT_NAME}-grafana" "${COMPOSE_PROJECT_NAME}-alertmanager" "${COMPOSE_PROJECT_NAME}-node-exporter" "${COMPOSE_PROJECT_NAME}-cadvisor" "${COMPOSE_PROJECT_NAME}-redis")
  for container in "${containers[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^$container$"; then
      echo "✅ Container $container is running"
    else
      echo "❌ Container $container is not running!"
    fi
  done
}

check_backup_status() {
  local latest_backup
  latest_backup=$(docker compose exec restic restic snapshots --latest 1 2>/dev/null || echo "No backups found")
  if [[ "$latest_backup" == *"No backups found"* ]]; then
    echo "❌ No backups found!"
  else
    echo "✅ Latest backup: $(echo "$latest_backup" | grep -oE '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')"
  fi
}

check_docker
echo
check_containers
echo
check_backup_status