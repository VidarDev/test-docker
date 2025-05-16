FROM alpine:latest

RUN apk update && \
    apk add --no-cache \
    bash \
    mysql-client \
    tzdata \
    curl \
    tar \
    gzip \
    ca-certificates

RUN addgroup -g 1000 backup && \
    adduser -D -u 1000 -G backup backup

RUN mkdir -p /backup && \
    chown -R backup:backup /backup

COPY scripts/backup.sh /scripts/backup.sh
COPY scripts/cleanup.sh /scripts/cleanup.sh
COPY scripts/entrypoint.sh /scripts/entrypoint.sh

RUN chmod 755 /scripts/*.sh && \
    chown -R backup:backup /scripts

USER backup

ENTRYPOINT ["/bin/sh", "/scripts/entrypoint.sh"]