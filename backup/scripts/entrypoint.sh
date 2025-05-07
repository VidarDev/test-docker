#!/bin/sh
set -e

BACKUP_INTERVAL=${BACKUP_INTERVAL:-6h}

echo "=== Démarrage du service de backup ==="
echo "Intervalle de backup: ${BACKUP_INTERVAL}"
echo "Rétention des backups: ${BACKUP_RETENTION} fichiers"

echo "Exécution du backup initial..."
/bin/sh /scripts/backup.sh

echo "Démarrage de la planification des backups..."
while true; do
    echo "Prochain backup dans ${BACKUP_INTERVAL}"
    sleep ${BACKUP_INTERVAL}
    
    /bin/sh /scripts/backup.sh
done