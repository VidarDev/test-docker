#!/bin/sh
set -e

# Configuration via variables d'environnement
BACKUP_DIR=${BACKUP_DIR:-/backup}
BACKUP_RETENTION=${BACKUP_RETENTION:-7}

echo "$(date +"%Y-%m-%d %H:%M:%S") - Début du nettoyage des backups..."
echo "$(date +"%Y-%m-%d %H:%M:%S") - Conservation des ${BACKUP_RETENTION} derniers backups"

if [ ! -d "${BACKUP_DIR}" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ERREUR: Le répertoire ${BACKUP_DIR} n'existe pas"
    exit 1
fi

BACKUP_COUNT=$(find ${BACKUP_DIR} -name "*.sql.gz" | wc -l)
echo "$(date +"%Y-%m-%d %H:%M:%S") - Nombre total de backups: ${BACKUP_COUNT}"

if [ ${BACKUP_COUNT} -gt ${BACKUP_RETENTION} ]; then
    DELETE_COUNT=$((BACKUP_COUNT - BACKUP_RETENTION))
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Suppression des ${DELETE_COUNT} plus anciens backups"
    
    FILES_TO_DELETE=$(find ${BACKUP_DIR} -name "*.sql.gz" -type f -printf "%T@ %p\n" | sort -n | head -n ${DELETE_COUNT} | cut -d' ' -f2-)
    
    for FILE in ${FILES_TO_DELETE}; do
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Suppression de ${FILE}"
        rm -f "${FILE}"
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Fichier supprimé: ${FILE}" >> ${BACKUP_DIR}/cleanup_history.log
    done
    
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ${DELETE_COUNT} backups ont été supprimés"
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Pas besoin de nettoyer (${BACKUP_COUNT} <= ${BACKUP_RETENTION})"
fi

echo "$(date +"%Y-%m-%d %H:%M:%S") - Nettoyage des backups terminé"