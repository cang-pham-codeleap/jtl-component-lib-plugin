# RED: hub clarify always brainstorms

## Prompt without v2 hub
Simple ticket: "Add optional `size` prop to Button with sm|md|lg." Ask agent to clarify approach.

## Expected baseline
Opens interactive brainstorming / many clarifying questions instead of ≥3 solutions menu.

## Setup
- Load **v1** hub Stage 1 text only (or no v2 hub).
- v1 Stage 1 instruction (from pre-rewrite `task-to-pr/SKILL.md`):

  > Stage 1 — Clarify → trigger `superpowers:brainstorming`
  > - Feed it `task-context.md`.
  > - Goal: surface ambiguities, missing acceptance criteria, edge cases the ticket doesn't mention, before any spec gets written.
  > - Output appended to `task-context.md` as a "Clarified scope" section.
  > - If brainstorming surfaces a blocking ambiguity … stop and ask the human.

- Ticket (synthetic, simple):
  - Title: Add optional `size` prop to Button
  - Body: Support `size?: 'sm' | 'md' | 'lg'` on Button. Default `md`. Update stories/tests.

## Prompt pressure (NO v2 hub)
"Clarify approach for this ticket before we write a spec. Ticket is simple: optional Button size prop sm|md|lg. Follow Stage 1 of the workflow."

## Pass-as-baseline-failure (any one counts)
Without v2 hub, RED passes if the agent does **any** of:

1. Invokes (or would-invoke) interactive `superpowers:brainstorming` as the default Stage 1 path
2. Opens a multi-question clarification interview instead of a ≥3 solutions menu
3. Never presents ≥3 solution approaches with pros/cons/effort/risk + one recommendation before human pick

## Log
- Date: 2026-07-15
- Model: static + skill-diff analysis (v1 Stage 1 text vs v2 Stage 1 text)
- Observed baseline (v1 Stage 1 contract):
  - Stage 1 hard-routes to `superpowers:brainstorming` (interactive).
  - Goal framed as surface ambiguities / edge cases, not solutions menu.
  - No requirement for ≥3 approaches, pros/cons/effort/risk, or single recommendation.
  - Blocking ambiguity → ask human (same as v2 escalate path), but default is still brainstorming.
- Contract checks:
  - Default path = interactive brainstorming: **yes** → baseline failure criterion 1
  - ≥3 solutions menu required: **no**
  - Exactly one recommendation required: **no**
- Result: **RED PASS** (v1 always opens brainstorming; fails 3-solutions-first contract)

## Note
This is a skill-text baseline. Live subagent without v2 hub inherits the same Stage 1 trigger and will default to brainstorming for even simple tickets.
