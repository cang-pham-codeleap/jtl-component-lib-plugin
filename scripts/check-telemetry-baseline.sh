#!/usr/bin/env bash
set -euo pipefail

report_path="${1:?Usage: check-telemetry-baseline.sh <report.json> <baseline.json> <evaluation.json>}"
baseline_path="${2:?Usage: check-telemetry-baseline.sh <report.json> <baseline.json> <evaluation.json>}"
evaluation_path="${3:?Usage: check-telemetry-baseline.sh <report.json> <baseline.json> <evaluation.json>}"

for path in "$report_path" "$baseline_path"; do
  [[ -f "$path" ]] || {
    printf 'Telemetry input does not exist: %s\n' "$path" >&2
    exit 1
  }
done

mkdir -p "$(dirname "$evaluation_path")"
temporary_output="$(mktemp "${evaluation_path}.XXXXXX")"
trap 'rm -f "$temporary_output"' EXIT

jq -n \
  --slurpfile report "$report_path" \
  --slurpfile baseline "$baseline_path" '
    ($report[0]) as $actual
    | ($baseline[0]) as $baseline
    | if $baseline.schema_version != 1 then
        error("Unsupported telemetry baseline schema")
      elif ($baseline.expected | type) != "object" then
        error("Telemetry baseline expected must be an object")
      else
        [
          $baseline.expected
          | to_entries[]
          | select($actual[.key] != .value)
          | {
              field: .key,
              expected: .value,
              actual: $actual[.key]
            }
        ] as $differences
        | {
            schema_version: 1,
            scenario: $baseline.scenario,
            verdict: (if ($differences | length) == 0 then "PASS" else "FAIL" end),
            differences: $differences
          }
      end
  ' > "$temporary_output"

mv "$temporary_output" "$evaluation_path"
trap - EXIT

[[ "$(jq -r '.verdict' "$evaluation_path")" == "PASS" ]]
