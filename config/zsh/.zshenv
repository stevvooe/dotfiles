if [[ -s "$HOME/.cargo/env" ]]; then
  # Load Rust tooling when available
  source "$HOME/.cargo/env"
fi
export GPG_TTY=$TTY

if [[ "$(uname)" == "Darwin" ]]; then
  # librocksdb-sys build script links @rpath/libclang.dylib; dyld needs a
  # fallback path to resolve it at runtime. LIBCLANG_PATH is for bindgen
  # (compile-time), DYLD_FALLBACK_LIBRARY_PATH is for dyld (runtime).
  for _clang_dir in \
    /Library/Developer/CommandLineTools/usr/lib \
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib; do
    if [[ -f "$_clang_dir/libclang.dylib" ]]; then
      export LIBCLANG_PATH="$_clang_dir"
      export DYLD_FALLBACK_LIBRARY_PATH="${DYLD_FALLBACK_LIBRARY_PATH:+$DYLD_FALLBACK_LIBRARY_PATH:}$_clang_dir"
      break
    fi
  done
  unset _clang_dir
fi
