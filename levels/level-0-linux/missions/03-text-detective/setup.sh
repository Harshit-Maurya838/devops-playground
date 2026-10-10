#!/usr/bin/env bash
# ==============================================================================
# Mission 03: Setup script
# Generates a realistic 50,000-line web access log with embedded security events.
# Idempotent: completely resets /home/player/mission-03
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-03"
LOG_FILE="${TARGET_DIR}/access.log"

echo "⚙️  Setting up Mission 03: Text Detective..."

rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

echo "📝 Generating 50,000-line access.log (please wait a moment)..."

# Generate deterministic log file rapidly using python3
python3 - <<'EOF'
import random

target_path = "/home/player/mission-03/access.log"
random.seed(42)  # Deterministic seed

ips = [
    "192.168.1.10", "192.168.1.25", "192.168.1.44",
    "172.16.0.5", "172.16.0.12", "10.0.1.50"
]
endpoints = [
    "/index.html", "/api/v1/health", "/static/logo.png",
    "/dashboard", "/api/v1/catalog", "/auth/status"
]
statuses = [200, 200, 200, 200, 304, 404]

# Rogue event settings
breach_ip = "10.240.88.199"
breach_indices = {
    1204, 3812, 7920, 11400, 14592, 18991, 22104,
    26450, 29801, 33140, 37210, 40590, 42100, 45600,
    47890, 49120, 49950
}

with open(target_path, "w") as f:
    for i in range(50000):
        if i in breach_indices:
            line = f"2026-10-11T01:{i%60:02d}:00Z IP={breach_ip} STATUS=500 MSG=\"ALERT_UNAUTHORIZED_DATABASE_DUMP table=users attempt={i}\"\n"
        else:
            ip = ips[i % len(ips)]
            ep = endpoints[i % len(endpoints)]
            st = statuses[i % len(statuses)]
            line = f"2026-10-11T00:{i%60:02d}:{(i*7)%60:02d}Z IP={ip} STATUS={st} MSG=\"GET {ep} HTTP/1.1\"\n"
        f.write(line)

print(f"Log generated successfully: 50,000 lines written.")
EOF

echo "✅ Mission 03 setup complete. Log created at ${LOG_FILE}."
