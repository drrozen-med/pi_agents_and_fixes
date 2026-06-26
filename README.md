# pi_agents_and_fixes

SSOT (single source of truth) and documentation for Pi agent/extension
patterns, fixes, and resilience work. This repo is **not** a fork of
`pi-mono` and does not contain source — it contains the **specifications
and rationale** for in-place patches we apply to the installed global
`@earendil-works/pi-coding-agent` (and its `dist/` artifacts) so the
work survives `pi update`.

## Why this repo exists

`pi update` reinstalls the agent and overwrites any in-place edits to
`node_modules/@earendil-works/pi-coding-agent/`. Rather than fight
upstream on every issue, we document each fix here, link the upstream
GHIs we built on, and re-apply the patch on next update.

## Canonical entry point

➡️ **Issue #1 — [SSOT] Graceful extension loading: wrap, isolate, quarantine**
(https://github.com/drrozen-med/pi_agents_and_fixes/issues/1)

That issue is the **live spec**. Read it first; everything in this repo
points back to it or to upstream issues.

## Conventions for new SSOT entries

- One issue per pattern/fix. Title format: `[SSOT] <short topic>`.
- Body sections in this order: **Problem → Solution (layers) → Tunables → Files patched → Verified behavior → Upstream precedents → Related internal work → Update log**.
- Reference upstream issues and internal issues (`NurseBridge-prep`, `parents-apps`) inline. Do not duplicate the work in those repos — link instead.
- When `pi update` rolls the patch back, the **Update log** section of the SSOT is the place to re-apply from. No separate changelog file.

## Specialized worker agents (`agents/`)

This repo also persists **custom pi subagent definitions** (`.md` files with
`name`/`description` frontmatter). These are the shareable, versioned
counterpart to the loose agent files that otherwise live only in
`~/.pi/agent/agents/` and don't survive reinstall or sync across machines.

Because the pi `subagent` extension discovers agents from **two fixed
locations only** — `~/.pi/agent/agents/` (user) and the nearest `.pi/agents/`
(project) — agents in this repo are made discoverable by **symlinking** them
into `~/.pi/agent/agents/`, exactly the way bundled example agents
(`planner.md`, `worker.md`, …) already are:

```bash
for a in agents/*.md; do
  ln -sf "$(pwd)/$a" "$HOME/.pi/agent/agents/$(basename "$a")"
done
```

Current agents: `ghi-triage`, `ghi-pr-worker` (part of the GHI→PR
orchestrator — see `[SSOT]` issue #4 and `skills/ghi-orchestrator/`).

## Related internal repos

- `drrozen-med/NurseBridge-prep` — the fleet/extension consumer (`#1966` silent-catch audit, `#3908` Pi Worker Extension)
- `drrozen-med/parents-apps` — cross-cutting ecosystem work
- `drrozen-med/claude-launcher` — universal wrapper for Claude Code CLI

## Re-symlinking after clone / `pi update`

Both `skills/` and `agents/` need to be (re)pointed at after a fresh clone or
a `pi update` that resets `~/.pi/agent/`. The `skills/` pointer is in
`~/.pi/agent/settings.json` (`"skills": ["…/pi_agents_and_fixes/skills"]`);
the `agents/` symlinks are recreated by the one-liner above.
