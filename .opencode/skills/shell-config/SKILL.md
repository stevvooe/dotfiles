---
name: shell-config
description: Apply shell configuration conventions for zsh and runcoms in this dotfiles repo
---

## Scope

- `config/zsh/`
- `runcoms/` (for login/startup files and shared shell setup)

## Rules

- Put persistent shell config in managed dotfiles, not ad-hoc local files.
- Keep aliases/functions grouped with related shell config.
- Prefer explicit, readable shell logic over clever one-liners.
- Preserve existing style and naming conventions in this repo.
- Follow repo workflow gates from `config/opencode/AGENTS.md` for non-trivial changes.

## When to use

- Adding shell aliases/functions
- Updating environment initialization
- Adjusting zsh behavior globally
