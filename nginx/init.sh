#!/bin/bash
set -e

envsubst < /etc/nginx/conf.d/prestashop.template.conf > /etc/nginx/conf.d/prestashop.conf

echo "NGINX configuration generated with environment variables"