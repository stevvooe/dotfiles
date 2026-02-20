# Global Agent Instructions

## Communication

- Be direct and concise. Skip preamble and filler.
- Don't be verbose in documentation, READMEs, or comments. Tell the reader what it is, how to run it, how to test it. They can read godoc or source for details.
- When you get something wrong, just fix it. Don't apologize or explain why you were wrong.
- If I say something doesn't work, investigate the actual problem before suggesting the same fix again.

## Git

- Read-only git commands are fine: `log`, `status`, `diff`, `show`, `blame`, etc.
- Never run commands that mutate the repository: no commits, pushes, rebases, amends, resets, or checkouts.
- When asked to commit, suggest a commit message in the repository's existing style, but do not execute it.

## Code Philosophy

- Write pragmatic, efficient code. Simplicity over cleverness.
- Remove dead code, unused exports, and redundant abstractions immediately. Don't keep things around "just in case."
- If something is redundant, collapse it. If two types serve the same purpose, pick one and delete the other.
- Avoid config objects and unnecessary indirection. Prefer direct arguments. Use functional options when there are genuine optional parameters.
- Don't introduce wrapper types or abstractions unless they earn their keep. Every layer of indirection must justify its existence.
- Some duplication is fine when it avoids tight coupling. Do not follow DRY at all costs.
- When renaming or refactoring, breaking the API is fine for new or internal packages. Don't waste time on backward compatibility for code that has no users yet.

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
