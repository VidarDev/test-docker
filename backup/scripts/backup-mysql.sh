#!/bin/bash
set -e

MYSQL_HOST=${MYSQL_HOST:-mysql}
MYSQL_DATABASE=${MYSQL_DATABASE:-prestashop}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=${MYSQL_ROOT_PASSWORD}
BACKUP_DIR=${BACKUP_DIR:-/backups}

mkdir -p ${BACKUP_DIR}

DATE=$(date +"%Y-%m-%d-%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${MYSQL_DATABASE}_${DATE}.sql.gz"

echo "Starting MySQL backup at $(date)"
echo "Database: ${MYSQL_DATABASE}"
echo "Backup file: ${BACKUP_FILE}"

mysqldump -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} --single-transaction --quick --lock-tables=false ${MYSQL_DATABASE} | gzip > ${BACKUP_FILE}

if [ $? -eq 0 ]; then
    echo "Backup completed successfully at $(date)"
    echo "File size: $(du -h ${BACKUP_FILE} | cut -f1)"
    
    if gzip -t ${BACKUP_FILE}; then
        echo "File integrity check passed"
        
        /scripts/rotate-backups.sh
    else
        echo "ERROR: File integrity check failed"
        exit 1
    fi
else
    echo "ERROR: Backup failed"
    exit 1
fi