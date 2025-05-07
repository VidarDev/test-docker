#!/bin/bash
set -e

echo "=== PrestaShop Infrastructure Cleanup Script ==="
echo "This script will clean unused Docker resources."

if [ "$1" == "--all" ]; then
    REMOVE_VOLUMES=true
    echo "WARNING: Volumes will also be removed!"
else
    REMOVE_VOLUMES=false
    echo "Volumes will be preserved. Use --all to remove them."
fi

echo
echo "=== Stopping unused containers ==="
docker ps -a | grep 'Exited' | awk '{print $1}' | xargs -r docker stop

echo
echo "=== Removing stopped containers ==="
docker container prune -f

echo
echo "=== Removing dangling images ==="
docker images | grep '<none>' | awk '{print $3}' | xargs -r docker rmi -f

echo
echo "=== Removing unused networks ==="
docker network prune -f

if [ "$REMOVE_VOLUMES" = true ]; then
    echo
    echo "=== Removing unused volumes ==="
    docker volume prune -f
fi

echo
echo "=== Cleaning Docker caches ==="
docker system prune -f

echo
echo "=== Statistics after cleanup ==="
echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

echo
echo "Docker disk usage:"
docker system df

echo
echo "Cleanup completed!"