#!/usr/bin/env bash
# ==============================================================================
# Mission 06: Check script
# Verifies that order-processor is active (running) and configuration is valid.
# ==============================================================================
set -euo pipefail

ENV_FILE="/etc/order-processor/config.env"

echo "🔍 Verifying Mission 06..."

# 1. Verify config exists
if [[ ! -f "${ENV_FILE}" ]]; then
    echo "❌ Fail: ${ENV_FILE} not found."
    exit 1
fi

# 2. Verify PORT was fixed to a numeric port
PORT_VAL=$(grep -E "^PORT=" "${ENV_FILE}" 2>/dev/null | cut -d'=' -f2 | tr -d '[:space:]"' || true)
if [[ -z "${PORT_VAL}" || ! "${PORT_VAL}" =~ ^[0-9]+$ || "${PORT_VAL}" -lt 1024 || "${PORT_VAL}" -gt 65535 ]]; then
    echo "❌ Fail: PORT in ${ENV_FILE} is still invalid ('${PORT_VAL}')."
    echo "💡 Hint: Set PORT to a valid integer between 1024 and 65535 (e.g. PORT=5000)."
    exit 1
fi

# 3. Check service status via systemctl
if ! systemctl is-active order-processor >/dev/null 2>&1; then
    echo "❌ Fail: order-processor.service is not active."
    echo "💡 Hint: Inspect the failure logs with 'journalctl -u order-processor' and"
    echo "   restart the service using 'sudo systemctl restart order-processor'."
    exit 1
fi

echo "🎉 SUCCESS! You diagnosed the service failure with journalctl and restored the service!"
exit 0
