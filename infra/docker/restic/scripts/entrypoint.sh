#!/bin/sh
set -e

chmod +x /scripts/*.sh

mkdir -p /backup/logs /backup/dumps

if [ ! -d "$RESTIC_REPOSITORY/data" ]; then
  echo "Initializing restic repository..."
  restic init || { echo "Failed to initialize restic repository!"; exit 1; }
  echo "Repository initialized successfully."
fi

echo "Setting up cron job for backups every 6 hours..."
echo "0 */6 * * * /scripts/backup.sh" > /var/spool/cron/crontabs/root

echo "Running initial backup..."
/scripts/backup.sh

echo "Backup system initialized successfully."
echo "Scheduled backups will run every 6 hours."
echo "Logs will be saved to /backup/logs/backup.log"

exec crond -f -l 8
