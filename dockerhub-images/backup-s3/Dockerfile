FROM alpine:3.20

LABEL maintainer="Krishna Yada <yadakrishna245>" \
      description="Automated backup of Docker volumes and databases to AWS S3" \
      version="1.0.0"

RUN apk add --no-cache \
    bash curl aws-cli \
    postgresql16-client mysql-client \
    gzip tar

COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

ENV BACKUP_SCHEDULE="0 2 * * *" \
    S3_BUCKET="" \
    S3_PREFIX="backups" \
    BACKUP_SOURCE="/data" \
    RETENTION_DAYS="7"

VOLUME ["/data"]
ENTRYPOINT ["/usr/local/bin/backup.sh"]
