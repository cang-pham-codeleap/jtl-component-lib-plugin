# Contributing

How a change lands in this library. Any change to a Component or Block API, any new
Component or Block, and any behavioral change follows the spec-first workflow — no
exceptions, even for a "small" prop addition. A prop that seems simple often has
architectural implications.

## Safe zones (no spec required)

You can explore freely here without the spec protocol:

- **Recipes and examples** — compose existing pieces, document a pattern. If you
  cannot build what you need from existing pieces, that is a signal: file an issue
  describing the gap, not a PR adding a prop.
- **Token / theme tuning** — adjust what a token resolves to. See
  [authoring/tokens.md](authoring/tokens.md).
- **Stories** — realistic compositions, edge cases, state coverage.

The moment a change needs a new core prop, variant, or export, switch to the spec
protocol.

## The spec-first workflow

1. **File an issue.** Describe the problem, not the solution: what users need to do
   and why they can't today. Include design intent and who needs it.
2. **Research existing usage.** How is this used today, which props are actually
   used, how do people work around the current limitation. Compare with shadcn,
   Radix, and other systems. This is the step most often skipped and the most
   important one.
3. **Propose the API.** Show code examples, explain trade-offs, reference the
   research. Discussion happens here — it is cheaper to iterate on an issue than a
   PR.
4. **Build it.** Compose from existing pieces, tokens everywhere, follow
   [api-conventions.md](api-conventions.md) and the bundled `shadcn` skill. Write
   colocated tests, add stories, add registry metadata.
5. **Evaluate when the API is contested.** When choosing between API shapes, build
   both and see which one an agent reaches for naturally, rather than debating.

## Pull requests

- **Draft first.** Open PRs as drafts (`gh pr create --draft`). Mark ready only
  when the change is actually ready. Use the bundled `create-pr` skill.
- **Self-review before requesting review.** Read every line, verify tokens and
  a11y attributes are real, run tests / build / lint locally, confirm the output
  matches the brief.
- **Link the issue** the PR implements.

## Common reasons a change gets closed

- **Coverage without usage evidence** — a change with no data on which products
  need it or how the piece is used today.
- **Proposing a solution instead of a problem** — "add prop X" instead of "users
  need Y." Describe the problem and let the workflow find the right solution.
- **Putting things in the wrong place** — know where each thing goes (see the
  [decision matrix](decision-matrix.md) and [architecture](architecture.md)).
- **Building without prior discussion** — jumping to implementation before the API
  is agreed wastes everyone's effort.
- **Raw values instead of tokens** — swapping one hardcoded number for another does
  not fix the problem. Replace it with a token reference.

## Writing style

Write like a careful engineer. No AI-slop: no buzzword filler, no significance
padding, no hollow intensifiers. Straight quotes and `...`, not curly characters.
See [maintenance.md](maintenance.md).

## Related

- [decision-matrix.md](decision-matrix.md) — decide the form first.
- [hardening.md](hardening.md) — the quality pass after merge.
