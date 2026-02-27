---
description: Draft PR description and propose gh command
subtask: true
agent: build
---

Load and use the `github-pr-create` skill.

Arguments:
- `$1` = base branch (optional; omit to infer `main` then `master`)
- `$2` = max commit count for context (optional, defaults to `30`)

Behavior:
- Draft PR title/body and return:
  - `Title: <single line>`
  - `Body:` markdown
  - `Review requested: confirm or edit the draft before running command.`
  - The exact command that will be executed if approved:
    - `gh pr create --base <base> --title "<title>" --body-file <tempfile>`

Approval flow:
- After showing the draft + exact command, ask: `Run this command?`
- If user approves (for example: `run it`, `yes`, `looks good`), execute that exact command.
- If user requests edits, update title/body first, then re-propose and re-confirm.

Requirements:
- If a base branch is provided, validate it; if invalid, return `Invalid base branch: <name>` and stop.
- Analyze only commits and diff since merge-base with base branch.
- Use repository PR template if present.
- Do not include commit-by-commit changelog in PR body.
