# Copilot Cross-Harness Pressure Tests

Run the same synthetic ticket in Claude Code, Copilot local agent mode, and
GitHub Copilot coding agent. The ticket must contain no real customer data.

Expected portable evidence:

- committed `.jtl/workflow/CP-42/` artifacts
- sanitized `task-context.md` and optional `design-context.md`
- approval blocks in FULL-tier `specs.md`, `plan.md`, and `review-verdict.md`
- `bash scripts/validate-cross-harness.sh` passes

Harness-specific role-agent dispatch is evidence of an enhancement, not a
portable acceptance criterion. If a harness lacks fresh-context review, the
review verdict must declare that limitation and CI plus human approval remain
the hard gates.
