# Slack Notification Reference

## Transport

Slack Incoming Webhook.

Resolve `SLACK_WEBHOOK_URL` from the **active coding repository** (where the task is being implemented), not from this plugin repository.

Lookup order:

1. `<active-repo>/.env.local`
2. `<active-repo>/.env`
3. Current process environment (`$SLACK_WEBHOOK_URL`)

Example:

`/Users/canqpham/Documents/sources/jtl-platform-ui-react/.env.local`

## Send call

Use a single HTTP POST (for example via `curl`) to `SLACK_WEBHOOK_URL`:

```bash
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-type: application/json" \
  --data '{"text":"<envelope below>"}'
```

Delivery is **required** at every checkpoint. If `SLACK_WEBHOOK_URL` is missing,
or the webhook call fails, stop and ask the human to fix configuration before
continuing.

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

## Configuration

Set webhook URL in the active repo env file (recommended) or process environment:

```
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
```

Recommended local setup for per-repo isolation:

- Put it in `<active-repo>/.env.local` (gitignored).
- Keep CI value in secret store.

Never commit webhook URLs into tracked files.
