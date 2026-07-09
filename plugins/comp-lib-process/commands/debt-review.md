# /debt-review — Post-Task Technical Debt Review

Trigger the `tech-debt-reviewer` subagent to review all code changed in the
current task. Run this after completing any feature, fix, or refactor before
committing.

## Usage

```
/debt-review
/debt-review --scope staged          # only staged files
/debt-review --scope last-commit     # HEAD~1 diff
/debt-review --focus security        # only security + error handling dims
```

## What happens

1. Agent collects git diff of changed files
2. Runs all 9 debt dimensions against the diff
3. Outputs a structured report (Critical → Low)
4. Appends Critical + High items to `_tech-debt.md`
5. Issues a merge verdict: ✅ CLEAN | ⚠️ NEEDS ATTENTION | 🚫 BLOCK

---

Use the `tech-debt-reviewer` subagent on the code changed in the current
task. Analyze the git diff, produce a structured debt report covering all
nine dimensions (architecture, code quality, test debt, types, error
handling, security, performance, dependency health, documentation), classify
each finding by Fowler quadrant and severity, then update `_tech-debt.md`
with any Critical or High items. End with a merge verdict.

$ARGUMENTS
