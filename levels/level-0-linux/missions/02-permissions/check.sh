#!/usr/bin/env bash
# ==============================================================================
# Mission 02: Check script
# Verifies execution permissions, strict vault permissions, and deployment success.
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-02"
DEPLOY_SCRIPT="${TARGET_DIR}/deploy.sh"
VAULT_FILE="${TARGET_DIR}/secret_vault.env"
RECORD_FILE="${TARGET_DIR}/deployment.success"

echo "🔍 Verifying Mission 02..."

# 1. Check if deploy.sh is executable
if [[ ! -x "${DEPLOY_SCRIPT}" ]]; then
    echo "❌ Fail: ${DEPLOY_SCRIPT} does not have execute permissions (+x)."
    echo "💡 Hint: Run 'chmod +x ${DEPLOY_SCRIPT}' to make it runnable."
    exit 1
fi

# 2. Check if secret_vault.env has strict 600 permissions
CURRENT_PERMS=$(stat -c "%a" "${VAULT_FILE}" 2>/dev/null || stat -f "%Lp" "${VAULT_FILE}")
if [[ "${CURRENT_PERMS}" != "600" ]]; then
    echo "❌ Fail: ${VAULT_FILE} permissions are ${CURRENT_PERMS}, but must be 600 (-rw-------)."
    echo "💡 Hint: Run 'chmod 600 ${VAULT_FILE}' to restrict access to owner-only read/write."
    exit 1
fi

# 3. Check if deployment.success was created
if [[ ! -f "${RECORD_FILE}" ]]; then
    echo "❌ Fail: ${RECORD_FILE} was not found."
    echo "💡 Hint: After fixing the permissions, run './deploy.sh' inside ${TARGET_DIR}!"
    exit 1
fi

# 4. Check deployment success content
if ! grep -q "DEPLOYMENT_SUCCESSFUL=true" "${RECORD_FILE}"; then
    echo "❌ Fail: ${RECORD_FILE} exists but does not indicate a successful deployment."
    echo "💡 Hint: Try re-running './deploy.sh' to regenerate the status."
    exit 1
fi

echo "🎉 SUCCESS! You mastered file permissions and secured sensitive credentials!"
exit 0
