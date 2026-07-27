#!/usr/bin/env bash
set -euo pipefail

input_path="${1:?Usage: summarize-otel-jsonl.sh <input.jsonl> <output.json>}"
output_path="${2:?Usage: summarize-otel-jsonl.sh <input.jsonl> <output.json>}"

[[ -f "$input_path" ]] || {
  printf 'Telemetry input does not exist: %s\n' "$input_path" >&2
  exit 1
}

mkdir -p "$(dirname "$output_path")"
temporary_output="$(mktemp "${output_path}.XXXXXX")"
trap 'rm -f "$temporary_output"' EXIT

jq -s '
  def spans:
    [
      ..
      | objects
      | select(
          (.name? | type) == "string"
          and (.attributes? | type) == "array"
          and (.startTimeUnixNano? | type) == "string"
          and (.endTimeUnixNano? | type) == "string"
        )
    ];
  def attribute($span; $key):
    [
      $span.attributes[]?
      | select(.key == $key)
      | (.value.intValue? // .value.doubleValue? // .value.stringValue?)
    ]
    | first;
  def number_attribute($span; $key):
    attribute($span; $key) | tonumber? // 0;
  def duration_ms($span):
    (((($span.endTimeUnixNano | tonumber) - ($span.startTimeUnixNano | tonumber)) / 1000000) | floor);
  def count_by_model($spans):
    reduce $spans[] as $span (
      {};
      (attribute($span; "gen_ai.response.model")
        // attribute($span; "gen_ai.request.model")
        // attribute($span; "gen_ai.agent.name")) as $model
      | if $model == null or $model == "" then . else .[$model] = (.[$model] // 0) + 1 end
    );

  spans as $all_spans
  | [$all_spans[] | select(.name == "invoke_agent")] as $agent_spans
  | (if ($agent_spans | length) > 0
     then $agent_spans
     else [$all_spans[] | select(.name == "chat")]
     end) as $token_spans
  | {
      schema_version: 1,
      source: "otel-jsonl",
      span_count: ($all_spans | length),
      agent_invocations: ($agent_spans | length),
      tool_calls: ([$all_spans[] | select(.name == "execute_tool")] | length),
      error_count: ([$all_spans[] | select(.status.code? == 2 or .status.code? == "STATUS_CODE_ERROR")] | length),
      duration_ms: ([$agent_spans[] | duration_ms(.)] | add // 0),
      input_tokens: ([$token_spans[] | number_attribute(.; "gen_ai.usage.input_tokens")] | add // 0),
      output_tokens: ([$token_spans[] | number_attribute(.; "gen_ai.usage.output_tokens")] | add // 0),
      reasoning_tokens: ([$token_spans[] | number_attribute(.; "gen_ai.usage.reasoning.output_tokens")] | add // 0),
      cache_read_tokens: ([$token_spans[] | number_attribute(.; "gen_ai.usage.cache_read.input_tokens")] | add // 0),
      models: count_by_model($agent_spans)
    }
' "$input_path" > "$temporary_output"

mv "$temporary_output" "$output_path"
trap - EXIT
