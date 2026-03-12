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
    - ```bash
      BASE=$(cat <<'__PR_CREATE_BASE__'
      <base>
      __PR_CREATE_BASE__
      )
      TITLE=$(cat <<'__PR_CREATE_TITLE__'
      <title>
      __PR_CREATE_TITLE__
      )
      BODY=$(cat <<'__PR_CREATE_BODY__'
      <body>
      __PR_CREATE_BODY__
      )
      gh pr create --base "$BASE" --title "$TITLE" --body "$BODY"
      ```

Approval flow:
- After showing the draft + exact command, ask: `Run this command?`
- Validate the exact shell snippet by passing it to `bash -n` on stdin before presenting it.
- If user approves (for example: `run it`, `yes`, `looks good`), validate the exact shell snippet again by passing it to `bash -n` on stdin, then execute that exact command.
- If user requests edits, update title/body first, then re-propose and re-confirm.

Requirements:
- If a base branch is provided, validate it; if invalid, return `Invalid base branch: <name>` and stop.
- Analyze only commits and diff since merge-base with base branch.
- Use repository PR template if present.
- Do not include commit-by-commit changelog in PR body.
- Do not write the PR body to a file; build it inline in the proposed command.
- Review the final PR body before running `gh pr create`.
- Use shell-safe quoting for all command examples; avoid inline quoting that can break on markdown or quotes.
- Choose heredoc delimiters that do not appear as standalone lines in the base branch, title, or body.
