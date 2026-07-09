# create-pr Skill — Design Spec

**Date:** 2026-07-09  
**Scope:** `jtl-platform-ui-react` component library  
**Status:** Approved, pending implementation plan

---

## Overview

A skill that automates the full pull request creation workflow for the `jtl-platform-ui-react` component library. It handles version bump detection, changelog updates, draft PR creation, PR number back-fill, and PR description generation — in a strict sequential order with one hard dependency: the draft PR must exist before changelogs can be finalized.

### Trigger conditions

Invoke when the user says: "create a PR", "open a PR", "submit a PR", "make a pull request", or "push this to review" in the context of `jtl-platform-ui-react`.

### Out of scope

- Running tests, builds, or storybook checks (user's responsibility per PR template final gate)
- Pushing commits — the skill only creates the PR and edits changelog/description files
- PRs targeting `main` — always targets `dev`

---

## Step 1 — Version Resolution

**Primary:** `git describe --tags --abbrev=0`  
Strip leading `v` to get a semver string (e.g., `v1.54.0` → `1.54.0`).

**Fallback (if no git tag):** Parse the first `## X.Y.Z` heading in `CHANGELOG.md`.

---

## Step 2 — Commit Collection

```bash
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  git log --oneline
else
  git log "$LAST_TAG"..HEAD --oneline
fi
```

---

## Step 3 — Bump Type Detection

Scan all collected commit subjects. The highest-priority match across all commits wins.

| Priority | Pattern | Bump | Example |
|----------|---------|------|---------|
| 1 | Any commit containing `!` (e.g., `feat!`, `fix!`) | **major** | `feat!: drop React 18 support` |
| 2 | Commit starting with `feat` | **minor** | `feat: add Avatar component` |
| 3 | Commit starting with `fix` | **patch** | `fix: button focus ring` |
| — | Any other prefix (`chore`, `docs`, `refactor`, etc.) | **no bump** | `chore: update deps` |

**If no bumpable commits found:** warn the user and stop. Do not create a PR.

### Version calculation

```
current: 1.54.0
  + patch → 1.54.1
  + minor → 1.55.0
  + major → 2.0.0
```

---

## Step 4 — Summary Generation

### Source priority

1. **Spec file:** search `docs/superpowers/specs/` for a `.md` file whose name contains the ticket ID (e.g., `CP-4216`) or the branch name. Use the spec's first `#` heading as the title, first section body as bullet source.
2. **Fallback:** synthesize from `git log` commit messages + `git diff <last-tag>..HEAD --stat`. Read changed files to write a consumer-facing summary.

### Ticket ID extraction

Scan commit messages for pattern `[A-Z]+-[0-9]+` (e.g., `CP-4216`). If multiple found, list all.

### Output format

**Title (1 line):**
```
<Feature/task description> - <TICKET-ID> - [#PR_PLACEHOLDER]()
```

**Bullets (2–4):**
- Each starts with a bold label: `- **Label:** explanation`
- Focus on what changed for consumers, not implementation internals
- If any commit has `!`: first bullet must be:
  ```
  - **BREAKING:** <what breaks and migration path>
  ```

**Example:**
```markdown
### Refactor Stepper Layout Component - CP-4216 - [#PR_PLACEHOLDER]()

- **Centralized Data Management:** Enhance `StepperLayout` to centralize form data handling across steps.
- **Composition Mode Support:** Refactor architecture to support flexible composition pattern.
```

---

## Step 5 — Changelog Update

### Files to update (both must stay in sync)

- `CHANGELOG.md` (repo root)
- `docs/introduction/3-changelog.mdx`

### Logic

```
Read CHANGELOG.md → check if first entry heading matches "## X.Y.Z (unreleased)"
  → YES: replace that entry's content (re-compute version if bump type differs)
  → NO:  prepend a new entry above the current latest entry
```

### Entry format

```markdown
## 1.55.0 (unreleased) - 2026/07/09

### <Title from Step 4> - <TICKET-ID> - [#PR_PLACEHOLDER]()

- **Label:** explanation
- **Label:** explanation

---
```

- Date is today's date at write time (`YYYY/MM/DD`)
- `PR_PLACEHOLDER` is a temporary empty link — replaced in Step 8

---

## Step 6 — Draft PR Creation

```bash
gh pr create \
  --draft \
  --base dev \
  --title "<title from Step 4>" \
  --body "<filled PR description>" \
  --repo jtl-software/jtl-platform-ui-react
```

Capture the PR number from the returned URL (e.g., `.../pull/616` → `616`).

### PR description

Fill `.github/PULL_REQUEST_TEMPLATE.md` with:

| Section | Source |
|---------|--------|
| `## PR Type` | Inferred: `feat` → New/Modify component; `fix` → Modify non-breaking; `!` → BREAKING CHANGE |
| `## What changed` | Summary bullets from Step 4 |
| `## Breaking changes` | From `!` commits; if none → `None.` for all three fields |
| `## Linked references` | Ticket ID as `Closes #<ticket>`; Figma → `N/A` if not found |
| All checklists | Left **unchecked** — human fills before marking ready for review |

---

## Step 7 — Changelog Finalization + PR Description Update

After capturing the real PR number:

1. In both `CHANGELOG.md` and `docs/introduction/3-changelog.mdx`, replace:
   ```
   [#PR_PLACEHOLDER]() → [#616](https://github.com/jtl-software/jtl-platform-ui-react/pull/616)
   ```

2. Update the draft PR description with the finalized content:
   ```bash
   gh pr edit 616 --body "<updated description with real PR link>"
   ```

Both changelog files and the PR description are now consistent.

---

## Full Ordered Checklist

```
1. Resolve current version (git tag → CHANGELOG.md fallback)
2. Collect commits since last tag
3. Detect bump type; stop if no bumpable commits
4. Compute next version
5. Generate summary (spec → commit fallback)
6. Write changelog entry with PR_PLACEHOLDER to CHANGELOG.md and 3-changelog.mdx
7. Create draft PR; capture PR number
8. Replace PR_PLACEHOLDER with real PR link in both changelog files
9. Update draft PR description via gh pr edit
```

---

## Constraints

- Always targets `dev` branch, never `main`
- Requires `gh` CLI authenticated with write access to `jtl-software/jtl-platform-ui-react`
- Working branch must have at least one `feat`, `fix`, or `!` commit beyond the last tag
- PR description template source: `.github/PULL_REQUEST_TEMPLATE.md` (repo-local file takes precedence over any inline template)
