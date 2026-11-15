---
name: mmf-telemetry
description: >-
  Telemetry gap pass for a Growth MMF: compare events needed for KR and
  guardrails vs what exists in Mixpanel (and known backend telemetry). Use
  during refine-mmf, when kicking off an experiment/FF MMF, or when asked
  "what events do we need", "Mixpanel gap", "telemetry for MMF-", or
  "/mmf-telemetry". Outputs exist / missing / slice-1 vs later. Does not
  invent event schemas as shipped fact — proposes names clearly marked as
  draft. Confirm before writing into brief or GROW Epic.
---

# MMF telemetry gap

Specialist called by **`refine-mmf`** (or standalone). One job: can we **measure** the bet?

## Defaults (tell the user)

- Read-only Mixpanel (+ note backend claims from brief) unless user asks to create lexicon entries
- Write findings into brief + GROW Epic **Tracking** section only after confirm (or “confirm once for this refine”)
- Propose draft event names for gaps — never claim they already ship

## Inputs

At least one of: `MMF-` / `GROW-` key, brief path, or KR + guardrails + surface stated in chat.

## Steps

### 1. Load bet

From brief / Epic:
- Primary + secondary KR
- Guardrails
- Surface (SQS / SQC / …)
- Release type (FF ⇒ need assignment exposure)
- Any “backend events exist” claims — treat as **unverified** until checked or eng-confirmed

### 2. Mixpanel

1. `Get-Business-Context` (and org/project resolution per Mixpanel server rules)
2. Prefer **SQC / Cloud** project for SQC bets; **don’t** search Server project for Cloud billing
3. `Search-Entities` / lexicon for: trial, plan, checkout, credit card / payment method, billing, subscription, convert, suspend, feature flag / experiment
4. Note high-signal existing events + key properties (plan, interval, FF, org id)

### 3. Gap table

Build:

| Need (for KR / guardrail) | Exists today? | Source | Slice |
|---|---|---|---|
| … | Yes / Partial / No | Mixpanel event or “backend only (claimed)” | 1 / later / defer |

Must cover:
- Funnel steps that prove the hypothesis (e.g. trial start with/without CC)
- Conversion / paid outcome
- Guardrails (first charge, suspend, abuse proxies, cost proxies if any)
- **FF / experiment assignment** if release is FF

### 4. Recommend

- **Slice 1 must-have instrumentation** (minimum to learn)
- **Nice-to-have / later**
- **Unblockers** (eng confirm backend event names; data owner for dashboard)

### 5. Hand back to spine

Return the gap table + recommendations. If invoked from `refine-mmf`, spine merges into Epic **Tracking** and brief after confirm.

## Output shape (chat + optional write)

```markdown
## Telemetry gap — <MMF-XXX>
**Project:** <Mixpanel project>
**KR / guardrails checked:** …

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

- Create Mixpanel events or lexicon edits unless user explicitly asks
- Invent volume metrics (“~70%”) as if from this pass
- Skip FF assignment when release type is experiment/FF
- Dump the full lexicon — only events relevant to this bet

## Voice

Conclusion first. Tables over prose. Name the Mixpanel project used.
