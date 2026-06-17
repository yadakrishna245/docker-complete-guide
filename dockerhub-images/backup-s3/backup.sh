#!/bin/bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/tmp/backup_${TIMESTAMP}.tar.gz"

echo "[$(date)] Starting backup..."

# Database backup if configured
if [ -n "$POSTGRES_HOST" ]; then
    echo "[$(date)] Backing up PostgreSQL..."
    PGPASSWORD="$POSTGRES_PASSWORD" pg_dumpall -h "$POSTGRES_HOST" -U "${POSTGRES_USER:-postgres}" | gzip > /tmp/pg_dump_${TIMESTAMP}.sql.gz
    aws s3 cp /tmp/pg_dump_${TIMESTAMP}.sql.gz "s3://${S3_BUCKET}/${S3_PREFIX}/postgres/pg_dump_${TIMESTAMP}.sql.gz"
    rm -f /tmp/pg_dump_${TIMESTAMP}.sql.gz
    echo "[$(date)] PostgreSQL backup uploaded to S3"
fi

if [ -n "$MYSQL_HOST" ]; then
    echo "[$(date)] Backing up MySQL..."
    mysqldump -h "$MYSQL_HOST" -u "${MYSQL_USER:-root}" -p"$MYSQL_PASSWORD" --all-databases | gzip > /tmp/mysql_dump_${TIMESTAMP}.sql.gz
    aws s3 cp /tmp/mysql_dump_${TIMESTAMP}.sql.gz "s3://${S3_BUCKET}/${S3_PREFIX}/mysql/mysql_dump_${TIMESTAMP}.sql.gz"
    rm -f /tmp/mysql_dump_${TIMESTAMP}.sql.gz
    echo "[$(date)] MySQL backup uploaded to S3"
fi

# Volume backup
if [ -d "$BACKUP_SOURCE" ] && [ "$(ls -A $BACKUP_SOURCE)" ]; then
    echo "[$(date)] Backing up volume: $BACKUP_SOURCE"
    tar -czf "$BACKUP_FILE" -C "$BACKUP_SOURCE" .
    aws s3 cp "$BACKUP_FILE" "s3://${S3_BUCKET}/${S3_PREFIX}/volumes/backup_${TIMESTAMP}.tar.gz"
    rm -f "$BACKUP_FILE"
    echo "[$(date)] Volume backup uploaded to S3"
fi

# Cleanup old backups
if [ -n "$RETENTION_DAYS" ] && [ "$RETENTION_DAYS" -gt 0 ]; then
    echo "[$(date)] Cleaning backups older than ${RETENTION_DAYS} days..."
    CUTOFF=$(date -d "-${RETENTION_DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${RETENTION_DAYS}d +%Y-%m-%d)
    aws s3 ls "s3://${S3_BUCKET}/${S3_PREFIX}/" --recursive | while read -r line; do
        FILE_DATE=$(echo "$line" | awk '{print $1}')
        if [[ "$FILE_DATE" < "$CUTOFF" ]]; then
            FILE_PATH=$(echo "$line" | awk '{print $4}')
            aws s3 rm "s3://${S3_BUCKET}/${FILE_PATH}"
        fi
    done
fi

echo "[$(date)] Backup complete!"
