# Workflow spine
> **Template.** Fill in every `{{TOKEN}}` before use. This is the note the intake, refine, and split templates call `{{WORKFLOW_DOC}}`.
>
> Reuse a token from the template that already defines it. Intake: `notes/start-mmf-skill-template.md`. Refine: `notes/refine-mmf-skill-template.md`. Split: `notes/split-mmf-tickets-skill-template.md`. Telemetry: `notes/mmf-telemetry-skill-template.md`. `{{UPSTREAM_SKILL}}` is the installed name of the intake skill.
Spine skills own the **stage** and the writes to `{{BRIEF_STORE}}` and `{{ISSUE_TRACKER}}`. Specialists fill one gap. The spine invokes them when needed, shows the results, then **confirms before it writes**.
```
{{UPSTREAM_SKILL}}
  → brief + bet ticket (confirm)
  → (optional) {{EPIC_PREFIX}} epic parented to the bet
       ↓
  grooming / bet lock
       ↓
  {{REFINE_SKILL}}  (+ {{EPIC_PREFIX}} epic if missing)
       │  auto-pull specialists when gaps:
       │    · {{TELEMETRY_SKILL}}     (events exist vs needed)
       │    · {{TECH_SKETCH_SKILL}}   (thin code / context)
       │    · UX call                 (checklist; a skill later if needed)
       │    · {{DRI_ROLE}}            = {{DRI_FIELD}} on the bet ticket
       ↓
  {{SPLIT_SKILL}}  → {{CHILD_ISSUE_TYPES}} under the {{EPIC_PREFIX}} epic
       │  thicker code context per child; consume refine outputs
       ↓
  build → validate → ship → watch
```
## Spine vs specialists
| Layer | Skills | Job | Auto? |
|---|---|---|---|
| **Spine** | `{{UPSTREAM_SKILL}}` → `{{REFINE_SKILL}}` → `{{SPLIT_SKILL}}` | Stage gates, brief + {{ISSUE_TRACKER}} as the system of record | User-triggered ("start a bet", "kick off", "split") |
| **Specialists** | `{{TELEMETRY_SKILL}}`, `{{TECH_SKETCH_SKILL}}`, later `{{REPO_CONTEXT_SKILL}}` | One gap each; propose, don't invent scope | **Inside the stage** when data is missing |
| **Write gates** | All | {{BRIEF_STORE}}, {{ISSUE_TRACKER}}, and {{DO_NOT_PUBLISH}} | Confirm (or "confirm once for this refine") |
Do **not** build one mega-skill. Compose. Specialists don't create tickets unless the spine asks after confirm.
## Bet owner
**{{DRI_ROLE}} = {{DRI_FIELD}} on the bet ticket** (type `{{BET_ISSUE_TYPE}}`).
Not a parallel custom field. The epic and children may have other assignees. The bet's `{{DRI_FIELD}}` is the named owner, usually `{{DRI_DEFAULT_FUNCTION}}`. `{{REFINE_SKILL}}` must set or confirm it before exit.
## What each stage owns
| Stage | Must lock / produce | Leave for later |
|---|---|---|
| `{{UPSTREAM_SKILL}}` | Problem, surfaces, draft success signal, slices, lean bet ticket | Full locks, children, deep code |
| `{{REFINE_SKILL}}` | Must-haves, access, release, tracking gap, UX in/out, thin tech sketch, {{DRI_ROLE}} (`{{DRI_FIELD}}`), slice-1 done-when, epic handoff | Child tickets, file-level design |
| `{{SPLIT_SKILL}}` | Children with outcome acceptance criteria; event names from the telemetry gap; repo guess | Shipping code |
## Specialist status
| Specialist | Status | When the spine calls it |
|---|---|---|
| Telemetry gap (product analytics + known backend) | Invoke `{{TELEMETRY_SKILL}}` when that folder exists | Refine, if tracking is unnamed or the success metric is unmeasurable |
| Thin tech sketch | `{{TECH_SKETCH_SKILL}}` — inline until that folder exists | Refine, if there is no "where it lives in code" yet |
| UX involvement | Checklist step in `{{REFINE_SKILL}}` | Product UI, or a new user-facing flow |
| Cross-repo context | `{{REPO_CONTEXT_SKILL}}`, when that token is set | End of refine, or start of split |
When a specialist folder is missing, the spine does that job inline. Prefer invoking `{{TELEMETRY_SKILL}}` when it is present.
## Naming
| Skill | Triggers |
|---|---|
| `{{UPSTREAM_SKILL}}` | `/start-bet`, "start a bet", "intake" |
| `{{REFINE_SKILL}}` | `/refine`, `/kickoff`, "refine this bet", "kick off" |
| `{{SPLIT_SKILL}}` | "split <epic key>", "create implementation tickets" |
## Issue-tracker decisions
| Confirm? | Artifact |
|---|---|
| Yes at intake | Bet ticket in `{{WORK_ITEM_PROJECT}}`, type `{{BET_ISSUE_TYPE}}`, team `{{TEAM_NAME}}` when `{{TEAM_FIELD}}` is set. Not issue type `{{BET_ISSUE_TYPE_DO_NOT_USE}}` when that token is set. |
| Ask (often bet lock / refine) | `{{EPIC_PREFIX}}` epic in `{{EPIC_PROJECT}}` (parent = the bet), eng handoff body |
| After refine exit | `{{CHILD_ISSUE_TYPES}}` under the epic |
| On refine | **`{{DRI_FIELD}}` on the bet** = `{{DRI_ROLE}}` |
## Tokens only in this file
| Token | Replace with |
|---|---|
| `{{TECH_SKETCH_SKILL}}` | Installed name of the thin tech-sketch skill. Leave blank to keep that pass inline inside refine. |
