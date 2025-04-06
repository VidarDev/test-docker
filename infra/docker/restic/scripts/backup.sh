#!/bin/sh
set -e

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="/backup/dumps"
BACKUP_LOG="/backup/logs/backup.log"
RETENTION=${BACKUP_RETENTION:-7}

mkdir -p "$BACKUP_DIR" /backup/logs

log() {
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" | tee -a "$BACKUP_LOG"
}

handle_error() {
  log "ERROR: Backup failed - $1"
  exit 1
}

log "Starting MySQL backup for $MYSQL_DATABASE"

if ! mysqldump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --databases "$MYSQL_DATABASE" --single-transaction --quick --lock-tables=false | gzip > "$BACKUP_DIR/mysql_$TIMESTAMP.sql.gz"; then
  handle_error "MySQL dump failed"
fi

log "MySQL backup completed successfully: mysql_$TIMESTAMP.sql.gz"

log "Creating restic snapshot"
if ! restic backup "$BACKUP_DIR"; then
  handle_error "Restic snapshot creation failed"
fi

log "Pruning old snapshots (keeping last $RETENTION)"
if ! restic forget --keep-last "$RETENTION" --prune; then
  handle_error "Restic pruning failed"
fi

log "Cleaning up old SQL dumps (keeping last $RETENTION)"
cd "$BACKUP_DIR" && ls -t *.sql.gz | tail -n +$((RETENTION+1)) | xargs -r rm

BACKUP_SIZE=$(du -sh "$BACKUP_DIR/mysql_$TIMESTAMP.sql.gz" | cut -f1)
log "Backup completed successfully. Backup size: $BACKUP_SIZE"
