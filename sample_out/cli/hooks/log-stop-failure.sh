#!/bin/bash
mkdir -p ~/.claude/audit
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Stop: exit=$CLAUDE_EXIT_CODE dir=$PWD" >> ~/.claude/audit/stop-failures.log
