---
description: Draft PR description and propose gh pr create command
subtask: true
agent: build
---

Load and follow the `github-pr` skill.

Arguments:
- All arguments are a freeform prompt for PR drafting guidance.
- Do not treat any positional argument as the base branch or commit count.
- If the prompt explicitly says `base branch is <branch>` or `use <branch> as the base`, use that base; otherwise infer the base branch locally.
- Use a max commit count of `30` for context unless the prompt explicitly asks for a different count.

Prompt:

$ARGUMENTS

Draft the PR, propose the command, and stop.

Rules:
- Treat `$ARGUMENTS` as literal prompt text.
- Resolve the base branch locally via `origin/HEAD`, then `origin/main`, `origin/master`, `main`, `master`, unless the prompt explicitly names a different base branch.
- Do not run `gh pr create`, `gh pr edit`, `gh pr merge`, `gh pr close`, or any other mutating GitHub command in this drafting step.
- Do not fetch or push in this drafting step.
- Only present the title, body, and exact command to the user.
- Execution requires a separate, explicit user instruction to create/open the PR in that turn.
