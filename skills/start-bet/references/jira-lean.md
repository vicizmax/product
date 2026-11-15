# Lean Jira — Growth MMF hierarchy

## Principle

**Drive brief = source of truth for context.**  
**Jira = tracking + handoff**, not a second PRD.

```
MMF-XXX          ← MMF Initiative (PM initiates — company pattern)
                   Assignee = MMF DRI (usually eng)
  └── GROW-YYY   ← GROW Epic (parent = MMF-XXX) — squad delivery container
        ├── GROW-… Story/Task  ← after refine
        └── GROW-… Story/Task
```

Productboard: do not depend on it. Prefer Drive `backlog/mmfs/*.md`, optional Confluence later.

**Orchestration:** spine + specialists — [workflow.md](workflow.md).

## What to create when

| Artifact | Project | When | Skill |
|---|---|---|---|
| Drive brief | — | Always at intake | `start-mmf` |
| MMF Initiative | **MMF** | Confirm at intake | `start-mmf` — type **Initiative**, Team **Growth** (`customfield_10001` = `e923828c-1f51-4f27-844a-fb5bb2160f61`). Do not use issue type "MMF". |
| **MMF Assignee** | **MMF** | Refine (or earlier if known) | `refine-mmf` — **MMF DRI = Assignee** |
| GROW Epic (parent = MMF) | **GROW** | Confirm — often at bet lock / refine | `start-mmf` or `refine-mmf` |
| Stories/Tasks under Epic | **GROW** | After refine | `split-mmf-tickets` |
| Confluence | — | Only if asked | `/publish-confluence` |

## MMF ticket body (lean)

```markdown
## Summary
<1–2 sentences: problem + intended outcome>

## Brief
<Drive path>

## Draft KR
<one line>

## Surfaces
SQS / SQC / …

## Proposed slices
1. …
2. …

## Lock before build
- [ ] Who can access / where it lives
- [ ] SQS vs SQC permission differences checked
- [ ] Release type
- [ ] Tracking needs named

## Delivery
GROW Epic: <GROW-YYY or TBD>
```

## GROW Epic body (eng/agent handoff — not a second PRD)

One screen an engineer can trust without the PM in the room. Do **not** clone the MMF body. Link out for evidence.

```markdown
## Outcome
<what changes for the user / system when this Epic succeeds — 1–2 lines>

## Not in this Epic (yet)
<non-goals / deferred>

## Success / kill
- Win: <primary KR>
- Watch: <guardrails>
- Kill / iterate if …

## Constraints
- Surfaces (SQS / SQC / …)
- Access / permissions if known
- Release type (FF / staged / …)
- Hard product or legal facts already locked
- Abuse / cost risks that change architecture (one tight block)

## Tech sketch (thin — from refine)
- Repos / entry points known today
- Hard constraints (billing, entitlements, FF)
- Feasibility: path-change vs platform rewrite (one line)

## Tracking
- Exists today: …
- Missing for KR / guardrails: … (slice 1 vs later)
- Who watches post-ship: …

## UX
- In / out / which slice(s)

## Open (block refine → build)
- [ ] …

## Slice 1 (done when)
<outcome AC — not activity list>

**Later slices:** …

## Source of truth
- Brief: <clickable Drive/Docs URL if available, else path + “ask PM”>
- Parent MMF: MMF-XXX (Assignee = MMF DRI)
- PM: <name>
```
## Child tickets

Under **GROW Epic**, after refine. Each: outcome + slice AC + links to MMF + brief.
