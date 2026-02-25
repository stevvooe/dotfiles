---
name: nvim-config
description: Apply Neovim configuration conventions for this dotfiles repo
---

## Scope

- `config/nvim/`

## Rules

- Follow the existing module layout and plugin organization.
- Keep changes scoped to requested behavior; avoid unrelated cleanup.
- Prefer clear mappings/options over dense abstractions.
- Keep plugin-specific settings near the plugin configuration.
- Follow repo workflow gates from `config/opencode/AGENTS.md` for non-trivial changes.

## When to use

- Adding/updating Neovim plugins and settings
- Adjusting keymaps or editor behavior
- Refactoring Neovim config structure in this repo
