---
description: GHI→PR orchestrator — enumerate open issues in target repos, fan out ghi-triage + ghi-pr-worker subagents into clean PRs, and run a recurring status-check loop. Invoked headlessly by scripts/ghi-orchestrator.sh every 20 min. Use when coordinating issue-driven autonomous PRs across drrozen-med/* consumer repos.
---

# GHI→PR Orchestrator

Autonomous loop: **enumerate open issues → triage → fan out workers → report →
repeat.** Designed to be driven headless (`pi -p`) on a cron, resuming the same
session each tick so state (in-flight PRs, seen issues) persists.

## Target repos

The set of repos this orchestrator works on. Default (edit per deployment):
`NurseBridge-prep`, `parents-apps`, `boardsBridge`, `solids-buddy`, `baby-briefs`,
`vera`, `story-weaver-studio`, `pre-sss`, `shared-marketing`. All under
`drrozen-med/`. Restrict via the `GHI_REPOS` env var (comma-separated) if needed.

## Per-tick loop (run this exactly once each invocation)

1. **Re-query issues.** For each repo: `gh issue list --repo drrozen-med/<repo>
   --state open --json number,title,labels,assignees --limit 30`. Skip repos
   whose clone is missing AND not in `GHI_REPOS` (avoid cloning the world).

2. **Dedup against state.** This session persists across ticks. Maintain (in your
   own message context) a `seen` map of `repo#issue → first_seen_tick`. Only
   triage issues you have not already triaged this session. An issue re-triages
   if its **labels changed** since last triage.

3. **Triage (parallel).** For each new/changed issue, spawn a **`ghi-triage`**
   subagent (use the `subagent` tool, `tasks` array / parallel mode, cap 4
   concurrent). Feed it the issue JSON. Collect the decision JSONs.

4. **Fan out workers (parallel).** For every triage result with
   `decision: "spawn"`:
   - Skip if a PR already references that issue: `gh pr list --repo <repo>
     --state open --search "<issue title>"` and check bodies for `Closes #N`.
   - Otherwise spawn a **`ghi-pr-worker`** subagent with the brief, branch,
     acceptance, and `needs_human` flag. Cap 4 concurrent workers total.

5. **Status check (always run).** For every PR opened by this orchestrator
   in a prior tick (track their `repo#PR` list in-session): `gh pr view
   <n> --repo <repo> --json state,mergeable,reviewDecision,statusCheckRollup`.
   Report: ✅ merged / 🟢 mergeable / 🟡 checks pending / 🔴 failing / 💬 changes
   requested.

6. **Emit a status digest** (printed, since this is `pi -p` headless):
   ```
   === GHI orchestrator tick <ISO> ===
   Scanned: <N> repos, <M> open issues (<K> new).
   Triaged: <T> (spawn <S>, skip <X>).
   Workers spawned this tick: <W>.
   In-flight PRs: <list with one-line status each>.
   Blocked / needs-human: <list>.
   ```

## Concurrency & cost bounds

- Max 4 triage subagents concurrent, 4 worker subagents concurrent, **8 total
  pi processes** at once (matches `MAX_PARALLEL_TASKS` in the subagent extension).
- Skip an issue if a worker is already running for it this session (prevent
  double-spawn across ticks).
- A worker that returned `status: "blocked"` is NOT retried automatically — it
  goes in the "blocked / needs-human" list for a human.

## Failure modes & self-limits

- `gh` not authed → print the auth status and exit non-zero (cron will surface it).
- A repo's clone missing → skip it, list it under "skipped (no local clone)".
- Worker subagent crashed/timed out → record `repo#issue → errored`, move on.
- Never retry the same failing issue more than 2 ticks in a row; after that,
  park it in needs-human.

## Persistence

State lives in the **session** (resume via `--session-id ghi-orchestrator`).
Do not write state files; the session transcript is the SSOT. If the session is
lost, the loop self-heals on the next tick by re-deriving `seen` from
`gh pr list --search "Closes #"` across repos.
