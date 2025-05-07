#!/bin/bash
set -e

envsubst < /etc/prometheus/prometheus.template.yml > /etc/prometheus/prometheus.yml
envsubst < /etc/prometheus/alert_rules.template.yml > /etc/prometheus/alert_rules.yml

echo "Prometheus configuration generated with environment variables"

exec /bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/usr/share/prometheus/console_libraries \
  --web.console.templates=/usr/share/prometheus/consoles