# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if which nvim > /dev/null; then
  export EDITOR=$(which nvim)
else
  export EDITOR=$(which vim)
fi

# include secrets if we have the file around.
[ -f "${ZDOTDIR}/.zshrc.secrets" ] && source "${ZDOTDIR}/.zshrc.secrets"

if [[ -z "$PYENV_ROOT" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
fi
if [[ -d "$PYENV_ROOT/bin" ]] && [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v go >/dev/null 2>&1; then
  # Ensure private Docker modules resolve without repeatedly rewriting go env files
  export GOPRIVATE="${GOPRIVATE:+$GOPRIVATE,}github.com/docker/*"
fi
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sjd/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Configures eza directory
export EZA_CONFIG_DIR=$XDG_CONFIG_HOME/eza
export EZA_ICONS_AUTO=1
alias ls="eza"
alias ll="eza -l --git"
alias la="eza -la --git"

# zoxide
eval "$(zoxide init zsh)"

wks() {
  local wks_cmd dest

  wks_cmd="$(whence -p wks 2>/dev/null || true)"
  if [[ -z "$wks_cmd" && -x "$HOME/.dotfiles/bin/wks" ]]; then
    wks_cmd="$HOME/.dotfiles/bin/wks"
  fi

  if [[ -z "$wks_cmd" ]]; then
    print -u2 "wks: command not found: run 'make link' in ~/.dotfiles or add ~/.dotfiles/bin to PATH"
    return 127
  fi

  if (( $# == 0 )) || [[ "$1" == "sw" ]] || [[ "$1" == "switch" ]]; then
    dest="$($wks_cmd "$@")" || return $?
    [[ -n "$dest" ]] && cd "$dest"
    return 0
  fi

  "$wks_cmd" "$@"
}
