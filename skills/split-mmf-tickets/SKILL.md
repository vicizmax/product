---
name: split-mmf-tickets
description: >-
  Create lean GROW Stories/Tasks under a refined GROW Epic (parent MMF) after
  must-haves are locked. Consumes refine outputs (telemetry gaps, tech sketch,
  UX call, MMF DRI). Use when eng or PM says "split GROW-XXX", "split MMF-XXX",
  "create implementation tickets", "break into slices", or after refine-mmf.
  Do not run at start-mmf / intake time.
---

# Split MMF tickets

Creates **child** work items under the **GROW Epic**. Requires refine exit criteria (or explicit override).

Spine position: after `refine-mmf`. See [../start-mmf/references/workflow.md](../start-mmf/references/workflow.md).

## Hierarchy

```
MMF-XXX (Assignee = MMF DRI) → GROW Epic (YYY) → Stories/Tasks (this skill)
```

## Steps

1. Load brief + MMF + GROW Epic. If Epic missing, stop and offer to create it first (`refine-mmf` / `start-mmf` step).
2. Verify refine exit criteria (incl. MMF Assignee, tracking exist/missing, UX call, thin tech sketch); warn if still open.
3. Consume refine outputs: missing events → instrumentation AC or ticket; tech sketch → repo guess on children.
4. Propose children from **locked slices** (title, outcome, AC, repo guess). Thicker code context per child here (or later `cross-repo-context`).
5. Confirm which slices → tickets now (usually slice 1 only).
6. Create in **GROW** with **parent = GROW Epic**. Lean body:

```markdown
## Outcome
<one line>

## Parent
Epic GROW-YYY · MMF-XXX (DRI = MMF Assignee)
Brief: <path>

## AC
- [ ] …

## Tracking (if any)
Events / properties from refine telemetry gap.

## Notes
Slice N. See brief + Epic tech sketch.
```

7. Write keys into the brief slice table.

## Do not

- Create tickets in the MMF project
- Recreate the full brief on every child
- Ticket unlocked nice-to-haves
- Create Epics here (unless recovering a missing Epic after user confirm)
- Invent event names that refine said were TBD without calling that out
