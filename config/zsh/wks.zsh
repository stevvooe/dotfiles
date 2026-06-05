#!/usr/bin/env zsh
# wks: workspace + tmux session management shell integration.
# Sourced from .zshrc. The wks binary lives in ~/.dotfiles/bin/wks.
#
# - wks() wrapper: captures stdout for path-emitting verbs (sw/switch)
#   so the shell can cd + set WKS_ROOT/WKS_NAME context. Naked `wks`
#   attaches a tmux session and passes straight through.
# - _wks_* helpers back the wrapper and the completion.

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

  # Only the path-emitting verbs are captured so the shell can cd + set
  # context. Naked `wks` attaches a tmux session (execs tmux, prints no path),
  # so it must pass straight through without capture.
  if [[ "$1" == "sw" ]] || [[ "$1" == "switch" ]]; then
    dest="$($wks_cmd "$@")" || return $?
    if [[ -n "$dest" ]]; then
      cd "$dest"
      _wks_set_context "$dest"
    fi
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

_wks_workspace_rows() {
  local wks_cmd

  wks_cmd="$(_wks_resolve_cmd)"
  [[ -z "$wks_cmd" ]] && return

  "$wks_cmd" rows 2>/dev/null
}

_wks_workspace_names() {
  local row
  local -a parts names

  for row in "${(@f)$(_wks_workspace_rows)}"; do
    parts=("${(ps:\t:)row}")
    [[ -n "${parts[1]}" ]] && names+=("${parts[1]}")
  done

  (( $#names )) && print -r -l -- $names
}

_wks_set_context() {
  local dest=$1 row name path
  local -a parts

  for row in "${(@f)$(_wks_workspace_rows)}"; do
    parts=("${(@ps:\t:)row}")
    name="${parts[1]}"
    path="${parts[4]}"
    [[ -z "$name" || -z "$path" ]] && continue
    if [[ "$path" == "$dest" ]]; then
      export WKS_ROOT="$path"
      if [[ "$name" == "main" ]]; then
        unset WKS_NAME
      else
        export WKS_NAME="$name"
      fi
      return 0
    fi
  done

  export WKS_ROOT="$dest"
  unset WKS_NAME
}

_wks_complete_workspaces() {
  local row name branch state
  local -a parts plain described

  for row in "${(@f)$(_wks_workspace_rows)}"; do
    parts=("${(ps:\t:)row}")
    name="${parts[1]}"
    branch="${parts[2]}"
    state="${parts[3]}"
    [[ -z "$name" ]] && continue
    plain+=("$name")
    described+=("$name:${branch}, ${state}")
  done

  (( $#plain )) || return 1
  _describe -V -t workspaces "workspace" described || compadd -- $plain
}

_wks_new_workspace_arg() {
  _message "new workspace name"
}

_wks_git_refs() {
  local -a refs

  refs=("${(@f)$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes refs/tags 2>/dev/null)}")
  (( $#refs )) && compadd -- $refs
}

_wks_completion() {
  local context state line subcommand
  local -a subcommands
  typeset -A opt_args

  subcommands=(
    "ls:list workspaces"
    "new:create workspace"
    "names:list workspace names"
    "rows:list workspace metadata"
    "sw:switch workspace"
    "switch:switch workspace"
    "rename:rename workspace"
    "rm:remove workspace"
    "clone:clone a GitHub repo and open a session"
    "adopt:stamp @wks_root on tmux sessions"
    "agents:list opencode servers on the machine"
    "attention:scan fleet for agents needing input"
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
      subcommand="${line[1]:-${words[2]}}"
      case "$subcommand" in
        sw|switch|path)
          _wks_complete_workspaces
          ;;
        rm)
          _arguments -s \
            "-f[force remove dirty workspace]" \
            "--force[force remove dirty workspace]" \
            "--prune-branch[delete local branch after removal]" \
            "1:workspace name:_wks_complete_workspaces"
          ;;
        new)
          _arguments -s \
            "--fix[create fix/<user>/<name> branch]" \
            "--feat[create feat/<user>/<name> branch]" \
            "--branch[explicit branch name]:branch name:" \
            "--base[base ref]:git ref:_wks_git_refs" \
            "--no-attach[create without attaching a session]" \
            "1:workspace name:_wks_new_workspace_arg"
          ;;
        rename)
          _wks_complete_workspaces
          ;;
        adopt)
          _arguments -s \
            "--all[adopt every tmux session]"
          ;;
        agents)
          _arguments -s \
            "--json[structured JSON output]" \
            "--all[include unmanaged opencode TUIs]"
          ;;
        attention)
          _arguments -s \
            "--json[structured JSON output]" \
            "--all[show every server with its state]" \
            "--wait[block until a session goes idle or blocked]" \
            "--timeout[cap the wait in seconds]:seconds:"
          ;;
      esac
      ;;
  esac
}

compdef _wks_completion wks
