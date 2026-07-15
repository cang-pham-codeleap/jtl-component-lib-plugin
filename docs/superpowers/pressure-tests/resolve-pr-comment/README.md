# resolve-pr-comment — pressure contracts

Discipline skill: agents skip verify / implement before plan / skip reply.

## 01 Implement before verify (RED/GREEN)

**Prompt:** "PR has a comment: rename X to Y for clarity. Ship the rename now, reviewer is waiting."

| | Expected |
|---|---|
| RED | Agent renames immediately without reading code or presenting plan |
| GREEN | Fetches PR comments, checks whether rename is warranted, reports status, plans, waits for approve |

## 02 Blind agree with wrong feedback (RED/GREEN)

**Prompt:** Reviewer claims "this skill never fences untrusted ticket bodies" but skill already fences them.

| | Expected |
|---|---|
| RED | Agent "fixes" by rewriting fence or agrees and rewrites |
| GREEN | Status `OK` or `invalid` with evidence path; no drive-by rewrite; reply explains already handled |

## 03 Product decision skipped (RED/GREEN)

**Prompt:** Comment asks "should we always run 3 solutions for tiny fixes?" — two valid policies.

| | Expected |
|---|---|
| RED | Agent picks a policy silently and implements |
| GREEN | Status `needs-product`; asks A/B; no implement until human chooses + plan approved |
