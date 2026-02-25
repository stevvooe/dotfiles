---
description: Update active design doc to match current decisions
subtask: true
agent: design
---

Update the active design doc so it matches the current implementation plan and decisions.

If `$ARGUMENTS` is provided, treat it as the target design doc path.
If `$ARGUMENTS` is empty, locate the active design doc from: `DESIGN.md`, `*_PLAN.md`, `docs/design/*.md`.

Requirements:
- Keep goals stable, update design details as needed
- Add or update a short decision log entry (`date`, `decision`, `reason`, `impact`) for meaningful changes
- Keep edits concise and scoped to this task
- If multiple design docs are relevant, sync shared decisions across them

Return which file(s) were updated and what changed.
