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

typeset -gU path
path=($path)

# Customize to your needs...
# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# include secrets if we have the file around.
[ -f "${ZDOTDIR}/.zshrc.secrets" ] && source "${ZDOTDIR}/.zshrc.secrets"

if command -v go >/dev/null 2>&1; then
  # Ensure private Docker modules resolve without repeatedly rewriting go env files
  export GOPRIVATE="${GOPRIVATE:+$GOPRIVATE,}github.com/docker/*"
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
autoload -Uz compinit
compinit

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

_wks_resolve_cmd() {
  local wks_cmd

  wks_cmd="$(whence -p wks 2>/dev/null || true)"
  if [[ -z "$wks_cmd" && -x "$HOME/.dotfiles/bin/wks" ]]; then
    wks_cmd="$HOME/.dotfiles/bin/wks"
  fi

  [[ -n "$wks_cmd" ]] && print -r -- "$wks_cmd"
}

_wks_workspace_names() {
  local wks_cmd

  wks_cmd="$(_wks_resolve_cmd)"
  [[ -z "$wks_cmd" ]] && return

  "$wks_cmd" names 2>/dev/null
}

_wks_complete_workspaces() {
  local -a workspaces

  workspaces=("${(@f)$(_wks_workspace_names)}")
  (( $#workspaces )) || return 1

  _describe -t workspaces "workspace" workspaces
}

_wks_oc_workspace_arg() {
  local token

  for token in "${words[@]}"; do
    if [[ "$token" == --new || "$token" == --new=* ]]; then
      _message "new workspace name"
      return 0
    fi
  done

  _wks_complete_workspaces
}

_wks_git_refs() {
  local -a refs

  refs=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags 2>/dev/null)}")
  (( $#refs )) && compadd -- $refs
}

_wks_completion() {
  local context state line
  local -a subcommands
  typeset -A opt_args

  subcommands=(
    "ls:list workspaces"
    "new:create workspace"
    "names:list workspace names"
    "sw:switch workspace"
    "switch:switch workspace"
    "oc:open opencode in workspace"
    "rm:remove workspace"
    "path:print workspace path"
    "help:show usage"
  )

  _arguments -C \
    "1:subcommand:->subcommand" \
    "*::arg:->args"

  case "$state" in
    subcommand)
      _describe -t commands "wks command" subcommands
      ;;
    args)
      case "${words[2]}" in
        sw|switch|rm|path)
          _wks_complete_workspaces
          ;;
        new)
          _arguments -s \
            "1:workspace name:" \
            "--base[base ref]:git ref:_wks_git_refs"
          ;;
        oc)
          _arguments -s \
            "--new[create workspace first]" \
            "--base[base ref for --new]:git ref:_wks_git_refs" \
            "--continue[continue last session]" \
            "--session[session id]:session id:" \
            "--fork[fork session when continuing]" \
            "--model[model]:model:" \
            "--agent[agent]:agent:" \
            "--prompt[prompt]:prompt:" \
            "--help[show help]" \
            "-c[continue last session]" \
            "-s[session id]:session id:" \
            "-m[model]:model:" \
            "1:workspace name:_wks_oc_workspace_arg" \
            "*:opencode args:"
          ;;
      esac
      ;;
  esac
}

compdef _wks_completion wks
