---
name: github-pr
description: Draft and create pull requests using the repository's conventions and template
---

## Workflow

1. **Determine base branch**
   - First refresh remote-tracking refs with `git fetch origin`.
   - Use user-supplied base if provided. Prefer the remote-tracking ref: if the user says `main` or `master`, validate `origin/<name>` with `git rev-parse --verify` and use that for analysis.
   - If the user already supplied `origin/<name>`, validate that exact ref.
   - Otherwise infer: try `origin/main`, fall back to `origin/master`.
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
   - Use `rtk` prefix on all bash commands (the plugin hook does not intercept subagent calls).
   - Use git's own flags to limit output; never pipe to `head`/`tail` (pipes break permission matching).
     ```
     rtk git log --oneline -<N> <merge-base>..HEAD
     rtk git diff --stat <merge-base>..HEAD
     rtk git diff <merge-base>..HEAD
     ```
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
    - Do not run `gh pr create` during validation. `bash -n` is the maximum allowed validation step in draft mode.

6. **Present and confirm**
    - Show: `Title:`, `Body:`, the exact command, then `Run this command?`
    - Treat execution as permission-gated. Only execute if the user explicitly asks to create/open the PR in the current turn.
    - If approved, validate with `bash -n` again, then execute.
    - If edits requested, revise and re-confirm.

## Rules

- Do not write the PR body to a file; build it inline.
- Use shell-safe quoting throughout.
- Do not include preamble text or follow-up questions beyond the confirmation.
- In draft/proposal mode, never run mutating GitHub commands. Specifically forbidden until explicit user authorization: `gh pr create`, `gh pr edit`, `gh pr merge`, `gh pr close`, and any equivalent GitHub write action.
