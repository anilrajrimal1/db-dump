#!/bin/sh
set -e

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/backups/$DATE"
mkdir -p "$BACKUP_DIR"

echo "[INFO] Starting backup at $DATE"

# --- Backup Postgres if requested ---
if [ "$BACKUP_TYPE" = "postgres" ] || [ "$BACKUP_TYPE" = "all" ]; then
    for DB in $POSTGRES_DBS; do
        echo "[INFO] Dumping Postgres DB: $DB"
        PGPASSWORD=$POSTGRES_PASSWORD pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER "$DB" \
            | gzip > "$BACKUP_DIR/postgres_${DB}.sql.gz"
    done
fi

# --- Backup Mongo if requested ---
if [ "$BACKUP_TYPE" = "mongo" ] || [ "$BACKUP_TYPE" = "all" ]; then
    echo "[INFO] Dumping MongoDB: $MONGO_DB"
    if [ -n "$MONGO_USERNAME" ]; then
        mongodump --host $MONGO_HOST --db $MONGO_DB \
            --username $MONGO_USERNAME --password $MONGO_PASSWORD \
            --authenticationDatabase admin \
            --archive="$BACKUP_DIR/mongo_${MONGO_DB}.archive.gz" --gzip
    else
        mongodump --host $MONGO_HOST --db $MONGO_DB \
            --archive="$BACKUP_DIR/mongo_${MONGO_DB}.archive.gz" --gzip
    fi
fi

# --- Upload to AWS S3 ---
echo "[INFO] Uploading backups to S3"
aws s3 cp "$BACKUP_DIR" s3://$S3_BACKUP_PATH/$DATE --recursive --region $AWS_REGION

# --- Retention cleanup ---
echo "[INFO] Cleaning up backups older than $RETENTION_DAYS days locally"
find /backups/* -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +

echo "[INFO] Backup completed successfully!"
