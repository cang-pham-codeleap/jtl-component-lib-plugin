---
name: teach-back-verification
description: Use when about to claim substantial multi-file work is complete or done, before merging or opening a PR, at the end of a long implementation session, or when the user asks to verify understanding of a change ("quiz me", "explain what you did", "am I sure I understand this").
---

# Teach-Back Verification

## Overview

Tests passing proves the code runs. It does not prove anyone — including you — understands what shipped. Work is **done** only when a fresh reader can pass a quiz about the change using your report alone, and the user then passes it too.

**"Done" without the gate is not done.** Mechanical checks (tests green, lint clean, docs updated, pushed) are prerequisites, not completion.

## When to Use

- Substantial work: 3+ files changed, new behavior, or anything headed for merge/PR.
- End of a long session where the user saw only fragments of what happened.

**When NOT to use:** typo fixes, one-liners, config bumps, pure formatting. Don't gate trivia.

## The Gate

1. **Write the understanding report** — copy `report-template.html` from this skill's folder into the session scratchpad (or user-specified path) as `understanding-report.html`. Fill every section: what changed, why, how it behaves (gate-flow diagram if the change has decision shape), key code paths, decisions & deviations, risks. **Never restyle the template** — replace content only.
2. **Write the quiz** — 5–8 questions at the bottom of the report covering behavior, edge cases, integration points, decisions. Rules: answerable ONLY from a complete report, never from the question's own wording; no trivia (line numbers, variable names). Write the **answer key in a separate file** the quiz-taker never sees; every answer cites the code that proves it.
3. **Fresh-reader gate** — use an isolated, no-tools reader when the active
   harness supports it. Claude Code dispatches
   `Agent(subagent_type="comp-lib-process:quiz-taker", description="teach-back quiz CP-XXXX", prompt="<report content + questions only>")`. In a harness without an isolated reader, record `Fresh-reader gate: unavailable` in the report, perform the documented self-review, and rely on CI plus human approval; do not claim an isolated gate ran.
4. **Grade against code, not memory** — compare its answers to the key, and re-verify each key claim against actual source. Pass = every question correct.
5. **On fail, diagnose which failure:**
   - Subagent wrong but key correct → **docs gap**. Rewrite the report section, re-run the gate.
   - Key wrong vs actual code → **you misunderstood your own change**. Investigate the code, fix understanding (and the code if needed), restart from step 1.
6. **User quiz** — only after the gate passes, give the user the report path and have them take the quiz (answers stay behind the `REVEAL ANSWER` toggles). Grade, explain misses. Declare done / invite merge **only after the user passes perfectly**.

## Example prompt shape (step 3)

The `quiz-taker` agent prompt contains ONLY this — report, then questions:

> "You are taking a comprehension quiz. Below is a report on a code change, followed by questions. Answer each question using ONLY the report. Do not use tools. If the report doesn't contain the answer, say 'NOT IN REPORT'."

`NOT IN REPORT` answers are docs gaps — treat as fails.

## Rationalizations — all mean STOP

| Excuse | Reality |
|---|---|
| "Tests green, checks all clear → done" | Checks verify execution, not understanding. The gate IS the done-check. |
| "Not asked, not blocking" | The user asking "is it done?" IS asking for this. Done includes the gate. |
| "User is in a hurry — merge now" | Hurry is when unknown unknowns merge. The gate takes minutes; a misunderstood merge costs days. |
| "The diff is self-explanatory" | Diffs show text, not behavior on existing code paths. |
| "I obviously understand my own change" | Step 5b exists because agents regularly fail their own answer key. |
| "I'll self-grade, skip the subagent" | You wrote the docs; you can't see their gaps. Fresh reader or no gate. |
| "2 quick questions is enough" | Fewer than 5 questions can't cover behavior + edges + integration. |

## Red Flags — you are about to violate the gate

- Typing "done", "ready to merge", "all clear" with no `understanding-report.html` in the session.
- Fresh reader given file access or conversation context.
- Questions whose wording contains the answer.
- Grading from memory without re-reading the source.
- Presenting the quiz to the user before the subagent gate passed.
- Claiming an isolated gate passed without a real isolated reader run in this session.
