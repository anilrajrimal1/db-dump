#!/bin/sh
set -e

# Default cron schedule if BACKUP_CRON not set
: "${BACKUP_CRON:=0 2 * * *}"

# Export all environment variables so cron can see them
printenv | sed 's/^/export /' > /etc/profile.d/env.sh

echo "$BACKUP_CRON /scripts/backup.sh >> /backups/backup.log 2>&1" | crontab -

echo "Current crontab:"
crontab -l

# Start cron in foreground
exec crond -f -l 2
