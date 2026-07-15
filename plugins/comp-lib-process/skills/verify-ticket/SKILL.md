---
name: verify-ticket
description: Use when the user asks "is this bug real?", "verify this ticket", "does this feature already exist?", or when task-to-pr Stage 0.6 must validate the ticket claim before branching/build. Produces verification-report.md with CONFIRMED / PARTIALLY-VALID / NOT-REPRODUCIBLE / ALREADY-EXISTS. Stops pipeline on negative verdicts.
---

# verify-ticket

## Overview

Do not trust the ticket. Prove or disprove the claim with codebase evidence before any implementation.

## Inputs

- Prefer `.claude/workflow/<ticket-id>/task-context.md`
- If only a ticket ref given: run `ticket-intake` first, then continue
- Use loaded project conventions (`docs/agents/` or jtl-init templates) for where components/blocks/recipes/registry live

## Steps

1. Extract the **CLAIM** from task-context (bug: X broken; feature: Y missing). Phrase as a claim, not a conclusion.
2. Spawn `Agent(subagent_type="deep-explore")` with prompt shaped like:
   - "Ticket claims: <CLAIM>. Find evidence FOR and AGAINST. Return file:line paths. Do not implement."
   - If deep-explore fails to start (type not found / namespaced): parent searches using registry/components/blocks/recipes paths from docs review; still write `verification-report.md` and note the fallback in the report. Never invent a verdict without evidence. Never skip the report.
3. Bug tickets:
   - Locate suspect path
   - When cheap, attempt minimal repro (failing test or short script). If repro is expensive, document why skipped.
4. Feature tickets:
   - Search registry, components, blocks, recipes for existing implementation
5. Write `.claude/workflow/<ticket-id>/verification-report.md`:

```markdown
# Verification report — <ticket-id>

- **Claim:** …
- **Verdict:** CONFIRMED | PARTIALLY-VALID | NOT-REPRODUCIBLE | ALREADY-EXISTS
- **Evidence for:**
  - `path:line` — …
- **Evidence against:**
  - `path:line` — …
- **Corrections for spec** (if PARTIALLY-VALID): …
- **Insufficient evidence?** yes/no — if yes, do NOT pick a verdict; ask human

## Draft comment (NOT posted)

<comment for GitHub issue and/or Jira explaining findings; include PR/next-step suggestion>
```

## Verdict rules

| Verdict | Meaning | Pipeline |
|---------|---------|----------|
| `CONFIRMED` | Evidence supports claim | Continue |
| `PARTIALLY-VALID` | Right substance, wrong details | Continue; feed corrections to spec |
| `NOT-REPRODUCIBLE` | Bug claim unsupported | **STOP** |
| `ALREADY-EXISTS` | Feature already implemented | **STOP** |

### Insufficient evidence

If deep-explore returns weak/no evidence either way: **do not** default to `PARTIALLY-VALID`. Say "insufficient evidence", present what was checked, ask human. Never guess a verdict.

## On STOP

1. Present report with file:line evidence
2. Suggest next step (close ticket, reword claim, point to existing API)
3. Show **drafted** ticket/issue comment
4. Post **only** after explicit human approval via `gh issue comment` and/or `addCommentToJiraIssue`

## Hard rules

- Never start Stage 4 implement from this skill
- Never post comments without human approval
- Standalone-invocable: "is this bug real?" works outside the hub
