# Teams Notification Reference

## MCP Server

`local-mcp` — macOS-native Teams integration. Config in `.vscode/mcp.json`.

## Tool call

```
local-mcp: teams_send_message
  chat_id: <Teams chat id from teams_list_chats>
  text: <envelope below>
  confirm: true
```

Tool behavior is two-step by default:

1. First call without `confirm` returns a preview.
2. Second call with `confirm: true` sends the message.

If `local-mcp` or `teams_send_message` is unavailable, **skip silently** — log
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

| Checkpoint            | Source                                        | What to send                                              |
| --------------------- | --------------------------------------------- | --------------------------------------------------------- |
| SIMPLE-path gate      | `task-context.md § Clarified scope`           | Full change-list block (files + what changes)             |
| Checkpoint 1 — Spec   | `.jtl/workflow/<ticket-id>/specs.md`          | Full file body                                            |
| Checkpoint 2 — Plan   | `.jtl/workflow/<ticket-id>/plan.md`           | Full file body                                            |
| Checkpoint 3 — Review | `.jtl/workflow/<ticket-id>/review-verdict.md` | Full file body                                            |
| Checkpoint 4 — PR     | PR title + description + diff stat            | `gh pr view --json title,body` + `git diff --stat HEAD~1` |
| Stage 7 — Reflect     | PR URL + drafted GH/Jira comment bodies       | From reflect skill output                                 |

## Channel target

Resolve and store a stable chat target before first send:

1. List available chats via `teams_list_chats`.
2. Pick one `chat_id` for notifications (for example, "Just me" or a team chat).
3. Save it to `TEAMS_NOTIFY_CHAT_ID` in your shell env.

Example:

```
TEAMS_NOTIFY_CHAT_ID="19:...@thread.tacv2"
```

For channel posts (team/channel ids) use `teams_send_channel_message` instead of
`teams_send_message`.
