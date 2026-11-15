---
name: start-bet
description: >-
  Start a bet: a short brief, proposed slices, and one lean ticket in the bet
  project. Optionally create a delivery epic parented to that bet when it is
  ready for eng. Use when a PM spots an opportunity, starts a bet, intakes a
  feature, or says "start a bet", "new bet", "opportunity brief", "should we
  build X", "intake this", "/start-bet", or "/bet". Does not create
  implementation tickets under the epic — those wait until after refine
  (the split skill).
---

# Start bet

> **Template.** Fill in every `{{TOKEN}}` in the config block before installing this skill. Leave runtime values in `<angle brackets>` alone — the agent resolves those on each run. Do not invent evidence, metrics, project keys, issue types, or field ids that are not in the config.
>
> This skill is what the refine and split templates call `{{UPSTREAM_SKILL}}`. Use the same values here for `{{WORK_ITEM_NAME}}`, `{{WORK_ITEM_PREFIX}}`, `{{WORK_ITEM_PROJECT}}`, `{{EPIC_PREFIX}}`, `{{EPIC_PROJECT}}`, `{{TEAM_FIELD}}`, `{{TEAM_NAME}}`, `{{EPIC_TYPE_FIELD}}`, `{{EPIC_TYPE_RULES}}`, `{{REFINE_SKILL}}`, `{{SPLIT_SKILL}}`, `{{REPO_CONTEXT_SKILL}}`, `{{WORKFLOW_DOC}}`, `{{HANDOFF_SPEC}}`, `{{PRODUCT_SURFACES}}`, `{{TECH_RISK_PROMPTS}}`, and `{{VOICE_RULES}}`.

Lean intake. Rich context in the brief; the issue tracker stays thin.

**Issue hierarchy:**

1. **Bet ticket** in `{{WORK_ITEM_PROJECT}}` (intake starts here)
2. **{{EPIC_PREFIX}} epic** with the bet as **parent** (delivery container)
3. **Child issues** under that epic (after `{{REFINE_SKILL}}`, via `{{SPLIT_SKILL}}`)

Matches the stages **Intake → Triage → Bet lock**. Stops before refine and build. Full spine and specialists: {{WORKFLOW_DOC}}. If that token is blank, this file is the whole procedure.

## Config — fill in once

| Token | Replace with |
|---|---|
| `{{WORK_ITEM_NAME}}` | What you call the bet. |
| `{{WORK_ITEM_PREFIX}}` | Issue-key prefix for the bet. |
| `{{WORK_ITEM_PROJECT}}` | Project the bet ticket is created in. |
| `{{BET_ISSUE_TYPE}}` | Issue type to create for the bet. |
| `{{BET_ISSUE_TYPE_DO_NOT_USE}}` | An issue type that looks right but is wrong. Leave blank if none. |
| `{{EPIC_PREFIX}}` | Issue-key prefix for the delivery epic. |
| `{{EPIC_PROJECT}}` | Project the epic is created in. |
| `{{TEAM_FIELD}}` | Field that records the owning team. Leave blank to skip. |
| `{{TEAM_FIELD_ID}}` | Custom-field id for `{{TEAM_FIELD}}`, if the tracker needs an id. |
| `{{TEAM_FIELD_VALUE}}` | Value to write into that field (id or name, whichever the tracker expects). |
| `{{TEAM_NAME}}` | Team name to show in the brief and in chat. |
| `{{EPIC_TYPE_FIELD}}` | Field that records the epic type. Leave blank to skip. |
| `{{EPIC_TYPE_RULES}}` | Which value to set for which kind of bet. |
| `{{WORKSPACE_ROOT}}` | Workspace root the brief path is relative to. |
| `{{BRIEF_DIR}}` | Folder for briefs, under `{{WORKSPACE_ROOT}}` or absolute. |
| `{{BRIEF_TEMPLATE}}` | Path to the brief template. |
| `{{HANDOFF_SPEC}}` | Path to the lean epic-body spec. |
| `{{WORKFLOW_DOC}}` | Path to the spine-and-specialists note. Leave blank to skip. |
| `{{CONTEXT_SOURCES}}` | Connected tools to pull from before asking (analytics, warehouse, chat, meetings, wiki, company knowledge). Skip any that are not connected. |
| `{{PRODUCT_SURFACES}}` | Surfaces this team ships on. |
| `{{TECH_RISK_PROMPTS}}` | Early risks to prompt for. Paste yours. |
| `{{REFINE_SKILL}}` | Skill that locks must-haves before build. |
| `{{SPLIT_SKILL}}` | Skill that creates child issues after refine. |
| `{{REPO_CONTEXT_SKILL}}` | Later skill for a multi-repo pass. Leave blank to drop that offer. |
| `{{PRIORITIZE_SKILL}}` | Skill or ritual for grooming before work in progress. Leave blank to drop that row. |
| `{{DO_NOT_PUBLISH}}` | Destinations this skill must not publish to unless asked. |
| `{{VOICE_RULES}}` | Extra voice rules, or "none". |

## Defaults (tell the user)

- Saving the brief to `{{BRIEF_DIR}}/<slug>-YYYY-MM-DD.md`
- Creating **one lean bet ticket** in `{{WORK_ITEM_PROJECT}}` after the user confirms
- Creating the **{{EPIC_PREFIX}} epic** only when the user confirms (often at bet lock, when eng will pick it up — not forced on the first draft)
- **Not** creating child issues at intake
- Not publishing to `{{DO_NOT_PUBLISH}}` unless asked

## Do not

- Invent evidence, metrics, or customer quotes
- Put the bet ticket in `{{EPIC_PROJECT}}` when that is a different project from `{{WORK_ITEM_PROJECT}}`
- Use `{{BET_ISSUE_TYPE_DO_NOT_USE}}` when that token is set
- Auto-create the epic without asking
- Auto-create child issues under the epic
- Dump the full brief into any issue description
- Skip the access, surface, and tracking prompts when the surface is product UI
- Fill a `{{TOKEN}}` from memory of another team's projects, field ids, or surfaces

## Steps

### 0. Resolve paths

```
workspace_root = {{WORKSPACE_ROOT}}
brief_dir      = {{BRIEF_DIR}}
slug           = kebab-case short title
brief_path     = <brief_dir>/<slug>-YYYY-MM-DD.md
```

### 1. Gather (ask only what's missing)

From the conversation and `{{CONTEXT_SOURCES}}`, pull what you can. Name gaps explicitly. If a source is not connected, skip it.

Minimum to proceed:

1. Problem or opportunity in one sentence
2. Who hurts (persona or segment)
3. Why now
4. Draft success signal (even rough)
5. Surfaces, from `{{PRODUCT_SURFACES}}`

If that is too thin, ask 1–3 clarifying questions. Do not invent scope.

### 2. Write the brief

Use `{{BRIEF_TEMPLATE}}`. If that token is blank, use the headings below and nothing else.

Keep the brief short enough for a person to skim in about a minute. Agents read structure, not essays.

- **Proposed slices** — shippable chunks. Mark slice 1 as the starting bet.
- **Open decisions to lock before irreversible tech** — who has access, where it lives, and where `{{PRODUCT_SURFACES}}` differ
- **Early risks** — `{{TECH_RISK_PROMPTS}}`
- **Evidence** — links, or "no data yet" (one short section)

If context is long (research, quotes), put it beside the brief or link out — not in the main brief.

Save to `brief_path`. Show it for review.

### 3. Create the bet ticket (lean) — confirm first

Follow `{{HANDOFF_SPEC}}` for how thin the description stays. If that token is blank, use the description rule below.

Ask: create the `{{WORK_ITEM_PROJECT}}` ticket now? (Default yes after the brief is accepted.)

On confirm, create it in the issue tracker:

- Project: `{{WORK_ITEM_PROJECT}}`
- Issue type: `{{BET_ISSUE_TYPE}}`
- If `{{TEAM_FIELD}}` is set, prefill it with `{{TEAM_FIELD_VALUE}}` (field id `{{TEAM_FIELD_ID}}` when that token is set). Skip the team prefill when those tokens are blank.

Description = a short summary, the brief path, the draft success signal, surfaces, proposed slices, and the lock-before-build checklist. Not the evidence dump.

Update the brief with the new `{{WORK_ITEM_PREFIX}}` key.

### 4. Delivery epic — separate confirm

Ask when they want the `{{EPIC_PREFIX}}` epic:

- **Now** — already committing, or they need a delivery container on the board
- **Later** — at bet lock / `{{REFINE_SKILL}}` (recommended default for early ideas)

On confirm: create an epic in `{{EPIC_PROJECT}}` with **parent = the bet**. Set `{{TEAM_FIELD}}` to `{{TEAM_NAME}}` and `{{EPIC_TYPE_FIELD}}` from `{{EPIC_TYPE_RULES}}` when those tokens are filled in. Skip a field whose token is blank.

Epic body = the eng handoff in `{{HANDOFF_SPEC}}` — not a clone of the bet. If `{{HANDOFF_SPEC}}` is blank, write a short handoff: outcome, not in scope, success and kill criteria, constraints, open questions, slice 1 done-when, and where the brief lives.

Update the brief with the new `{{EPIC_PREFIX}}` key.

### 5. Hand off

| Next | When | Trigger |
|---|---|---|
| Groom / prioritize | Before work in progress | `{{PRIORITIZE_SKILL}}`, if that token is set |
| Epic (if deferred) | Bet lock | "create the epic for <bet key>" |
| **`{{REFINE_SKILL}}`** | Before build | "refine <bet key>" / "kick off <bet key>" |
| Child issues under the epic | After refine | `{{SPLIT_SKILL}}` — "split <epic key>" |
| Cross-repo context | Multi-repo | `{{REPO_CONTEXT_SKILL}}`, if that token is set |

Stop. Do not design the solution unless they invoke `{{REFINE_SKILL}}`.

## Edge cases

- **Unfilled tokens:** if a `{{TOKEN}}` is still literal when the skill runs, stop and name the token. Do not guess a project, an issue type, or a field id.
- **User has not confirmed the ticket:** show the brief and stop before any issue-tracker write.
- **Asked to split or implement:** stop and point at `{{REFINE_SKILL}}`, then `{{SPLIT_SKILL}}`.

## Voice

Conclusion first, plain language, no hype, no invented numbers. Follow `{{VOICE_RULES}}` when that token is set.
