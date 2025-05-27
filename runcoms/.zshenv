# Sets up zsh to pull from the .config directory. Put everything else in there,
# and keep this clean.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"
[[ -d $XDG_CONFIG_HOME/zsh ]] && export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
source "$ZDOTDIR/.zshenv"
. "$HOME/.cargo/env"
