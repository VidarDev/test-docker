#!/bin/sh
set -e

certbot renew --quiet

nginx -s reload