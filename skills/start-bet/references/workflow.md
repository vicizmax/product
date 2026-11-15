# Growth AI workflow spine (v2)

Spine skills own **stage + Drive/Jira writes**. Specialists fill one gap; the spine auto-invokes them when needed, shows results, then **confirms before write**.

```
start-mmf
  → Drive brief + MMF Initiative (confirm)
  → (optional) GROW Epic parented to MMF
       ↓
  grooming / bet lock
       ↓
  refine-mmf  (+ GROW Epic if missing)
       │  auto-pull specialists when gaps:
       │    · mmf-telemetry   (events exist vs needed)
       │    · mmf-tech-sketch (thin code/context)
       │    · UX call         (checklist; skill later if needed)
       │    · MMF DRI         = Assignee on MMF ticket
       ↓
  split-mmf-tickets  → Stories/Tasks under GROW Epic
       │  thicker code context per child; consume refine outputs
       ↓
  build → validate → ship → watch
```

## Spine vs specialists

| Layer | Skills | Job | Auto? |
|---|---|---|---|
| **Spine** | `start-mmf` → `refine-mmf` → `split-mmf-tickets` | Stage gates, brief + Jira SoT | User-triggered (“start MMF”, “kick off”, “split”) |
| **Specialists** | `mmf-telemetry`, `mmf-tech-sketch`, later `cross-repo-context` | One gap each; propose, don’t invent scope | **Inside the stage** when data missing |
| **Write gates** | All | Jira / Slack / Confluence | Confirm (or “confirm once for this refine”) |

Do **not** build one mega-skill. Compose. Specialists don’t create tickets unless the spine asks after confirm.

## MMF DRI

**MMF DRI = Assignee on the MMF Initiative ticket.**  
Not a parallel custom field. Epic/children may have other assignees; the MMF Assignee is the named eng owner. `refine-mmf` must set or confirm it before exit.

## What each stage owns

| Stage | Must lock / produce | Leave for later |
|---|---|---|
| `start-mmf` | Problem, surfaces, draft KR, slices, lean MMF | Full locks, children, deep code |
| `refine-mmf` | Must-haves, access, release, tracking gap, UX in/out, thin tech sketch, MMF DRI (Assignee), slice-1 done-when, GROW Epic handoff | Child tickets, file-level design |
| `split-mmf-tickets` | Children with outcome AC; event names from telemetry gap; repo guess | Shipping code |

## Specialist status

| Specialist | Status | When spine calls it |
|---|---|---|
| Telemetry gap (Mixpanel + known backend) | **Exists** — `mmf-telemetry` | Refine if tracking unnamed or KR unmeasurable |
| Thin tech sketch | **Planned** (`mmf-tech-sketch`) | Refine if no “where it lives in code” yet |
| UX involvement | Checklist step in `refine-mmf` | Product UI / new collect flows |
| Cross-repo context | Later | End of refine or start of split |

Until a specialist folder is missing: spine agent **does the same job inline**. Prefer invoking `mmf-telemetry` when present.

## Naming

| Skill | Triggers |
|---|---|
| `start-mmf` | `/start-mmf`, `/mmf`, “start MMF”, “intake” |
| `refine-mmf` | `/refine-mmf`, `/refine`, `/kickoff`, “refine the MMF”, “kick off” |
| `split-mmf-tickets` | “split GROW-”, “create implementation tickets” |

## Jira decision

| Confirm? | Artifact |
|---|---|
| Yes at intake | MMF Initiative · Team **Growth** (not issue type “MMF”) |
| Ask (often bet lock / refine) | GROW Epic (parent = MMF), eng/agent handoff body |
| After refine exit | Children under Epic |
| On refine | **Assignee on MMF** = MMF DRI |
