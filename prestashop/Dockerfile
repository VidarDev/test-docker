FROM prestashop/prestashop:latest

RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

ENV PS_LANGUAGE=fr
ENV PS_COUNTRY=FR

USER www-data

EXPOSE 80