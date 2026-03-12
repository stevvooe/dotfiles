---
name: github-pr-create
description: Draft PR description and propose gh pr create command
---

## Purpose

Prepare a PR from the current branch by drafting title/body and proposing the `gh pr create` command in one response.

## Workflow

1. Determine base branch:
   - If user supplied base, validate it; if invalid, return `Invalid base branch: <name>`.
   - If no base is supplied, infer `main` then `master` automatically.
2. Compute merge-base and analyze only commits/diff since merge-base.
3. Locate and follow repository PR template if present.
4. Draft concise PR title/body (no commit-by-commit changelog).
5. Return draft plus a copy-paste `gh pr create` command.

## Output

- Return:
  - `Title: <single line>`
  - `Body:` markdown
  - `Review requested: confirm or edit the draft before running command.`
  - Exact command to run:
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
  - `Run this command?`

## Approval and execution

- Ask `Run this command?` after presenting the draft and exact command.
- Validate the exact shell snippet by passing it to `bash -n` on stdin before presenting it.
- If user approves (`run it`, `yes`, `looks good`), validate the exact shell snippet again by passing it to `bash -n` on stdin, then execute that exact command.
- If user requests edits, revise the draft, then re-propose command and re-confirm.

## Rules

- Do not invent tests or behavior.
- Preserve template heading names/order when template exists.
- If no template exists, use `## Summary`, `## Testing`, `## Risks`.
- Do not write the PR body to a file; construct it inline in the proposed command.
- Review the final PR body before running `gh pr create`.
- Use shell-safe quoting for all command examples; avoid inline quoting that can break on markdown or quotes.
- Choose heredoc delimiters that do not appear as standalone lines in the base branch, title, or body.
