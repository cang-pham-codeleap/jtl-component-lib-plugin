<!--
BEFORE SUBMITTING: Read every word of this template. PRs that leave
required sections blank, bundle multiple unrelated changes, or skip the
final gate checklist will be closed without review.

Also read CLAUDE.md before submitting. It defines what belongs in this
repo and what gets closed without review.
-->

> **This PR MUST target the `dev` branch, not `main`.** `main` is the
> release branch. PRs opened against `main` will be asked to retarget
> `dev` before review.

## PR Type

<!-- Check exactly one. -->

- [ ] New skill
- [ ] Modify skill — behavior change
- [ ] Modify skill — docs / clarity only
- [ ] Supporting files only (scripts, examples, references)
- [ ] Repo tooling / infra

## What changed

<!-- 1–3 sentences. What, not why. -->

## What behavior does this skill teach or change?

<!--
Describe the specific agent behavior this skill produces.
"Agents will now..." — be concrete.
If this is a modification, describe what the old behavior was and what it is now.
-->

**Before (without this skill):**

**After (with this skill):**

## Existing skills checked

<!--
REQUIRED. List the skills you checked for overlap or conflict.
If a related skill exists, explain why you didn't extend it instead.
-->

- [ ] I searched existing skills and this is not a duplicate

**Skills checked:**

## Pressure test evidence

<!--
REQUIRED for new skills and behavior changes. Docs-only changes may omit this.
Attach or describe the subagent test results proving the skill changes agent behavior.

Minimum: one baseline run (agent fails without skill) + one passing run (agent complies with skill).
-->

**Baseline (agent fails without skill):**

**Passing (agent complies with skill):**

## Linked issue

- Closes #<!-- issue number, or remove this line -->

## Skill checklist

<!-- Skip if PR type is "Supporting files only" or "Repo tooling / infra". -->

- [ ] YAML frontmatter has `name` and `description`
- [ ] `description` reads as an invocation trigger, not a title
- [ ] Skill lives at `skills/<skill-name>/SKILL.md`
- [ ] Skill is reusable, not a one-time narrative
- [ ] No contradictions with existing skills — or conflicts are explicitly resolved
- [ ] Supporting files (scripts, examples) are in the same skill directory

## Authoring environment

<!--
REQUIRED. Disclose what produced this contribution.
Hiding agent authorship is grounds for closing.
-->

| Field                               | Value |
| ----------------------------------- | ----- |
| Written by (human / agent)          |       |
| Model + version (if agent)          |       |
| Harness (Claude Code, Cursor, etc.) |       |
| Harness version                     |       |
| Plugins installed                   |       |

## Final gate

<!-- All PRs. Do not submit until every box is checked. -->

- [ ] PR targets `dev`, not `main`
- [ ] I have self-reviewed the complete diff
- [ ] My human partner has reviewed and approved the diff
- [ ] This PR contains exactly one skill concern — not bundled changes
- [ ] All required sections above are filled in — no placeholders

<!--
PRs will be closed without review if they:
- Target `main`
- Leave required sections blank or write placeholder text
- Add a skill that duplicates an existing one without justification
- Have no pressure test evidence (for behavior changes)
- Hide agent authorship
-->
