---
name: create-jira-ticket
description: Use when the user asks to create/file a new Jira ticket in the JTL Cloud Platform (CP) project, wants a ticket written in the same format as an existing reference ticket (e.g. CP-4301), or pastes raw notes/a quote and asks for it to be turned into a ticket. Triggers on "create a ticket", "file this as a Jira ticket", "same format as CP-xxxx".
---

# Create Jira Ticket (JTL Cloud Platform template)

## Overview

Turns a raw problem description (a quote, Slack message, research notes) into a
well-formed Jira ticket in the **CP** (JTL Cloud Platform) project, using the
structured description template observed on existing tickets (reference:
CP-4301). Never invents missing fields silently — ask the human first, batched
into one round of questions, until confident the ticket is complete and correct.

**Cloud site:** `jtl-software.atlassian.net` — use this as `cloudId` for all
Atlassian MCP calls.

## Description template (8 fixed sections, in this order)

```
**Relevant Component:**

* <component/package name, e.g. Public Component Library (`jtl-platform-ui-react`)>

**Problem to solve (must):**

* <what's broken/unproven/blocking, bullet list>

**User Story / Jobs To Be Done (optional):**

* <"As a ___, I want ___, so that ___" or "n.a.">

**Designs:**

* <links, or "n.a.">

**To do/actions (must):**

* <concrete action items, bullet list>

**Acceptance Criteria (must):**

* <verifiable, testable statements>

**Technical notes/developer hints:**

* <root cause, links to source/spikes, references>

**Test process (must):**

* <how the fix/PoC will be validated>
```

Keep bold section headers and bullet lists exactly like this — it's what makes
the ticket match the existing CP style. If a section truly doesn't apply, put
`n.a.` rather than deleting it.

## Workflow

### 1. Gather the raw material

Read whatever the user gave you (quote, message, doc, code). If they reference
a specific existing ticket to copy the format from, fetch it first:

```
mcp_atlassian-mcp_getJiraIssue(cloudId="jtl-software.atlassian.net", issueIdOrKey="CP-4301", fields=["*all"])
```

Pull from it: `project.key`, `issuetype.name`, `labels`, `priority.name`,
`components[].name`, `parent.key` (if any), and the description section
structure. Treat these as _candidate defaults_, not final answers.

### 2. Identify what's missing or ambiguous, then ask ONE batched question round

Never guess silently on these — use `vscode_askQuestions` with recommended
defaults pre-filled so the human can confirm quickly instead of typing
everything out. Typical open points, only ask the ones actually unresolved:

- **Scope**: is this a decision/finding record only, or does it also carry
  actionable next steps (To do/Acceptance Criteria)?
- **Parent epic**: link to an existing epic, or none?
- **Summary/title**: propose 1-2 candidate titles (matching the existing
  `[Phase X] [Tag] ...` bracket style if the project uses one) and let the
  user pick or free-type.
- **Assignee**: self-assign, specific person, or unassigned? If given a name
  instead of an account ID, resolve it with
  `mcp_atlassian-mcp_lookupJiraAccountId`.
- **Priority & labels**: reuse the reference ticket's values, or different?
- **Linking**: should the new ticket explicitly link to the reference ticket
  (e.g. "relates to")?

Do not proceed to creation until these are answered. If the user's answers
still leave a real gap (e.g. no project key at all, and no reference ticket
given), ask a follow-up — don't fabricate.

### 3. Draft the description

Fill the 8-section template using the user's raw material verbatim where
possible; only lightly edit for clarity. Ground technical claims in the
actual codebase/repo when available (grep/read relevant files) instead of
inventing details — e.g. reference real file paths, real doc names.

### 4. Create the issue

```
mcp_atlassian-mcp_createJiraIssue(
  cloudId="jtl-software.atlassian.net",
  projectKey="CP",
  issueTypeName="Aufgabe",       # Jira's internal name for "Task" in this project
  summary="<confirmed title>",
  description="<8-section markdown>",
  contentFormat="markdown",
  assignee_account_id="<resolved account id, omit if unassigned>",
  additional_fields={
    "labels": ["<label1>", "<label2>"],
    "priority": {"name": "<Priority>"},
    "components": [{"name": "<Component>"}]
  }
)
```

If the user wants an explicit link to another issue, use
`mcp_atlassian-mcp_createJiraIssue`'s `parent` param for parent/child, or
follow up with an issue-link call if a "relates to" (not parent/child) link is
needed — check `mcp_atlassian-mcp_getIssueLinkTypes` for the link type ID if
unsure.

### 5. Confirm

Report back the created ticket's key, URL, and a one-line summary of the
field choices made (project/type/assignee/priority/labels/parent), so the
human can verify at a glance.

## Notes

- `issueTypeName="Aufgabe"` is this org's Jira name for a generic Task — don't
  translate it to "Task", the API call will fail to match.
- Labels in this project often encode a sprint/quarter (e.g. `P8_Q3/26`) —
  these go stale; always confirm rather than blindly reusing an old ticket's
  labels weeks/months later.
- Never create the ticket before the human has confirmed the ambiguous
  fields from step 2 — a wrong assignee/priority/parent is easy to create and
  annoying to clean up in Jira.
