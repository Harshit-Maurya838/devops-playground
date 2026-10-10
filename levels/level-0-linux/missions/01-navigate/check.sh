#!/usr/bin/env bash
# ==============================================================================
# Mission 01: Check script
# Verifies that the player located the token and saved it into solution.txt
# ==============================================================================
set -euo pipefail

SOLUTION_FILE="/home/player/mission-01/solution.txt"
EXPECTED_TOKEN="TOKEN{lost_in_th3_sh3ll_found_by_f1nd_9921}"

echo "🔍 Verifying Mission 01..."

if [[ ! -f "${SOLUTION_FILE}" ]]; then
    echo "❌ Missing file: /home/player/mission-01/solution.txt was not found."
    echo "💡 Hint: Locate the hidden file '.credential_key', read it, and save the token into solution.txt."
    exit 1
fi

# Trim whitespace from learner's file
SUBMITTED_TOKEN=$(tr -d '[:space:]' < "${SOLUTION_FILE}")

if [[ "${SUBMITTED_TOKEN}" == "${EXPECTED_TOKEN}" ]]; then
    echo "🎉 SUCCESS! You mastered file navigation and found the hidden credential token!"
    exit 0
else
    echo "❌ Incorrect token submitted."
    echo "   Submitted: '${SUBMITTED_TOKEN}'"
    echo "💡 Hint: Make sure you extracted the key from '.credential_key', not one of the decoy files!"
    exit 1
fi
