#!/usr/bin/env bash
# PreToolUse Edit/Write hook — enforces write scope against the
# active mission's "Files to Modify" list.
#
# Default mode: WARN (log violations, do not block).
# Set CLAUDE_HOOK_MODE=block to flip to BLOCK mode.
#
# Reads stdin as JSON. Fails open with a logged warning if
# .claude/active-mission.md is absent or unparseable.

set -euo pipefail

[ -n "${HOME:-}" ] || exit 0

MODE="${CLAUDE_HOOK_MODE:-warn}"
AUDIT_DIR="${HOME}/.claude/audit"
AUDIT_LOG="${AUDIT_DIR}/hook-events.log"
RAW_DIR="${AUDIT_DIR}/raw"
mkdir -p "$AUDIT_DIR" "$RAW_DIR"

ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

stdin_raw="$(cat)"
echo "$stdin_raw" > "$RAW_DIR/preToolUse-Edit-${ts//[:T]/-}-$$.json"

tool_name=""
target_path=""
if command -v jq >/dev/null 2>&1; then
    tool_name="$(printf '%s' "$stdin_raw" | jq -r '.tool_name // .toolName // .name // ""' 2>/dev/null || printf '')"
    target_path="$(printf '%s' "$stdin_raw" | jq -r '.tool_input.file_path // .tool_input.path // .input.file_path // .input.path // ""' 2>/dev/null || printf '')"
fi

if [ -z "$target_path" ]; then
    echo "${ts} | enforce-write-scope | mode=${MODE} | result=fail_open | reason=no_target_path | tool=${tool_name}" >> "$AUDIT_LOG"
    exit 0
fi

abs_cwd="$(pwd -P 2>/dev/null || pwd)"
case "$target_path" in
    "$abs_cwd"/*) rel_target="${target_path#${abs_cwd}/}" ;;
    /*)            rel_target="$target_path" ;;
    *)             rel_target="$target_path" ;;
esac

ACTIVE_MISSION=".claude/active-mission.md"
if [ ! -e "$ACTIVE_MISSION" ]; then
    echo "${ts} | enforce-write-scope | mode=${MODE} | result=fail_open | reason=no_active_mission | target=${rel_target}" >> "$AUDIT_LOG"
    exit 0
fi

# Operational allow-list — universally allowed
operational_allowed=0
case "$rel_target" in
    .claude/agent-memory/*) operational_allowed=1 ;;
    .claude/transcripts/*)  operational_allowed=1 ;;
esac
if [ "$operational_allowed" = "1" ]; then
    echo "${ts} | enforce-write-scope | mode=${MODE} | result=allow_operational | tool=${tool_name} | target=${rel_target}" >> "$AUDIT_LOG"
    exit 0
fi

# Extract allowed paths from "Files to Modify" / "Files You Will Modify" /
# "Files You Will Create" sections. Looks for table rows or list items
# containing a backticked path.
allowed_paths="$(awk '
    /^## Files (to|You Will) (Modify|Create)/ { in_section=1; next }
    /^## /                                     { in_section=0 }
    in_section && /`[^`]+`/                 {
        match($0, /`[^`]+`/);
        path = substr($0, RSTART+1, RLENGTH-2);
        print path
    }
' "$ACTIVE_MISSION")"

if [ -z "$allowed_paths" ]; then
    echo "${ts} | enforce-write-scope | mode=${MODE} | result=fail_open | reason=no_allowed_paths_parsed | target=${rel_target}" >> "$AUDIT_LOG"
    exit 0
fi

allowed=0
matched_rule=""
while IFS= read -r allowed_path; do
    [ -z "$allowed_path" ] && continue
    if [ "$rel_target" = "$allowed_path" ]; then
        allowed=1; matched_rule="exact"; break
    fi
    case "$rel_target" in
        "$allowed_path"/*) allowed=1; matched_rule="prefix"; break ;;
    esac
done <<< "$allowed_paths"

if [ "$allowed" = "1" ]; then
    echo "${ts} | enforce-write-scope | mode=${MODE} | result=allow | tool=${tool_name} | target=${rel_target} | rule=${matched_rule}" >> "$AUDIT_LOG"
    exit 0
fi

if [ "$MODE" = "block" ]; then
    echo "${ts} | enforce-write-scope | mode=${MODE} | result=block | tool=${tool_name} | target=${rel_target}" >> "$AUDIT_LOG"
    cat <<JSON
{"permissionDecision": "deny", "reason": "Write to '${rel_target}' is outside the active mission's allowed-files list. Update .claude/active-mission.md (Files to Modify section) before retrying."}
JSON
    exit 0
else
    echo "${ts} | enforce-write-scope | mode=${MODE} | result=warn | tool=${tool_name} | target=${rel_target}" >> "$AUDIT_LOG"
    exit 0
fi
