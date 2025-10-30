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

# Default Codex to read-only sandbox with approval prompts.
alias codex='nocorrect command codex --sandbox read-only --ask-for-approval on-request'

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
