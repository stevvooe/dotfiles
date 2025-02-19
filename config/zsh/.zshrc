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

# Load virtualenvwrapper prior to loading prezto plugins
venvw=$(brew --prefix virtualenvwrapper)/bin/virtualenvwrapper_lazy.sh
[ -f "$venvw" ] && source "$venvw"

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

[ -f ~/.cargo/env ] && . ~/.cargo/env

[ -f "$(which go)" ] && go env -w 'GOPRIVATE=github.com/docker/*'
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sjd/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
