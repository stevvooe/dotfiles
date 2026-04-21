---
name: github-pr
description: Draft and create pull requests using the repository's conventions and template
---

## Workflow

1. **Determine base branch**
   - Use the user-supplied base if provided.
   - Otherwise resolve the default branch locally in this order:
     - `rtk git symbolic-ref refs/remotes/origin/HEAD`
     - `rtk git rev-parse --verify refs/remotes/origin/main`
     - `rtk git rev-parse --verify refs/remotes/origin/master`
     - `rtk git rev-parse --verify main`
     - `rtk git rev-parse --verify master`
   - Prefer the remote-tracking ref when available; otherwise use the local branch name.
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
   - Assume the branch is already committed and pushed unless the user asks for help with that.
   - Use `rtk` prefix on all bash commands (the plugin hook does not intercept subagent calls).
   - Use git's own flags to limit output; never pipe to `head`/`tail` (pipes break permission matching).
   - Prefer a practical summary of current branch work over exhaustive commit archaeology.
      ```
      rtk git branch --show-current
      rtk git diff --stat <base>...HEAD
      rtk git diff <base>...HEAD
      rtk git log --oneline -<N> HEAD
      ```
    - If context is large, summarize by file-level impact and recent intent.

4. **Draft PR**
   - Extract the main intent and user-visible impact.
   - Fill template sections with concrete, repo-relevant details.
   - Keep content concise and specific.
   - Do not invent tests or behavior that didn't happen.
   - Do not include a commit-by-commit changelog.
   - If a template section doesn't apply, write `N/A`.
   - Preserve template heading names and order.

5. **Construct command**
     - Build a `gh pr create` command using shell-safe quoting.
     - For multiline bodies, prefer `--body-file - <<'EOF'` to avoid brittle inline escaping.
      ```bash
      gh pr create --base "$BASE" --title "$TITLE" --body-file - <<'EOF'
      <body>
      EOF
      ```
     - Set `BASE` and `TITLE` with shell-safe quoting when they contain spaces or special characters.
     - Choose a heredoc delimiter that does not appear as a standalone line in the body.

6. **Present and confirm**
     - Show: `Title:`, `Body:`, the exact command, then `Run this command?`
     - Treat execution as permission-gated. Only execute if the user explicitly asks to create/open the PR in the current turn.
     - If approved, execute.
     - If edits requested, revise and re-confirm.

## Rules

- Do not write the PR body to a file; build it inline.
- Use shell-safe quoting throughout.
- Do not include preamble text or follow-up questions beyond the confirmation.
- Do not fetch, push, or re-verify branch state unless the user asks or the workflow is blocked without it.
- In draft/proposal mode, never run mutating GitHub commands. Specifically forbidden until explicit user authorization: `gh pr create`, `gh pr edit`, `gh pr merge`, `gh pr close`, and any equivalent GitHub write action.
