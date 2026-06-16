#!/usr/bin/env bash
# =============================================================================
# dispatch-ghi-batch.sh
# Dispatches a batch of GHI workers, one per issue, in isolated worktrees.
# Workers auto-commit, push, and open PRs on PASS (handled by the agent spec).
#
# Usage:
#   ./dispatch-ghi-batch.sh <repo-slug> <worktree-base> <issue-number> [...]
#   Example:
#     ./dispatch-ghi-batch.sh drrozen-med/boardsBridge /tmp/boardsBridge 33 34 35 36
#
# Requirements:
#   - gh cli authenticated:  gh auth status
#   - Git remote 'origin' pointing to the repo
#   - Node/npm in PATH (for npm test)
# =============================================================================

set -euo pipefail

REPO_SLUG="${1:-}"; shift || { echo "Usage: $0 <owner/repo> <worktree-base> <issue-number> [...]"; exit 1; }
WORKTREE_BASE="${1:-}"; shift || { echo "Usage: $0 <owner/repo> <worktree-base> <issue-number> [...]"; exit 1; }

if [ $# -eq 0 ]; then
  echo "Usage: $0 <owner/repo> <worktree-base> <issue-number> [...]"
  echo "Example: $0 drrozen-med/boardsBridge /tmp/boardsBridge 33 34 35 36"
  exit 1
fi

ISSUES=("$@")
MAX_CONCURRENT=4
WORKTREE_PARENT="$(dirname "$WORKTREE_BASE")"
REPO_NAME="$(basename "$WORKTREE_BASE")"

# --- Helpers ---

log()  { echo "[$(date '+%H:%M:%S')] $*"; }
warn() { echo "[$(date '+%H:%M:%S')] WARN: $*" >&2; }

# --- Prereqs ---

log "Checking prereqs..."
if ! gh auth status &>/dev/null; then
  warn "gh CLI not authenticated. Run: gh auth login"
  exit 1
fi

# Clone/freshen the base repo if needed
if [ ! -d "$WORKTREE_BASE/.git" ]; then
  log "Cloning $REPO_SLUG into $WORKTREE_BASE..."
  git clone "https://github.com/$REPO_SLUG.git" "$WORKTREE_BASE"
fi

cd "$WORKTREE_BASE"
git fetch origin main
git checkout main
git pull origin main

# --- Create worktrees and dispatch ---

dispatched=()
for ISSUE_NUM in "${ISSUES[@]}"; do
  WT_PATH="$WORKTREE_BASE/issue-$ISSUE_NUM"
  BRANCH="issue/$ISSUE_NUM"

  if [ -d "$WT_PATH/.git" ]; then
    log "Worktree already exists: $WT_PATH — skipping creation"
  else
    log "Creating worktree: $WT_PATH → branch $BRANCH"
    git worktree add -b "$BRANCH" "$WT_PATH" origin/main
  fi

  # Derive GHI label from issue title (fallback to "GHI-$ISSUE_NUM")
  GHI_LABEL=$(gh issue view "$ISSUE_NUM" --repo "$REPO_SLUG" --json title --jq '.title' 2>/dev/null | \
    grep -oP '(?<=^#\d+\s)\K(GHI-\d+)' | head -1 || echo "GHI-$ISSUE_NUM")

  log "Dispatching worker for $GHI_LABEL (#$ISSUE_NUM) → $WT_PATH"
  # The agent will auto-commit+push+PR on PASS (handled by updated spec)
  pi "You are the github-issue-worker agent.

## Context
- ISSUE_NUMBER=$ISSUE_NUM
- GHI_NUMBER=$GHI_LABEL
- WORKTREE_PATH=$WT_PATH
- REPO_SLUG=$REPO_SLUG

## Instructions
1. cd $WT_PATH
2. Read the issue: gh issue view $ISSUE_NUMBER --repo $REPO_SLUG --json title,body --jq '{title:.title,body:.body}'
3. Implement the issue fully
4. Run: npm test -- run
5. Run: npm run build 2>&1 | tail -5 (if exists)
6. Write $WT_PATH/IMPLEMENTATION_SUMMARY.md
7. If PASS: commit, push branch, and open PR automatically per the agent spec
8. Report: {GHI_NUMBER}: {verdict} | PR: #{number or 'n/a'}

Stop only after IMPLEMENTATION_SUMMARY.md is written and (if PASS) PR is open." &

  dispatched+=("$ISSUE_NUM:$GHI_LABEL:$WT_PATH:$!")
  log "Agent dispatched (PID $!) — waiting for next slot (max $MAX_CONCURRENT concurrent)..."
done

log "All ${#ISSUES[@]} workers dispatched."
log "Waiting for all agents to complete..."
wait

log ""
log "=== All workers complete ==="
log "Run: ./ghi-dashboard.sh $REPO_SLUG $WORKTREE_BASE"
log "Or check PRs: gh pr list --repo $REPO_SLUG --state open"
