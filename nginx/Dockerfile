FROM nginx:alpine

RUN apk add --no-cache python3 py3-pip certbot certbot-nginx openssl

RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp \
             /var/run/nginx

RUN chmod 700 /var/cache/nginx/* /var/run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx

RUN mkdir -p /var/www/certbot /etc/letsencrypt /etc/nginx/ssl && \
    chown -R nginx:nginx /etc/nginx/ssl

COPY ./renew-certs.sh /usr/local/bin/renew-certs.sh
RUN chmod +x /usr/local/bin/renew-certs.sh

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN sed -i 's/user nginx;/#user nginx;/' /etc/nginx/nginx.conf && \
    sed -i 's#/var/run/#/var/run/nginx/#g' /etc/nginx/nginx.conf

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]