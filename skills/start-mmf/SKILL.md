---
name: start-mmf
description: >-
  Start a Sonar MMF the Growth way: Drive brief, proposed slices, and a lean
  ticket in the MMF Jira project. Optionally create a GROW Epic parented to that
  MMF when the bet is ready for eng. Use when a PM spots an opportunity, starts
  an MMF, intakes a feature, or says "start MMF", "new MMF", "opportunity
  brief", "should we build X", "intake this", "/start-mmf", or "/mmf". Does not
  create implementation tickets under the GROW Epic — those wait until after
  Kickoff (split-mmf-tickets).
---

# Start MMF

Lean intake for Growth. Rich context on Drive; Jira stays thin.

**Jira hierarchy (Growth):**
1. **MMF** project ticket (PM initiates here — company pattern)
2. **GROW Epic** with the MMF as **parent** (squad delivery container)
3. **GROW Stories/Tasks** under that Epic (after kickoff)

Matches WoW: **Intake → Triage → Bet lock**. Stops before refine/build. Full spine + specialists: [references/workflow.md](references/workflow.md).

## Naming note

Skill id is `start-mmf` (Sonar language). “Opportunity brief” is the Drive artifact + a trigger synonym — not the primary command name.

## Defaults (tell the user)

- Saving brief to `backlog/mmfs/<slug>-YYYY-MM-DD.md`
- Creating **one lean MMF-project ticket** after user confirms
- Creating **GROW Epic** only when user confirms (often at bet lock / when eng will pick up — not forced at first draft)
- **Not** creating child Stories/Tasks at intake
- Not publishing to Confluence/Slack unless asked

## Do not

- Invent evidence, metrics, or customer quotes
- Put the MMF in the GROW project (wrong project)
- Auto-create GROW Epic without ask
- Auto-create Stories/Tasks under the Epic
- Dump the full brief into any Jira description
- Skip access / SQS-vs-SQC / tracking prompts when the surface is product UI

## Steps

### 0. Resolve paths

```
Drive_root = Growth (1H26 Project - CPA3) workspace root
brief_dir  = <Drive_root>/backlog/mmfs
slug       = kebab-case short title
brief_path = <brief_dir>/<slug>-YYYY-MM-DD.md
```

### 1. Gather (ask only what's missing)

From conversation + tools (Mixpanel, Atlan/Redshift, Slack, Zoom, Confluence, Glean) pull what you can. Name gaps explicitly.

Minimum to proceed:
1. Problem / opportunity in one sentence
2. Who hurts (persona / segment)
3. Why now
4. Draft success signal / KR (even rough)
5. Surfaces: SQS / SQC / both / other

If too thin, ask 1–3 clarifying questions. Do not invent scope.

### 2. Write the brief

Use template in [references/brief-template.md](references/brief-template.md).

Must include (keep the **Drive brief short enough for a human to skim in ~1 min** — agents read structure, not essays):
- **Proposed slices** — 1–2 week shippable chunks. Mark slice 1 as the starting bet.
- **Open decisions to lock before irreversible tech** — who has access / where it lives / SQS≠SQC
- **Early risks** — security, perf, dogfood, bulk actions, permissions / abuse
- **Evidence** — links or "no data yet" (one short section; no novels)

If context is long (research, quotes), put it in `references/` or link out — not in the main brief.

Save to `brief_path`. Show for review.

### 3. Create MMF ticket (lean) — confirm first

Per [references/jira-lean.md](references/jira-lean.md).

Ask: create **MMF project** ticket now? (default yes after brief OK)

On confirm: create via Jira MCP:
- `projectKey: MMF`
- `issueTypeName: Initiative` (confusing but correct — do **not** use type "MMF")
- `additional_fields.customfield_10001: "e923828c-1f51-4f27-844a-fb5bb2160f61"` (**Team = Growth** — always prefill)

Description = TL;DR + brief path + draft KR + surfaces + proposed slices + lock-before-build checklist — **not** the full evidence dump.

Update brief with `MMF-XXX`.

### 4. GROW Epic — separate confirm

Ask when they want the GROW Epic:
- **Now** — if already committing / need a delivery container on the board
- **Later** — at bet lock / `refine-mmf` (recommended default for early ideas)

On confirm: create **Epic** in `GROW` with **parent = MMF-XXX**, Team **Growth**, and required **Eng Epic Type**. Epic body = eng/agent handoff per [jira-lean.md](references/jira-lean.md) (Outcome / Not in / Success-kill / Constraints / Open / Slice 1 done-when / SoT) — **not** a clone of the MMF. Update brief with `GROW-YYY`.

### 5. Hand off

| Next | When | Trigger |
|---|---|---|
| Groom / prioritize | Before WIP | Squad / `/prioritize-backlog` |
| GROW Epic (if deferred) | Bet lock | "create GROW epic for MMF-XXX" |
| **`refine-mmf`** | Before build | "refine MMF-XXX" / "kick off MMF-XXX" |
| Child tickets under Epic | After refine | `split-mmf-tickets` — "split GROW-YYY" |
| Cross-repo context | Multi-repo | Later skill |

Stop. Do not design the solution unless they invoke `refine-mmf`.

## Voice

Growth CLAUDE.md: conclusion first, plain language, no hype, no invented numbers.
