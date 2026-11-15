---
name: refine-mmf
description: >-
  Refine an accepted Growth MMF before build: prioritize and plan — lock
  must-haves vs nice-to-haves, access/permissions (SQS vs SQC), release type,
  tracking, UX involvement, thin tech sketch, and MMF DRI (Assignee on the
  MMF ticket). Ensures a GROW Epic exists (parent = MMF) before split. Auto-
  pulls specialist passes (telemetry gap, tech sketch) when those gaps exist;
  confirm before Jira/Drive writes. Use after start-mmf / bet lock, or when
  kicking work off with eng. Triggers: "refine the MMF", "refine MMF-",
  "refine GROW-", "plan this MMF", "kick off", "kickoff", "lock must-haves",
  "refine-mmf", "/refine-mmf", "/refine", "/kickoff". Does not write
  production code. (Formerly feature-shape / kickoff-mmf.)
---

# Refine MMF

Spine skill for Growth WoW **Bet lock → Refine / plan**. Sync with eng/UX is still the real session — this skill prepares the packet, pulls specialists when needed, captures locks, and updates brief + lean Jira.

**Hierarchy:** MMF Initiative → GROW Epic (parent = MMF) → Stories/Tasks (after refine, via `split-mmf-tickets`).

**Orchestration:** see [../start-mmf/references/workflow.md](../start-mmf/references/workflow.md) (spine + specialists).

## Defaults (tell the user)

- Saving locks to the Drive brief + GROW Epic handoff body
- **MMF DRI = Assignee on the MMF ticket** (set or confirm; not a separate field)
- Auto-running telemetry + thin tech sketch when those gaps exist (inline until specialist skills land)
- Creating GROW Epic if missing (confirm)
- **Not** creating child Stories/Tasks unless user asks to split
- Confirm before Jira edits (or “confirm once for this refine”)

## Do not

- Invent permission models, event schemas, or repo facts — mark unknown
- Clone the MMF body onto the GROW Epic
- Create children here
- Skip MMF Assignee / tracking / UX call when surface is product UI
- Pretend specialist skills exist if folders are missing — run the pass inline

## Inputs

Need at least one of: `MMF-` key, `GROW-` Epic key, brief path, or enough context to find the brief.

## Steps

### 1. Load context

- Read brief; open MMF + GROW Epic
- Note surfaces (SQS/SQC), slices, open decisions
- Read **Assignee on MMF** — empty ⇒ MMF DRI unset

### 2. Ensure GROW Epic

If MMF exists but no GROW Epic: confirm, then create Epic in `GROW` with parent = MMF, Team Growth, Eng Epic Type as appropriate. Body = eng/agent handoff per [jira-lean.md](../start-mmf/references/jira-lean.md) — not an MMF clone.

### 3. Specialist passes (auto when needed)

Run (or invoke specialist skill when it exists). Show results before writing.

| Gap | Pass | Output |
|---|---|---|
| Tracking unnamed / KR unmeasurable | **`mmf-telemetry`** (or inline Mixpanel) — events vs needed for KR + guardrails | Exist / missing / slice-1 must-have vs defer |
| No “where in code” yet | **Tech sketch** — thin code/context (repos, entry points, hard constraints) | Short Epic block; feasibility flag |
| Product UI / new collect flows | **UX call** | UX in / out / which slice(s) |

Do not deep-design here. Feasibility + measurability only. Thicker implementation → `split-mmf-tickets` (+ later `cross-repo-context`).

### 4. Lock checklist (interactive)

1. **Why / what / impact** — still true? Draft KR still right?
2. **Must-haves vs nice-to-haves** — nice-to-haves → later slices
3. **Where it lives + who can access** — lock before tech path; SQS vs SQC
4. **Release type** — FF / staged / alpha-beta / full
5. **Tracking** — from telemetry pass; who watches post-ship
6. **UX** — in / out / which slice
7. **Technical risks** — abuse, Stripe, perf, pentest, dogfood (eng surfaces many)
8. **MMF DRI** — Assignee on MMF (usually eng); slice-1 target date
9. **Slice 1 done-when** — outcome AC only

### 5. Write back

Update brief (status → Refined). Update GROW Epic handoff (locks, tech sketch, tracking, open → closed). Set **Assignee on MMF** if confirmed. Light touch on MMF description (Delivery + locks). No essays.

### 6. Offer next

| Offer | Trigger |
|---|---|
| Child tickets under GROW Epic | `split-mmf-tickets` / “split GROW-YYY” |
| Deeper repo context | Later `cross-repo-context` |

## Exit criteria

- [ ] GROW Epic exists (parent = MMF) or explicitly deferred
- [ ] Must-haves locked for slice 1
- [ ] Access / visibility locked (or deferred with owner)
- [ ] Release type named
- [ ] Tracking: exist vs missing named; watch owner named
- [ ] UX involvement called (in / out / slice)
- [ ] Thin tech sketch on Epic (or deferred with reason)
- [ ] **MMF Assignee set** (= MMF DRI)
- [ ] Slice-1 target date (or explicit TBD with owner)
- [ ] Brief + Jira updated

## Voice

Plain, crisp. Challenge vague “everyone can see it,” “we’ll figure permissions later,” and “we’ll add events somehow.”
