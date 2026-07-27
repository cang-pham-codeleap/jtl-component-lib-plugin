#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
telemetry_dir="${TASK_AUDIT_DIRECTORY:-$repo_root/.telemetry}"
output_path="${TASK_AUDIT_OUTPUT_PATH:-$telemetry_dir/task-audit.json}"
trace_path="${TASK_AUDIT_OTEL_JSONL:-}"
baseline_path="${TASK_AUDIT_BASELINE_PATH:-}"

find_latest_trace() {
  local candidate=""
  local trace

  [[ -d "$telemetry_dir" ]] || return 1
  while IFS= read -r -d '' trace; do
    if [[ -z "$candidate" || "$trace" -nt "$candidate" ]]; then
      candidate="$trace"
    fi
  done < <(find "$telemetry_dir" -type f -name '*.jsonl' -print0 2>/dev/null)
  [[ -n "$candidate" ]] || return 1
  printf '%s\n' "$candidate"
}

git_base_ref() {
  git merge-base HEAD '@{upstream}' 2>/dev/null || \
    git merge-base HEAD origin/HEAD 2>/dev/null || \
    git rev-parse HEAD^ 2>/dev/null || \
    git rev-parse HEAD
}

git_lines_as_json() {
  jq -Rsc 'split("\n") | map(select(length > 0))'
}

mkdir -p "$(dirname "$output_path")"
temporary_output="$(mktemp "${output_path}.XXXXXX")"
temporary_report="$(mktemp "${output_path}.report.XXXXXX")"
temporary_evaluation="$(mktemp "${output_path}.evaluation.XXXXXX")"
trap 'rm -f "$temporary_output" "$temporary_report" "$temporary_evaluation"' EXIT

base_ref="$(git_base_ref)"
head_ref="$(git rev-parse HEAD)"
branch="$(git branch --show-current)"
changed_files="$(git diff --name-only "$base_ref...$head_ref" | git_lines_as_json)"
commits="$(git log --format='%H %s' "$base_ref..$head_ref" | git_lines_as_json)"
worktree_status="$(git status --short | git_lines_as_json)"

if [[ -z "$trace_path" ]]; then
  trace_path="$(find_latest_trace || true)"
fi

telemetry_status="unavailable"
telemetry_reason="No OTel JSONL trace found. Export a trace to .telemetry/ or set TASK_AUDIT_OTEL_JSONL."
baseline_status="not-configured"

if [[ -n "$trace_path" && -f "$trace_path" ]]; then
  bash "$repo_root/scripts/summarize-otel-jsonl.sh" "$trace_path" "$temporary_report"
  telemetry_status="available"
  telemetry_reason=""

  if [[ -n "$baseline_path" ]]; then
    if [[ -f "$baseline_path" ]]; then
      if bash "$repo_root/scripts/check-telemetry-baseline.sh" "$temporary_report" "$baseline_path" "$temporary_evaluation"; then
        baseline_status="pass"
      else
        baseline_status="fail"
      fi
    else
      baseline_status="unavailable"
    fi
  fi
fi

jq -n \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg branch "$branch" \
  --arg base_ref "$base_ref" \
  --arg head_ref "$head_ref" \
  --arg telemetry_status "$telemetry_status" \
  --arg telemetry_reason "$telemetry_reason" \
  --arg baseline_status "$baseline_status" \
  --argjson changed_files "$changed_files" \
  --argjson commits "$commits" \
  --argjson worktree_status "$worktree_status" \
  --slurpfile aggregate "$temporary_report" \
  --slurpfile evaluation "$temporary_evaluation" '
    {
      schema_version: 1,
      generated_at: $generated_at,
      git: {
        branch: $branch,
        base_ref: $base_ref,
        head_ref: $head_ref,
        changed_files: $changed_files,
        commits: $commits,
        worktree_status: $worktree_status
      },
      telemetry: {
        status: $telemetry_status,
        reason: (if $telemetry_reason == "" then null else $telemetry_reason end),
        aggregate: ($aggregate[0] // null)
      },
      baseline: {
        status: $baseline_status,
        evaluation: ($evaluation[0] // null)
      }
    }
  ' > "$temporary_output"

mv "$temporary_output" "$output_path"
trap - EXIT
rm -f "$temporary_report" "$temporary_evaluation"

printf 'Task audit report: %s\n' "$output_path"