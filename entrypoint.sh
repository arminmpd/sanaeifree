#!/usr/bin/env bash
set -Eeuo pipefail

export PUBLIC_PORT="${PORT:-3000}"
export PANEL_PORT="${PANEL_PORT:-2053}"
export PANEL_PATH="${PANEL_PATH:-panel}"
export XRAY_WS_PORT="${XRAY_WS_PORT:-8080}"
export XRAY_WS_PATH="${XRAY_WS_PATH:-vpn-ws}"
export SUB_PORT="${SUB_PORT:-2096}"

PANEL_PATH="${PANEL_PATH#/}"
PANEL_PATH="${PANEL_PATH%/}"

XRAY_WS_PATH="${XRAY_WS_PATH#/}"
XRAY_WS_PATH="${XRAY_WS_PATH%/}"

echo "Starting official 3x-ui on Railway"
echo "Public port: ${PUBLIC_PORT}"

mkdir -p /etc/x-ui /run/nginx

envsubst \
  '${PUBLIC_PORT} ${PANEL_PORT} ${PANEL_PATH} ${XRAY_WS_PORT} ${XRAY_WS_PATH} ${SUB_PORT}' \
  < /etc/nginx/nginx.conf.template \
  > /etc/nginx/nginx.conf

nginx -t

# اول nginx را اجرا می‌کنیم تا Healthcheck فوراً پاسخ بدهد
nginx

echo "Nginx started; /health is ready."

# سپس 3x-ui را با EntryPoint رسمی خودش اجرا می‌کنیم
exec /app/DockerEntrypoint.sh /app/x-ui
