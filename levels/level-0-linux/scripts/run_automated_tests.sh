#!/usr/bin/env bash
# ==============================================================================
# DevOps Playground - Level 0 Automated Verification Test Suite
# Tests initial failure, solution pass, and idempotency for all missions.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${SCRIPT_DIR}"

GREEN="\033[1;32m"
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

pass_count=0
fail_count=0

assert_fails() {
    local cmd="$1"
    local desc="$2"
    echo -n "  Testing EXPECTED FAILURE: ${desc}... "
    if eval "${cmd}" >/dev/null 2>&1; then
        echo -e "${RED}[FAILED] (command unexpectedly passed)${RESET}"
        fail_count=$((fail_count + 1))
    else
        echo -e "${GREEN}[OK]${RESET}"
        pass_count=$((pass_count + 1))
    fi
}

assert_passes() {
    local cmd="$1"
    local desc="$2"
    echo -n "  Testing EXPECTED PASS: ${desc}... "
    if eval "${cmd}" >/dev/null 2>&1; then
        echo -e "${GREEN}[OK]${RESET}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}[FAILED]${RESET}"
        fail_count=$((fail_count + 1))
    fi
}

echo -e "${CYAN}================================================================${RESET}"
echo -e "${CYAN}🚀 Running Level 0 Automated Verification Suite${RESET}"
echo -e "${CYAN}================================================================${RESET}"

# Ensure fresh progress
rm -f "${SCRIPT_DIR}/progress.json"

# --- Mission 01 ---
echo -e "\n${YELLOW}▶ Testing Mission 01: 01-navigate${RESET}"
"${SCRIPT_DIR}/play.sh" start 01 >/dev/null
assert_fails "${SCRIPT_DIR}/missions/01-navigate/check.sh" "Unsolved state"
# Solve
find /home/player/mission-01 -name ".credential_key" -exec cat {} + > /home/player/mission-01/solution.txt
assert_passes "${SCRIPT_DIR}/missions/01-navigate/check.sh" "Solved state"
# Check via play.sh
assert_passes "${SCRIPT_DIR}/play.sh check" "play.sh check awards XP"

# --- Mission 02 ---
echo -e "\n${YELLOW}▶ Testing Mission 02: 02-permissions${RESET}"
"${SCRIPT_DIR}/play.sh" start 02 >/dev/null
assert_fails "${SCRIPT_DIR}/missions/02-permissions/check.sh" "Unsolved state"
# Solve
chmod +x /home/player/mission-02/deploy.sh
chmod 600 /home/player/mission-02/secret_vault.env
/home/player/mission-02/deploy.sh >/dev/null
assert_passes "${SCRIPT_DIR}/missions/02-permissions/check.sh" "Solved state"
assert_passes "${SCRIPT_DIR}/play.sh check" "play.sh check awards XP"

# --- Mission 03 ---
echo -e "\n${YELLOW}▶ Testing Mission 03: 03-text-detective${RESET}"
"${SCRIPT_DIR}/play.sh" start 03 >/dev/null
assert_fails "${SCRIPT_DIR}/missions/03-text-detective/check.sh" "Unsolved state"
# Solve
cat <<'EOF' > /home/player/mission-03/investigation.txt
ROGUE_IP=10.240.88.199
OCCURRENCE_COUNT=17
EOF
assert_passes "${SCRIPT_DIR}/missions/03-text-detective/check.sh" "Solved state"
assert_passes "${SCRIPT_DIR}/play.sh check" "play.sh check awards XP"

# --- Mission 04 ---
echo -e "\n${YELLOW}▶ Testing Mission 04: 04-processes${RESET}"
"${SCRIPT_DIR}/play.sh" start 04 >/dev/null
assert_fails "${SCRIPT_DIR}/missions/04-processes/check.sh" "Unsolved state"
# Solve
pkill -9 -f port_bandit || true
/home/player/mission-04/start_gateway.sh >/dev/null
assert_passes "${SCRIPT_DIR}/missions/04-processes/check.sh" "Solved state"
assert_passes "${SCRIPT_DIR}/play.sh check" "play.sh check awards XP"

# --- Mission 05 ---
echo -e "\n${YELLOW}▶ Testing Mission 05: 05-ssh${RESET}"
"${SCRIPT_DIR}/play.sh" start 05 >/dev/null
if python3 -c 'import socket; s = socket.create_connection(("target-server", 22), timeout=2)' >/dev/null 2>&1; then
    assert_fails "${SCRIPT_DIR}/missions/05-ssh/check.sh" "Unsolved state"
    mkdir -p /home/player/.ssh
    if [[ ! -f /home/player/.ssh/id_ed25519 ]]; then
        ssh-keygen -t ed25519 -N "" -f /home/player/.ssh/id_ed25519 >/dev/null
    fi
    sshpass -p insecure_temp_pass ssh-copy-id -o StrictHostKeyChecking=no targetuser@target-server >/dev/null 2>&1 || true
    scp -o StrictHostKeyChecking=no targetuser@target-server:/opt/tokens/secret_token.txt /home/player/mission-05/secret_token.txt >/dev/null 2>&1 || true
    assert_passes "${SCRIPT_DIR}/missions/05-ssh/check.sh" "Solved state"
    assert_passes "${SCRIPT_DIR}/play.sh check" "play.sh check awards XP"
else
    echo "  [SKIP] target-server ssh container not online in standalone host mode"
fi

# --- Mission 06 ---
echo -e "\n${YELLOW}▶ Testing Mission 06: 06-services${RESET}"
"${SCRIPT_DIR}/play.sh" start 06 >/dev/null
assert_fails "${SCRIPT_DIR}/missions/06-services/check.sh" "Unsolved state"
# Solve
sed -i 's/PORT=INVALID_PORT_ABC/PORT=5000/' /etc/order-processor/config.env
sudo systemctl restart order-processor >/dev/null 2>&1 || systemctl restart order-processor >/dev/null 2>&1 || true
sleep 1
assert_passes "${SCRIPT_DIR}/missions/06-services/check.sh" "Solved state"
assert_passes "${SCRIPT_DIR}/play.sh check" "play.sh check awards XP"

# --- Boss Fight ---
echo -e "\n${YELLOW}▶ Testing Boss Fight: boss-cpu-hog${RESET}"
"${SCRIPT_DIR}/play.sh" start boss >/dev/null
assert_fails "${SCRIPT_DIR}/missions/boss-cpu-hog/check.sh" "Unsolved state"
# Solve
sudo rm -f /etc/cron.d/hydra-respawn || rm -f /etc/cron.d/hydra-respawn 2>/dev/null || true
sudo pkill -9 -f hydra || pkill -9 -f hydra 2>/dev/null || true
sleep 0.5
assert_passes "${SCRIPT_DIR}/missions/boss-cpu-hog/check.sh" "Solved state"
assert_passes "${SCRIPT_DIR}/play.sh check" "play.sh check awards XP"

echo ""
echo -e "${CYAN}================================================================${RESET}"
echo -e "Test Results: ${GREEN}${pass_count} Passed${RESET}, ${RED}${fail_count} Failed${RESET}"
echo -e "${CYAN}================================================================${RESET}"

if [[ "${fail_count}" -eq 0 ]]; then
    exit 0
else
    exit 1
fi
