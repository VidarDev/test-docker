#!/bin/sh
set -e

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="/backup/dumps"
RETENTION=${BACKUP_RETENTION:-7}

mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD --databases $MYSQL_DATABASE --single-transaction --quick --lock-tables=false | gzip > "$BACKUP_DIR/mysql_$TIMESTAMP.sql.gz"

restic backup $BACKUP_DIR

restic forget --keep-last $RETENTION --prune

cd $BACKUP_DIR && ls -t *.sql.gz | tail -n +$((RETENTION+1)) | xargs -r rm
