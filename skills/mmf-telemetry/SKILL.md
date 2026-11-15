---
name: telemetry-gap
description: >-
  Telemetry gap pass for a product bet: compare events needed for the
  success metric and guardrails vs what exists in product analytics (and
  known backend telemetry). Use during the parent refine skill, when
  kicking off an experiment bet, or when asked "what events do we need",
  "telemetry gap", "telemetry for <work item>", or "/telemetry-gap".
  Outputs exist / missing / slice-1 vs later. Does not invent event
  schemas as shipped fact — proposes names clearly marked as draft.
  Confirm before writing into the brief or the epic.
---
# Telemetry gap
> **Template.** Fill in every `{{TOKEN}}` in the config block before installing this skill. Leave runtime values in `<angle brackets>` alone — the agent resolves those on each run. Do not invent event names, project routing, or lexicon search terms that are not in the config.
Specialist called by **`{{PARENT_SKILL}}`** (or standalone). One job: can we **measure** the bet?
## Config — fill in once
| Token | Replace with |
|---|---|
| `{{WORK_ITEM_NAME}}` | What you call the bet (the word people use in chat). |
| `{{WORK_ITEM_PREFIX}}` | Issue-key prefix for the bet. |
| `{{EPIC_PREFIX}}` | Issue-key prefix for the parent epic. |
| `{{PARENT_SKILL}}` | Skill that calls this one, if any. Leave blank if this skill only runs standalone. |
| `{{TRACKING_SECTION}}` | Heading in the epic where findings get written after confirm. |
| `{{ANALYTICS_CONTEXT_TOOL}}` | Tool that loads business context and resolves the analytics org and project. |
| `{{ANALYTICS_SEARCH_TOOL}}` | Tool that searches events, properties, and the lexicon. |
| `{{LEXICON_SEARCH_TERMS}}` | Search terms for this product. Paste your own vocabulary. Do not leave another product's funnel words here. |
| `{{HIGH_SIGNAL_PROPERTIES}}` | Properties worth noting when an event hits (account id, plan, experiment assignment, and so on). |
| `{{EXPERIMENT_RELEASE_TYPES}}` | Release types that require assignment exposure (for example feature flag, experiment). |
| `{{VOICE_RULES}}` | Extra voice rules, or "none". |
### Tool names
Match tools by **name** from the connected tool list. Do not hardcode server UUIDs.
| Capability | Tool | If missing |
|---|---|---|
| Resolve analytics org and project | `{{ANALYTICS_CONTEXT_TOOL}}` | Stop. Do not guess which project to search. |
| Search events and lexicon | `{{ANALYTICS_SEARCH_TOOL}}` | Stop. A gap table with no lexicon check is not a result. |
### Project routing
One row per product surface. The agent searches only the project on the matching row.
| If the bet's surface is | Search this analytics project | Do not search |
|---|---|---|
| {{SURFACE_1}} | {{PROJECT_1}} | {{AVOID_1}} |
| {{SURFACE_2}} | {{PROJECT_2}} | {{AVOID_2}} |
### What every gap table must cover
Paste the checks this team always needs. Delete rows you don't use. The experiment-assignment row stays when the release type is one of `{{EXPERIMENT_RELEASE_TYPES}}`.
| Need | Why it's here |
|---|---|
| {{MUST_COVER_1}} | Funnel step that proves the hypothesis |
| {{MUST_COVER_2}} | Outcome that counts as success |
| {{MUST_COVER_3}} | Guardrail |
## Defaults (tell the user)
- Read-only analytics (+ note backend claims from the brief) unless the user asks to create lexicon entries
- Write findings into the brief + the `{{EPIC_PREFIX}}` epic **{{TRACKING_SECTION}}** section only after confirm (or "confirm once for this pass")
- Propose draft event names for gaps — never claim they already ship
## Inputs
At least one of: a `{{WORK_ITEM_PREFIX}}` / `{{EPIC_PREFIX}}` key, a brief path, or the success metric + guardrails + surface stated in chat.
## Steps
### 1. Load bet
From brief / epic:
- Primary + secondary success metric
- Guardrails
- Surface (match a row in **Project routing**)
- Release type (one of `{{EXPERIMENT_RELEASE_TYPES}}` ⇒ need assignment exposure)
- Any "backend events exist" claims — treat as **unverified** until checked or eng-confirmed
### 2. Analytics
1. Call `{{ANALYTICS_CONTEXT_TOOL}}` (and org/project resolution per that server's rules).
2. Pick the project from **Project routing** for this bet's surface. Do not search a project on another row.
3. Call `{{ANALYTICS_SEARCH_TOOL}}` / lexicon for: `{{LEXICON_SEARCH_TERMS}}`. Add terms taken from this bet's metric and guardrails. Do not add terms from memory of a different product.
4. Note high-signal existing events + key properties (`{{HIGH_SIGNAL_PROPERTIES}}`).
### 3. Gap table
Build:
| Need (for metric / guardrail) | Exists today? | Source | Slice |
|---|---|---|---|
| … | Yes / Partial / No | Analytics event, or "backend only (claimed)" | 1 / later / defer |
Must cover every row in **What every gap table must cover**, plus **assignment exposure** when the release type is one of `{{EXPERIMENT_RELEASE_TYPES}}`.
### 4. Recommend
- **Slice 1 must-have instrumentation** (minimum to learn)
- **Nice-to-have / later**
- **Unblockers** (eng confirm backend event names; data owner for the dashboard)
### 5. Hand back to the parent skill
Return the gap table + recommendations. If invoked from `{{PARENT_SKILL}}`, that skill merges into the epic **{{TRACKING_SECTION}}** section and the brief after confirm.
## Output shape (chat + optional write)
```markdown
## Telemetry gap — <work-item key>
**Project:** <analytics project>
**Metrics / guardrails checked:** …
| Need | Exists? | Evidence | Slice |
|---|---|---|---|
| … | | | |
### Slice 1 must-have
- …
### Later / defer
- …
### Draft event names (not shipped)
- …
### Gaps / unverified
- …
```
## Do not
- Create analytics events or lexicon edits unless the user explicitly asks
- Invent volume metrics ("~70%") as if from this pass
- Skip assignment exposure when the release type is one of `{{EXPERIMENT_RELEASE_TYPES}}`
- Dump the full lexicon — only events relevant to this bet
- Fill a `{{TOKEN}}` from memory of another team's events, projects, or ticket prefixes
## Edge cases
- **Unfilled tokens:** if a `{{TOKEN}}` is still literal when the skill runs, stop and name the token. Do not guess a project, search term, or threshold.
- **No routing row for this surface:** stop and ask which analytics project to search.
- **Analytics tool missing:** stop. Do not produce a gap table from the brief alone.
## Voice
Conclusion first. Tables over prose. Name the analytics project used. Follow `{{VOICE_RULES}}` when that token is set.
