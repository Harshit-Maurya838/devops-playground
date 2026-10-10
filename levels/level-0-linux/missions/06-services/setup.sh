#!/usr/bin/env bash
# ==============================================================================
# Mission 06: Setup script
# Configures the order-processor service in a failing state.
# Idempotent: cleanly resets configs, services, and log streams.
# ==============================================================================
set -euo pipefail

echo "⚙️  Setting up Mission 06: Service Doctor..."

# 1. Install service manager wrapper into /usr/local/bin if needed
if [[ -f "/game/scripts/service_manager.py" ]]; then
    sudo chmod +x /game/scripts/service_manager.py
    sudo ln -sf /game/scripts/service_manager.py /usr/local/bin/systemctl
    sudo ln -sf /game/scripts/service_manager.py /usr/local/bin/journalctl
fi

# Stop existing service if running
systemctl stop order-processor >/dev/null 2>&1 || true

# 2. Deploy service executable
sudo mkdir -p /usr/local/bin
sudo tee /usr/local/bin/order-processor >/dev/null <<'EOF'
#!/usr/bin/env python3
import os
import sys
import time

port_str = os.environ.get("PORT", "")
print(f"[INFO] Initializing Order Processing Backend...")
print(f"[INFO] Loading configuration environment...")

if not port_str.isdigit() or not (1024 <= int(port_str) <= 65535):
    sys.stderr.write(f"[CRITICAL] Configuration parse error: PORT must be a valid integer between 1024 and 65535. Current value: '{port_str}'\n")
    sys.stderr.write(f"[CRITICAL] Service failed to bind to configured socket. Aborting startup.\n")
    sys.exit(1)

port = int(port_str)
print(f"[INFO] Order processor daemon listening on port {port}...")
print(f"[INFO] Ready to ingest transactions. Healthy status: OK.")

# Stay alive processing transactions
while True:
    time.sleep(2)
EOF
sudo chmod +x /usr/local/bin/order-processor

# 3. Deploy broken configuration file
sudo mkdir -p /etc/order-processor
sudo tee /etc/order-processor/config.env >/dev/null <<'EOF'
# Order Processor Environment Configuration
APP_ENV=production
# BUG: PORT must be an integer between 1024 and 65535
PORT=INVALID_PORT_ABC
DB_HOST=127.0.0.1
LOG_LEVEL=DEBUG
EOF

# Grant write permissions for student editing with sudo or player
sudo chown -R player:player /etc/order-processor
sudo chmod 664 /etc/order-processor/config.env

# 4. Deploy systemd unit file
sudo mkdir -p /etc/systemd/system
sudo tee /etc/systemd/system/order-processor.service >/dev/null <<'EOF'
[Unit]
Description=Order Processing Backend Service
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/order-processor/config.env
ExecStart=/usr/local/bin/order-processor
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reset logs for unit
sudo rm -f /var/log/journal/order-processor.service.log

# 5. Attempt startup to trigger the initial failure state
systemctl start order-processor >/dev/null 2>&1 || true

echo "✅ Mission 06 setup complete. 'order-processor.service' has been deployed and triggered."
