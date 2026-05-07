#!/bin/bash
set -e

AUTO_INIT=0
case "${1:-}" in
  --init|-y) AUTO_INIT=1; shift ;;
esac
REPO="${1:-.}"
case "${2:-}" in
  --init|-y) AUTO_INIT=1 ;;
esac

mkdir -p "$REPO"

if [ ! -d "$REPO/.git" ]; then
  if [ "$AUTO_INIT" = "1" ] || [ ! -t 0 ]; then
    echo "Initializing new git repo at $REPO"
    (cd "$REPO" && git init -q)
  else
    printf "%s is not a git repo. Initialize one? [Y/n] " "$REPO"
    read resp || resp="n"
    case "${resp:-Y}" in
      [nN]*) echo "Aborted. Re-run with --init to skip this prompt."; exit 1 ;;
    esac
    echo "Initializing new git repo at $REPO"
    (cd "$REPO" && git init -q)
  fi
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$REPO/.claude/agents" "$REPO/.claude/skills" "$REPO/.claude/rules" "$REPO/.claude/missions"

cp "$SCRIPT_DIR/cli/agents/"*.md "$REPO/.claude/agents/"
cp -r "$SCRIPT_DIR/cli/skills/"* "$REPO/.claude/skills/"
cp "$SCRIPT_DIR/cli/rules/"*.md "$REPO/.claude/rules/"
cp "$SCRIPT_DIR/cli/missions/"*.md "$REPO/.claude/missions/" 2>/dev/null || true

if [ -d "$SCRIPT_DIR/cli/hooks" ] && [ "$(ls "$SCRIPT_DIR/cli/hooks/" 2>/dev/null)" ]; then
  mkdir -p "$REPO/.claude/hooks"
  cp "$SCRIPT_DIR/cli/hooks/"* "$REPO/.claude/hooks/"
  chmod +x "$REPO/.claude/hooks/"*.sh 2>/dev/null || true
fi

if [ -f "$REPO/CLAUDE.md" ]; then
  echo "CLAUDE.md exists. New version saved as CLAUDE.md.fleet"
  cp "$SCRIPT_DIR/cli/CLAUDE.md" "$REPO/CLAUDE.md.fleet"
else
  cp "$SCRIPT_DIR/cli/CLAUDE.md" "$REPO/CLAUDE.md"
fi

if [ -f "$REPO/.claude/settings.json" ]; then
  echo "settings.json exists. New version saved as settings.json.fleet"
  cp "$SCRIPT_DIR/cli/settings.json" "$REPO/.claude/settings.json.fleet"
else
  cp "$SCRIPT_DIR/cli/settings.json" "$REPO/.claude/settings.json"
fi

echo ""
echo "Fleet installed to $REPO"
echo "Agents: $(ls "$SCRIPT_DIR/cli/agents/" | wc -l | tr -d ' ')"
echo "Skills: $(ls "$SCRIPT_DIR/cli/skills/" | wc -l | tr -d ' ')"
echo ""
echo "Chat skills are zipped in chat/ — drag them into claude.ai → Settings → Capabilities → Skills"
echo ""
echo "To run a mission:"
echo "  cd $REPO"
echo "  claude --agent woodstock --model opus --dangerously-skip-permissions"
echo "  # paste mission content"
