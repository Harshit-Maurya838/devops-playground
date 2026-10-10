#!/usr/bin/env bash
# ==============================================================================
# Boss Fight: Check script
# Verifies all Hydra processes are killed, cron persistence removed, and no respawn.
# ==============================================================================
set -euo pipefail

CRON_FILE="/etc/cron.d/hydra-respawn"

echo "🔍 Verifying Boss Fight: The Hydra Protocol..."

# 1. Check for cron persistence
if [[ -f "${CRON_FILE}" ]]; then
    echo "❌ Fail: The persistence mechanism is still active at ${CRON_FILE}!"
    echo "💡 Hint: Remove the cron trigger using 'sudo rm -f ${CRON_FILE}'."
    exit 1
fi

# 2. Check for active Hydra processes
if pgrep -f "hydra" >/dev/null 2>&1; then
    COUNT=$(pgrep -f "hydra" | wc -l || true)
    echo "❌ Fail: There are still ${COUNT} active Hydra process(es) running!"
    echo "💡 Hint: Terminate the entire process tree with 'sudo pkill -9 -f hydra'."
    exit 1
fi

# 3. Liveness verification check (ensure it does not respawn)
echo "⏳ Monitoring system stability for 2 seconds..."
sleep 2

if pgrep -f "hydra" >/dev/null 2>&1; then
    echo "❌ Fail: The Hydra resurrected! You must kill the watchdog AND remove the cron trigger."
    exit 1
fi

echo "🏆 VICTORY! You completely eradicated the Hydra process tree and defeated the Level 0 Boss!"
exit 0
