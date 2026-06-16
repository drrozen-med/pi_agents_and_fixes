#!/usr/bin/env bash
# =============================================================================
# ghi-dashboard.sh
# Shows the full status of all GHI worktrees: worktree exists, commits ahead,
# branch pushed, PR open, gate verdict.
#
# Usage:
#   ./ghi-dashboard.sh <owner/repo> <worktree-base>
#   Example: ./ghi-dashboard.sh drrozen-med/boardsBridge /tmp/boardsBridge
# =============================================================================

set -euo pipefail

REPO_SLUG="${1:-}"; shift || { echo "Usage: $0 <owner/repo> <worktree-base>"; exit 1; }
WORKTREE_BASE="${1:-}"; shift || { echo "Usage: $0 <owner/repo> <worktree-base>"; exit 1; }

# Color codes
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'
CYAN='\033[0;36m'; DIM='\033[2m'; BOLD='\033[1m'; NC='\033[0m'

pr_list=$(gh pr list --repo "$REPO_SLUG" --state open --json number,title,headRefName 2>/dev/null || echo '[]')

# Fetch all issue numbers from GHIS
if [ -f "$WORKTREE_BASE/GHIS.md" ]; then
  ISSUES=$(grep -oP '^\d+\.' "$WORKTREE_BASE/GHIS.md" | sed 's/\.//' | sort -n || echo "")
elif gh issue list --repo "$REPO_SLUG" --state all --limit 100 -json number --jq '.[].number' &>/dev/null; then
  ISSUES=$(gh issue list --repo "$REPO_SLUG" --state all --limit 100 -json number --jq '.[].number' | sort -n || echo "")
else
  ISSUES=""
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║         GHI Processor Dashboard  —  $REPO_SLUG${NC}"
printf "${BOLD}║%66s║${NC}\n" ""
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

printf "%-8s %-30s %-12s %-10s %-10s %-8s\n" \
  "ISSUE" "TITLE" "WORKTREE" "COMMITTED" "PR" "GATE"
printf "%s\n" "$(printf '%.0s─' {1..105})"

for ISSUE_NUM in $ISSUES; do
  # Get issue title
  TITLE=$(gh issue view "$ISSUE_NUM" --repo "$REPO_SLUG" --json title --jq '.title' 2>/dev/null | cut -c1-28 || echo "?")

  # GHI label
  GHI=$(gh issue view "$ISSUE_NUM" --repo "$REPO_SLUG" --json title --jq '.title' 2>/dev/null | \
    grep -oP '(?<=^#\d+\s)\K(GHI-\d+)' | head -1 || echo "?")

  # Worktree status
  WT_PATH="$WORKTREE_BASE/issue-$ISSUE_NUM"
  if [ -d "$WT_PATH/.git" ]; then
    cd "$WT_PATH"
    # Check if on correct branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")

    # Commits ahead
    COMMITS=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ' || echo "?")

    if [ "$COMMITS" -gt 0 ] 2>/dev/null; then
      COMMITS_COLOR="$YELLOW"
      COMMITS_STR="${COMMITS}commits"
    elif [ "$COMMITS" == "0" ]; then
      # Check for uncommitted changes
      UNSTAGED=$(git status --porcelain 2>/dev/null | grep -v "^??" | wc -l | tr -d ' ')
      if [ "$UNSTAGED" -gt 0 ]; then
        COMMITS_COLOR="$RED"
        COMMITS_STR="${UNSTAGED}uncommitted"
      else
        COMMITS_COLOR="$GREEN"
        COMMITS_STR="synced"
      fi
    else
      COMMITS_COLOR="$DIM"
      COMMITS_STR="?"
    fi

    # Branch pushed to remote
    if git rev-parse --verify "origin/$CURRENT_BRANCH" &>/dev/null; then
      PUSHED_COLOR="$GREEN"
      PUSHED_STR="pushed"
    else
      PUSHED_COLOR="$YELLOW"
      PUSHED_STR="local only"
    fi

    # Implementation summary
    if [ -f "$WT_PATH/IMPLEMENTATION_SUMMARY.md" ]; then
      VERDICT=$(grep -m1 "^## Gate Verdict" "$WT_PATH/IMPLEMENTATION_SUMMARY.md" -A1 | tail -1 | tr -d '**' | xargs)
      if [ "$VERDICT" == "PASS" ]; then
        VERDICT_COLOR="$GREEN"; VERDICT_STR="PASS"
      elif [ "$VERDICT" == "FAIL" ]; then
        VERDICT_COLOR="$RED"; VERDICT_STR="FAIL"
      elif [ "$VERDICT" == "BLOCKED" ]; then
        VERDICT_COLOR="$YELLOW"; VERDICT_STR="BLOCKED"
      else
        VERDICT_COLOR="$DIM"; VERDICT_STR="${VERDICT:0:8}"
      fi
    else
      VERDICT_COLOR="$DIM"; VERDICT_STR="no summary"
    fi

    WORKTREE_COLOR="$BLUE"; WORKTREE_STR="✓ exists"
    WT_CLEAN=""
  else
    WORKTREE_COLOR="$DIM"; WORKTREE_STR="✗ absent"
    COMMITS_COLOR="$DIM"; COMMITS_STR="—"
    PUSHED_COLOR="$DIM"; PUSHED_STR="—"
    VERDICT_COLOR="$DIM"; VERDICT_STR="—"
    WT_CLEAN=""
  fi

  # PR status
  PR_NUM=$(echo "$pr_list" | jq -r ".[] | select(.headRefName == \"issue/$ISSUE_NUM\") | .number" 2>/dev/null | head -1 || echo "")
  if [ -n "$PR_NUM" ] && [ "$PR_NUM" != "null" ]; then
    PR_COLOR="$GREEN"; PR_STR="#$PR_NUM"
  elif [ "$COMMITS" -gt 0 ] 2>/dev/null; then
    PR_COLOR="$YELLOW"; PR_STR="not opened"
  else
    PR_COLOR="$DIM"; PR_STR="—"
  fi

  # Build status line
  printf "${CYAN}%-8s${NC} %-30s ${WORKTREE_COLOR}%-12s${NC} ${COMMITS_COLOR}%-10s${NC} ${PR_COLOR}%-10s${NC} ${VERDICT_COLOR}%-8s${NC}\n" \
    "$GHI" "$TITLE" "$WORKTREE_STR" "$COMMITS_STR" "$PR_STR" "$VERDICT_STR"
done

echo ""
echo -e "${BOLD}Legend:${NC}"
echo -e "  ${GREEN}✓ worktree${NC}   ${YELLOW}commits ahead${NC}   ${GREEN}#N = PR open${NC}   ${GREEN}PASS${NC}   ${RED}FAIL${NC}   ${YELLOW}BLOCKED${NC}   ${DIM}uncommitted/no summary${NC}"
echo ""

# Summary stats
TOTAL=$(echo "$ISSUES" | wc -w | tr -d ' ')
WORKTREE_COUNT=$(find "$WORKTREE_BASE" -maxdepth 1 -mindepth 1 -name "issue-*" -type d 2>/dev/null | wc -l | tr -d ' ')
PR_COUNT=$(echo "$pr_list" | jq length 2>/dev/null || echo 0)
PASS_COUNT=0; FAIL_COUNT=0; BLOCKED_COUNT=0; NO_SUMMARY=0

for ISSUE_NUM in $ISSUES; do
  WT_PATH="$WORKTREE_BASE/issue-$ISSUE_NUM"
  if [ -f "$WT_PATH/IMPLEMENTATION_SUMMARY.md" ]; then
    VERDICT=$(grep -m1 "^## Gate Verdict" "$WT_PATH/IMPLEMENTATION_SUMMARY.md" -A1 | tail -1 | tr -d '**' | xargs)
    case "$VERDICT" in
      PASS)   PASS_COUNT=$((PASS_COUNT+1)) ;;
      FAIL)   FAIL_COUNT=$((FAIL_COUNT+1)) ;;
      BLOCKED) BLOCKED_COUNT=$((BLOCKED_COUNT+1)) ;;
      *)      NO_SUMMARY=$((NO_SUMMARY+1)) ;;
    esac
  fi
done

echo -e "${BOLD}Summary:${NC} $TOTAL total issues | $WORKTREE_COUNT worktrees | ${GREEN}$PASS_COUNT PASS${NC} | ${RED}$FAIL_COUNT FAIL${NC} | ${YELLOW}$BLOCKED_COUNT BLOCKED${NC} | ${GREEN}$PR_COUNT PRs open${NC}"
echo ""
echo "  gh pr list --repo $REPO_SLUG --state open   # view all open PRs"
echo "  ./dispatch-ghi-batch.sh $REPO_SLUG $WORKTREE_BASE <issue-numbers>   # dispatch new batch"
echo ""
