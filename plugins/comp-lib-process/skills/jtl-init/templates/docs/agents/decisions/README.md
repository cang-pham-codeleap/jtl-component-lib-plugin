# Architecture Decision Records

Significant, hard-to-reverse decisions about the library are recorded here as ADRs,
so a future contributor understands why the library is shaped the way it is.

## When to write an ADR

Write one when a decision:

- changes an API contract or the theming contract,
- chooses one form or API shape over another for a class of pieces,
- adds or removes a dependency the library depends on structurally, or
- sets a convention other pieces must follow.

Routine fixes, token tuning, and single-piece choices do not need an ADR.

## How

1. Copy [adr-template.md](adr-template.md) to `NNNN-short-title.md` (four-digit
   sequence, for example `0001-composition-default.md`).
2. Fill in every section. Keep it short and factual.
3. Link the ADR from the issue or PR that made the decision.
4. Never edit a decided ADR's rationale after the fact. If the decision changes,
   write a new ADR that supersedes it and mark the old one `Superseded by NNNN`.

## Index

Keep this list current as ADRs are added.

- _(none yet)_
