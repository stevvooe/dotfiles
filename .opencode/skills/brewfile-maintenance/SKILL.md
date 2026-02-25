---
name: brewfile-maintenance
description: Maintain Brewfile entries and Homebrew conventions used in this dotfiles repo
---

## Scope

- File: `Brewfile`
- Sections: `brew`, `cask`, `tap`, and other package declarations already present

## Rules

- Keep entries alphabetized within their section.
- Avoid duplicate formulas/casks.
- Use stable package names; avoid ad-hoc comments unless needed.
- Keep changes narrow: only add/remove/update entries relevant to the request.
- Follow repo workflow gates from `config/opencode/AGENTS.md` for non-trivial changes.

## When to use

- Adding a global CLI/app dependency
- Removing unused packages
- Reviewing Brewfile consistency
