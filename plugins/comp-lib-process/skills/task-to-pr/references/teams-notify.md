# Teams Notification Reference

## MCP Server

`local-mcp` — macOS-native Teams integration. Config in `.vscode/mcp.json`.

## Tool call

```
local-mcp: send_teams_message
  recipient: <channel or user — configure per project>
  message: <envelope below>
```

If `local-mcp` or `send_teams_message` is unavailable, **skip silently** — log
`[teams-notify] unavailable, skipping` and continue the pipeline. Never block on delivery.

## Message envelope

```
🛑 [<ticket-id>] — <Stage Name>

<full artifact content>

---
Ticket: <ticket URL>
Branch: <git branch>
Action: Reply "approved" in chat to continue.
```

For Stage 7 (✅ already shipped) replace 🛑 with ✅ and omit the Action line.

## Artifact content per checkpoint

| Checkpoint | Source | What to send |
|---|---|---|
| SIMPLE-path gate | `task-context.md § Clarified scope` | Full change-list block (files + what changes) |
| Checkpoint 1 — Spec | `.jtl/workflow/<ticket-id>/specs.md` | Full file body |
| Checkpoint 2 — Plan | `.jtl/workflow/<ticket-id>/plan.md` | Full file body |
| Checkpoint 3 — Review | `.jtl/workflow/<ticket-id>/review-verdict.md` | Full file body |
| Checkpoint 4 — PR | PR title + description + diff stat | `gh pr view --json title,body` + `git diff --stat HEAD~1` |
| Stage 7 — Reflect | PR URL + drafted GH/Jira comment bodies | From reflect skill output |

## Channel target

Set `TEAMS_NOTIFY_TARGET` in your shell env, or hardcode a default in this file:

```
default: "me"   # sends as self-chat; change to channel name e.g. "Engineering > dev-workflow"
```
