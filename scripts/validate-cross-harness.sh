#!/usr/bin/env bash
set -euo pipefail

root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
errors=0

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  errors=$((errors + 1))
}

contains_approval() {
  local file="$1"
  grep -q '^## Approval$' "$file" && \
    grep -q '^- Approved-by: .\+' "$file" && \
    grep -q '^- Date: [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$' "$file" && \
    grep -q '^- Mode: \(interactive\|headless\)$' "$file"
}

validate_workflow() {
  local workflow_dir="$1"
  local context="$workflow_dir/task-context.md"
  local required

  for required in task-context.md verification-report.md review-verdict.md; do
    [[ -f "$workflow_dir/$required" ]] || fail "$workflow_dir missing $required"
  done
  [[ -f "$context" ]] || return

  if grep -q '^- tier: full$' "$context"; then
    for required in specs.md plan.md; do
      [[ -f "$workflow_dir/$required" ]] || fail "$workflow_dir missing $required for FULL tier"
    done
    for required in specs.md plan.md; do
      [[ ! -f "$workflow_dir/$required" ]] || contains_approval "$workflow_dir/$required" || fail "$workflow_dir/$required missing valid approval"
    done
  elif grep -q '^- tier: simple$' "$context"; then
    grep -q '^- Approved-by: .\+' "$context" || fail "$context missing SIMPLE-tier approval"
  else
    fail "$context missing tier declaration"
  fi

  [[ ! -f "$workflow_dir/review-verdict.md" ]] || contains_approval "$workflow_dir/review-verdict.md" || fail "$workflow_dir/review-verdict.md missing valid approval"

  if grep -R -n -E '^(## (Ticket body|Secondary source|Raw (ticket|design) payload)|<!-- UNTRUSTED )|\.claude/workflow/' "$workflow_dir" >/dev/null; then
    fail "$workflow_dir contains raw payload markers or obsolete .claude/workflow path"
  fi
  if grep -R -n -E '(AKIA[0-9A-Z]{16}|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,})' "$workflow_dir" >/dev/null; then
    fail "$workflow_dir contains an apparent secret"
  fi
}

workflow_root="$root/.jtl/workflow"
if [[ -d "$workflow_root" ]]; then
  while IFS= read -r -d '' workflow_dir; do
    validate_workflow "$workflow_dir"
  done < <(find "$workflow_root" -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [[ -f "$root/.claude-plugin/marketplace.json" && -f "$root/plugins/comp-lib-process/.claude-plugin/plugin.json" ]]; then
  marketplace_version="$(jq -r '.plugins[] | select(.name == "comp-lib-process") | .version' "$root/.claude-plugin/marketplace.json")"
  plugin_version="$(jq -r '.version' "$root/plugins/comp-lib-process/.claude-plugin/plugin.json")"
  [[ "$marketplace_version" == "$plugin_version" ]] || fail "Claude marketplace and plugin versions differ"
fi

if [[ -d "$root/plugins/comp-lib-process/skills" ]]; then
  while IFS= read -r -d '' skill; do
    skill_name="$(basename "$(dirname "$skill")")"
    declared_name="$(grep '^name:' "$skill" | head -1 | cut -d: -f2- | xargs)"
    [[ "$declared_name" == "$skill_name" ]] || fail "$skill name does not match its directory"
  done < <(find "$root/plugins/comp-lib-process/skills" -name SKILL.md -print0)
fi

active_files=(
  "$root/README.md"
  "$root/docs/task-to-pr-workflow.md"
  "$root/docs/announcements/2026-07-16-task-to-pr-workflow.md"
)
if [[ -d "$root/plugins/comp-lib-process/skills" ]]; then
  while IFS= read -r -d '' skill; do
    active_files+=("$skill")
  done < <(find "$root/plugins/comp-lib-process/skills" -name SKILL.md -print0)
fi
for file in "${active_files[@]}"; do
  [[ -f "$file" ]] || continue
  if grep -n '\.claude/workflow/' "$file" >/dev/null; then
    fail "$file contains an obsolete .claude/workflow path"
  fi
done

if ((errors > 0)); then
  printf 'Cross-harness validation failed with %d error(s).\n' "$errors" >&2
  exit 1
fi

printf 'Cross-harness validation passed.\n'
