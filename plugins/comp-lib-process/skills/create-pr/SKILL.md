---
name: create-pr
description: Creates a pull request for the jtl-platform-ui-react component library. Invoke when the user says "create a PR", "open a PR", "submit a PR", "make a pull request", or "push this to review". Handles version bump detection from conventional commits, changelog updates, draft PR creation via GitHub CLI, PR number back-fill, and PR description generation from the repo's PULL_REQUEST_TEMPLATE.md.
user-invocable: true
allowed-tools: Bash(git *), Bash(gh *)
---

# create-pr

Automates the full pull request creation workflow for `jtl-platform-ui-react`. Run every step in order. Do not skip steps.

## Prerequisites

- Working directory is inside `jtl-platform-ui-react`
- `gh` CLI is authenticated with write access to `jtl-software/jtl-platform-ui-react`
- Current branch has at least one `feat`, `fix`, or `!` commit beyond the last tag

---

## Step 1 — Resolve Current Version

```bash
git describe --tags --abbrev=0 2>/dev/null
```

- Strip leading `v` → semver string (e.g., `v1.54.0` → `1.54.0`)
- **If the command fails (no tags):** parse the first `## X.Y.Z` heading from `CHANGELOG.md` instead

---

## Step 2 — Collect Commits Since Last Tag

```bash
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  git log --oneline
else
  git log "$LAST_TAG"..HEAD --oneline
fi
```

---

## Step 3 — Detect Bump Type

### 3a — Commit-subject signal

Scan all commit subjects collected in Step 2. The **highest-priority match across all commits** wins.

| Priority | Rule | Tentative bump |
|----------|------|----------------|
| 1 | Any commit subject contains `!` (e.g., `feat!:`, `fix!:`) | **major** |
| 2 | Any commit subject starts with `feat` | **minor** |
| 3 | Any commit subject starts with `fix` | **patch** |
| — | Only `chore`, `docs`, `refactor`, `test`, etc. | **none — stop** |

**If tentative bump is none:** tell the user no version-bumpable commits were found and stop. Do not proceed to Step 4.

### 3b — Diff-verification pass (required)

After 3a, review the **public-surface diff** since the last tag:

```bash
git diff <LAST_TAG>..HEAD -- <paths to exported components/props/types, registry items, peer deps>
```

Inspect for breaking changes such as:
- Removed or renamed exported components, props, types, or registry item names
- New required props / required peer dependencies without defaults
- Behavior changes that break documented public API contracts

**Reconcile tentative bump vs diff:**

| Commit signal | Diff finding | Action |
|---------------|--------------|--------|
| no `!` | breaking change present | Set bump to **major**; tell user which commit(s) understated it |
| `!` present | no breaking change found | Flag mismatch; **ask user** to confirm major vs downgrade |
| both agree | — | Proceed with that bump |
| minor/patch | non-breaking only | Proceed |

Commit subjects are **inputs**, never the sole source of truth for major.

### Compute next version

```
patch: 1.54.0 → 1.54.1
minor: 1.54.0 → 1.55.0
major: 1.54.0 → 2.0.0
```

---

## Step 4 — Extract Ticket IDs

Extract **both** when present. They are independent.

### 4a — Jira key(s)

Scan commit subjects for pattern `[A-Z]+-[0-9]+` (e.g., `CP-4216`).

- One → use it
- Multiple → comma-separated (e.g., `CP-4216, CP-4217`)
- None → leave blank

### 4b — GitHub issue number(s)

Resolve GH issue in this order (first hit wins per source; merge unique numbers):

1. **task-context** (if present): `.claude/workflow/*/task-context.md` — parse `Sources` / `ticket-id: gh-<n>` / GH issue URLs
2. **Branch name:** `gh-<n>`, or trailing/leading bare number when clearly issue-shaped
3. **Commits:** `#<n>`, or `fixes|closes|resolves #<n>` (case-insensitive)

- One → store as `GH_ISSUE=<n>`
- Multiple → comma-separated numbers
- None → leave blank (do not invent)

Use Jira key for changelog/title ticket segment when present; otherwise `gh-<n>` / `#<n>`.

---

## Step 5 — Generate Summary

### Source priority

1. **Spec file:** search `docs/superpowers/specs/` for a `.md` file whose name contains the ticket ID or current branch name. If found, use:
   - Its first `#` heading as the changelog title
   - Its first section body as the source for bullets
2. **Fallback:** read `git log` commit messages and `git diff <LAST_TAG>..HEAD --stat`, then read the most-changed source files to produce a consumer-facing summary

### Output: title + bullets

**Title format:**
```
<Feature description> - <TICKET-ID> - [#PR_PLACEHOLDER]()
```

**Bullets (2–4 items):**
- Format: `- **Bold label:** one sentence explaining the change`
- Focus on what changes for consumers of the library, not internal implementation details
- If bump is **major** (after Step 3 reconciliation), first bullet must be written from the **verified public-surface diff** (not only `!` commit text):
  ```
  - **BREAKING:** <what breaks> — migrate by <migration path>
  ```

**Example output:**
```markdown
### Refactor Stepper Layout Component - CP-4216 - [#PR_PLACEHOLDER]()

- **BREAKING:** `StepperLayout` no longer accepts `data` prop directly — pass data via context provider instead
- **Centralized Data Management:** Form data is now shared across steps via `StepperLayoutProvider`
- **Composition Mode:** Components accept `asChild` for flexible rendering composition
```

---

## Step 6 — Update Changelog Files

Update **both** files. They must stay in sync:

- `CHANGELOG.md` (repo root)
- `docs/introduction/3-changelog.mdx`

### Logic

```
Read CHANGELOG.md
  → If first entry heading matches "## X.Y.Z (unreleased)":
      Replace that entry's content with the new summary
      Update the version number if the bump type changed
  → Otherwise:
      Prepend a new entry above the current first entry
```

### Entry format to write

```markdown
## <NEW_VERSION> (unreleased) - <YYYY/MM/DD>

### <Title from Step 5>

<bullets from Step 5>

---

```

- Use today's date for `YYYY/MM/DD`
- `PR_PLACEHOLDER` stays as-is — it will be replaced in Step 8

---

## Step 7 — Build PR Description

Read `.github/PULL_REQUEST_TEMPLATE.md` from the repo root. Fill in every section:

| Section | Value |
|---------|-------|
| `## PR Type` | `feat`/`feat!` → check "New component" or "Modify component — BREAKING CHANGE"; `fix` → check "Modify component — non-breaking" |
| `## What changed` | Paste bullets from Step 5, without the bold labels |
| `## Breaking changes — What breaks` | From **verified public-surface diff**: name removed/changed API with file refs. Commit bodies may inform wording but are never the sole source. If none → `None.` |
| `## Breaking changes — Who is affected` | Derive from real usage surface (exported API consumers, registry names). If none → `None.` |
| `## Breaking changes — Migration path` | Written against the **new** API shown in the diff. If none → `None.` |
| `## Breaking changes — Semver bump required` | Delete the inapplicable option; keep `major`, `minor`, or `N/A — not breaking` |
| `## Linked references — Closes` (Ticket) | **GH issue present (Step 4b):** always include `Closes #<n>` so GitHub auto-links/closes the issue. **Jira key present (Step 4a):** include the key (e.g. `CP-4216`) on the same line or as a second bullet. **Both:** `Closes #<n>` + Jira key. **Neither:** remove the line |
| `## Linked references — Figma` | `N/A` unless a Figma link is found in commit messages or spec |
| All checklist items | Leave **unchecked** — the human completes these before marking ready for review |

---

## Step 8 — Create Draft PR

```bash
gh pr create \
  --draft \
  --base dev \
  --title "<title from Step 5, without the PR_PLACEHOLDER part>" \
  --body "<PR description from Step 7>" \
  --repo jtl-software/jtl-platform-ui-react
```

Capture the PR number from the returned URL:
```
https://github.com/jtl-software/jtl-platform-ui-react/pull/616  →  616
```

---

## Step 9 — Back-fill PR Number

Replace `[#PR_PLACEHOLDER]()` in all three locations with the real link:

```
[#PR_PLACEHOLDER]()  →  [#616](https://github.com/jtl-software/jtl-platform-ui-react/pull/616)
```

Files to update:
- `CHANGELOG.md`
- `docs/introduction/3-changelog.mdx`

Then update the draft PR description with the corrected content:

```bash
gh pr edit 616 \
  --body "<updated description with real PR link>" \
  --repo jtl-software/jtl-platform-ui-react
```

---

## Checklist (ordered, each step gates the next)

```
[ ] 1. Current version resolved (git tag or CHANGELOG.md)
[ ] 2. Commits since last tag collected
[ ] 3. Bump type determined from commits + public-surface diff reconciliation — stop here if none
[ ] 4. Ticket IDs extracted — Jira key(s) and/or GH issue number(s)
[ ] 5. Summary title + bullets generated
[ ] 6. CHANGELOG.md and 3-changelog.mdx updated with PR_PLACEHOLDER
[ ] 7. PR description filled from PULL_REQUEST_TEMPLATE.md — Closes includes `Closes #<n>` when GH issue present
[ ] 8. Draft PR created; PR number captured
[ ] 9. PR_PLACEHOLDER replaced with real link in changelog files and PR description
```

---

## Hard Rules

- Always target `dev`, never `main`
- Never push commits — only create/edit the PR and edit changelog files
- Never mark the PR ready for review — leave it as draft
- If `gh` is not authenticated, stop and tell the user to run `gh auth login`
- If bump type is `none`, stop before touching any files
