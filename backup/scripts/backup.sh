#!/bin/sh
set -e

MYSQL_HOST=${MYSQL_HOST:-mysql}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
MYSQL_DATABASE=${MYSQL_DATABASE:-prestashop}
BACKUP_DIR=${BACKUP_DIR:-/backup}

DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${MYSQL_DATABASE}_${DATE}.sql.gz"

mkdir -p ${BACKUP_DIR}

echo "$(date +"%Y-%m-%d %H:%M:%S") - Démarrage du backup MySQL (${MYSQL_DATABASE})"

mysqldump \
    --host=${MYSQL_HOST} \
    --user=${MYSQL_USER} \
    --password=${MYSQL_PASSWORD} \
    --single-transaction \
    --quick \
    --lock-tables=false \
    --routines \
    --triggers \
    --events \
    ${MYSQL_DATABASE} | gzip > ${BACKUP_FILE}

if [ $? -eq 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup réussi: ${BACKUP_FILE}"
    
    SIZE=$(du -h ${BACKUP_FILE} | cut -f1)
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Taille du backup: ${SIZE}"
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ${BACKUP_FILE} - ${SIZE}" >> ${BACKUP_DIR}/backup_history.log
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ERREUR: Échec du backup"
    exit 1
fi

/bin/sh /scripts/cleanup.sh

echo "$(date +"%Y-%m-%d %H:%M:%S") - Processus de backup terminé"