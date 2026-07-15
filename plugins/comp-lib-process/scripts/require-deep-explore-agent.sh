#!/usr/bin/env bash
# PreToolUse hook (matcher: Agent): force EXPLORATION work onto the `deep-explore`
# agent (Haiku) instead of the built-in `Explore` subagent or a `general-purpose`
# agent — both of which inherit the main session model (Sonnet/Opus).
#
# Ground truth (Claude Code v2.1.204, transcript-verified 2026-07-08):
#   The subagent tool is named `Agent` (NOT `Task`). Its input is
#   { description, prompt, subagent_type }. The native explorer is
#   `Agent(subagent_type="Explore")`. So gating `Task`/`Explore` tool names never
#   fired — the real tool_name is `Agent`.
#
# Why this exists:
#   require-deep-explore.sh stops the MAIN agent from reading raw files directly,
#   so it delegates. But ANY subagent bypasses that read-gate. The main agent then
#   satisfies it with `Agent(subagent_type="Explore")` or `"general-purpose"`, which
#   run on the EXPENSIVE main model and flood context with 40k-130k-token raw reads.
#   This hook forces discovery/exploration onto `deep-explore` (Haiku).
#
# Input (stdin): JSON with .tool_name ("Agent") and
#   .tool_input.{subagent_type,description,prompt}.
# Exit 0 = allow. Exit 2 = block with stderr guidance shown to the agent.

set -euo pipefail

payload="$(cat)"

tool_name=$(printf '%s' "$payload" | jq -r '.tool_name // ""')
# Accept both the current name (`Agent`) and the legacy name (`Task`) for resilience.
case "$tool_name" in
  Agent|Task) ;;
  *) exit 0 ;;
esac

subagent=$(printf '%s' "$payload" | jq -r '.tool_input.subagent_type // ""')
description=$(printf '%s' "$payload" | jq -r '.tool_input.description // ""')
prompt=$(printf '%s' "$payload" | jq -r '.tool_input.prompt // ""')

# When these agents are installed as a plugin, Claude Code namespaces the
# subagent_type as "<plugin>:<agent>" (e.g. "comp-lib-process:deep-explore").
# Strip the plugin prefix so every check below works whether the agents run
# standalone (project .claude/agents) or namespaced inside a plugin.
subagent_base="${subagent##*:}"

# deep-explore itself → allow (it IS the target).
[[ "$subagent_base" == "deep-explore" ]] && exit 0

# Built-in `Explore` subagent runs on the MAIN model — always reroute to deep-explore.
if [[ "$subagent_base" == "Explore" ]]; then
  cat >&2 <<'MSG'
Blocked: the built-in `Explore` subagent runs on the MAIN session model (Sonnet/Opus) and
floods context with raw reads — it does NOT use deep-explore (Haiku).

Re-dispatch with:
  Agent(subagent_type="comp-lib-process:deep-explore", description="...", prompt="<all exploration questions, batched>")

deep-explore returns compressed findings on Haiku — small context, low cost.
MSG
  exit 2
fi

# Any agent defined in this plugin's agents/ folder is deliberate work
# (fetch, plan, implement, review). Do NOT hardcode names — new agents
# (e.g. mcp-fetcher) auto-pass when their .md lands in agents/.
# ponytail: file existence check over maintain allowlist
agents_dir="${CLAUDE_PLUGIN_ROOT:-}/agents"
if [[ -n "$subagent_base" && -f "${agents_dir}/${subagent_base}.md" ]]; then
  exit 0
fi

# Past here, subagent is `general-purpose`, empty, or unknown — default agent
# that runs on the main session model. Police it: if the Task is
# exploration/discovery, it belongs on deep-explore (Haiku), not here.
haystack="${description} ${prompt}"
if printf '%s' "$haystack" | grep -qiE '(explor|investigat|discover|understand|find |search|where |how (does|is|are)|trace|look (for|into)|locate|survey|audit|map (out|the)|analy(z|s)e|inspect|read the|gather context|context (for|about)|tìm hiểu|điều tra|khám phá|khảo sát|phân tích|xem )'; then
  cat >&2 <<'MSG'
Blocked: exploration/discovery Tasks must run on the `deep-explore` agent (Haiku), NOT
`general-purpose` (which inherits the main Sonnet/Opus model and floods context).

Re-dispatch with:
  Agent(subagent_type="comp-lib-process:deep-explore", description="...", prompt="<all exploration questions, batched>")

deep-explore returns compressed findings on Haiku — small context, low cost.
Batch every exploration question into ONE deep-explore dispatch (it parallelizes internally).

If this Task is NOT exploration (it edits/implements/reviews code), pick a specific agent
(engine-specialist, ui-ux-stylist, code-quality-reviewer) instead of general-purpose.
MSG
  exit 2
fi

exit 0
