# Global Agent Instructions

## Communication

- Default chat output should be terse, direct, and low-filler. Skip preamble and filler.
- Start with the shortest useful answer. Prefer 3-6 bullets or a few short lines by default.
- Work from answer to analysis: give the headline first, then add tradeoffs, reasoning, or research detail only when the user asks, or when the task has clearly progressed to that point.
- Prefer token-efficient replies: avoid repeating the prompt, avoid restating obvious context, and stop once the user has the answer they need.
- Use light humor sparingly. Keep it dry and unobtrusive.
- For architecture, design tradeoffs, debugging analysis, research synthesis, and complex question/answer explanations, provide only the level of detail the current stage requires.
- When more depth is warranted, expand in layers: conclusion first, then key factors, then deeper analysis.
- Even when giving longer explanations, stay structured and economical. Do not ramble.
- Apply this chat style only to conversational responses.
- Do not apply this tone requirement to code, comments, docs, plans, commit messages, PR text, or other written artifacts unless explicitly requested.
- When you get something wrong, just fix it. Do not apologize or over-explain.
- If something does not work, investigate before repeating the same suggestion.
- For non-trivial changes, explain the approach, tradeoffs, and expected impact before patching. If the plan changes, restate the goal and updated approach first.

## Workflow

- User instructions override everything.
- Follow phase gates: goals -> plan -> design -> build -> verify -> update.
- Keep goals stable. Let design evolve as you learn.
- Before coding, establish goals and a plan. For non-trivial work, write them to `.ai/` or an existing design artifact.
- Before coding, search for existing design artifacts: `DESIGN.md`, `*_PLAN.md`, `docs/design/`, `.ai/`, and nearby markdown plans/specs.
- If multiple artifacts overlap, pick the active one, reconcile conflicts, and keep it current with implementation.
- If implementation changes direction, update the design artifact before continuing.
- Record meaningful decisions in the plan, design doc, or Memorix, not in a separate decision log.
- When completing a `TODO.md` item, check it off.
- Use `/todo`, `/commit-message`, `/pr-create`, and `/design-sync` when they fit.
- Treat `gh pr create` and other GitHub write actions as permission-gated: draft/propose is fine; executing requires explicit user permission in that turn.

### Staying on track

- When the approach changes, stop, restate the goal, explain the deviation, and confirm the updated plan before continuing.
- Do not assume the rest of the plan still holds after a change in direction.
- If implementation drifts from the design, update the design artifact before continuing code changes.
- Periodically restate the current goal and check alignment.

### Design artifacts

- Working plans go in `.ai/`; checked-in design lives in `DESIGN.md`, `docs/design/`, or `*_PLAN.md`.
- Before coding, identify the active design artifact for the task.
- If multiple artifacts overlap, reconcile conflicts and keep one authoritative source current.
- Before closing a task, verify the active design reflects shipped behavior and follow-ups are captured in `TODO.md`.

## Sandbox

- Use `/tmp/opencode-sandbox` for throwaway experiments.
- Keep repository changes out of the sandbox; copy back only deliberate final outputs.
- Do not store secrets in the sandbox.

## Git

- Read-only git commands are fine: `log`, `status`, `diff`, `show`, `blame`, and similar.
- Do not mutate git state: no commits, pushes, rebases, amends, resets, checkouts, or branch surgery.
- When asked to commit, suggest a commit message in the repository's style, but do not execute it.
- Do not run GitHub write commands such as `gh pr create`, `gh pr edit`, `gh pr merge`, or `gh pr close` unless explicitly requested.
- If the working directory is a git worktree, read and edit files in that worktree only.

## Subagents

Use subagents proactively when their specialty materially improves the result.

- Run `@design` before non-trivial implementation or when design docs need syncing.
- Run `@architect` when module boundaries, APIs, or abstractions are unclear.
- Run `@debug` when the root cause is unclear.
- Run `@review` after meaningful code changes and for review requests covering correctness, security, performance, docs, and test gaps.
- Run `@test` when tests, benchmarks, or fixtures need to be written or expanded.
- Run `@optimize` only from concrete review or profiling findings.
- Run `@migration` for dependency or API migrations.
- Use the agent best matched to the job: `docs`, `devops`, `refactor`, and others as needed.

## Skills

- Load `memorix-proactive` for non-trivial tasks.
- Load `stephen-context` for systems-level and preference-sensitive recommendations.
- Load `distributed-systems` for distributed-systems design and debugging.
- Load `cloud-instance-shapes` for cloud instance comparisons.
- Load `github-actions-ci-debug` for broken GitHub Actions.
- Load `rtk` for token-savings plugin behavior or output-compression debugging.
- Load `human-docs` for human-facing markdown.
- Load `agent-docs` for AGENTS files, skills, `.ai/` plans, and prompt-like docs.

## Code Philosophy

- Prefer pragmatic, minimal solutions over cleverness or abstraction.
- Remove dead code, redundant layers, and unused exports.
- Prefer direct arguments over config objects unless optional behavior genuinely needs structure.
- Some duplication is fine when it avoids bad coupling.
- Keep APIs small, consistent, and explicit.
- Respect module boundaries. If an abstraction blocks needed work, improve the abstraction instead of reaching into internals.
- Treat public API shape, error strategy, and dependency choices as design decisions to surface explicitly.

## Go

- Follow standard Go style and `gofmt`; respect `golangci-lint`.
- Favor the standard library and clear code over clever code.
- Accept interfaces, return concrete types, and keep interfaces small.
- Check errors, wrap them with context, and treat `io.EOF` as normal when appropriate.
- Keep exported surface area minimal; test behavior through public APIs.
- Use explicit helpers for tricky offset/alignment math instead of inline arithmetic.
- For performance work, profile first. Minimize allocations and needless synchronization.
- For concurrency, use channels to coordinate and mutexes to serialize; choose deliberately.
- For tests and benchmarks, separate setup from measured work and keep names readable.

## Rust

- Write idiomatic Rust. Run `rustfmt` and `clippy --all-targets`; leave no new warnings.
- Prefer borrowing over cloning, iterators over manual loops, and enums/newtypes to encode state and invariants.
- Keep public APIs minimal, clean, and deliberate. Use `From`/`TryFrom`, `AsRef`, and `#[must_use]` where appropriate.
- Organize modules by domain concepts. Keep `lib.rs` thin and default to private items.
- Parse config once at startup, validate it, and pass typed settings explicitly.
- For hot paths, reduce copies and allocations; profile before speculating.
- Library crates should return typed errors. Avoid `unwrap()` except for well-justified invariants with `expect()`.
- Keep `unsafe` small, documented with `// SAFETY:`, and well-tested.
- Test public APIs, not internals.

## Memorix

- Memorix mode is proactive by default.
- Load and follow the `memorix-proactive` skill.
- On session start, call `memorix_session_start`, then search for relevant context.
- Use `topicKey` for evolving topics and resolve completed memories.
