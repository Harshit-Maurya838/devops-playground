#!/usr/bin/env bash
# ==============================================================================
# Mission 05: Check script
# Verifies SSH keypair existence, passwordless key-based login, and file transfer.
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-05"
DOWNLOADED_TOKEN="${TARGET_DIR}/secret_token.txt"
EXPECTED_TOKEN="SECRET_FLAG{ssh_k3y_auth_mast3r_2026}"

echo "🔍 Verifying Mission 05..."

# 1. Check for local SSH private key
if [[ ! -f "/home/player/.ssh/id_ed25519" && ! -f "/home/player/.ssh/id_rsa" ]]; then
    echo "❌ Fail: No SSH keypair found in /home/player/.ssh/."
    echo "💡 Hint: Generate one using 'ssh-keygen -t ed25519'."
    exit 1
fi

# 2. Check for passwordless SSH login (BatchMode=yes fails immediately if password prompt is needed)
echo "🔑 Testing passwordless SSH key authentication to target-server..."
if ! ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 targetuser@target-server "echo ok" >/dev/null 2>&1; then
    echo "❌ Fail: Passwordless SSH login to targetuser@target-server failed."
    echo "💡 Hint: Copy your public key to target-server using:"
    echo "   ssh-copy-id targetuser@target-server"
    echo "   (Initial password: insecure_temp_pass)"
    exit 1
fi

# 3. Check for downloaded secret token file
if [[ ! -f "${DOWNLOADED_TOKEN}" ]]; then
    echo "❌ Fail: ${DOWNLOADED_TOKEN} was not found."
    echo "💡 Hint: Download the token from the target server using scp:"
    echo "   scp targetuser@target-server:/opt/tokens/secret_token.txt ${DOWNLOADED_TOKEN}"
    exit 1
fi

# 4. Verify token content
SUBMITTED_TOKEN=$(tr -d '[:space:]' < "${DOWNLOADED_TOKEN}")
if [[ "${SUBMITTED_TOKEN}" != "${EXPECTED_TOKEN}" ]]; then
    echo "❌ Fail: Downloaded token content does not match expected value."
    exit 1
fi

echo "🎉 SUCCESS! You mastered SSH key generation, remote auth, and scp transfers!"
exit 0
