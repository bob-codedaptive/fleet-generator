#!/usr/bin/env bash
# SubagentStart hook — logs every subagent spawn to a per-machine
# audit log. Replaces "subagent reports its own invocation" with
# structural audit.

set -euo pipefail

AUDIT_DIR="${HOME}/.claude/audit"
AUDIT_LOG="${AUDIT_DIR}/subagent-events.log"
RAW_DIR="${AUDIT_DIR}/raw"
mkdir -p "$AUDIT_DIR" "$RAW_DIR"

ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
ts_compact="$(date -u '+%Y%m%dT%H%M%SZ')"

raw_path="${RAW_DIR}/start-${ts_compact}-$$.json"
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

parent="$(extract parent_session_id)"
[ -z "$parent" ] && parent="unknown"

printf '%s | start | agent=%s | session=%s | parent=%s\n' \
    "$ts" "$agent" "$session" "$parent" >> "$AUDIT_LOG"
