---
description: Draft a conventional commit message from staged changes
subtask: true
agent: build
---

Generate a commit message based only on staged changes.

Use this staged diff as the source of truth:
!`git diff --cached`

Also inspect staged file list:
!`git diff --cached --name-only`

Check recent commit style in this repo:
!`git log --oneline -15`

Rules:
- Match the repository's existing commit style when clear from recent history
- If style is unclear, default to Conventional Commits (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`, etc.)
- Focus on the intent and impact, not line-by-line details
- Keep the subject concise and specific
- Include a body only when it adds important context
- Do not include unstaged or untracked changes
- Do not run `git commit`

If there are no staged changes, say: `No staged changes found.`

Return 3 options, best first, each in this format:
1) `<type>(<optional-scope>): <subject>`
   `<optional body>`
