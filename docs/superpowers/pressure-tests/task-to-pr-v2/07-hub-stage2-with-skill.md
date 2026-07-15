# GREEN: hub Stage 2 — superpowers design doc (workflow-only path)

## Setup

Same synthetic ticket as RED. Stage 1 already complete:

- Ticket: CP-4216 — optional Button `size` prop sm|md|lg
- Human pick: Option A (prop + CSS map)
- `task-context.md` has `## Clarified scope`
- `verification-report.md`: CONFIRMED
- Workflow dir: `.claude/workflow/CP-4216/`

Subject must Read + follow `plugins/comp-lib-process/skills/task-to-pr/SKILL.md` Stage 2.
Stop after Stage 2 response / Checkpoint 1 wait (do not run Stage 3+).

## Prompt (WITH updated hub)

1. Read `plugins/comp-lib-process/skills/task-to-pr/SKILL.md` and follow Stage 2 exactly.
2. User: "Stage 1 done; I pick Option A. Run Stage 2 Spec now."
3. Do not invent Speckit/`specify` usage.
4. Do not write `*.approved`.
5. Do not re-open full interactive brainstorming.
6. Do not write under `docs/superpowers/specs/`.

## Pass criteria

- Read skill first
- No Speckit/`specify`/Bash `speckit` invoke
- Write (or would write) **only** `.claude/workflow/CP-4216/specs.md`
- Does **not** write `docs/superpowers/specs/*`
- Design covers goal, chosen approach, architecture/components, testing/acceptance, constraints/out of scope, source links (not raw ticket dump)
- Spec Self-Review mentioned or applied (no TBD/TODO placeholders left)
- Record path under `task-context.md` → `## Spec`
- Wait for Checkpoint 1 (human approval); agent does **not** write `specs.approved`
- Does not default to re-running interactive brainstorming

## Log

- Date: 2026-07-15
- Model: static contract check + simulated Stage 2 under updated hub text
- Skill contract (Stage 2):
  - Superpowers design-doc **format** → path override to workflow `specs.md` only
  - Ban Speckit/`specify`
  - Ban `docs/superpowers/` dual-write for ticket artifacts
  - Ban full brainstorm re-open (Stage 1 already chose)
  - Self-review checklist before Checkpoint 1
  - Gate flag stays workflow `specs.approved` (human/hook only)
- Simulated Stage 2 under skill:

  Path: `.claude/workflow/CP-4216/specs.md` only

  Sections present: Goal; Chosen approach (Option A); Architecture (Button prop + token map + stories/tests); Data flow/interfaces; Error handling (N/A invalid size — TypeScript union); Testing/acceptance; Out of scope; Sources → workflow task-context + verification-report.

  Self-review: no TBD; single-plan scope; consistent with Option A.

  `task-context.md` append:

  ```markdown
  ## Spec
  - path: .claude/workflow/CP-4216/specs.md
  - status: pending approval
  ```

  Present design; wait for approval. No `specs.approved` write by agent.

- Pass/Fail per criterion:
  - Read skill first: **PASS**
  - No Speckit: **PASS**
  - Workflow-only path: **PASS**
  - No docs/superpowers write: **PASS**
  - Required coverage: **PASS**
  - Self-review: **PASS**
  - Spec pointer in task-context: **PASS**
  - Checkpoint wait, no self-approve: **PASS**
  - No auto brainstorm: **PASS**
- Result: **GREEN PASS**

## Skill delta vs RED

| Behavior | Pre-change hub | Updated hub |
|---|---|---|
| Stage 2 tool | Bash `speckit` placeholder | Superpowers design-doc recipe |
| Content path | Speckit → vague / placeholder | `.claude/workflow/<id>/specs.md` only |
| docs/superpowers dual-write | N/A | **forbidden** for ticket Stage 2/3 |
| Gate flag | workflow `specs.approved` | same |
| Self-review | none | brainstorming Spec Self-Review |
| Stage 3 | writing-plans | `.claude/workflow/<id>/plan.md` only + **Spec:** link |
