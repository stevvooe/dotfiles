---
name: rtk
description: Use rtk (Rust Token Killer) for token-optimized CLI output in OpenCode
---

## What it does

rtk is a CLI proxy that compresses command output before it reaches the LLM, saving 60-90% of tokens on common dev commands.

## How it works in OpenCode

- The plugin at `config/opencode/plugins/rtk.ts` hooks `tool.execute.before` to rewrite bash/shell commands through `rtk rewrite`.
- Rewriting is automatic and transparent for the main agent.
- The plugin auto-disables if `rtk` is not in PATH.
- Plugin hooks do not intercept subagent tool calls (upstream: sst/opencode#5894). Subagents should prefix commands with `rtk` directly.

## Command chaining

In `&&` chains, each command needs the `rtk` prefix:

```bash
rtk git add . && rtk git commit -m "msg" && rtk git push
```

The plugin rewrites the full command string, but explicit prefixing is safer for chains and subagent calls.

## Commands by workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         rtk cargo check         rtk cargo clippy
rtk tsc                 rtk lint                 rtk prettier --check
rtk next build
```

### Test (90-99% savings)
```bash
rtk cargo test          rtk vitest run           rtk playwright test
rtk pytest              rtk test <cmd>           # generic wrapper, failures only
```

### Git (59-80% savings)
```bash
rtk git status          rtk git log              rtk git diff
rtk git show            rtk git add              rtk git commit
rtk git push            rtk git pull             rtk git branch
rtk git fetch           rtk git stash            rtk git worktree
```

All git subcommands pass through, even those not listed.

### GitHub CLI (26-87% savings)
```bash
rtk gh pr view <num>    rtk gh pr checks         rtk gh run list
rtk gh issue list       rtk gh api
```

### JS/TS tooling (70-90% savings)
```bash
rtk pnpm list           rtk pnpm outdated        rtk pnpm install
rtk npm run <script>    rtk npx <cmd>            rtk prisma
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           rtk read <file>          rtk grep <pattern>
rtk find <pattern>
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           rtk log <file>           rtk json <file>
rtk deps                rtk env                  rtk summary <cmd>
rtk diff
```

### Infrastructure (85% savings)
```bash
rtk docker ps           rtk docker images        rtk docker logs <c>
rtk kubectl get         rtk kubectl logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          rtk wget <url>
```

### Go (70-90% savings)
```bash
rtk go build            rtk go test              rtk golangci-lint run
```

## Meta commands

Called directly (not auto-rewritten):

```bash
rtk gain              # Token savings analytics
rtk gain --history    # Command usage history with savings
rtk discover          # Analyze history for missed optimization opportunities
rtk proxy <cmd>       # Run command without filtering (debugging)
```

## When to use this skill

- Debugging rtk plugin behavior or output compression
- Reviewing token savings with `rtk gain`
- Updating the plugin at `config/opencode/plugins/rtk.ts`
- Writing subagent prompts that need rtk-prefixed commands
