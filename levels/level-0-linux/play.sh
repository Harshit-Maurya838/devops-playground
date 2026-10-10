#!/usr/bin/env bash
# ==============================================================================
# DevOps Playground - Level 0: Linux & The Terminal
# Interactive Game CLI Runner (play.sh)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_FILE="${SCRIPT_DIR}/progress.json"

# ANSI Color definitions
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
RESET="\033[0m"

# Mission metadata definition (Folder | Name | XP)
MISSIONS=(
    "01-navigate|The Lost Artifact|50"
    "02-permissions|The Lockdown Incident|50"
    "03-text-detective|Log Sleuth|50"
    "04-processes|Port Bandit|50"
    "05-ssh|The Bastion Gateway|50"
    "06-services|Service Doctor|50"
    "boss-cpu-hog|The Hydra Protocol (BOSS FIGHT)|150"
)

# ------------------------------------------------------------------------------
# Python JSON Helper Functions
# ------------------------------------------------------------------------------
init_progress() {
    if [[ ! -f "${PROGRESS_FILE}" ]]; then
        python3 - <<'EOF'
import json

progress = {
    "total_xp": 0,
    "max_xp": 450,
    "current_mission": "01-navigate",
    "missions": {
        "01-navigate": {"status": "available", "xp": 50, "hint_level": 0, "completed_at": None},
        "02-permissions": {"status": "locked", "xp": 50, "hint_level": 0, "completed_at": None},
        "03-text-detective": {"status": "locked", "xp": 50, "hint_level": 0, "completed_at": None},
        "04-processes": {"status": "locked", "xp": 50, "hint_level": 0, "completed_at": None},
        "05-ssh": {"status": "locked", "xp": 50, "hint_level": 0, "completed_at": None},
        "06-services": {"status": "locked", "xp": 50, "hint_level": 0, "completed_at": None},
        "boss-cpu-hog": {"status": "locked", "xp": 150, "hint_level": 0, "completed_at": None}
    }
}

with open("progress.json", "w") as f:
    json.dump(progress, f, indent=2)
EOF
    fi
}

get_current_mission() {
    python3 -c "
import json
with open('${PROGRESS_FILE}') as f:
    data = json.load(f)
print(data.get('current_mission', '01-navigate'))
"
}

get_total_xp() {
    python3 -c "
import json
with open('${PROGRESS_FILE}') as f:
    data = json.load(f)
print(data.get('total_xp', 0))
"
}

set_current_mission() {
    local target="$1"
    python3 -c "
import json
with open('${PROGRESS_FILE}', 'r') as f:
    data = json.load(f)
data['current_mission'] = '${target}'
if data['missions']['${target}']['status'] == 'locked':
    data['missions']['${target}']['status'] = 'in_progress'
with open('${PROGRESS_FILE}', 'w') as f:
    json.dump(data, f, indent=2)
"
}

mark_mission_complete() {
    local target="$1"
    local xp_award="$2"
    python3 -c "
import json, datetime
with open('${PROGRESS_FILE}', 'r') as f:
    data = json.load(f)

already_done = data['missions']['${target}']['status'] == 'completed'
if not already_done:
    data['missions']['${target}']['status'] = 'completed'
    data['missions']['${target}']['completed_at'] = datetime.datetime.utcnow().isoformat() + 'Z'
    data['total_xp'] += ${xp_award}

# Unlock next mission if available
mission_keys = [
    '01-navigate', '02-permissions', '03-text-detective',
    '04-processes', '05-ssh', '06-services', 'boss-cpu-hog'
]
if '${target}' in mission_keys:
    idx = mission_keys.index('${target}')
    if idx + 1 < len(mission_keys):
        next_m = mission_keys[idx + 1]
        if data['missions'][next_m]['status'] == 'locked':
            data['missions'][next_m]['status'] = 'available'
        data['current_mission'] = next_m

with open('${PROGRESS_FILE}', 'w') as f:
    json.dump(data, f, indent=2)
"
}

increment_hint_level() {
    local target="$1"
    python3 -c "
import json
with open('${PROGRESS_FILE}', 'r') as f:
    data = json.load(f)
lvl = data['missions']['${target}'].get('hint_level', 0)
if lvl < 3:
    lvl += 1
data['missions']['${target}']['hint_level'] = lvl
with open('${PROGRESS_FILE}', 'w') as f:
    json.dump(data, f, indent=2)
print(lvl)
"
}

get_hint_level() {
    local target="$1"
    python3 -c "
import json
with open('${PROGRESS_FILE}', 'r') as f:
    data = json.load(f)
print(data['missions']['${target}'].get('hint_level', 0))
"
}

# ------------------------------------------------------------------------------
# UI Helpers
# ------------------------------------------------------------------------------
banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ╔════════════════════════════════════════════════════════════════╗"
    echo "  ║        🕹️   DEVOPS PLAYGROUND — LEVEL 0: LINUX & SHELL         ║"
    echo "  ╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

print_progress_bar() {
    local xp="$1"
    local total=450
    local width=25
    local percent=$(( (xp * 100) / total ))
    local filled=$(( (xp * width) / total ))
    local empty=$(( width - filled ))

    printf "  XP Progress: ["
    printf "%0.s=" $(seq 1 $filled 2>/dev/null || true)
    if [ $filled -lt $width ]; then printf ">"; fi
    printf "%0.s " $(seq 1 $((empty - 1)) 2>/dev/null || true)
    printf "] %d%% (${xp} / ${total} XP)\n\n" "$percent"
}

normalize_mission_id() {
    local input="$1"
    case "${input}" in
        1|"01"|"nav"|"navigate") echo "01-navigate" ;;
        2|"02"|"perm"|"permissions") echo "02-permissions" ;;
        3|"03"|"text"|"text-detective") echo "03-text-detective" ;;
        4|"04"|"proc"|"processes") echo "04-processes" ;;
        5|"05"|"ssh") echo "05-ssh" ;;
        6|"06"|"service"|"services") echo "06-services" ;;
        7|"boss"|"cpu"|"boss-cpu-hog") echo "boss-cpu-hog" ;;
        *) echo "${input}" ;;
    esac
}

# ------------------------------------------------------------------------------
# Command Handlers
# ------------------------------------------------------------------------------
cmd_status() {
    banner
    local total_xp
    total_xp=$(get_total_xp)
    print_progress_bar "${total_xp}"

    local current_m
    current_m=$(get_current_mission)

    echo -e "${BOLD}Missions Roadmap:${RESET}"
    for entry in "${MISSIONS[@]}"; do
        IFS='|' read -r m_id m_name m_xp <<< "${entry}"
        local status
        status=$(python3 -c "
import json
with open('${PROGRESS_FILE}') as f:
    d = json.load(f)
print(d['missions']['${m_id}']['status'])
")
        local mark="[ ]"
        local color="${RESET}"
        if [[ "${status}" == "completed" ]]; then
            mark="[✔]"
            color="${GREEN}"
        elif [[ "${m_id}" == "${current_m}" ]]; then
            mark="[▶]"
            color="${YELLOW}${BOLD}"
        elif [[ "${status}" == "available" ]]; then
            mark="[•]"
            color="${CYAN}"
        else
            mark="[🔒]"
            color="\033[2m"
        fi

        printf "  ${color}%s %-16s %-32s (%s XP)${RESET}\n" "${mark}" "${m_id}" "${m_name}" "${m_xp}"
    done
    echo ""

    echo -e "${BOLD}Current Active Mission:${RESET} ${YELLOW}${current_m}${RESET}"
    echo -e "Available commands:"
    echo -e "  ${BOLD}./play.sh start [id]${RESET}  - Setup and begin a mission"
    echo -e "  ${BOLD}./play.sh check${RESET}       - Verify your solution and earn XP"
    echo -e "  ${BOLD}./play.sh hint${RESET}        - Get progressive hints (1 to 3)"
    echo -e "  ${BOLD}./play.sh reset${RESET}       - Reset current mission environment"
    echo -e "  ${BOLD}./play.sh solution${RESET}    - View the complete solution guide"
    echo ""
}

cmd_start() {
    local target="${1:-$(get_current_mission)}"
    target=$(normalize_mission_id "${target}")

    local mission_dir="${SCRIPT_DIR}/missions/${target}"
    if [[ ! -d "${mission_dir}" ]]; then
        echo -e "${RED}❌ Unknown mission '${target}'. Run './play.sh status' to view all missions.${RESET}"
        exit 1
    fi

    set_current_mission "${target}"
    echo -e "${CYAN}🚀 Initializing ${BOLD}${target}${RESET}..."

    # Run the mission setup script
    if [[ -f "${mission_dir}/setup.sh" ]]; then
        chmod +x "${mission_dir}/setup.sh"
        "${mission_dir}/setup.sh"
    fi

    echo ""
    # Display the mission briefing
    if [[ -f "${mission_dir}/mission.md" ]]; then
        echo -e "${BOLD}${MAGENTA}--- MISSION BRIEFING ---${RESET}"
        cat "${mission_dir}/mission.md"
        echo -e "${BOLD}${MAGENTA}------------------------${RESET}"
    fi

    echo ""
    echo -e "${GREEN}✨ Mission environment is ready!${RESET}"
    echo -e "Follow the instructions above, then test your fix with: ${BOLD}./play.sh check${RESET}"
}

cmd_check() {
    local current_m
    current_m=$(get_current_mission)
    local mission_dir="${SCRIPT_DIR}/missions/${current_m}"

    if [[ ! -f "${mission_dir}/check.sh" ]]; then
        echo -e "${RED}❌ check.sh not found for ${current_m}.${RESET}"
        exit 1
    fi

    chmod +x "${mission_dir}/check.sh"
    echo -e "${BLUE}🔍 Evaluating current state for: ${BOLD}${current_m}${RESET}..."
    echo ""

    if "${mission_dir}/check.sh"; then
        # Determine XP reward
        local award=50
        if [[ "${current_m}" == "boss-cpu-hog" ]]; then
            award=150
        fi

        mark_mission_complete "${current_m}" "${award}"

        local new_xp
        new_xp=$(get_total_xp)

        echo ""
        echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════════${RESET}"
        echo -e "${GREEN}${BOLD}🎉 MISSION PASSED! +${award} XP Awarded! Total XP: ${new_xp} / 450${RESET}"
        echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════════════${RESET}"

        local next_m
        next_m=$(get_current_mission)
        if [[ "${next_m}" != "${current_m}" ]]; then
            echo -e "Next mission unlocked: ${YELLOW}${BOLD}${next_m}${RESET}!"
            echo -e "Type ${BOLD}./play.sh start${RESET} to jump right in."
        else
            echo -e "🏆 ${BOLD}ALL LEVEL 0 MISSIONS COMPLETED! YOU CONQUERED THE LINUX SHELL!${RESET}"
        fi
    else
        echo ""
        echo -e "${YELLOW}Don't worry! Every great DevOps engineer debugs through trials.${RESET}"
        echo -e "Need a nudge? Type: ${BOLD}./play.sh hint${RESET}"
        exit 1
    fi
}

cmd_hint() {
    local current_m
    current_m=$(get_current_mission)
    local mission_md="${SCRIPT_DIR}/missions/${current_m}/mission.md"

    if [[ ! -f "${mission_md}" ]]; then
        echo -e "${RED}❌ mission.md not found.${RESET}"
        exit 1
    fi

    local current_lvl
    current_lvl=$(increment_hint_level "${current_m}")

    echo -e "${YELLOW}${BOLD}💡 HINT ${current_lvl} of 3 for ${current_m}:${RESET}"
    echo ""

    python3 - "${mission_md}" "${current_lvl}" <<'EOF'
import sys

mission_file = sys.argv[1]
hint_num = sys.argv[2]

with open(mission_file, "r") as f:
    content = f.read()

target_heading = f"### Hint {hint_num}:"
if target_heading in content:
    part = content.split(target_heading, 1)[1]
    # Split at next hint or end of file
    if "### Hint " in part:
        hint_text = part.split("### Hint ")[0]
    else:
        hint_text = part
    print(hint_text.strip())
else:
    print("No additional hints available for this mission.")
EOF
    echo ""
}

cmd_reset() {
    local current_m
    current_m=$(get_current_mission)
    echo -e "${YELLOW}🔄 Resetting environment and hints for ${current_m}...${RESET}"
    python3 -c "
import json
with open('${PROGRESS_FILE}', 'r') as f:
    data = json.load(f)
data['missions']['${current_m}']['hint_level'] = 0
with open('${PROGRESS_FILE}', 'w') as f:
    json.dump(data, f, indent=2)
"
    cmd_start "${current_m}"
}

cmd_solution() {
    local current_m
    current_m=$(get_current_mission)
    local sol_file="${SCRIPT_DIR}/missions/${current_m}/solution.md"

    if [[ ! -f "${sol_file}" ]]; then
        echo -e "${RED}❌ Solution file not found.${RESET}"
        exit 1
    fi

    read -p "⚠️  Are you sure you want to reveal the solution? (y/N): " -r answer
    if [[ "${answer}" =~ ^[Yy]$ ]]; then
        echo ""
        cat "${sol_file}"
    else
        echo "Keeping it secret! Keep hacking!"
    fi
}

# ------------------------------------------------------------------------------
# Main Dispatcher
# ------------------------------------------------------------------------------
init_progress

ACTION="${1:-status}"

case "${ACTION}" in
    status|list)
        cmd_status
        ;;
    start)
        shift
        cmd_start "$@"
        ;;
    check)
        cmd_check
        ;;
    hint)
        cmd_hint
        ;;
    reset)
        cmd_reset
        ;;
    solution)
        cmd_solution
        ;;
    shell|up)
        # Helper to launch Docker if run from host
        if command -v docker &>/dev/null && [[ -f "${SCRIPT_DIR}/docker-compose.yml" ]]; then
            echo "🐳 Starting sandbox containers and attaching shell..."
            docker compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d
            docker compose -f "${SCRIPT_DIR}/docker-compose.yml" exec -u player sandbox bash
        else
            echo "Run this command inside the Docker container!"
        fi
        ;;
    *)
        echo -e "${RED}Unknown command: ${ACTION}${RESET}"
        echo "Usage: ./play.sh [status|start|check|hint|reset|solution]"
        exit 1
        ;;
esac
