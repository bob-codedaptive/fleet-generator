#!/usr/bin/env bash
# SubagentStop hook — logs every subagent termination to the
# per-machine audit log. Closes the start/stop pair from
# log-subagent-start.sh.

set -euo pipefail

AUDIT_DIR="${HOME}/.claude/audit"
AUDIT_LOG="${AUDIT_DIR}/subagent-events.log"
RAW_DIR="${AUDIT_DIR}/raw"
mkdir -p "$AUDIT_DIR" "$RAW_DIR"

ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
ts_compact="$(date -u '+%Y%m%dT%H%M%SZ')"

raw_path="${RAW_DIR}/stop-${ts_compact}-$$.json"
cat > "$raw_path" || true

extract() {
    local key="$1"
    if command -v jq >/dev/null 2>&1; then
        jq -r ".${key} // empty" "$raw_path" 2>/dev/null || true
    else
        grep -o "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$raw_path" 2>/dev/null \
            | head -1 | sed -E 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true
    fi
}

agent="$(extract subagent_type)"
[ -z "$agent" ] && agent="$(extract agent_type)"
[ -z "$agent" ] && agent="$(extract agent)"
[ -z "$agent" ] && agent="unknown"

session="$(extract session_id)"
[ -z "$session" ] && session="unknown"

exit_reason="$(extract exit_reason)"
[ -z "$exit_reason" ] && exit_reason="$(extract reason)"
[ -z "$exit_reason" ] && exit_reason="unknown"

exit_status="$(extract exit_status)"
[ -z "$exit_status" ] && exit_status="$(extract status)"
[ -z "$exit_status" ] && exit_status="unknown"

printf '%s | stop  | agent=%s | session=%s | reason=%s | status=%s\n' \
    "$ts" "$agent" "$session" "$exit_reason" "$exit_status" >> "$AUDIT_LOG"
