---
name: dotfiles-stow
description: Apply repo-specific GNU Stow layout and linking rules for this dotfiles repo
---

## Scope

- Repo: `~/.dotfiles`
- `config/` stows to `~/.config/`
- `runcoms/` stows to `~/`
- `bin/` stows to `~/bin/`

## Rules

- Place new config files under the correct stow root (`config`, `runcoms`, `bin`).
- Do not create manual symlinks; links are managed via `make link`/stow.
- Keep machine-specific files out of managed templates unless explicitly intended.
- Prefer minimal, explicit config changes over broad rewrites.
- Follow repo workflow gates from `config/opencode/AGENTS.md` for non-trivial changes.

## When to use

- Adding globally managed configs
- Moving files into the right stow target
- Debugging symlink/layout issues in this repo
