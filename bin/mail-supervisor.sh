#!/usr/bin/env bash
# Send a letter to the supervisor and receive their reply.
# Keeps a persistent `claude -p` session so the supervisor "remembers"
# prior correspondence with the student, and mirrors every exchange to
# SUPERVISOR_COMMUNICATION.md in the current working directory for human
# audit.
#
# Installed under the plugin's bin/ and auto-added to PATH while the
# geo-lab plugin is enabled, so the student can invoke it directly.
#
# Usage:
#   mail-supervisor.sh "Dear Supervisor, ..."
#   cat letter.md | mail-supervisor.sh
#
# Reset (start a new supervisor with empty memory):
#   rm .supervisor-session
#   # optionally also: rm SUPERVISOR_COMMUNICATION.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$SCRIPT_DIR")}"
SUPERVISOR_MD="$PLUGIN_ROOT/agents/supervisor.md"
STATE_FILE=".supervisor-session"
LOG_FILE="SUPERVISOR_COMMUNICATION.md"

if [[ ! -f "$SUPERVISOR_MD" ]]; then
  echo "[mail-supervisor] cannot find $SUPERVISOR_MD" >&2
  exit 1
fi

MSG="${1:-$(cat)}"

if [[ -z "${MSG// }" ]]; then
  echo "[mail-supervisor] empty message; pass as arg or via stdin" >&2
  exit 1
fi

NOW=$(date -Iseconds)

{
  printf '\n\n---\n\n## %s — Student → Supervisor\n\n' "$NOW"
  printf '%s\n' "$MSG"
} >> "$LOG_FILE"

if [[ -f "$STATE_FILE" ]]; then
  SID=$(cat "$STATE_FILE")
  REPLY=$(claude -p --dangerously-skip-permissions \
    --resume "$SID" "$MSG") \
    || { echo "[mail-supervisor] claude invocation failed" >&2; exit 1; }
else
  # Strip the YAML frontmatter (everything up to and including the 2nd `---`).
  PROMPT_BODY=$(awk '/^---$/{c++; next} c>=2' "$SUPERVISOR_MD")
  SID=$(uuidgen)
  echo "$SID" > "$STATE_FILE"
  echo "[mail-supervisor] new session $SID -> $STATE_FILE" >&2
  REPLY=$(claude -p --dangerously-skip-permissions \
    --session-id "$SID" \
    --append-system-prompt "$PROMPT_BODY" \
    "$MSG") \
    || { echo "[mail-supervisor] claude invocation failed" >&2; exit 1; }
fi

{
  printf '\n\n## %s — Supervisor → Student\n\n' "$(date -Iseconds)"
  printf '%s\n' "$REPLY"
} >> "$LOG_FILE"

printf '%s\n' "$REPLY"
