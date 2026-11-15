---
name: refine-bet
description: >-
  Refine an accepted bet before build: prioritize and plan — lock must-haves
  vs nice-to-haves, access and permissions across product surfaces, release
  type, tracking, UX involvement, a thin tech sketch, and the bet owner
  (the assignee on the bet ticket). Ensures a delivery epic exists (parent =
  the bet) before tickets are split. Auto-pulls specialist passes (telemetry
  gap, tech sketch) when those gaps exist; confirm before issue-tracker or
  brief writes. Use after the upstream bet-lock skill, or when kicking work
  off with eng. Triggers: "refine this bet", "plan this bet", "kick off",
  "kickoff", "lock must-haves", "/refine", "/kickoff". Does not write
  production code.
---
# Refine bet
> **Template.** Fill in every `{{TOKEN}}` in the config block before installing this skill. Leave runtime values in `<angle brackets>` alone — the agent resolves those on each run. Do not invent permission models, release types, risk lists, or issue fields that are not in the config.
>
> Use the same values for `{{WORK_ITEM_NAME}}`, `{{WORK_ITEM_PREFIX}}`, `{{EPIC_PREFIX}}`, and `{{TRACKING_SECTION}}` as in the telemetry-gap template. Set this file's `{{TELEMETRY_SKILL}}` to that skill's `name`.
Spine skill for **Bet lock → Refine / plan**. Sync with eng and UX is still the real session — this skill prepares the packet, pulls specialists when needed, captures locks, and updates the brief plus a lean issue.
**Hierarchy:** {{WORK_ITEM_NAME}} → {{EPIC_PREFIX}} epic (parent = the bet) → stories and tasks (after refine, via `{{SPLIT_SKILL}}`).
**Orchestration:** see {{WORKFLOW_DOC}} (spine + specialists). If that token is blank, this file is the whole procedure.
## Config — fill in once
| Token | Replace with |
|---|---|
| `{{WORK_ITEM_NAME}}` | What you call the bet (the word people use in chat). |
| `{{WORK_ITEM_PREFIX}}` | Issue-key prefix for the bet. |
| `{{EPIC_PREFIX}}` | Issue-key prefix for the delivery epic. |
| `{{EPIC_PROJECT}}` | Issue-tracker project where the epic is created. Often the same as `{{EPIC_PREFIX}}`. |
| `{{TEAM_FIELD}}` | Field that records the owning team. Leave blank to skip. |
| `{{TEAM_NAME}}` | Value to set on `{{TEAM_FIELD}}`. |
| `{{EPIC_TYPE_FIELD}}` | Field that records the epic type. Leave blank to skip. |
| `{{EPIC_TYPE_RULES}}` | Which value to set for which kind of bet. Do not leave another team's type list here. |
| `{{UPSTREAM_SKILL}}` | Skill that locks the bet before this one. Leave blank if there is none. |
| `{{TELEMETRY_SKILL}}` | Skill that runs the telemetry gap. Use the installed name (`telemetry-gap` unless you renamed it). |
| `{{SPLIT_SKILL}}` | Skill that creates child stories and tasks after refine. |
| `{{REPO_CONTEXT_SKILL}}` | Later skill for a deeper repo pass. Leave blank to drop that offer. |
| `{{WORKFLOW_DOC}}` | Path to the spine-and-specialists note. Leave blank to skip. |
| `{{HANDOFF_SPEC}}` | Path to the lean epic-body spec. Leave blank to write a short handoff from the locks only. |
| `{{BRIEF_STORE}}` | Where the brief lives (shared drive, doc, wiki). |
| `{{ISSUE_TRACKER}}` | Issue tracker you write to. |
| `{{BRIEF_STATUS_REFINED}}` | Status value to set on the brief when refine is done. |
| `{{DRI_ROLE}}` | Name of the bet owner role. |
| `{{DRI_FIELD}}` | Issue field that holds that owner. This skill does not invent a second field. |
| `{{DRI_DEFAULT_FUNCTION}}` | Function that usually holds the role (for example eng). |
| `{{TRACKING_SECTION}}` | Heading on the epic where the telemetry pass is written. |
| `{{PRODUCT_SURFACES}}` | Surfaces this team ships on. Lock which surface, and who can access the change on each, before the tech path. |
| `{{RELEASE_TYPES}}` | Release types you actually use. Paste your list. |
| `{{TECH_RISK_PROMPTS}}` | Risks eng should surface (abuse, payments, performance, security review, internal trial, and so on). Paste yours. |
| `{{VOICE_RULES}}` | Extra voice rules, or "none". |
## Defaults (tell the user)
- Saving locks to the brief in `{{BRIEF_STORE}}` and the `{{EPIC_PREFIX}}` epic handoff body
- **{{DRI_ROLE}} = `{{DRI_FIELD}}` on the bet ticket** (set or confirm; not a separate field)
- Auto-running telemetry and a thin tech sketch when those gaps exist (inline until the specialist skill folder exists)
- Creating the `{{EPIC_PREFIX}}` epic if missing (confirm)
- **Not** creating child stories or tasks unless the user asks to split
- Confirm before `{{ISSUE_TRACKER}}` edits (or "confirm once for this refine")
## Do not
- Invent permission models, event schemas, or repo facts — mark unknown
- Clone the bet body onto the epic
- Create children here
- Skip `{{DRI_FIELD}}`, tracking, or the UX call when the surface is product UI
- Pretend a specialist skill exists if its folder is missing — run the pass inline
- Fill a `{{TOKEN}}` from memory of another team's projects, surfaces, or release types
## Inputs
Need at least one of: a `{{WORK_ITEM_PREFIX}}` key, a `{{EPIC_PREFIX}}` epic key, a brief path, or enough context to find the brief.
## Steps
### 1. Load context
- Read the brief; open the bet and the `{{EPIC_PREFIX}}` epic
- Note surfaces (`{{PRODUCT_SURFACES}}`), slices, and open decisions
- Read **`{{DRI_FIELD}}` on the bet** — empty ⇒ `{{DRI_ROLE}}` unset
### 2. Ensure the delivery epic
If the bet exists but no `{{EPIC_PREFIX}}` epic does: confirm, then create an epic in `{{EPIC_PROJECT}}` with parent = the bet. Set `{{TEAM_FIELD}}` to `{{TEAM_NAME}}` and `{{EPIC_TYPE_FIELD}}` from `{{EPIC_TYPE_RULES}}` when those tokens are filled in. Skip a field whose token is blank.
Body = an eng handoff per `{{HANDOFF_SPEC}}` — not a clone of the bet. If `{{HANDOFF_SPEC}}` is blank, write a short handoff from the locks only.
### 3. Specialist passes (auto when needed)
Run the specialist skill when its folder exists. Otherwise run the pass inline. Show results before writing.
| Gap | Pass | Output |
|---|---|---|
| Tracking unnamed, or the success metric is unmeasurable | **`{{TELEMETRY_SKILL}}`** (or an inline analytics pass) — events vs what the metric and guardrails need | Exist / missing / slice-1 must-have vs defer |
| No "where in code" yet | **Tech sketch** — thin code context (repos, entry points, hard constraints) | Short epic block; feasibility flag |
| Product UI, or a new user-facing flow | **UX call** | UX in / out / which slice(s) |
Do not deep-design here. Feasibility and measurability only. Thicker implementation → `{{SPLIT_SKILL}}` (and later `{{REPO_CONTEXT_SKILL}}` if that token is set).
### 4. Lock checklist (interactive)
1. **Why / what / impact** — still true? Draft success metric still right?
2. **Must-haves vs nice-to-haves** — nice-to-haves → later slices
3. **Where it lives + who can access** — lock before the tech path, across `{{PRODUCT_SURFACES}}`
4. **Release type** — one of `{{RELEASE_TYPES}}`
5. **Tracking** — from the telemetry pass; who watches post-ship
6. **UX** — in / out / which slice
7. **Technical risks** — `{{TECH_RISK_PROMPTS}}` (eng surfaces many)
8. **{{DRI_ROLE}}** — `{{DRI_FIELD}}` on the bet (usually `{{DRI_DEFAULT_FUNCTION}}`); slice-1 target date
9. **Slice 1 done-when** — outcome acceptance criteria only
### 5. Write back
Update the brief (status → `{{BRIEF_STATUS_REFINED}}`). Update the epic handoff (locks, tech sketch, tracking, open → closed). Set **`{{DRI_FIELD}}` on the bet** if confirmed. Light touch on the bet description (delivery + locks). No essays.
Write telemetry into the epic **{{TRACKING_SECTION}}** section.
### 6. Offer next
| Offer | Trigger |
|---|---|
| Child tickets under the epic | `{{SPLIT_SKILL}}` / "split <epic key>" |
| Deeper repo context | Later `{{REPO_CONTEXT_SKILL}}`, only if that token is set |
## Exit criteria
- [ ] `{{EPIC_PREFIX}}` epic exists (parent = the bet) or is explicitly deferred
- [ ] Must-haves locked for slice 1
- [ ] Access / visibility locked (or deferred with an owner)
- [ ] Release type named, from `{{RELEASE_TYPES}}`
- [ ] Tracking: exist vs missing named; watch owner named
- [ ] UX involvement called (in / out / slice)
- [ ] Thin tech sketch on the epic (or deferred with a reason)
- [ ] **`{{DRI_FIELD}}` set on the bet** (= `{{DRI_ROLE}}`)
- [ ] Slice-1 target date (or an explicit TBD with an owner)
- [ ] Brief and `{{ISSUE_TRACKER}}` updated
## Edge cases
- **Unfilled tokens:** if a `{{TOKEN}}` is still literal when the skill runs, stop and name the token. Do not guess a project, surface, release type, or field.
- **Specialist folder missing:** run that pass inline and say so in one line. Do not skip the pass.
- **User did not confirm writes:** show the packet and stop before `{{ISSUE_TRACKER}}` or `{{BRIEF_STORE}}` edits.
## Voice
Plain, crisp. Follow `{{VOICE_RULES}}` when that token is set. Challenge vague "everyone can see it," "we'll figure permissions later," and "we'll add events somehow."
