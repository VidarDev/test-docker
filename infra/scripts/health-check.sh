#!/bin/bash
set -e

echo "PrestaShop DevOps Infrastructure Health Check"
echo "============================================="
echo

check_docker() {
  if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running or accessible!"
    exit 1
  fi
  echo "✅ Docker is running"
}

check_containers() {
  local containers=("ps-prestashop" "ps-database" "ps-phpmyadmin" "ps-smtp" "ps-backup" "ps-reverse-proxy" "ps-prometheus" "ps-grafana" "ps-alertmanager" "ps-node-exporter" "ps-cadvisor" "ps-redis")
  for container in "${containers[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^$container$"; then
      echo "✅ Container $container is running"
    else
      echo "❌ Container $container is not running!"
    fi
  done
}

check_service_accessibility() {
  local services=("http://prestashop.localhost" "http://prometheus.ps.localhost" "http://grafana.ps.localhost")
  local names=("PrestaShop" "Prometheus" "Grafana")

  for i in "${!services[@]}"; do
    if curl -s -I "${services[$i]}" > /dev/null 2>&1; then
      echo "✅ ${names[$i]} is accessible"
    else
      echo "❌ ${names[$i]} is not accessible!"
    fi
  done
}

check_backup_status() {
  local latest_backup
  latest_backup=$(docker compose exec backup restic snapshots --latest 1 2>/dev/null || echo "No backups found")
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
check_service_accessibility
echo
check_backup_status
echo
echo "Health check completed at $(date)"