#!/bin/sh
set -e

chmod +x /scripts/*.sh

if [ ! -d "$RESTIC_REPOSITORY/data" ]; then
  restic init
fi

echo "* * * * * /scripts/backup.sh >> /backup/logs/backup.log 2>&1" > /var/spool/cron/crontabs/root
# echo "0 */6 * * * /scripts/backup.sh >> /backup/logs/backup.log 2>&1" > /var/spool/cron/crontabs/root
mkdir -p /backup/logs /backup/dumps

/scripts/backup.sh

exec crond -f -l 8
