#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

if [[ -z "$EDITOR" ]]; then
  if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
  elif command -v vim >/dev/null 2>&1; then
    export EDITOR='vim'
  else
    export EDITOR='nano'
  fi
fi
if [[ -z "$VISUAL" ]]; then
  if command -v nvim >/dev/null 2>&1; then
    export VISUAL='nvim'
  elif command -v vim >/dev/null 2>&1; then
    export VISUAL='vim'
  else
    export VISUAL='nano'
  fi
fi
if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

if [[ -z "$PYENV_ROOT" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
fi
if [[ -z "$PROTO_HOME" ]]; then
  export PROTO_HOME="$HOME/.proto"
fi

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  $PYENV_ROOT/bin(N)
  $PROTO_HOME/{shims,bin}(N)
  $HOME/go/{,s}bin(N)
  $HOME/{,s}bin(N)
  $HOME/.local/{,s}bin(N)
  /usr/local/go/bin
  /usr/local/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X to enable it.
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -X -z-4'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi
