#!/usr/bin/env bash
# GHI→PR orchestrator runner — cron-driven, headless.
# Invokes pi in print mode, resuming a stable session so state persists tick-to-tick.
#
# Install (crontab -e):
#   */20 * * * * /home/claude-agent/pi_agents_and_fixes/scripts/ghi-orchestrator.sh >> /home/claude-agent/pi_agents_and_fixes/scripts/ghi-orchestrator.log 2>&1
#
# Env:
#   GHI_REPOS   comma-separated repo names (without owner) to scan; default = all drrozen-med/* clones present locally
#   GHI_OWNER   github owner; default drrozen-med
#   GHI_SESSION pi session id; default ghi-orchestrator
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"
OWNER="${GHI_OWNER:-drrozen-med}"
SESSION="${GHI_SESSION:-ghi-orchestrator}"
LOG="$HERE/ghi-orchestrator.log"
STATE_FILE="$HERE/.last-tick"

echo "=== tick $(date -u +%FT%TZ) ==="

# 0. Preflight: gh must be authed with repo + workflow scope.
if ! gh auth status 2>&1 | grep -q "Logged in to github.com"; then
  echo "FATAL: gh not authenticated. Run: gh auth login" >&2
  exit 1
fi

# 1. Resolve which repos to scan.
PROJECTS_DIR="/home/claude-agent/projects"
if [[ -n "${GHI_REPOS:-}" ]]; then
  IFS=',' read -ra REPOS <<< "$GHI_REPOS"
else
  REPOS=()
  for d in "$PROJECTS_DIR"/*/; do
    [[ -d "$d/.git" ]] || continue
    REPOS+=("$(basename "$d")")
  done
fi
echo "repos: ${REPOS[*]}"

# 2. Build the prompt for this tick. The orchestrator skill does the real work.
REPO_LIST="${REPOS[*]}"
PROMPT="Run the ghi-orchestrator skill for these repos under ${OWNER}/: ${REPO_LIST}.
Re-query open issues, triage new ones, spawn ghi-pr-worker subagents for spawnable issues,
and report the status of all in-flight PRs this session has opened. Emit the status digest.
Tick: $(date -u +%FT%TZ)."

# 3. Invoke pi headless, resuming the persistent orchestrator session.
#    --no-tools is NOT used: the orchestrator needs bash + subagent.
#    Skills are loaded from settings.json (points at pi_agents_and_fixes/skills).
pi -p \
  --session-id "$SESSION" \
  --name "GHI Orchestrator" \
  "$PROMPT" || {
      echo "WARN: pi tick exited non-zero; see session log." >&2
    }

# 4. Record tick for observability.
date -u +%FT%TZ > "$STATE_FILE"
echo "=== tick done ==="
