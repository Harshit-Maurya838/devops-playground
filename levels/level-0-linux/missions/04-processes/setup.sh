#!/usr/bin/env bash
# ==============================================================================
# Mission 04: Setup script
# Launches port_bandit background process listening on port 8080.
# Idempotent: cleans up previous processes and restarts the bandit.
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-04"

echo "⚙️  Setting up Mission 04: Port Bandit..."

# Clean up any lingering processes from previous runs
pkill -9 -f port_bandit 2>/dev/null || true
sleep 0.5

rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

# Create the stubborn background daemon
cat <<'EOF' > "${TARGET_DIR}/port_bandit.py"
import socket
import signal
import time
import sys

# Stubbornly ignore SIGTERM (signal 15) to teach signal 9 (SIGKILL)
def ignore_sigterm(signum, frame):
    sys.stderr.write("\n[port_bandit] Received SIGTERM (15)! Ignoring... Only SIGKILL (-9) can stop me!\n")
    sys.stderr.flush()

signal.signal(signal.SIGTERM, ignore_sigterm)

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

try:
    server.bind(("0.0.0.0", 8080))
    server.listen(5)
    sys.stdout.write("[port_bandit] Successfully bound to port 8080.\n")
    sys.stdout.flush()
    while True:
        time.sleep(1)
except Exception as e:
    sys.stderr.write(f"[port_bandit] Error: {e}\n")
    sys.exit(1)
EOF

# Create the gateway startup script for the learner to test
cat <<'EOF' > "${TARGET_DIR}/start_gateway.sh"
#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Attempting to initialize API Gateway on port 8080..."

python3 - <<'PYEOF'
import socket
import sys

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

try:
    sock.bind(("0.0.0.0", 8080))
    sock.close()
    print("✅ Port 8080 is FREE! Gateway socket initialized successfully.")
    with open("/home/player/mission-04/gateway_ready.flag", "w") as f:
        f.write("GATEWAY_ACTIVE_PORT_8080\n")
    sys.exit(0)
except OSError as e:
    print(f"❌ Failed to bind to port 8080: {e}")
    print("🚨 A process is still listening on port 8080! Find and kill it.")
    sys.exit(1)
PYEOF
EOF

chmod +x "${TARGET_DIR}/start_gateway.sh"

# Launch port_bandit in the background detached
nohup python3 "${TARGET_DIR}/port_bandit.py" >/dev/null 2>&1 &

# Brief pause to ensure socket bind has settled
sleep 0.5

echo "✅ Mission 04 setup complete. A rogue process is currently occupying port 8080."
