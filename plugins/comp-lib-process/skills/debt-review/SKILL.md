---
name: debt-review
description: Use when the user asks to check technical debt on the current PR/branch, review debt for code changed vs main, or says "debt review", "review tech debt", "check this PR for debt"
---

## Debt Review

Scope a technical-debt review to the **whole branch vs `main`** (not just the
last commit) and dispatch it to a fresh, context-isolated agent.

### Steps

1. Gather scope (Bash, cheap):
   - `git rev-parse --abbrev-ref HEAD` — current branch
   - `gh pr view --json number,url,title,baseRefName 2>/dev/null` — open PR for this branch, if any (ok if empty: no PR yet, review the local branch)
   - `git diff main...HEAD --name-only` — committed files that differ from `main`
   - `git status --short` — uncommitted changes to include too
2. Dispatch the review agent (single call, fresh context — do NOT do the review yourself):
   - Prefer `Agent(subagent_type: "comp-lib-process:tech-debt-reviewer")` if that agent type is available.
   - If not available/registered, fall back to `Agent(subagent_type: "general-purpose")` and paste the 9-dimension checklist + output-format contract from the `tech-debt-reviewer` agent definition into the prompt so the fallback agent follows the same structure.
   - The dispatch prompt MUST override the agent's own default scope (`git diff HEAD`, which only sees uncommitted changes) — tell it explicitly to run `git diff main...HEAD` (plus `git status --short` for anything uncommitted) as the diff to review, and to state the branch name / PR number in its report header.
3. Relay the agent's structured report back to the user as-is (severity-ranked findings + verdict). Do not re-summarize away the per-item evidence/fix fields.

### When there's no open PR

Still run the review against `git diff main...HEAD` — a PR isn't required, only a branch that has diverged from `main`. Say so in the report header instead of a PR link/number.

### Notes

- One dispatch per invocation. Don't fan out multiple review agents for one branch.
- This skill only decides _scope_ and _dispatch_; the actual 9-dimension analysis and report format live in the `tech-debt-reviewer` agent definition — don't duplicate that checklist here.
