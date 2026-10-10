#!/usr/bin/env bash
# ==============================================================================
# Mission 03: Check script
# Verifies the student's investigation report for rogue IP and breach count.
# ==============================================================================
set -euo pipefail

REPORT_FILE="/home/player/mission-03/investigation.txt"
EXPECTED_IP="10.240.88.199"
EXPECTED_COUNT="17"

echo "🔍 Verifying Mission 03..."

if [[ ! -f "${REPORT_FILE}" ]]; then
    echo "❌ Fail: ${REPORT_FILE} not found."
    echo "💡 Hint: Save your findings into /home/player/mission-03/investigation.txt with format:"
    echo "   ROGUE_IP=<ip>"
    echo "   OCCURRENCE_COUNT=<count>"
    exit 1
fi

SUBMITTED_IP=$(grep -E "^ROGUE_IP=" "${REPORT_FILE}" 2>/dev/null | cut -d'=' -f2 | tr -d '[:space:]' || true)
SUBMITTED_COUNT=$(grep -E "^OCCURRENCE_COUNT=" "${REPORT_FILE}" 2>/dev/null | cut -d'=' -f2 | tr -d '[:space:]' || true)

if [[ -z "${SUBMITTED_IP}" ]]; then
    echo "❌ Fail: Missing ROGUE_IP line in ${REPORT_FILE}."
    echo "   Expected line: ROGUE_IP=<ip>"
    exit 1
fi

if [[ -z "${SUBMITTED_COUNT}" ]]; then
    echo "❌ Fail: Missing OCCURRENCE_COUNT line in ${REPORT_FILE}."
    echo "   Expected line: OCCURRENCE_COUNT=<count>"
    exit 1
fi

if [[ "${SUBMITTED_IP}" != "${EXPECTED_IP}" ]]; then
    echo "❌ Incorrect IP: Found '${SUBMITTED_IP}', expected '${EXPECTED_IP}'."
    echo "💡 Hint: Grep for 'ALERT_UNAUTHORIZED_DATABASE_DUMP' and extract the IP column."
    exit 1
fi

if [[ "${SUBMITTED_COUNT}" != "${EXPECTED_COUNT}" ]]; then
    echo "❌ Incorrect occurrence count: Found '${SUBMITTED_COUNT}', expected '${EXPECTED_COUNT}'."
    echo "💡 Hint: Count matching lines using 'grep ... | wc -l'."
    exit 1
fi

echo "🎉 SUCCESS! You mastered text filtering and isolated the breach signature!"
exit 0
