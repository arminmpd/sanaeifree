FROM ghcr.io/mhsanaei/3x-ui:latest

USER root

RUN apk add --no-cache \
    nginx \
    gettext \
    bash

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh \
    && mkdir -p /run/nginx /etc/x-ui

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
