# /resolve-pr-comment — Verify and resolve PR review feedback

Run the `resolve-pr-comment` skill on the current branch PR (or a given PR).

## Usage

```
/resolve-pr-comment
/resolve-pr-comment 12
/resolve-pr-comment https://github.com/org/repo/pull/12
```

## What happens

1. Resolve PR (current branch or argument)
2. Fetch issue comments + inline review comments + review bodies
3. Verify each concern against code on this branch (OK / partial / gap / invalid / needs-product)
4. Report table + ask human until ≥95% on product decisions
5. Plan fix; **wait for approve**
6. Implement surgical changes
7. Post PR thread reply mapping each bullet → outcome
8. Show diff; no commit/push unless asked

---

Use the `resolve-pr-comment` skill. $ARGUMENTS
