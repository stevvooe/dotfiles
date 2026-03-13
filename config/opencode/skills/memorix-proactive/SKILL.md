# Skill: memorix-proactive

## Purpose

Run Memorix in proactive mode so durable context is captured and kept current.

## When to use

- At session start.
- During non-trivial implementation, debugging, or design work.
- Before closing a substantial task.

## Session bootstrap

At the first user turn in a new session:

1. Call `memorix_session_start`.
2. Call `memorix_search` for context relevant to the current request.
3. If needed, call `memorix_detail` for the most relevant memory IDs.

## Operating policy

- Automatically store decisions, trade-offs, gotchas, problem-solutions, and meaningful what-changed items.
- Use `topicKey` for evolving topics so updates upsert instead of duplicating.
- Track multi-session efforts with `progress` (`feature`/`status`/`completion`).
- Resolve completed memories when tasks are done.
- At the end of each substantial task, add/update a summary at `topicKey: "session/latest-summary"`.
- If uncertain whether to store, bias toward concise structured memory.

## Memory checkpoint cadence

After every non-trivial exchange, run a quick checkpoint:

1. What new facts or decisions were introduced?
2. What should be stored or updated?
3. What can be resolved?
