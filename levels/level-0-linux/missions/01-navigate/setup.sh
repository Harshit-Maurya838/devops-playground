#!/usr/bin/env bash
# ==============================================================================
# Mission 01: Setup script
# Generates the directory labyrinth and hides the credential key.
# Idempotent: safely wipes and rebuilds /home/player/mission-01
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-01"

echo "⚙️  Setting up Mission 01: The Lost Artifact..."

# Ensure a clean slate
rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

# Build labyrinth hierarchy
mkdir -p "${TARGET_DIR}/sector_alpha/node_01/cache"
mkdir -p "${TARGET_DIR}/sector_alpha/node_02/logs"
mkdir -p "${TARGET_DIR}/sector_bravo/backups/daily"
mkdir -p "${TARGET_DIR}/sector_bravo/backups/weekly"
mkdir -p "${TARGET_DIR}/sector_charlie/.deep_vault/archive/legacy_storage"
mkdir -p "${TARGET_DIR}/sector_delta/empty_corridor"

# Create decoy files
echo "Nothing to see here, keep looking!" > "${TARGET_DIR}/sector_alpha/node_01/cache/decoy.txt"
echo "Log rotated at 04:00 AM." > "${TARGET_DIR}/sector_alpha/node_02/logs/system.log"
echo "Dummy backup payload" > "${TARGET_DIR}/sector_bravo/backups/daily/data.bin"
echo "FAKECREDENTIAL{almost_but_not_quite}" > "${TARGET_DIR}/sector_bravo/backups/weekly/.decoy_key"
echo "Welcome to the labyrinth. Use your tools wisely." > "${TARGET_DIR}/README.txt"

# Plant the authentic hidden credential key
TARGET_FILE="${TARGET_DIR}/sector_charlie/.deep_vault/archive/legacy_storage/.credential_key"
echo "TOKEN{lost_in_th3_sh3ll_found_by_f1nd_9921}" > "${TARGET_FILE}"

# Set permissions
chmod 644 "${TARGET_FILE}"

echo "✅ Mission 01 setup complete. Navigate to ${TARGET_DIR} to begin!"
