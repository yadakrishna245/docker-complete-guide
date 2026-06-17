# 💾 Backup S3

Automated backup of Docker volumes and databases (PostgreSQL/MySQL) to AWS S3.

## Usage

```bash
# Backup a volume to S3
docker run --rm \
  -v mydata:/data \
  -e AWS_ACCESS_KEY_ID=xxx \
  -e AWS_SECRET_ACCESS_KEY=xxx \
  -e AWS_DEFAULT_REGION=us-east-1 \
  -e S3_BUCKET=my-backups \
  krishna8688/backup-s3

# Backup PostgreSQL
docker run --rm \
  -e POSTGRES_HOST=db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -e S3_BUCKET=my-backups \
  -e AWS_ACCESS_KEY_ID=xxx \
  -e AWS_SECRET_ACCESS_KEY=xxx \
  -e AWS_DEFAULT_REGION=us-east-1 \
  --network myapp_network \
  krishna8688/backup-s3
```

## Docker Compose (scheduled via restart)

```yaml
services:
  backup:
    image: krishna8688/backup-s3
    volumes:
      - app_data:/data
    environment:
      - S3_BUCKET=my-backups
      - RETENTION_DAYS=7
      - AWS_ACCESS_KEY_ID=${AWS_KEY}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET}
      - AWS_DEFAULT_REGION=us-east-1
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| S3_BUCKET | ✅ | - | Target S3 bucket |
| S3_PREFIX | - | backups | Folder prefix in bucket |
| BACKUP_SOURCE | - | /data | Volume mount path |
| RETENTION_DAYS | - | 7 | Auto-delete old backups |
| POSTGRES_HOST | - | - | Enable PostgreSQL backup |
| MYSQL_HOST | - | - | Enable MySQL backup |

## Author
[Krishna Yada](https://github.com/yadakrishna245)
