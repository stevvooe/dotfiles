#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
#

typeset -gU path fpath
path=($path)

_proto_update_path() {
  local proto_root proto_dir
  local -a next_path

  proto_root="${PROTO_HOME:-$HOME/.proto}"
  proto_dir="$(_proto_local_config_dir 2>/dev/null || true)"

  next_path=()
  for _path_entry in $path; do
    if [[ "$_path_entry" != "$proto_root/shims" && "$_path_entry" != "$proto_root/bin" ]]; then
      next_path+=("$_path_entry")
    fi
  done

  if [[ -n "$proto_dir" ]]; then
    [[ -d "$proto_root/bin" ]] && next_path=("$proto_root/bin" $next_path)
    [[ -d "$proto_root/shims" ]] && next_path=("$proto_root/shims" $next_path)
  fi

  path=("${next_path[@]}")
  export PATH
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _proto_update_path
_proto_update_path

# Customize to your needs...
# Starship prompt
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Apply Catppuccin Macchiato colors to all fzf usage.
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--color=bg:#24273a,bg+:#363a4f,fg:#cad3f5,fg+:#f4dbd6,gutter:#24273a,hl:#f5a97f,hl+:#f5a97f,pointer:#c6a0f6,marker:#a6da95,prompt:#8aadf4,spinner:#8bd5ca,info:#91d7e3,border:#494d64,separator:#363a4f,header:#a5adcb"

# include secrets if we have the file around.
[ -f "${ZDOTDIR}/.zshrc.secrets" ] && source "${ZDOTDIR}/.zshrc.secrets"

if command -v go >/dev/null 2>&1; then
  # Ensure private Baseten modules resolve without repeatedly rewriting go env files
  export GOPRIVATE="${GOPRIVATE:+$GOPRIVATE,}github.com/basetenlabs/*."
fi
# Cache Docker completion locally and load it via fpath.
docker_completion_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
docker_completion_file="$docker_completion_dir/_docker"
if command -v docker >/dev/null 2>&1; then
  mkdir -p "$docker_completion_dir"
  if [[ ! -s "$docker_completion_file" || "$(command -v docker)" -nt "$docker_completion_file" ]]; then
    docker_completion_tmp="$(mktemp "${TMPDIR:-/tmp}/_docker.XXXXXX")"
    if docker completion zsh >| "$docker_completion_tmp" 2>/dev/null; then
      mv "$docker_completion_tmp" "$docker_completion_file"
    else
      rm -f "$docker_completion_tmp"
    fi
  fi
  fpath=("$docker_completion_dir" $fpath)
fi
# Cache Rust/Cargo completions locally and load them via fpath.
rust_completion_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
if command -v rustup >/dev/null 2>&1; then
  mkdir -p "$rust_completion_dir"
  for _rc_pair in "cargo:_cargo" "rustup:_rustup"; do
    _rc_cmd="${_rc_pair%%:*}"
    _rc_file="$rust_completion_dir/${_rc_pair##*:}"
    if [[ ! -s "$_rc_file" || "$(command -v rustup)" -nt "$_rc_file" ]]; then
      rustup completions zsh "$_rc_cmd" >| "$_rc_file" 2>/dev/null
    fi
  done
  unset _rc_pair _rc_cmd _rc_file
  fpath=("$rust_completion_dir" $fpath)
fi

# Include system and Homebrew completion directories when present.
for _zsh_site_functions in /opt/homebrew/share/zsh/site-functions /usr/local/share/zsh/site-functions; do
  [[ -d "$_zsh_site_functions" ]] && fpath=("$_zsh_site_functions" $fpath)
done
unset _zsh_site_functions

autoload -Uz compinit
_zsh_compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${_zsh_compdump:h}"
if [[ -n "$_zsh_compdump"(#qN.m+1) ]]; then
  compinit -i -d "$_zsh_compdump"
else
  compinit -C -i -d "$_zsh_compdump"
fi
unset _zsh_compdump

# Interactive shell defaults.
export HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY
bindkey -e
[[ -o interactive && -t 0 ]] && stty -ixon

# Completion behavior.
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST
setopt AUTO_PARAM_SLASH
unsetopt MENU_COMPLETE
unsetopt FLOW_CONTROL

zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':completion:*' matcher-list \
  'm:{[:lower:]}={[:upper:]}' \
  'm:{[:upper:]}={[:lower:]}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# Interactive plugins.
_zsh_plugin_prefix=""
if command -v brew >/dev/null 2>&1; then
  _zsh_plugin_prefix="$(brew --prefix)/share"
elif [[ -d /opt/homebrew/share ]]; then
  _zsh_plugin_prefix="/opt/homebrew/share"
elif [[ -d /usr/local/share ]]; then
  _zsh_plugin_prefix="/usr/local/share"
fi

if [[ -n "$_zsh_plugin_prefix" ]]; then
  if [[ -r "$_zsh_plugin_prefix/fzf-tab/fzf-tab.zsh" ]]; then
    source "$_zsh_plugin_prefix/fzf-tab/fzf-tab.zsh"
  fi

  if [[ -r "$_zsh_plugin_prefix/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$_zsh_plugin_prefix/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [[ -r "$_zsh_plugin_prefix/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$_zsh_plugin_prefix/zsh-history-substring-search/zsh-history-substring-search.zsh"
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
  fi

  if [[ -r "$_zsh_plugin_prefix/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$_zsh_plugin_prefix/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
fi

unset _zsh_plugin_prefix

# Configures eza directory
export EZA_CONFIG_DIR=$XDG_CONFIG_HOME/eza
export EZA_ICONS_AUTO=1
alias ls="eza"
alias ll="eza -l --git"
alias la="eza -la --git"

# Kubernetes shortcuts
alias k="kubectl"
alias kc="kubectl"
alias kx="kubectx"
alias kn="kubens"

# zoxide
eval "$(zoxide init zsh)"

opencode() {
  local opencode_cmd project_root

  opencode_cmd="$(whence -p opencode 2>/dev/null || true)"
  if [[ -z "$opencode_cmd" ]]; then
    print -u2 "opencode: command not found"
    return 127
  fi

  project_root="${MEMORIX_PROJECT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  MEMORIX_PROJECT_ROOT="$project_root" "$opencode_cmd" "$@"
}

# hdi - "how do I" inline AI shell helper
# Sends a question (with recent shell history for context) to opencode's
# shell-helper agent and offers to load the suggested command into the prompt.
hdi() {
  if (( $# == 0 )); then
    print -u2 "usage: hdi <question>"
    return 1
  fi

  local history_ctx
  history_ctx=$(fc -ln -20 | sed 's/^[[:space:]]*//')

  local raw cmd
  raw=$(opencode run --agent shell-helper \
    "Recent shell history:
${history_ctx}

Working directory: ${PWD}
OS: $(uname -s)
Question: $*" 2>/dev/null)

  # Strip markdown fences and surrounding whitespace
  cmd=$(echo "$raw" | sed '/^```/d' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v '^$')

  if [[ -z "$cmd" ]]; then
    print -u2 "No suggestion returned."
    return 1
  fi

  echo "$cmd"
  read -q "?Run? [y/N] " && { echo; print -z "$cmd"; } || echo
}

# wks workspace/session integration (function + completion)
[ -f "${ZDOTDIR}/wks.zsh" ] && source "${ZDOTDIR}/wks.zsh"
