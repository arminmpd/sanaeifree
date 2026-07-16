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

echo "======================================"
echo "Starting official 3x-ui on Railway"
echo "Public port: ${PUBLIC_PORT}"
echo "Panel port: ${PANEL_PORT}"
echo "Panel path: /${PANEL_PATH}/"
echo "WS port: ${XRAY_WS_PORT}"
echo "WS path: /${XRAY_WS_PATH}"
echo "======================================"

mkdir -p /etc/x-ui /run/nginx

envsubst '${PUBLIC_PORT} ${PANEL_PORT} ${PANEL_PATH} ${XRAY_WS_PORT} ${XRAY_WS_PATH} ${SUB_PORT}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

echo "Testing nginx configuration..."
nginx -t

echo "Starting official 3x-ui..."
/app/x-ui &
XUI_PID=$!

cleanup() {
    echo "Stopping services..."
    nginx -s quit 2>/dev/null || true
    kill "${XUI_PID}" 2>/dev/null || true
    wait "${XUI_PID}" 2>/dev/null || true
}

trap cleanup SIGTERM SIGINT EXIT

echo "Waiting for 3x-ui panel..."
for i in $(seq 1 60); do
    if curl -fsS --max-time 2 "http://127.0.0.1:${PANEL_PORT}/" >/dev/null 2>&1; then
        echo "3x-ui panel is ready."
        break
    fi

    if ! kill -0 "${XUI_PID}" 2>/dev/null; then
        echo "ERROR: 3x-ui stopped unexpectedly."
        wait "${XUI_PID}"
        exit 1
    fi

    sleep 1
done

echo "Starting nginx..."
nginx

while true; do
    if ! kill -0 "${XUI_PID}" 2>/dev/null; then
        echo "ERROR: 3x-ui process stopped."
        wait "${XUI_PID}"
        exit 1
    fi

    if ! pgrep -x nginx >/dev/null 2>&1; then
        echo "ERROR: nginx process stopped."
        exit 1
    fi

    sleep 5
done
