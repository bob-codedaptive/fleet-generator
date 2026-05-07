#!/usr/bin/env bash
# PostCompact hook — verifies critical context survived compaction.
# Fires AFTER compaction completes. Reads stdin, checks for an
# active mission file, emits a diagnostic to stdout that gets
# injected into post-compaction context.
# Fail-open: if anything goes wrong, the session continues normally.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo "{}")

AUDIT_LOG="${HOME}/.claude/audit/hook-events.log"
mkdir -p "$(dirname "$AUDIT_LOG")"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

MISSION_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/active-mission.md"
MISSION_STATUS="absent"
MISSION_NAME="unknown"
if [ -f "$MISSION_FILE" ] || [ -L "$MISSION_FILE" ]; then
    MISSION_STATUS="present"
    MISSION_NAME=$(grep -m1 "^# Mission" "$MISSION_FILE" 2>/dev/null | sed 's/^# Mission: *//' || echo "unknown")
fi

echo "${TIMESTAMP} verify-post-compact mission_status=${MISSION_STATUS} mission=${MISSION_NAME}" >> "$AUDIT_LOG"

cat <<EOF
## Post-compaction diagnostic
- Compaction completed at: ${TIMESTAMP}
- Active mission: ${MISSION_NAME} (${MISSION_STATUS})
- Pre-compact transcript saved: check ~/.claude/transcripts/ for the lossless record
- If context feels incomplete, re-read the active mission file and check git log.
EOF
