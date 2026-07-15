---
name: reflect
description: Use after a PR exists when the user says "notify the ticket", "comment on the issue with the PR", "update Jira that this is implemented", or when task-to-pr Stage 7 runs. Drafts GitHub and Jira comments plus a Jira transition; posts only after human approval. Absorbs post-PR ticket notification from the old task-to-pr ship stage.
---

# reflect

## Overview

Close the loop with reporters: PR URL + short implementation summary. Draft first, post after human review.

## Inputs

- PR URL (required)
- GitHub issue number and/or Jira key — from args or `.claude/workflow/<ticket-id>/task-context.md`
- One-paragraph summary of what shipped (from specs/teach-back if available)

## Steps

1. Load refs from args or task-context. If missing, ask human.
2. **Draft only** (print for human; do not call write APIs yet):

### GitHub issue comment draft

```text
Hi <reporter if known>,

This is implemented in <PR_URL>.

<summary one paragraph>

Please review the PR when you can.
```

### Jira comment draft

Same content, Jira-friendly formatting (no GH-only markdown that breaks Jira; use plain links).

### Jira transition proposal

- Explicit name, e.g. `→ In Review` (or project-appropriate status). Do not invent status names if unknown — list candidate and ask.

3. 🛑 **Stop for human approval** of drafts + transition.
4. On approval, post in order:
   - `gh issue comment <n> --body "..."` when GH issue present
   - Atlassian `addCommentToJiraIssue` when Jira present
   - Atlassian `transitionJiraIssue` when transition approved
5. **Failure reporting:** if any post fails, report exact failed call + what succeeded. Never silent "PR created but ticket stale."

## Hard rules

- Never post before explicit human approval
- Never transition Jira without naming the target status in the draft
- Notify the GitHub **issue** via `gh issue comment`; never treat `gh pr comment` as the ticket/issue notify
- Standalone: "notify the ticket about PR X" works without full hub
