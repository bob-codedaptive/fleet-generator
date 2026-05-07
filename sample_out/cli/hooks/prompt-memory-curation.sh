#!/usr/bin/env bash
# Stop hook — nudges the agent to consider writing a learning note
# at session end if the session was substantive (>10 hook events
# in the last 60 minutes). Non-blocking suggestion only.

set -euo pipefail

AUDIT_DIR="${HOME}/.claude/audit"
AUDIT_LOG="${AUDIT_DIR}/hook-events.log"
RAW_DIR="${AUDIT_DIR}/raw"
mkdir -p "$AUDIT_DIR" "$RAW_DIR"

ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

stdin_raw="$(cat || printf '')"
echo "$stdin_raw" > "$RAW_DIR/stop-curation-${ts//[:T]/-}-$$.json"

agent=""
if command -v jq >/dev/null 2>&1; then
    agent="$(printf '%s' "$stdin_raw" | jq -r '.agent_type // .agent_name // "main"' 2>/dev/null || printf 'main')"
fi
agent="${agent:-main}"

session_window_minutes=60
recent_events=0
if [ -f "$AUDIT_LOG" ]; then
    cutoff="$(date -u -v-${session_window_minutes}M '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || \
              date -u -d "${session_window_minutes} minutes ago" '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || \
              echo '')"
    if [ -n "$cutoff" ]; then
        recent_events="$(awk -F' \\| ' -v cutoff="$cutoff" '$1 >= cutoff' "$AUDIT_LOG" 2>/dev/null | wc -l | tr -d ' ')"
    fi
fi

threshold=10
if [ "${recent_events:-0}" -lt "$threshold" ]; then
    echo "${ts} | prompt-memory-curation | result=skip | reason=light_session | recent_events=${recent_events} | agent=${agent}" >> "$AUDIT_LOG"
    exit 0
fi

echo "${ts} | prompt-memory-curation | result=suggested | recent_events=${recent_events} | agent=${agent}" >> "$AUDIT_LOG"

cat <<JSON
{
  "additionalContext": "Session-end memory curation prompt: this session had ${recent_events} hook events (substantive activity). If you observed findings worth carrying across sessions — patterns, pitfalls, decisions — consider writing them to .claude/agent-memory/${agent}/learning_<topic>.md before exiting. The decision is yours; this is a nudge, not a requirement."
}
JSON
