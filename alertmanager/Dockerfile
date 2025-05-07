FROM prom/alertmanager:latest

USER root

RUN apt-get update && \
    apt-get install -y gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY alertmanager.template.yml /etc/alertmanager/
COPY init.sh /bin/init.sh

RUN chmod +x /bin/init.sh

USER 65534:65534

ENTRYPOINT ["/bin/init.sh"]