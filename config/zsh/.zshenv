if [[ -s "$HOME/.cargo/env" ]]; then
  # Load Rust tooling when available
  source "$HOME/.cargo/env"
fi
export GPG_TTY=$TTY
