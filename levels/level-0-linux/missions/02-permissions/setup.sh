#!/usr/bin/env bash
# ==============================================================================
# Mission 02: Setup script
# Generates broken permission scenarios for deploy.sh and secret_vault.env
# Idempotent: safely wipes and reconstructs /home/player/mission-02
# ==============================================================================
set -euo pipefail

TARGET_DIR="/home/player/mission-02"

echo "⚙️  Setting up Mission 02: The Lockdown Incident..."

# Clean previous state
rm -rf "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

# Create secret vault with zero permissions initially
cat <<'EOF' > "${TARGET_DIR}/secret_vault.env"
DATABASE_USER=production_admin
DATABASE_PASS=super_secure_vault_pass_9876
API_KEY=live_key_9948271049281
EOF

# Set secret_vault.env to completely unreadable (0000)
chmod 000 "${TARGET_DIR}/secret_vault.env"

# Create deploy.sh that requires reading the vault
cat <<'EOF' > "${TARGET_DIR}/deploy.sh"
#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="./secret_vault.env"

echo "🚀 Starting automated deployment..."

# Verify the secret file exists
if [[ ! -f "${ENV_FILE}" ]]; then
    echo "❌ Error: ${ENV_FILE} not found."
    exit 1
fi

# Verify secret file permissions (compliance requirement: 600)
CURRENT_PERMS=$(stat -c "%a" "${ENV_FILE}" 2>/dev/null || stat -f "%Lp" "${ENV_FILE}")
if [[ "${CURRENT_PERMS}" != "600" ]]; then
    echo "🚨 SECURITY COMPLIANCE FAILURE!"
    echo "   ${ENV_FILE} permissions are currently ${CURRENT_PERMS}."
    echo "   Compliance policy mandates strictly 600 (-rw-------)."
    exit 2
fi

# Verify secret file can be read
if ! head -n 1 "${ENV_FILE}" >/dev/null 2>&1; then
    echo "❌ Error: Cannot read ${ENV_FILE}. Permission denied."
    exit 3
fi

# Simulate deployment process
echo "📦 Injecting environment credentials..."
echo "✅ Verification passed. Generating deployment record..."
echo "DEPLOYMENT_SUCCESSFUL=true" > ./deployment.success
echo "🎉 Deployment successfully completed!"
EOF

# Explicitly remove execute permission from deploy.sh (simulate developer mistake)
chmod 644 "${TARGET_DIR}/deploy.sh"

echo "✅ Mission 02 setup complete. Inspect files in ${TARGET_DIR}."
