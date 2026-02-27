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

- Return only:
  - `Title: <single line>`
  - `Body:` markdown
  - `Review requested: confirm or edit the draft before running command.`
  - Exact command to run:
    - `gh pr create --base <base> --title "<title>" --body-file <tempfile>`

## Approval and execution

- Ask `Run this command?` after presenting the draft and exact command.
- If user approves (`run it`, `yes`, `looks good`), execute that exact command.
- If user requests edits, revise the draft, then re-propose command and re-confirm.

## Rules

- Do not invent tests or behavior.
- Preserve template heading names/order when template exists.
- If no template exists, use `## Summary`, `## Testing`, `## Risks`.
