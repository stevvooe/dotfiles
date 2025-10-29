# Sets up zsh to pull from the .config directory. Put everything else in there,
# and keep this clean.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"
if [[ -d $XDG_CONFIG_HOME/zsh ]]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

if [[ -n "$ZDOTDIR" && -s "$ZDOTDIR/.zshenv" ]]; then
  source "$ZDOTDIR/.zshenv"
fi
