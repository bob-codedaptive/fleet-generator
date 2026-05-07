#!/bin/bash
mkdir -p ~/.claude/audit
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Session start: dir=$PWD" >> ~/.claude/audit/instructions-loaded.log
