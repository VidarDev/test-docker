FROM nginx:alpine

RUN apk add --no-cache openssl gettext

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Hauts-de-France/L=Lille/O=PrestaShop/OU=DevOps/CN=localhost"

RUN rm /etc/nginx/conf.d/default.conf

COPY conf/prestashop.template.conf /etc/nginx/conf.d/
COPY init.sh /docker-entrypoint.d/40-envsubst-on-templates.sh

RUN chmod +x /docker-entrypoint.d/40-envsubst-on-templates.sh && \
    chown -R nginx:nginx /etc/nginx/ssl /var/cache/nginx /var/log/nginx /etc/nginx/conf.d

USER nginx