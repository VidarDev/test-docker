#!/bin/sh
set -e

if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo "Aucun certificat trouvé pour ${DOMAIN}, génération d'un certificat auto-signé..."
    
    if [ -z "${DOMAIN}" ] || [ "${DOMAIN}" = "localhost" ]; then
        mkdir -p /etc/nginx/ssl
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/prestashop.key \
            -out /etc/nginx/ssl/prestashop.crt \
            -subj "/C=FR/ST=Hauts-de-France/L=Lille/O=PrestaShop/CN=localhost"
        echo "Certificat auto-signé généré pour localhost"
    else
        echo "Demande d'un certificat Let's Encrypt pour ${DOMAIN}..."
        certbot certonly --standalone \
            --non-interactive --agree-tos \
            --email ${EMAIL} \
            --domains ${DOMAIN} \
            --keep-until-expiring
            
        ln -sf /etc/letsencrypt/live/${DOMAIN}/fullchain.pem /etc/nginx/ssl/prestashop.crt
        ln -sf /etc/letsencrypt/live/${DOMAIN}/privkey.pem /etc/nginx/ssl/prestashop.key
        echo "Certificat Let's Encrypt obtenu pour ${DOMAIN}"
    fi
else
    echo "Certificat existant trouvé pour ${DOMAIN}"
    ln -sf /etc/letsencrypt/live/${DOMAIN}/fullchain.pem /etc/nginx/ssl/prestashop.crt
    ln -sf /etc/letsencrypt/live/${DOMAIN}/privkey.pem /etc/nginx/ssl/prestashop.key
fi

# Démarrer le serveur Nginx
echo "Démarrage de Nginx..."
exec "$@"