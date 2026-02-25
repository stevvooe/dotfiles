---
name: github-pr-template
description: Draft pull request descriptions using the repository's GitHub PR template and current branch changes
---

## Purpose

Generate a PR title/body that matches the repository's template and current commit set.

## Inputs to gather

- PR template file (first match):
  - `.github/pull_request_template.md`
  - `.github/PULL_REQUEST_TEMPLATE.md`
  - `.github/PULL_REQUEST_TEMPLATE/*.md`
  - `.github/pull_request_template/*.md`
- Current branch name and base branch (usually `main`/`master`)
- Commits on branch since base
- Diff summary since base

## Workflow

1. Locate the PR template. If none exists, produce a compact default PR body with `## Summary` and `## Testing`.
2. Analyze all commits on the branch since divergence from base, not just the latest commit.
3. Extract the main intent of the change and user-visible impact.
4. Fill template sections with concrete, repo-relevant details.
5. Return:
   - Suggested PR title
   - Filled PR body (markdown)
   - Optional `gh pr create` command snippet

## Output requirements

- Keep content concise and specific.
- Do not invent tests or behavior that did not happen.
- If a section is not applicable, use `N/A` instead of leaving placeholders.
- Preserve the template's heading names and order.
- Do not include a commit-by-commit changelog in the PR body.
- Return only title and body content (no preamble text, no "want me to create PR" question).

## Useful commands

- `git branch --show-current`
- `git status --short`
- `git log --oneline --decorate --graph <base>..HEAD`
- `git diff --stat <base>...HEAD`
- `git diff <base>...HEAD`
