# Global Agent Instructions

## Communication

- Be direct and concise. Skip preamble and filler.
- Don't be verbose in documentation, READMEs, or comments. Tell the reader what it is, how to run it, how to test it. They can read godoc or source for details.
- When you get something wrong, just fix it. Don't apologize or explain why you were wrong.
- If I say something doesn't work, investigate the actual problem before suggesting the same fix again.
- When given a problem or feature request, don't jump straight to implementation. Present the approach (or multiple options with tradeoffs) and wait for confirmation before writing code. The only exception is trivial, unambiguous changes.
- If there are meaningful design decisions (data structures, public API shape, error strategy, dependency choices), surface them explicitly. Don't bury decisions in code and hope I agree.

## Workflow

- Projects follow a goals -> plan -> design -> build -> verify -> update cycle. Respect this order.
- Before writing code, establish goals and a design. Write them down in a design doc or issue if one doesn't exist.
- Goals are stable. Design evolves. Keep goals and design separate so changing the approach doesn't lose sight of the objective.
- When the design needs to change mid-build, update the design first, then update the code. Don't let the code drift from the design silently.
- Frequently revisit goals during implementation to make sure we haven't wandered off track.
- When I describe a change in direction, confirm what the new design looks like before proceeding. Don't assume the rest of the plan stays the same.
- Use `/todo` to capture ideas, tasks, or follow-ups to the project's `TODO.md` without interrupting the current work. Example: `/todo fix buffer alignment in reader.rs`. To review or reorganize the full list, use `!$EDITOR TODO.md`.
- Use `/commit-message` to draft conventional commit messages from staged changes only. Do not include unstaged or untracked changes.
- Use `/pr-description` to draft PR title/body from branch changes, following the repository PR template when available.
- When completing work that corresponds to an item in `TODO.md`, check it off by changing `- [ ]` to `- [x]`.

## Design Docs

- Treat design docs as live artifacts, not one-time specs. Keep them updated as implementation evolves.
- Before coding, look for and read relevant design files: `DESIGN.md`, `*_PLAN.md`, and `docs/design/*.md`.
- For repos with multiple design docs, identify the active design doc for the current task and state it explicitly.
- If implementation diverges from the current design, update the design doc first, then implement code changes.
- Keep goals stable and design mutable. Preserve a clear goals section while updating design details.
- Record meaningful design changes in a short decision log (`date`, `decision`, `reason`, `impact`).
- If no design doc exists for non-trivial work, create one before implementation (default: `DESIGN.md` or task-specific `SOME_TASK_PLAN.md`).
- Use the `@design` subagent when a task needs design doc creation, synchronization, or cross-doc updates.
- Use `/design-sync` to quickly sync design docs with current decisions without derailing active implementation.
- Use phase gates: goals -> plan -> design -> build -> verify -> update.
- Verify alignment at each phase transition so goals, approach, and implementation stay synchronized.
- Before closing a task, verify the active design doc reflects shipped behavior, unresolved gaps are called out, and follow-ups are captured in `TODO.md`.

## Git

- Read-only git commands are fine: `log`, `status`, `diff`, `show`, `blame`, etc.
- Never run commands that mutate the repository: no commits, pushes, rebases, amends, resets, or checkouts.
- When asked to commit, suggest a commit message in the repository's existing style, but do not execute it.

## Subagents

Use subagents to delegate specialized work. Invoke them with `@agent-name` or let the Build agent delegate automatically based on context.

- `@code-reviewer` — after completing a feature or fix, or when reviewing someone else's changes
- `@architect` — before starting a feature, when the design is unclear, or when module boundaries need rethinking
- `@design` — create/update design docs (`DESIGN.md`, `*_PLAN.md`, `docs/design/*.md`) and keep them in sync with implementation
- `@debug` — when a bug needs root cause analysis rather than guessing at fixes
- `@security-auditor` — before merging code that handles auth, user input, secrets, or `unsafe`
- `@perf-review` — when code touches hot paths, I/O, or allocation-heavy areas. Analyze first, don't guess.
- `@perf-optimize` — after `@perf-review` identifies concrete bottlenecks. Implements and benchmarks the fix.
- `@test-writer` — when adding test coverage for existing or new code
- `@refactor` — when restructuring code without changing behavior. Runs tests after each change.
- `@migration` — for dependency upgrades and API migrations. Plans before executing.
- `@docs-writer` — when doc comments or package-level documentation need writing or updating
- `@api-designer` — when designing or reviewing protobuf, gRPC, REST, or inter-service API schemas
- `@devops` — for Dockerfiles, CI pipelines, and build configuration
- `@dotfiles` — when a tool, config, or shell setting needs to be added globally via the dotfiles repo

Agents should suggest delegating to other agents when their findings cross into another agent's domain. When a change belongs in the global dotfiles (new brew package, shell alias, tool config), suggest `@dotfiles`. When implementation changes design or uncovers design drift, suggest `@design`.

When working on OpenCode setup in this repo (`config/opencode/*`), load the `opencode-config` skill.

## Code Philosophy

- Write pragmatic, efficient code. Simplicity over cleverness.
- Remove dead code, unused exports, and redundant abstractions immediately. Don't keep things around "just in case."
- If something is redundant, collapse it. If two types serve the same purpose, pick one and delete the other.
- Avoid config objects and unnecessary indirection. Prefer direct arguments. Use functional options when there are genuine optional parameters.
- Don't introduce wrapper types or abstractions unless they earn their keep. Every layer of indirection must justify its existence.
- Some duplication is fine when it avoids tight coupling. Do not follow DRY at all costs.
- When renaming or refactoring, breaking the API is fine for new or internal packages. Don't waste time on backward compatibility for code that has no users yet.
- Keep APIs consistent. If related types exist (e.g., Request and Response), they should support the same set of operations. Don't implement `Write` on one and forget the other.
- Define objects with clear boundaries and explicit relationships. Don't rely on naming conventions or implicit knowledge to convey how types relate.
- Proactively identify ways to simplify, remove clutter, or promote implicit concepts into explicit types or interfaces.

## Go

### Style

- Follow Go idioms and proverbs. When in doubt, do what the standard library does.
- Prefer copying small amounts of code over introducing a dependency.
- Favor the standard library over third-party packages unless there's a clear, measurable benefit.
- Use `gofmt`. Respect `golangci-lint` output.
- Clear is better than clever. Avoid reflection unless absolutely necessary.
- Make the zero value useful.
- The bigger the interface, the weaker the abstraction. Keep interfaces small.
- Exported names should be semantically meaningful, not mechanical. For example, `event.Allow()` rather than exposing the internal fd to the caller.
- Prefer methods on the concrete type over standalone functions when there's clear ownership.
- Functions should return concrete types, not interfaces. Accept interfaces, return structs.
- Use `t.Cleanup` instead of deferred cleanup in tests.
- Use iterators (`iter.Seq`) over channels when the consumer is synchronous and there's no need for concurrent producers.
- Internal types and helper functions should be unexported unless there's a reason to expose them.

### Error Handling

- Always check error return values. Fix errcheck lint findings.
- Wrap errors with context using `fmt.Errorf("doing something: %w", err)`. Bare `return err` loses context.
- Handle `io.EOF` gracefully. Don't log it as an error during normal read operations.
- Validate preconditions early. If mismatched parameters would cause silent corruption, panic with a clear message.

### Architecture

- Keep exported surface area minimal. Test the external interface, not internals.
- Organize tests into separate files by component (e.g., `align_test.go`, `prefetch_test.go`).
- Comments on exported types are for the user of the type, not internal implementation details. Put internal details on unexported types or inline in the code.
- Use `doc.go` for package-level documentation. Keep it current with the actual state of the package.
- For linux-specific syscall work, check man pages for correct behavior rather than guessing.
- Use build tags (`//go:build linux`) for platform-specific code.
- Use or create helper functions for complex math like buffer offsets and alignment. Inline arithmetic is hard to read and easy to get wrong. Check for existing project-local helpers before writing new ones.

### Performance

- Profile before speculating. Use `pprof` and flamegraphs to find actual bottlenecks, then fix those.
- Be aware of lock contention. Prefer atomic operations for monotonically increasing state. Use `sync.Pool` for buffer reuse.
- Minimize allocations on hot paths. Pre-allocate slices when the size is known. Avoid unnecessary channel operations in tight loops.
- Lazy evaluation: don't resolve expensive data (e.g., resolving a path from an fd) unless the caller actually needs it.

### Concurrency

- Channels orchestrate; mutexes serialize. Prefer channel-based designs when they simplify the code.
- When using channels for work queues, size them appropriately to avoid dropped sends. Dropped work that causes deadlocks is panic-worthy.
- Separate read and write workers when they have different performance characteristics to avoid starving one path.
- Use `context.Context` for cancellation even when linters complain about storing it in structs, if it's the right design. Use lint directives to suppress false positives.

### Testing

- Write benchmarks with custom metrics (`b.ReportMetric` for reads/s, MB/s).
- Use subtests for variations but don't nest so deeply that test names become unreadable.
- Benchmark helpers should separate setup from measured work (`b.StopTimer`/`b.StartTimer`).
- Keep baseline (direct) benchmarks alongside each variant for easy comparison.
- For linux-only code, use docker-based test runners. Be aware of workspace and module resolution when mounting partial source trees into containers.

## Rust

### Style

- Write idiomatic Rust. If you don't know the correct pattern, look it up before writing bad code.
- Follow `rustfmt`. Respect `clippy` output. Run with `--all-targets`.
- Prefer borrowing over cloning. `clone()` on a hot path is a code smell. If you're cloning to appease the borrow checker, rethink ownership.
- Use `Cow<'_, str>` and `Cow<'_, [u8]>` when you might or might not need to own the data.
- Prefer iterator chains over manual loops. They compose, they're lazy, and LLVM optimizes them well.
- Use enums aggressively for state machines, error variants, and protocol messages. The compiler enforces exhaustiveness — use that.
- Use newtypes to encode invariants at the type level. `struct UserId(u64)` is better than a bare `u64` passed through 10 functions.
- If you're littering code with named lifetimes, the ownership model is probably wrong. Rethink before adding `'a` everywhere.

### API Design

- API design matters more in Rust than most languages. It is hard to change after the fact, especially for external interfaces. Keep it minimal, clean, and performant.
- Implement `From`/`TryFrom` (and by extension `Into`/`TryInto`) for type conversions. Don't make callers do manual conversion.
- Use `AsRef` and `AsMut` on function parameters to accept multiple types ergonomically.
- Use `#[must_use]` on functions where ignoring the return value is almost certainly a bug.
- Be deliberate about `Send + Sync` bounds. Don't blanket-require them unless the design demands it.
- Don't abuse `Deref` for inheritance-like patterns. It's for smart pointer types.

### Memory & Performance

- Reduce buffer copying as much as possible. This is why we are using Rust. `Bytes`/`BytesMut` is a good tool for this but not always the right one.
- Minimize allocations on hot paths. Pre-allocate vectors when the size is known.
- For parsers and protocol handling, prefer borrowing from the input buffer (zero-copy) over allocating new strings.
- Profile before speculating. Use `criterion` for benchmarking. Use `perf`/`flamegraph` to find actual bottlenecks.

### Error Handling

- Use `thiserror` for library error types, `anyhow` for application-level errors. Don't mix them.
- Don't use `unwrap()`. Propagate errors with `?`, or use `expect()` with a message that explains the invariant if a panic is truly the right choice.
- Add context to errors. Bare `?` with no `.context()` or wrapping loses information.
- Make error variants specific. A single `Error::Unknown(String)` is useless for callers.

### Architecture

- If you have an abstraction, maintain it or modify the abstraction. Don't write spaghetti around it.
- `unsafe` is a last resort. When used, document the exact safety invariants in a `// SAFETY:` comment. Contain it in small, well-tested modules.
- Be conservative with dependencies. Check maintenance status and transitive dependency count before adding a crate.
- Use cargo features for optional functionality, not for core behavior.

### Testing

- Use `criterion` for benchmarks. Separate setup from measured work.
- Use `#[cfg(test)]` modules for test utilities. Don't pollute the public API with test helpers.
- Test the public API, not internals. If you need to test internals, that's a sign the module boundary is wrong.
