#!/bin/bash
set -e

BACKUP_DIR=${BACKUP_DIR:-/backups}
BACKUP_RETENTION=${BACKUP_RETENTION:-10}

echo "Starting backup rotation"
echo "Backup directory: ${BACKUP_DIR}"
echo "Backups to keep: ${BACKUP_RETENTION}"

BACKUP_COUNT=$(find ${BACKUP_DIR} -name "*.sql.gz" | wc -l)
echo "Current backup count: ${BACKUP_COUNT}"

if [ ${BACKUP_COUNT} -gt ${BACKUP_RETENTION} ]; then
    DELETE_COUNT=$((BACKUP_COUNT - BACKUP_RETENTION))
    echo "Deleting ${DELETE_COUNT} oldest backups"
    
    find ${BACKUP_DIR} -name "*.sql.gz" -type f -print0 | \
        xargs -0 ls -tr | \
        head -n ${DELETE_COUNT} | \
        xargs rm -f
    
    echo "Rotation completed"
else
    echo "No rotation needed, backup count below retention limit"
fi

echo "Remaining backups:"
ls -lh ${BACKUP_DIR}/*.sql.gz 2>/dev/null || echo "No backups found"