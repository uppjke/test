#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
PID_FILE="/var/run/monitoring_test.pid"
PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

CURRENT_PID=$(pgrep -x "$PROCESS_NAME")

if [ -z "$CURRENT_PID" ]; then
    [ -f "$PID_FILE" ] && rm -f "$PID_FILE"
    exit 0
fi

if [ -f "$PID_FILE" ]; then
    PREVIOUS_PID=$(cat "$PID_FILE")
    if [ "$CURRENT_PID" != "$PREVIOUS_PID" ]; then
        log_message "Процесс $PROCESS_NAME перезапущен. Новый PID: $CURRENT_PID"
    fi
else
    echo "$CURRENT_PID" > "$PID_FILE"
fi

echo "$CURRENT_PID" > "$PID_FILE"

if ! curl -s -o /dev/null --max-time 10 "$MONITORING_URL"; then
    log_message "Сервер мониторинга недоступен: $MONITORING_URL"
fi

exit 0
