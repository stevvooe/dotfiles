---
name: design-doc-workflow
description: Keep DESIGN.md and plan docs synchronized with implementation decisions across repositories
---

## Scope

- `.ai/` — working plans and scratch designs (gitignored)
- `DESIGN.md`, `*_PLAN.md`, `docs/design/*.md` — checked-in design artifacts
- Any project markdown files that look like plans or specs

## Phases

1. **Goals**
   - Identify the active design artifact for the task.
   - Capture stable goals and keep them separate from implementation details.

2. **Plan**
   - Confirm scope, constraints, and success criteria.
   - If no design artifact exists for non-trivial work, create one in `.ai/`.

3. **Design**
   - Capture options and tradeoffs, then document the chosen approach.
   - For multiple docs, note which is authoritative for this task.
   - If artifacts overlap in scope, reconcile: identify conflicts, pick the authoritative source, update or remove the others.

4. **Build**
   - If implementation diverges from design, update the artifact first.
   - Record meaningful decisions in the plan, design doc, or memorix.
   - Keep related design artifacts synchronized when decisions overlap.

5. **Verify**
   - Confirm implementation and documented design are aligned.
   - Confirm goals are still satisfied by the current design.

6. **Update**
   - Reconcile design artifacts with final implementation state.
   - Promote `.ai/` plans to `DESIGN.md` or `docs/design/` when worth checking in.
   - Mark stale assumptions, open questions, and follow-ups.
   - Ensure next steps are reflected in `TODO.md`.

## Verification checklist

- Active design artifact is identified.
- Goals are explicit and stable unless scope changed intentionally.
- Meaningful decisions are captured in the artifact or memorix.
- Implementation and docs are aligned at task completion.
- Follow-up work is captured in `TODO.md`.

## When to use

- Before non-trivial implementation
- During mid-build design changes
- When multiple design artifacts need reconciliation
- At task handoff/finalization to sync docs with reality
