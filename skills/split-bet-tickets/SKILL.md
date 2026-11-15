---
name: split-bet-tickets
description: >-
  Create lean child stories and tasks under a refined delivery epic (parent =
  the bet) after must-haves are locked. Consumes refine outputs (telemetry
  gaps, tech sketch, UX call, bet owner). Use when eng or PM says "split
  <epic key>", "split <bet key>", "create implementation tickets", "break
  into slices", or after the refine skill. Do not run at intake time.
---
# Split bet tickets
> **Template.** Fill in every `{{TOKEN}}` in the config block before installing this skill. Leave runtime values in `<angle brackets>` alone — the agent resolves those on each run.
>
> Use the same values for `{{WORK_ITEM_NAME}}`, `{{WORK_ITEM_PREFIX}}`, `{{EPIC_PREFIX}}`, `{{EPIC_PROJECT}}`, `{{DRI_ROLE}}`, `{{DRI_FIELD}}`, `{{UPSTREAM_SKILL}}`, `{{TELEMETRY_SKILL}}`, `{{REPO_CONTEXT_SKILL}}`, and `{{WORKFLOW_DOC}}` as in the refine template. `{{WORK_ITEM_PROJECT}}` is the project the bet lives in, which may differ from `{{EPIC_PROJECT}}`. Set `{{REFINE_SKILL}}` to that skill's `name`.
Creates **child** work items under the **{{EPIC_PREFIX}} epic**. Requires the refine exit criteria (or an explicit override).
Spine position: after `{{REFINE_SKILL}}`. See {{WORKFLOW_DOC}}. If that token is blank, this file is the whole procedure.
## Config — fill in once
| Token | Replace with |
|---|---|
| `{{WORK_ITEM_NAME}}` | What you call the bet. |
| `{{WORK_ITEM_PREFIX}}` | Issue-key prefix for the bet. |
| `{{WORK_ITEM_PROJECT}}` | Project the bet lives in. Do not create children here. |
| `{{EPIC_PREFIX}}` | Issue-key prefix for the delivery epic. |
| `{{EPIC_PROJECT}}` | Project where children are created. Parent = the epic. |
| `{{CHILD_ISSUE_TYPES}}` | Issue types to create (for example story, task). |
| `{{REFINE_SKILL}}` | Skill that locks must-haves before this one. |
| `{{UPSTREAM_SKILL}}` | Intake skill that creates the bet and the epic if refine has not run. |
| `{{TELEMETRY_SKILL}}` | Skill whose gap output this one copies onto children. |
| `{{REPO_CONTEXT_SKILL}}` | Later skill for a thicker per-child repo pass. Leave blank to drop that offer. |
| `{{WORKFLOW_DOC}}` | Path to the spine-and-specialists note. Leave blank to skip. |
| `{{DRI_ROLE}}` | Name of the bet owner role. |
| `{{DRI_FIELD}}` | Issue field on the bet that holds that owner. |
## Hierarchy
```
{{WORK_ITEM_PREFIX}}-XXX ({{DRI_FIELD}} = {{DRI_ROLE}}) → {{EPIC_PREFIX}} epic (YYY) → {{CHILD_ISSUE_TYPES}} (this skill)
```
## Steps
1. Load the brief, the bet, and the `{{EPIC_PREFIX}}` epic. If the epic is missing, stop and offer to create it first (`{{REFINE_SKILL}}` / `{{UPSTREAM_SKILL}}`).
2. Verify the refine exit criteria (including `{{DRI_FIELD}}` on the bet, tracking exist/missing, the UX call, and a thin tech sketch). Warn if any are still open.
3. Consume the refine outputs: missing events → instrumentation acceptance criteria or a ticket; tech sketch → a repo guess on each child.
4. Propose children from **locked slices** (title, outcome, acceptance criteria, repo guess). Add thicker code context per child here, or later via `{{REPO_CONTEXT_SKILL}}` if that token is set.
5. Confirm which slices become tickets now (usually slice 1 only).
6. Create them in **{{EPIC_PROJECT}}** with **parent = the {{EPIC_PREFIX}} epic**. Lean body:
```markdown
## Outcome
<one line>
## Parent
Epic <{{EPIC_PREFIX}}-YYY> · <{{WORK_ITEM_PREFIX}}-XXX> ({{DRI_ROLE}} = {{DRI_FIELD}})
Brief: <path>
## AC
- [ ] …
## Tracking (if any)
Events / properties from the {{TELEMETRY_SKILL}} gap. Mark anything refine left as TBD.
## Notes
Slice N. See the brief and the epic tech sketch.
```
7. Write the new keys into the brief slice table.
## Do not
- Create tickets in `{{WORK_ITEM_PROJECT}}`
- Recreate the full brief on every child
- Ticket unlocked nice-to-haves
- Create epics here (unless recovering a missing epic after the user confirms)
- Invent event names that refine left as TBD without calling that out
- Fill a `{{TOKEN}}` from memory of another team's projects or issue types
## Edge cases
- **Unfilled tokens:** if a `{{TOKEN}}` is still literal when the skill runs, stop and name the token. Do not guess a project or an issue type.
- **Refine exit criteria still open:** show which items are open and ask for an explicit override before creating tickets.
- **Invoked at intake:** stop. This skill runs only after `{{REFINE_SKILL}}`.
