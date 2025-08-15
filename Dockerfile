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

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create backup folder
RUN mkdir -p /backups

# run cron in foreground
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
