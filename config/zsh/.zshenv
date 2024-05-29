[ -f ~/.cargo/env ] && . ~/.cargo/env

go env -w 'GOPRIVATE=github.com/docker/*'
