name: SSOT Specification
description: File a new SSOT (single source of truth) for an in-place patch to `@earendil-works/pi-coding-agent`.
title: "[SSOT] "
labels: ["documentation", "ssot"]
body:
  - type: markdown
    attributes:
      value: |
        ## How to use this template

        One issue per pattern/fix. Title format: `[SSOT] <short topic>`.

        Sections are in the canonical order — keep them in this order. Tables and code blocks are encouraged.

        **On `pi update` rollback:** append a new bullet to the *Update log* section, do not create a new issue.

        See [pi_agents_and_fixes#1](https://github.com/drrozen-med/pi_agents_and_fixes/issues/1) for the reference SSOT body.
  - type: input
    id: status
    attributes:
      label: Status header
      placeholder: "Patched in-place against @earendil-works/pi-coding-agent X.Y on YYYY-MM-DD"
      description: "First line of the body. Include scope, opt-in flags, and the agent version targeted."
    validations:
      required: true
  - type: textarea
    id: problem
    attributes:
      label: "1. Problem"
      placeholder: |
        What broke? Verbatim error messages help. What was the loader/agent doing wrong? Why is it bad (user-visible impact)?
      description: "Root cause, not symptoms. Include a code block of the error if available."
    validations:
      required: true
  - type: textarea
    id: solution
    attributes:
      label: "2. Solution (layers)"
      placeholder: |
        | # | Layer | What it does | Where |
        |---|-------|--------------|-------|
        | 1 | ...   | ...          | path:line |
    validations:
      required: true
  - type: textarea
    id: tunables
    attributes:
      label: "3. Tunable env vars"
      placeholder: |
        | Env | Default | Purpose |
        |-----|---------|---------|
        | `PI_FOO` | `1000` | ... |
    validations:
      required: false
  - type: textarea
    id: files
    attributes:
      label: "4. Files patched"
      placeholder: |
        - `node_modules/@earendil-works/pi-coding-agent/dist/path/to/file.js`: what changed (line range)
    validations:
      required: true
  - type: textarea
    id: verified
    attributes:
      label: "5. Verified behavior"
      placeholder: |
        - **Default** (`pi`): ...
        - **Strict** (`PI_...=1 pi`): ...
    validations:
      required: true
  - type: textarea
    id: upstream
    attributes:
      label: "6. Upstream precedents"
      placeholder: |
        - `owner/repo#123` — what it added or asked for
    validations:
      required: false
  - type: textarea
    id: internal
    attributes:
      label: "7. Related internal work"
      placeholder: |
        - `drrozen-med/NurseBridge-prep#1966` — ...
    validations:
      required: false
  - type: textarea
    id: update_log
    attributes:
      label: "8. Update log"
      placeholder: |
        - **YYYY-MM-DD** — initial patch / re-apply after `pi update` to vX.Y
    validations:
      required: true
