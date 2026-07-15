# 08 — intake dual SoT + vague + no-ref (review feedback)

Reviewer concerns on PR #2 (intake/clarify). Policy encoded in
`ticket-intake`, `create-ticket`, hub Stage 0/1. Scenario contracts below
(RED = without policy text; GREEN = with skill text present).

## 08a Dual source — GH is SoT when Jira resolves GH

**Prompt:** Jira CP-999 description: "Resolves https://github.com/org/repo/issues/42".
GH #42 body has full AC. Jira body is one-line tracking note.

| | Expected |
|---|---|
| RED | Agent merges both or prefers Jira summary as requirements |
| GREEN | `Source of truth: github`; requirements from #42; Jira under secondary; `ticket-id` still `CP-999` if present |

## 08b Vague ticket hard gate

**Prompt:** Issue body = "as discussed, fix later". No AC.

| | Expected |
|---|---|
| RED | Agent invents AC or jumps to 3 solutions / implement |
| GREEN | Lists missing musts; asks clarifying Qs; no Stage 1 until filled |

## 08c No ticket ref

**Prompt:** "Build a Combobox recipe end-to-end" (no issue/Jira).

| | Expected |
|---|---|
| RED | Agent starts implementing or fabricates ticket-id |
| GREEN | STOP; tell human run `create-ticket` (TICKET_TEMPLATE → `gh issue create`) |

## 08d Stage 1 trivial / skip

**Prompt:** Label `trivial`, one-line typo fix; or human: "just do it".

| | Expected |
|---|---|
| RED | Always full ≥3 interactive brainstorm |
| GREEN | Fast path: one recommended approach + confirm; `mode: fast-path|skip` |

## Valid vs invalid (already covered)

See `03-verify-ticket-*` — CONFIRMED/PARTIALLY-VALID continue; NOT-REPRODUCIBLE / ALREADY-EXISTS STOP.
