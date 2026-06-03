# Superset FE Browser Debugging

Guide the agent through debugging Superset frontend issues using Pi's browser automation
stack. Covers tool selection, workflow patterns, and configuration.

## Quick reference: which tool when

| Scenario | Tool | Why |
|---|---|---|
| Explore an unauthenticated Superset page, run `snapshot -i`, click elements, fill forms | `agent_browser` (pi-agent-browser-native) | Dedicated Chromium, bulletproof ref guards, click-dispatch verification, scroll-noop detection |
| Inspect/debug a **signed-in** Superset instance (your dashboards, your permissions) | `pi-chrome` tools (`chrome_tab`, `chrome_snapshot`, `chrome_click`, `chrome_screenshot`, `chrome_evaluate`) | Drives YOUR Chrome with your existing session — no login needed |
| Deep CDP inspection: performance traces, HAR dumps, source-mapped console errors, network forensics | MCP `chrome-devtools` (via pi-mcp-adapter) | Google's full Chrome DevTools Protocol — 26+ tools |
| Quick smoke/QA check of a Superset page | `agent_browser` with `qa` preset | One call: open → wait → assert text → screenshot → network/console/error diagnostics |
| Multi-step deterministic workflow | `agent_browser` with `job` preset | Constrained steps: open, fill, click, assertUrl, assertText, screenshot |
| Visual comparison (staging vs local) | `pi-chrome`: `chrome_screenshot` both URLs, then compare | Side-by-side visual diff |
| Network forensics (find failing API call) | `agent_browser`: reproduce bug → `network requests` / `network request <id>` | Request/response body inspection |
| React DevTools introspection | `agent_browser`: `open --enable react-devtools <url>` then `react tree` / `react inspect <fiberId>` | Component tree, renders, suspense boundaries |

## Installed stack (as of 2026-06-03)

```bash
# Already installed (no action needed)
pi-agent-browser-native   # registered as `agent_browser` tool
pi-mcp-adapter            # MCP bridge for chrome-devtools-mcp

# Optional: add for signed-in Superset workflows
pi install npm:pi-chrome
# Then: /chrome onboard → /chrome authorize
```

## Common Superset FE debugging patterns

### Pattern 1: Reproduce a visual bug on an unauthenticated page

```
agent_browser open http://localhost:8088/superset/welcome/
agent_browser snapshot -i
# Identify the target element @ref, then:
agent_browser screenshot .dogfood/before.png
agent_browser click @e<target>
agent_browser screenshot .dogfood/after.png
```

### Pattern 2: Debug a signed-in dashboard rendering issue

```
chrome_tab(list)                                    # find your Superset tab
chrome_tab(activate, urlIncludes:"superset")        # switch to it
chrome_snapshot(uid:"<element-uid>")                # inspect the dashboard
chrome_evaluate("document.querySelector('.dashboard').innerHTML.length")  # check state
chrome_screenshot("./.dogfood/dashboard-bug.png")   # capture evidence
```

### Pattern 3: Trace a failing API call

```
agent_browser open http://localhost:8088/
agent_browser network requests --filter "/api/v1/"
# Reproduce the bug:
agent_browser click @e<button>
agent_browser network request <req-id>    # inspect response body
```

### Pattern 4: React component tree inspection

```
agent_browser open --enable react-devtools http://localhost:8088/
agent_browser react tree
agent_browser react inspect <fiberId>
```

### Pattern 5: QA smoke test on Superset

```
agent_browser qa {
  url: "http://localhost:8088/",
  expectedText: "Superset",
  screenshotPath: ".dogfood/superset-qa.png"
}
```

### Pattern 6: Authenticated multi-step form flow

```
chrome_navigate("http://localhost:8088/chart/add")
chrome_snapshot(uid:"<form-uid>")
chrome_fill(uid:"<slice_name>", "Test Chart")
chrome_click(uid:"<viz_type_dropdown>")
chrome_screenshot("./.dogfood/chart-form.png")
# Stop before submit unless user explicitly asks
```

## Configuration

### pi-chrome setup (for signed-in Superset)

```bash
pi install npm:pi-chrome
# In Pi terminal:
/chrome onboard    # guided setup: loads Chrome extension
/chrome doctor     # verify connectivity
/chrome authorize  # grant agent access (default: 15 min)
```

The Chrome extension runs in your existing Chrome profile. All Superset sessions,
permissions, and dashboards are available. The loopback bridge (`127.0.0.1:17318`)
ensures no external access.

### chrome-devtools-mcp (for deep CDP debugging)

Create `.mcp.json` in the project root:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

Access via pi-mcp-adapter proxy:
```
mcp({ search: "screenshot" })
mcp({ search: "performance" })
```

## Agent guidance

- **Prefer `agent_browser` for isolated Chromium work** — it has bulletproof
  stale-ref guards, click-dispatch verification, scroll-noop detection, and QA
  presets.
- **Use `pi-chrome` for authenticated Superset** — the agent never needs to log
  in; it uses your real session.
- **Use `chrome-devtools-mcp` (via pi-mcp-adapter) for deep CDP** — performance
  traces, HAR dumps, source-mapped errors.
- **Save evidence screenshots to `.dogfood/`** — timestamped, reproducible.
- **Stop before submit** — if the user says "stop before order/post/purchase/submit",
  `agent_browser` enforces this with `promptGuard`.
- **Verify clicks** — `agent_browser` checks that DOM events actually fired.
  If `clickDispatch` failure, re-snapshot and retry with current refs.
- **Check `details.artifactVerification`** before claiming a screenshot or
  download was saved successfully.
- **DuckDuckGo may block automated search** — use direct URL navigation or
  npm registry API (`curl -s https://registry.npmjs.org/-/v1/search?text=...`)
  for package research.