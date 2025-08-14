FROM alpine:latest

# Install required tools
RUN apk add --no-cache \
    bash \
    postgresql-client \
    mongodb-tools \
    aws-cli \
    gzip \
    coreutils \
    busybox-extras \
    && rm -rf /var/cache/apk/*

# Copy backup script
COPY scripts/backup.sh /scripts/backup.sh
RUN chmod +x /scripts/backup.sh

# Create backup folder
RUN mkdir -p /backups

# run cron in foreground
ENTRYPOINT ["sh", "-c", "crond -f -l 2"]
