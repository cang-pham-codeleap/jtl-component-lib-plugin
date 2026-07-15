---
name: create-ticket
description: Use when the user says "create ticket", "file an issue", "open a ticket", or starts freeform work with no GitHub issue and no Jira key. Fills the plugin ticket template and creates a GitHub issue before task-to-pr can run.
---

# create-ticket

## Overview

Always work from a ticket. Freeform work with no GH/Jira ref must create a GitHub issue from the shared template first — then hand off to `task-to-pr` / `ticket-intake`.

Template path: [`./TICKET_TEMPLATE.md`](./TICKET_TEMPLATE.md).

## When to use

- User wants a new ticket / issue filed
- `task-to-pr` Stage 0 finds no GH and no Jira ref
- Standalone: "create a ticket for …"

## When NOT to use

- GH issue and/or Jira already exist → use `ticket-intake`
- User only wants analysis, not a filed issue

## Steps

1. Read [`./TICKET_TEMPLATE.md`](./TICKET_TEMPLATE.md) (plugin docs).
2. Interview human for **must** fields (do not invent):
   - Relevant Component
   - Problem to solve
   - To do/actions
   - Acceptance Criteria
   - Test process
   - Tester (internal)
   - Description of the breaking changes (explicit "none" is allowed)
3. Optional fields only if human provides: User Story / JTBD, Designs, Technical notes, Stakeholder validation.
4. Build issue body by filling the template sections with answers. Leave unanswered optional sections as empty or omit.
5. Confirm title + body with human (one short preview).
6. Create GitHub issue:
   ```bash
   gh issue create --title "<title>" --body "<filled template>"
   ```
   Use repo default; do not force labels unless human asks.
7. Print issue number + URL. Instruct: re-run `task-to-pr` (or `ticket-intake`) with that issue.

## Hard rules

- Never invent acceptance criteria, problem, or test steps.
- Never create Jira in this skill unless human explicitly asks in a follow-up (out of default path).
- Never write `*.approved`, never push, never open PR.
- Never start implementation from this skill.
- On `gh issue create` failure: report exact error; do not fake an issue number.

## Standalone output

```
Created: #<n> <url>
Next: task-to-pr with issue #<n>
```
