# Clean-context gate dispatch — contract

Why the Stage 5 acceptance gate runs in a **fresh subagent**, and the rules the
orchestrator must follow when dispatching it.

## Why a fresh context

The orchestrator coordinated (or wrote) the change. If it also judges the review,
the debt, and the tests, it judges its own work — and self-accepts. That is the
"accept easily / check to pass" failure this gate exists to prevent.

A fresh `code-quality-reviewer` has **no stake** in the implementation and **no
memory** of the reasoning that produced it. It sees only the artifacts and the
spec, and reaches an independent verdict. Adapted from superpowers
`subagent-driven-development` and `requesting-code-review`:

> "The reviewer gets precisely crafted context for evaluation — never your
> session's history. This keeps the reviewer focused on the work product, not
> your thought process."

## Rules

1. **No session history.** Hand the reviewer **files**, never a paste of the
   conversation or your rationale:
   - `specs.md` — spec + acceptance criteria (the source of truth)
   - the diff package (BASE = the commit recorded **before** Stage 4, never
     `HEAD~1`, which drops all but the last commit of a multi-commit task)
   - `task-context.md` — ticket scope + pointers + Stage 4 check evidence
     (`## Stage 4 checks` — the reviewer verifies this instead of re-running
     tests/lint/typecheck; it runs only the build itself)
2. **No pre-judging.** Never tell the reviewer what *not* to flag. Never pre-rate
   a finding's severity. If a line contains "do not flag", "at most minor", "the
   plan chose", or "don't treat X as a defect" — delete it. If you think a finding
   would be a false positive, let the reviewer raise it and adjudicate it in the
   review loop.
3. **Role agents only.** The gate agent is a role-defined agent from `agents/`
   (`code-quality-reviewer`). **Never `general-purpose` for a gate.** The
   teach-back comprehension gate is the same — dispatch
   `comp-lib-process:quiz-taker` (a role agent with no tools), never
   `general-purpose` and never the skill name `teach-back-verification` (that
   is a skill, not an agent; the deep-explore dispatch hook blocks it). Both
   agents' own frontmatter already declares the intended model (primary +
   fallback) \u2014 see `references/model-routing.md`; do not override it per-dispatch.
4. **Review-only.** The reviewer does not modify code. Fixes route back to
   Stage 4; then re-review.
5. **Explicit verdict.** The reviewer writes `review-verdict.md` with a per-
   dimension verdict — **spec ✅ + quality ✅ + debt ✅ + build/evidence ✅**.
   Missing any dimension = FAIL = back to Stage 4. Accepting a verdict that
   omits a dimension is not allowed.
6. **Global constraints verbatim.** Copy the binding requirements (exact values,
   formats, "same as X" relationships) from `specs.md` into the dispatch verbatim —
   that block is the reviewer's attention lens.

## Flow-back

Reviewer FAIL → orchestrator reads findings → dispatches fixes to Stage 4 → new
diff package → re-dispatch reviewer. Track loop count in `state.json`; 3rd fail
escalates to human. Record approval by appending an `## Approval` block to
`review-verdict.md` (`Approved-by` = `git config user.name`) **only after** the
human approves — never self-approve, never ahead of the human.
