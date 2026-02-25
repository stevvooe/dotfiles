# Dotfiles Repo Instructions

## Scope

- These instructions apply only to this repository.
- Keep global behavior from `~/.config/opencode/AGENTS.md` unless this file overrides it.

## Repo Layout

- `config/` -> stowed to `~/.config/`
  - `config/nvim/` -> Neovim config
  - `config/zsh/` -> zsh modules and shell config
  - `config/git/` -> git config includes and defaults
  - `config/opencode/` -> OpenCode config, agents, commands, rules
  - `config/ghostty/` -> terminal config
  - `config/k9s/` -> k9s config
  - `config/eza/` -> eza config
  - `config/starship.toml` -> starship prompt config
- `runcoms/` -> stowed to `~/` (`.zshenv`, fzf startup files)
- `bin/` -> stowed to `~/bin/` (custom scripts)
- `.opencode/agents/` -> repo-local agents
- `.opencode/skills/` -> repo-local skills
- `Brewfile` -> Homebrew formulas/casks/taps
- `Makefile` -> setup and stow orchestration
- `npm-global-packages.txt` -> globally installed npm packages
- `macos-defaults.sh` -> macOS preference setup
- `TODO.md` -> follow-up tasks

## Skills

- For OpenCode setup in this repo (`config/opencode/*`), load `opencode-config`.
- For stow/layout changes, load `dotfiles-stow`.
- For `Brewfile` edits, load `brewfile-maintenance`.
- For shell setup (`config/zsh`, `runcoms`), load `shell-config`.
- For Neovim config (`config/nvim`), load `nvim-config`.

## Subagent Usage

- Use `@dotfiles` for global environment changes (brew packages, shell/tool config, stow-managed files).
- If work changes OpenCode agent behavior, use `@architect` for design decisions and keep `config/opencode/AGENTS.md` in sync.

## Repo Rules

- Do not create manual symlinks. Use stow via `make link`.
- Keep `Brewfile` entries alphabetized within each section.
- Do not edit machine-specific git include files: `config/git/signingkey.inc`, `config/git/email.inc`.
- Keep changes minimal and scoped; avoid unrelated cleanup.
