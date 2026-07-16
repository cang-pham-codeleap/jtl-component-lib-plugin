# task-to-pr automation (headless mode)

This document describes headless assumptions already present in the interactive skill.
It does **not** invent new automation product behavior.

## When headless

Triggers that may start the workflow without a human in the loop for every keystroke:

- Scheduled polling of labeled issues / Jira queue
- Label-triggered GitHub Actions
- Jira webhook → agent session

## Asynchronous checkpoints

Interactive mode stops mid-turn and waits for human chat confirmation.

Headless mode treats checkpoints as **async gates**:

Approvals are `## Approval` annotations inside the artifact (`specs.md` / `plan.md` / `review-verdict.md`), not `*.approved` flag files. `Approved-by` = `git config user.name`.

| Checkpoint | Interactive | Headless |
|------------|-------------|----------|
| 1 Spec | Wait for chat approval → append `## Approval` to `specs.md` | Persist `specs.md`; wait until an `## Approval` block appears in it (human/out-of-band) before Stage 3 |
| 2 Plan | Wait for chat approval → append `## Approval` to `plan.md` | Persist `plan.md`; wait until `## Approval` appears in it |
| 3 Review | Wait for chat approval → append `## Approval` to `review-verdict.md` | Same pattern — wait until `## Approval` appears in `review-verdict.md` |
| 4 PR | Print draft; wait before invoking `create-pr` | Invoke `create-pr` skill (always draft — sole PR path). Human marking "Ready for review" is the approval act |

SIMPLE-tier tasks skip Checkpoints 1–2; their approval is the SIMPLE-path `Approved-by` line in `task-context.md`. Checkpoint 3 gates on reviewer verdict for **every** tier; teach-back (`teach-back-report.md`) runs **FULL tier only** — SIMPLE skips it (reviewer + debt + tests is its gate). The agent **must never** append an `## Approval` block ahead of the human's approval.

## Draft-PR-as-approval

In automation mode at Checkpoint 4:

1. Run tests
2. Invoke `create-pr` (always draft)
3. Do not auto-mark ready for review
4. Proceed to Stage 7 `reflect` drafts only; posting ticket comments still requires human approval (reflect skill) unless a separate human-approved automation policy is added later — **default remains human-gated posts**

## Failure reporting

Unchanged from interactive: any post-PR Jira/GitHub notification failure must report exact failed step + PR URL. Silent ticket-stale is forbidden.

## Cache note (carry-over)

Keep MCP config and model choice stable across stages in a single session so prefix cache remains warm.
