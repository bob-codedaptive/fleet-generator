#!/usr/bin/env bash
# PreCompact hook — saves the session transcript before compaction.
# Fires BEFORE context compaction. Dumps the stdin JSON payload to
# a timestamped file so the lossless record survives summarization.
# Storage: ~/.claude/transcripts/<timestamp>_pre-compact.json
# Fail-open: if anything goes wrong, compaction proceeds normally.

set -euo pipefail

TRANSCRIPT_DIR="${HOME}/.claude/transcripts"
mkdir -p "$TRANSCRIPT_DIR"

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
OUTFILE="${TRANSCRIPT_DIR}/${TIMESTAMP}_pre-compact.json"

if cat > "$OUTFILE" 2>/dev/null; then
    AUDIT_LOG="${HOME}/.claude/audit/hook-events.log"
    mkdir -p "$(dirname "$AUDIT_LOG")"
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") save-pre-compact result=saved file=${OUTFILE}" >> "$AUDIT_LOG"
else
    rm -f "$OUTFILE" 2>/dev/null
fi
