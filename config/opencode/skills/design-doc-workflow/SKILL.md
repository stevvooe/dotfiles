---
name: design-doc-workflow
description: Keep DESIGN.md and plan docs synchronized with implementation decisions across repositories
---

## Scope

- `DESIGN.md`
- `*_PLAN.md`
- `docs/design/*.md`

## Phases

1. **Goals**
   - Identify the active design doc for the task.
   - Capture stable goals and keep them separate from implementation details.

2. **Plan**
   - Confirm scope, constraints, and success criteria.
   - If no design doc exists for non-trivial work, create one.

3. **Design**
   - Capture options and tradeoffs, then document the chosen approach.
   - For multiple docs, note which doc is authoritative for this task.

4. **Build**
   - If implementation diverges from design, update design docs first.
   - Record meaningful decisions (`date`, `decision`, `reason`, `impact`).
   - Keep related design docs synchronized when decisions overlap.

5. **Verify**
   - Confirm implementation and documented design are aligned.
   - Confirm goals are still satisfied by the current design.

6. **Update**
   - Reconcile design docs with final implementation state.
   - Mark stale assumptions, open questions, and follow-ups.
   - Ensure next steps are reflected in `TODO.md` when needed.

## Verification checklist

- Active design doc is identified.
- Goals are explicit and stable unless scope changed intentionally.
- Decision log captures material design changes.
- Implementation and docs are aligned at task completion.
- Follow-up work is captured in `TODO.md`.

## When to use

- Before non-trivial implementation
- During mid-build design changes
- At task handoff/finalization to sync docs with reality
