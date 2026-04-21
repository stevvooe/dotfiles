---
description: Draft PR description and propose gh pr create command
subtask: true
agent: build
---

Load and follow the `github-pr` skill.

Arguments:
- `$1` = base branch (optional; omit to infer `main` then `master`)
- `$2` = max commit count for context (optional, defaults to `30`)

Draft the PR, propose the command, and stop.

Rules:
- Resolve the base branch locally via `origin/HEAD`, then `origin/main`, `origin/master`, `main`, `master`, unless the user explicitly provided a different base.
- Do not run `gh pr create`, `gh pr edit`, `gh pr merge`, `gh pr close`, or any other mutating GitHub command in this drafting step.
- Do not fetch or push in this drafting step.
- Only present the title, body, and exact command to the user.
- Execution requires a separate, explicit user instruction to create/open the PR in that turn.
