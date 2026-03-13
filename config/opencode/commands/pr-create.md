---
description: Draft PR description and propose gh pr create command
subtask: true
agent: build
---

Load and follow the `github-pr` skill.

Arguments:
- `$1` = base branch (optional; omit to infer `main` then `master`)
- `$2` = max commit count for context (optional, defaults to `30`)

Draft the PR, propose the command, and confirm before executing.
