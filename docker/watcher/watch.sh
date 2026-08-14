#!/bin/sh
set -e

echo "[watcher] Starting Config Watcher..."
echo "[watcher] Waiting for services to initialize..."

until curl -s http://prometheus:9090/-/ready > /dev/null 2>&1; do
  echo "[watcher] Waiting for Prometheus..."
  sleep 2
done

echo "[watcher] Prometheus is ready. Monitoring /config for file changes..."

CONFIG_DIR="/config"

inotifywait -m -r -e modify,create,delete,moved_to,close_write "$CONFIG_DIR" 2>/dev/null | while read -r path action file; do
    echo "[watcher] Change detected: ${path}${file} [${action}]"
    
    # Debounce brief write bursts
    sleep 1
    
    # Trigger Prometheus config reload
    echo "[watcher] Sending reload to Prometheus..."
    PROM_RESP=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://prometheus:9090/-/reload || true)
    if [ "$PROM_RESP" = "200" ]; then
        echo "[watcher] SUCCESS: Prometheus config reloaded (HTTP 200)"
    else
        echo "[watcher] WARNING: Prometheus reload returned HTTP ${PROM_RESP}"
    fi

    # Trigger Blackbox Exporter config reload
    echo "[watcher] Sending reload to Blackbox Exporter..."
    BB_RESP=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://blackbox-exporter:9115/-/reload || true)
    if [ "$BB_RESP" = "200" ]; then
        echo "[watcher] SUCCESS: Blackbox Exporter config reloaded (HTTP 200)"
    else
        echo "[watcher] WARNING: Blackbox Exporter reload returned HTTP ${BB_RESP}"
    fi
done
