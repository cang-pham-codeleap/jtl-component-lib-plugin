---
name: resolve-pr-comment
description: Use when the user says "resolve PR comments", "check PR feedback", "address review comments", "/resolve-pr-comment", or wants open PR review threads verified and fixed before merge. Also when feedback arrives on the current branch PR and the agent must not implement until comments are verified against code.
---

# resolve-pr-comment

## Overview

Turn PR review feedback into verified fixes. **Never implement from a comment until the comment is checked against the real code and the human has approved a plan.**

**REQUIRED BACKGROUND:** Treat feedback like `superpowers:receiving-code-review` — technical claims need evidence; wrong feedback is rejected, not performed.

## When to use

- `/resolve-pr-comment` or "resolve PR comments"
- "Check review on this PR / address long's comments"
- Open PR has issue comments, inline review comments, or review bodies to handle
- Agent about to "just fix what the reviewer said" without verifying

## When NOT to use

- Writing a new PR review of others' code → use review skills
- Post-merge ticket notify → `reflect`
- No PR exists yet → create PR first (`create-pr` / hub Stage 6)

## Inputs

- PR number/URL **or** current branch PR (`gh pr view`)
- Optional: focus one comment/thread

## Pipeline (do in order)

### 1 — Resolve PR

```bash
gh pr view --json number,title,url,state,baseRefName,headRefName
# or: gh pr view <n> --json …
```

If no PR for branch: stop; say so.

### 2 — Fetch all feedback

Load **all** of:

| Source | How |
|--------|-----|
| Issue comments | `gh api repos/<owner>/<repo>/issues/<n>/comments` |
| Inline review comments | `gh api repos/<owner>/<repo>/pulls/<n>/comments` |
| Reviews (body/state) | `gh api repos/<owner>/<repo>/pulls/<n>/reviews` |

Dedupe by id. Skip empty review bodies. Note author + URL per item.

### 3 — Verify each comment (no coding yet)

For **each** discrete concern (split multi-bullet comments):

1. Find related code/skill/docs on **this branch**.
2. Classify:

| Status | Meaning |
|--------|---------|
| `OK` | Already handled correctly — no change |
| `partial` | Some handling; gap remains |
| `gap` | Valid concern; not handled |
| `invalid` | Factually wrong / out of scope / conflicts with locked decision |
| `needs-product` | Technical check done; needs human product choice |

3. Record **evidence** (path + behavior), not vibes.

**Hard rule:** Do **not** implement in this step. Do **not** agree performatively with wrong feedback.

### 4 — Report

Present table:

| # | Author | Concern (short) | Status | Evidence | Proposed action |
|---|--------|-----------------|--------|----------|-----------------|

Then: what is already fine vs what needs work.

### 5 — Ask until ≥95% confident

If any `needs-product`, ambiguous scope, or multiple fix shapes:

- Ask human **decision questions** (A/B/C preferred).
- State **assumptions** when defaulting.
- Loop until product choices locked.

**Do not** invent product policy to "save a round trip."

### 6 — Plan (still no code)

Output short plan:

1. File touch list (fewest files)
2. Exact rule/behavior per change
3. Order of work
4. Out of scope / skipped
5. Whether PR thread reply will map each bullet (yes by default)

**🛑 Checkpoint — wait for human approve** before any edit.

### 7 — Implement (only after approve)

- Surgical diffs only; match surrounding style.
- Prefer root-cause / shared policy over per-callsite hacks.
- No drive-by refactors.
- Do **not** commit or push unless human asks.

### 8 — Reply on PR thread

After implement (no extra approve for reply):

- Post **one** issue comment on the PR mapping each original bullet → outcome (fixed / already OK / rejected + why / deferred).
- Use `gh api repos/.../issues/<n>/comments` or `gh pr comment`.
- Be concrete; no filler.

### 9 — Closeout

- Show `git status` / diff summary.
- List what was skipped and when to add it.
- Commit/push only if human asks.

## Comment type handling

| Type | Notes |
|------|--------|
| Issue (conversation) comment | Primary for multi-bullet design questions |
| Inline `pulls/.../comments` | Anchor to `path` + `line`; verify that hunk still exists |
| Review body | Treat as one or more concerns; same verify table |
| Bot noise (empty approve) | Skip with one-line note |

## Rationalizations (do not)

| Excuse | Reality |
|--------|---------|
| "Reviewer said so — just do it" | Verify first. Wrong feedback stays wrong. |
| "Faster to code then ask" | Violates plan checkpoint; rework risk. |
| "Mostly right, I'll fill gaps" | Product gaps need human; don't invent policy. |
| "Reply later / skip reply" | Reply is part of resolve; post after implement. |
| "Only issue comments matter" | Inline + review bodies count too. |

## Red flags — STOP

- Editing files before verify table + approved plan
- Accepting every comment without evidence
- Silent scope expansion ("while I'm here")
- Posting reply that claims fix without matching diff
- Commit/push without human ask

## Hard rules

- Verify → report → decide → plan → **approve** → implement → reply.
- Never write `*.approved` for task-to-pr gates from this skill.
- Never force-push, never merge PR.
- Reject invalid feedback with evidence; still reply so thread closes cleanly.

## Standalone output shape

1. PR link + comment count  
2. Verify table  
3. Questions (if any) **or** plan waiting approve  
4. After approve: files changed + PR reply URL  
