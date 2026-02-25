---
description: Draft PR title/body from branch changes and repo template
subtask: true
agent: build
---

Load and use the `github-pr-template` skill.

Draft a pull request title and body for the current branch.

Arguments:
- `$1` = base branch (optional, defaults to inferred `main`/`master`)
- `$2` = max commit count for context (optional, defaults to `30`)

If `$1` is provided, use it as base branch. Otherwise infer base branch (`main` or `master`).
If `$2` is provided, use it to limit commit history size.

Use compact inputs only (avoid full-history/full-diff dumps):
!`git branch --show-current`
!`git status --short`
!`BASE=${1:-main}; git rev-parse --verify "$BASE" >/dev/null 2>&1 || BASE=master; MB=$(git merge-base "$BASE" HEAD); echo "$BASE ($MB)"`
!`BASE=${1:-main}; git rev-parse --verify "$BASE" >/dev/null 2>&1 || BASE=master; MB=$(git merge-base "$BASE" HEAD); git log --oneline --decorate --no-merges -n ${2:-30} "$MB"..HEAD`
!`BASE=${1:-main}; git rev-parse --verify "$BASE" >/dev/null 2>&1 || BASE=master; MB=$(git merge-base "$BASE" HEAD); git diff --stat "$MB"...HEAD`
!`for f in .github/pull_request_template.md .github/PULL_REQUEST_TEMPLATE.md .github/PULL_REQUEST_TEMPLATE/*.md .github/pull_request_template/*.md; do [ -f "$f" ] && { echo "TEMPLATE_PATH=$f"; cat "$f"; exit 0; }; done; echo "TEMPLATE_PATH="`

Requirements:
- Find and follow the repository PR template if present.
- Analyze all commits on this branch since it diverged from base.
- Keep output concise and concrete.
- Do not invent tests or behavior.
- If template sections do not apply, write `N/A`.
- If context is too large, summarize by commit groups and file-level impact instead of requesting full diffs.
- Only use commits and diff since merge-base with base branch.
- Do not include a commit-by-commit changelog in the PR body. Use commit history only as context to produce a concise summary.
- If a PR template exists, preserve its section headings and order exactly. Do not add extra sections.
- If no PR template exists, use this default body:
  - `## Summary`
  - `## Testing`
  - `## Risks`

Example usage:
- `/pr-description`
- `/pr-description main`
- `/pr-description main 30`

Return:
1) `Title: <single line>`
2) `Body:` followed by markdown content only

Do not include preamble text like "Here's the PR draft" and do not ask follow-up questions.
