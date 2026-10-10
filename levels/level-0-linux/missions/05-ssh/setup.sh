#!/usr/bin/env bash
# ==============================================================================
# Mission 05: Setup script
# Resets the SSH target environment and ensures connectivity.
# Idempotent: wipes downloaded token and resets target authorized_keys.
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-05"

echo "⚙️  Setting up Mission 05: The Bastion Gateway..."

rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

# Reset authorized_keys on target server if the volume mount is active
if [[ -d "/var/targetuser-ssh" ]]; then
    sudo rm -f "/var/targetuser-ssh/authorized_keys" || rm -f "/var/targetuser-ssh/authorized_keys" 2>/dev/null || true
fi

# Also test network reachability of target-server port 22
echo "📡 Checking connectivity to target-server:22..."
python3 - <<'EOF'
import socket
import sys
import time

for attempt in range(10):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2.0)
        s.connect(("target-server", 22))
        s.close()
        print("✅ target-server is reachable on port 22.")
        sys.exit(0)
    except Exception as e:
        time.sleep(1)

print("⚠️  Warning: target-server port 22 not reachable yet. Ensure docker compose is running.")
sys.exit(0)
EOF

echo "✅ Mission 05 setup complete. Target host 'target-server' is waiting."
