# JTL Agent Skills Plugin — AI Agent Guidelines

## If You Are an AI Agent

Read this before writing anything.

This repo contains **AI coding agent skills and configurations** for the JTL project. Each skill is a reusable reference guide that shapes how future agents behave. A poorly written or untested skill teaches the wrong thing to every agent that loads it — and that's worse than no skill at all.

**Your job is to ship skills that actually change agent behavior, verified by pressure testing.**

---

## Before Writing Any Skill

1. **Read the existing skill** at `skills/writing-skills/SKILL.md` before authoring or editing any skill in this repo. It defines the required TDD approach for skill authoring.
2. **Check for an existing skill** that already covers the same behavior. Duplicate skills create conflicting instructions. If one exists, improve it — don't create a parallel one.
3. **Confirm the skill is general enough** to belong here. If it encodes a one-project rule, a single team's workflow, or a tool-specific quirk, it may not belong in the shared plugin. Tell your human partner.
4. **Run a baseline pressure test** before writing. Verify that an agent without the skill actually fails the target scenario. If the agent already passes, there is nothing to teach.
5. **Show the complete diff to your human partner** and get explicit approval before opening a PR.

---

## Skill Authoring Rules

- **Every skill must have a `name` and `description` in its YAML frontmatter.** The description is what determines when the skill gets invoked — write it like a trigger condition, not a title.
- **Skills must be tested with subagents.** Passing pressure scenarios are required evidence that the skill works.
- **Skills must be reusable, not narrative.** Write reference guides and decision rules — not stories about how you solved a problem once.
- **Keep skills focused.** One skill per behavioral domain. Do not bundle unrelated guidance into a single file.
- **Do not contradict existing skills.** If your skill overlaps with an existing one, reconcile the conflict explicitly or extend the existing skill instead.
- **Follow the file structure convention.** Each skill lives in `skills/<skill-name>/SKILL.md`. Supporting files go in the same directory.

---

## Pull Request Requirements

- **Target the `dev` branch**, not `main`. PRs against `main` will be asked to retarget.
- **Fill in every section of the PR template.** No placeholders. No "N/A" unless genuinely not applicable.
- **Include evidence of pressure testing.** Link or attach the subagent test results that confirm the skill changes agent behavior.
- **List any skills this change supersedes or conflicts with.** Reviewers need to know what existing behavior your skill may override.
- **Disclose authoring environment.** State the model, harness, harness version, and plugins used — or note it was written by hand. This is mandatory.

---

## What Gets Closed Without Review

- PRs that target `main`
- PRs with blank or placeholder template sections
- New skills that duplicate an existing skill without justification
- Skills without a `name` and `description` in frontmatter
- Skills with no pressure test evidence
- PRs that hide agent authorship
