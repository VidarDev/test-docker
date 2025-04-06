ARG PS_VERSION=8.2.1

FROM prestashop/prestashop:${PS_VERSION} as prestashop

RUN apt-get update && \
    apt-get install -y wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/ps-custom

RUN wget -q https://github.com/PrestaShop/hummingbird/archive/refs/tags/v1.0.0.zip -O /tmp/hummingbird.zip && \
    unzip -q /tmp/hummingbird.zip -d /var/www/html/themes/ && \
    rm /tmp/hummingbird.zip

RUN php /var/www/html/bin/console prestashop:language:add fr