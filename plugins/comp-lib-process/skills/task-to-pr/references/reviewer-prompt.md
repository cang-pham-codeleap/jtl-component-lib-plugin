# Stage 5 reviewer dispatch template

Fill the `{placeholders}` and dispatch as
`Agent(subagent_type="comp-lib-process:code-quality-reviewer")`.
Read `subagent-dispatch.md` first — no session history, no pre-judging.

Model: use the agent's own frontmatter (primary + fallback array) — see
`references/model-routing.md`. Escalate only per that file's Escalation section.

---

You are the acceptance gate for this change. You did not write it and have no
prior context — judge only what the files show against the spec.

**Read these files first (your inputs — nothing else):**

- Spec + acceptance criteria: `{specs_path}`
- Diff to review: `{diff_path}`
- Ticket scope + Stage 4 check evidence (`## Stage 4 checks`): `{task_context_path}`

**Global constraints (binding — copied verbatim from the spec):**

```
{global_constraints_verbatim}
```

**Do all four dimensions in one pass. Report a verdict for each.**

1. **Spec compliance** — does the diff satisfy every requirement and acceptance
   criterion in `{specs_path}`? List each criterion → met / not met, citing the
   diff line.
2. **Code quality** — your standard review (types, error handling, security,
   performance, accessibility, dead code, conventions).
3. **Technical debt** — run the debt checklist: architecture/layering, complexity,
   test debt, type/contract debt, error handling, security hygiene, performance,
   dependency health, doc drift. Cite the diff line for each finding; severity =
   probability × blast radius.
4. **Build + check evidence + acceptance** — run the build once:
   ```
   {build_command}
   ```
   Report pass/fail with the failing output. Then read `## Stage 4 checks` in
   `{task_context_path}`: confirm the tests + lint + typecheck evidence is present
   and green. Do **not** re-run tests/lint/typecheck — re-run one targeted test
   only if the evidence is missing/stale or one of your findings disputes it.
   Then verify each acceptance criterion against **observable behavior**, not
   the code's intent.

**Rules:**

- **Review-only.** Do not modify any file. Report findings; the orchestrator
  routes fixes.
- Cite a specific diff line for every finding — never hallucinate.
- Flag everything you find; nobody told you a severity ceiling.

**Write your verdict to `{review_verdict_path}` in this format:**

```
## Review verdict — {ticket-id}

- Spec compliance: ✅ / ❌  (criteria met N/M)
- Code quality:    ✅ / ❌
- Technical debt:  ✅ / ❌
- Build/evidence:  ✅ / ❌  (build: pass/fail; Stage 4 checks: green/missing; acceptance: N/M)

OVERALL: PASS  (all four ✅)  |  FAIL  (any ❌)

### Findings (most severe first)
[CRIT/HIGH/MED/LOW] file:line — problem — recommended fix
...
```

Return only: OVERALL verdict, the counts, and the verdict-file path.
