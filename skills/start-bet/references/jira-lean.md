# Lean issues — bet hierarchy
> **Template.** Fill in every `{{TOKEN}}` before use. This is the handoff spec the start and refine templates call `{{HANDOFF_SPEC}}`.
>
> Reuse a token from the template that already defines it, instead of inventing a second value. Intake: `notes/start-mmf-skill-template.md`. Refine: `notes/refine-mmf-skill-template.md`. Split: `notes/split-mmf-tickets-skill-template.md`. `{{UPSTREAM_SKILL}}` is the installed name of the intake skill.
## Principle
**Brief in {{BRIEF_STORE}} = source of truth for context.**
**{{ISSUE_TRACKER}} = tracking + handoff**, not a second PRD.
```
{{WORK_ITEM_PREFIX}}-XXX   ← {{BET_ISSUE_TYPE}} in {{WORK_ITEM_PROJECT}} (intake starts here)
                              {{DRI_FIELD}} = {{DRI_ROLE}} (usually {{DRI_DEFAULT_FUNCTION}})
  └── {{EPIC_PREFIX}}-YYY   ← epic in {{EPIC_PROJECT}} (parent = the bet) — delivery container
        ├── {{EPIC_PREFIX}}-… {{CHILD_ISSUE_TYPES}}  ← after refine
        └── {{EPIC_PREFIX}}-… {{CHILD_ISSUE_TYPES}}
```
{{ROADMAP_TOOL}}: do not depend on it. Prefer `{{BRIEF_DIR}}`. Publish elsewhere only if asked, via `{{PUBLISH_SKILL}}`.
**Orchestration:** spine + specialists — {{WORKFLOW_DOC}}.
## What to create when
| Artifact | Project | When | Skill |
|---|---|---|---|
| Brief | — | Always at intake | `{{UPSTREAM_SKILL}}` |
| Bet ticket | **{{WORK_ITEM_PROJECT}}** | Confirm at intake | `{{UPSTREAM_SKILL}}` — type **{{BET_ISSUE_TYPE}}**. If `{{TEAM_FIELD}}` is set, prefill `{{TEAM_FIELD_ID}}` = `{{TEAM_FIELD_VALUE}}` ({{TEAM_NAME}}). Do not use issue type "{{BET_ISSUE_TYPE_DO_NOT_USE}}" when that token is set. |
| **{{DRI_FIELD}}** on the bet | **{{WORK_ITEM_PROJECT}}** | Refine (or earlier if known) | `{{REFINE_SKILL}}` — **{{DRI_ROLE}} = {{DRI_FIELD}}** |
| Epic (parent = the bet) | **{{EPIC_PROJECT}}** | Confirm — often at bet lock / refine | `{{UPSTREAM_SKILL}}` or `{{REFINE_SKILL}}` |
| {{CHILD_ISSUE_TYPES}} under the epic | **{{EPIC_PROJECT}}** | After refine | `{{SPLIT_SKILL}}` |
| Published page | — | Only if asked | `{{PUBLISH_SKILL}}` |
## Bet ticket body (lean)
```markdown
## Summary
<1–2 sentences: problem + intended outcome>
## Brief
<{{BRIEF_STORE}} path>
## Draft success signal
<one line>
## Surfaces
{{PRODUCT_SURFACES}}
## Proposed slices
1. …
2. …
## Lock before build
- [ ] Who can access / where it lives
- [ ] Differences across {{PRODUCT_SURFACES}} checked
- [ ] Release type ({{RELEASE_TYPES}})
- [ ] Tracking needs named
## Delivery
{{EPIC_PREFIX}} epic: <{{EPIC_PREFIX}}-YYY or TBD>
```
## Epic body (eng handoff — not a second PRD)
One screen an engineer can trust without the PM in the room. Do **not** clone the bet body. Link out for evidence.
```markdown
## Outcome
<what changes for the user / system when this epic succeeds — 1–2 lines>
## Not in this epic (yet)
<non-goals / deferred>
## Success / kill
- Win: <primary success metric>
- Watch: <guardrails>
- Kill / iterate if …
## Constraints
- Surfaces ({{PRODUCT_SURFACES}})
- Access / permissions if known
- Release type ({{RELEASE_TYPES}})
- Hard product or legal facts already locked
- {{TECH_RISK_PROMPTS}} that change architecture (one tight block)
## Tech sketch (thin — from refine)
- Repos / entry points known today
- Hard constraints ({{TECH_SKETCH_CONSTRAINTS}})
- Feasibility: path-change vs platform rewrite (one line)
## Tracking
- Exists today: …
- Missing for the success metric / guardrails: … (slice 1 vs later)
- Who watches post-ship: …
## UX
- In / out / which slice(s)
## Open (block refine → build)
- [ ] …
## Slice 1 (done when)
<outcome acceptance criteria — not an activity list>
**Later slices:** …
## Source of truth
- Brief: <clickable {{BRIEF_STORE}} URL if available, else path + "ask the PM">
- Parent bet: {{WORK_ITEM_PREFIX}}-XXX ({{DRI_FIELD}} = {{DRI_ROLE}})
- PM: <name>
```
## Child tickets
Under the **{{EPIC_PREFIX}} epic**, after refine. Each one: outcome, slice acceptance criteria, and links to the bet and the brief.
## Tokens only in this file
| Token | Replace with |
|---|---|
| `{{ROADMAP_TOOL}}` | A roadmap tool you do not want this flow to depend on. Leave blank to drop that sentence. |
| `{{PUBLISH_SKILL}}` | Skill that publishes when someone asks. Leave blank to drop that row. |
| `{{TECH_SKETCH_CONSTRAINTS}}` | Hard constraints the tech sketch should name. Paste the ones that change the design for your product. |
