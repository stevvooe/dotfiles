if [[ -s "$HOME/.cargo/env" ]]; then
  # Load Rust tooling when available
  source "$HOME/.cargo/env"
fi
export GPG_TTY=$TTY

if [[ "$(uname)" == "Darwin" ]]; then
  # LIBCLANG_PATH is for bindgen at compile time.
  for _clang_dir in \
    /Library/Developer/CommandLineTools/usr/lib \
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib; do
    if [[ -f "$_clang_dir/libclang.dylib" ]]; then
      export LIBCLANG_PATH="$_clang_dir"
      break
    fi
  done

  if [[ -z "${DYLD_FALLBACK_LIBRARY_PATH:-}" ]]; then
    if [[ -d "/Library/Developer/CommandLineTools/usr/lib" ]]; then
      export DYLD_FALLBACK_LIBRARY_PATH="/Library/Developer/CommandLineTools/usr/lib"
    fi
  fi

  unset _clang_dir
fi

# Raise open-file limit for builds and tools that exhaust the macOS default (256).
ulimit -n 4096
