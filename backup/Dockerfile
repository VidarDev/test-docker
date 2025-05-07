FROM alpine:latest

RUN apk add --no-cache \
    bash \
    mysql-client \
    tzdata \
    coreutils \
    findutils \
    gzip \
    tar \
    grep \
    curl

RUN addgroup -g 1000 backup && \
    adduser -u 1000 -G backup -s /bin/bash -D backup

RUN mkdir -p /scripts /backups && \
    chown -R backup:backup /scripts /backups

COPY --chown=backup:backup scripts/backup-mysql.sh /scripts/
COPY --chown=backup:backup scripts/rotate-backups.sh /scripts/
COPY --chown=backup:backup scripts/entrypoint.sh /scripts/

RUN chmod +x /scripts/*.sh

ENV BACKUP_INTERVAL=6h \
    BACKUP_RETENTION=10 \
    MYSQL_HOST=mysql \
    MYSQL_DATABASE=prestashop \
    MYSQL_USER=root

WORKDIR /backups

USER backup

ENTRYPOINT ["/scripts/entrypoint.sh"]