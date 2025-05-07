#!/bin/bash
set -e

envsubst < /etc/alertmanager/alertmanager.template.yml > /etc/alertmanager/alertmanager.yml

echo "Alertmanager configuration generated with environment variables"

exec /bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/alertmanager