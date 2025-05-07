FROM prestashop/prestashop:latest

USER root
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 prestashop && \
    useradd -u 1000 -g prestashop -s /bin/bash -m prestashop

WORKDIR /var/www/html
RUN mkdir -p /tmp/ps-theme && \
    chown -R prestashop:prestashop /var/www/html /tmp

COPY --chown=prestashop:prestashop init-prestashop.sh /tmp/
RUN chmod +x /tmp/init-prestashop.sh

USER prestashop

ENTRYPOINT ["/tmp/init-prestashop.sh"]