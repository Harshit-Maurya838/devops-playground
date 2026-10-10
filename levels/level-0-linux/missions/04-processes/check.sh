#!/usr/bin/env bash
# ==============================================================================
# Mission 04: Check script
# Verifies that port_bandit is terminated and port 8080 is accessible.
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-04"

echo "🔍 Verifying Mission 04..."

# 1. Verify port_bandit process is terminated
if pgrep -f "port_bandit.py" >/dev/null 2>&1; then
    echo "❌ Fail: The 'port_bandit' process is still alive and running!"
    echo "💡 Hint: Identify its PID using 'ps aux | grep port_bandit' and kill it with 'kill -9 <PID>'."
    exit 1
fi

# 2. Verify port 8080 is free
if ss -tulpn 2>/dev/null | grep -q ":8080 "; then
    echo "❌ Fail: Port 8080 is still in use by another process."
    echo "💡 Hint: Check 'ss -tulpn | grep 8080' or 'lsof -i :8080'."
    exit 1
fi

# 3. Test binding to port 8080 using the gateway script
if [[ -f "${TARGET_DIR}/start_gateway.sh" ]]; then
    if ! "${TARGET_DIR}/start_gateway.sh" >/dev/null 2>&1; then
        echo "❌ Fail: Gateway startup script failed to bind to port 8080."
        exit 1
    fi
fi

echo "🎉 SUCCESS! You mastered process inspection, signal killing, and freed port 8080!"
exit 0
