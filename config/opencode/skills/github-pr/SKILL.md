---
name: github-pr
description: Draft and create pull requests using the repository's conventions and template
---

## Workflow

1. **Determine base branch**
   - Use user-supplied base if provided; validate with `git rev-parse --verify`.
   - Otherwise infer: try `main`, fall back to `master`.
   - If invalid, stop: `Invalid base branch: <name>`.

2. **Find PR template**
   - Check the repo for a PR template using file tools (glob/read):
     - `.github/pull_request_template.md`
     - `.github/PULL_REQUEST_TEMPLATE.md`
     - `.github/PULL_REQUEST_TEMPLATE/*.md`
     - `.github/pull_request_template/*.md`
   - If no local template, use the GitHub MCP to check the repo for one.
   - If no template exists, use a default: `## Summary`, `## Testing`, `## Risks`.

3. **Analyze branch changes**
   - Compute merge-base between base and HEAD.
   - Analyze all commits since merge-base, not just the latest.
   - Use `git log`, `git diff --stat`, and `git diff` against merge-base.
   - If context is large, summarize by commit groups and file-level impact.

4. **Draft PR**
   - Extract the main intent and user-visible impact.
   - Fill template sections with concrete, repo-relevant details.
   - Keep content concise and specific.
   - Do not invent tests or behavior that didn't happen.
   - Do not include a commit-by-commit changelog.
   - If a template section doesn't apply, write `N/A`.
   - Preserve template heading names and order.

5. **Construct command**
   - Build a `gh pr create` command using heredocs for safe quoting:
     ```bash
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
   - Choose heredoc delimiters that don't appear as standalone lines in the content.
   - Validate the snippet with `bash -n` before presenting.

6. **Present and confirm**
   - Show: `Title:`, `Body:`, the exact command, then `Run this command?`
   - If approved, validate with `bash -n` again, then execute.
   - If edits requested, revise and re-confirm.

## Rules

- Do not write the PR body to a file; build it inline.
- Use shell-safe quoting throughout.
- Do not include preamble text or follow-up questions beyond the confirmation.
