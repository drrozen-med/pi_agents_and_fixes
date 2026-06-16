#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-.}"
BASE_BRANCH="${2:-main}"
AGENT_SPEC="${3:-/Users/urirozen_m4/pi_agents_and_fixes/agents/github-issue-worker.md}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required" >&2
  exit 1
fi

cd "$REPO_ROOT"

mapfile -t ISSUES < <(gh issue list --limit 200 --json number,title,labels,assignees --jq '.[] | [.number,.title,(.labels|map(.name)|join(",")),(.assignees|map(.login)|join(","))] | @tsv')

if [ "${#ISSUES[@]}" -eq 0 ]; then
  echo "No issues found"
  exit 0
fi

printf 'Found %d issues\n' "${#ISSUES[@]}"

for issue in "${ISSUES[@]}"; do
  IFS=$'\t' read -r number title labels assignees <<<"$issue"
  worktree="/tmp/boardsBridge-issue-${number}"
  rm -rf "$worktree"
  git worktree add "$worktree" -b "issue/${number}" "$BASE_BRANCH"
  (
    cd "$worktree"
    quality_gate=".github/quality-gates/${number}.md"
    mkdir -p "$(dirname "$quality_gate")"
    cat > "$quality_gate" <<EOF
# Quality Gate: ${title}

Issue: #${number}
Repo: boardsBridge
Worker agent: github-issue-worker

## Acceptance criteria

- [ ] TBD from issue body
- [ ] Tests added/updated
- [ ] Build passes

## Evidence to collect

- Test command and result
- Build command and result
- Changed file list
EOF
    gh issue view "$number" --json body,title,labels,assignees --jq '{number:.number,title:.title,body:.body,labels:[.labels[].name],assignees:[.assignees[].login]}' > issue-context.json
  )
  printf 'Prepared worktree for #%s: %s\n' "$number" "$worktree"
done

printf '\nNext step: dispatch one github-issue-worker agent per worktree with:\n'
printf '  - ISSUE_NUMBER\n'
printf '  - REPO_ROOT=<worktree path>\n'
printf '  - QUALITY_GATE_PATH=<worktree>/.github/quality-gates/<issue>.md\n'
