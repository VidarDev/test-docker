#!/bin/bash
set -e

BACKUP_INTERVAL=${BACKUP_INTERVAL:-6h}
MYSQL_HOST=${MYSQL_HOST:-mysql}
MYSQL_DATABASE=${MYSQL_DATABASE:-prestashop}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=${MYSQL_ROOT_PASSWORD}
BACKUP_DIR=${BACKUP_DIR:-/backups}
BACKUP_RETENTION=${BACKUP_RETENTION:-10}

echo "Starting backup service:"
echo "Interval: $BACKUP_INTERVAL"
echo "Database: $MYSQL_DATABASE@$MYSQL_HOST"
echo "Retention: $BACKUP_RETENTION backups"

export MYSQL_HOST MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD BACKUP_DIR BACKUP_RETENTION

function convert_to_seconds() {
    local interval=$1
    local value=${interval%[hms]}
    local unit=${interval#$value}
    
    case $unit in
        h) echo $((value * 3600)) ;;
        m) echo $((value * 60)) ;;
        s) echo $value ;;
        *) echo $((value * 3600)) ;;
    esac
}

INTERVAL_SECONDS=$(convert_to_seconds $BACKUP_INTERVAL)

while true; do
    /scripts/backup-mysql.sh
    echo "Next backup in ${BACKUP_INTERVAL}"
    sleep ${INTERVAL_SECONDS}
done