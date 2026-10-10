#!/usr/bin/env bash
# ==============================================================================
# Boss Fight: Setup script
# Spawns the Hydra process tree (watchdog + workers) and installs cron persistence.
# Idempotent: cleans previous instances before launching.
# ==============================================================================
set -euo pipefail

echo "⚙️  Setting up Boss Fight: The Hydra Protocol..."

# Clean up any lingering Hydra processes
sudo pkill -9 -f hydra >/dev/null 2>&1 || true
sudo rm -f /etc/cron.d/hydra-respawn
sleep 0.5

sudo mkdir -p /opt/hydra

# 1. Create the CPU worker script
# Uses a controlled math loop with microscopic sleeps to show elevated CPU in top
# without starving host resources.
sudo tee /opt/hydra/hydra-worker.py >/dev/null <<'EOF'
#!/usr/bin/env python3
import time
import math
import sys

def burn_cycles():
    count = 0
    while True:
        # Perform trigonometric computations
        for i in range(15000):
            val = math.sqrt(i) * math.sin(i)
        # Yield briefly so the system remains responsive
        time.sleep(0.005)
        count += 1

if __name__ == "__main__":
    burn_cycles()
EOF
sudo chmod +x /opt/hydra/hydra-worker.py

# 2. Create the parent watchdog that monitors and respawns workers
sudo tee /opt/hydra/hydra-watchdog.sh >/dev/null <<'EOF'
#!/usr/bin/env bash
set -eu

WORKER_SCRIPT="/opt/hydra/hydra-worker.py"
NUM_WORKERS=3

spawn_worker() {
    python3 "${WORKER_SCRIPT}" >/dev/null 2>&1 &
}

# Main supervision loop
while true; do
    CURRENT_COUNT=$(pgrep -f "hydra-worker.py" | wc -l || true)
    while [[ "${CURRENT_COUNT}" -lt "${NUM_WORKERS}" ]]; do
        spawn_worker
        CURRENT_COUNT=$((CURRENT_COUNT + 1))
    done
    sleep 1
done
EOF
sudo chmod +x /opt/hydra/hydra-watchdog.sh

# 3. Create persistence trigger in cron
sudo tee /etc/cron.d/hydra-respawn >/dev/null <<'EOF'
* * * * * root /opt/hydra/hydra-watchdog.sh >/dev/null 2>&1
EOF
sudo chmod 644 /etc/cron.d/hydra-respawn

# 4. Launch watchdog in background
sudo nohup /opt/hydra/hydra-watchdog.sh >/dev/null 2>&1 &

sleep 1
echo "✅ Boss Fight setup complete. The Hydra is consuming CPU cycles!"
