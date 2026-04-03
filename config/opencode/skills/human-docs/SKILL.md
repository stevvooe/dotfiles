---
name: human-docs
description: Write documentation for human readers — READMEs, design docs, protocol specs, ADRs, runbooks, and API guides
---

## When to use

- Writing or updating README, DESIGN.md, protocol specs, ADRs, runbooks, API guides.
- Any checked-in markdown intended for engineers to read in a browser or editor.
- Do NOT use for agent instructions, skill files, `.ai/` plans, or AGENTS.md — use `agent-docs` instead.

## Principles

- **Motivation before mechanics.** Start with why this exists, then what it does, then how it works. A reader who doesn't understand the problem won't trust the solution.
- **Concise, not cryptic.** Say what needs saying and stop. Don't pad with filler, but don't strip so much that context is lost. The reader should not need to read source code to understand the doc.
- **Structure for scanning, write for reading.** Use headings, bullet lists, and tables so readers can jump to what they need. But within a section, write coherent prose — not a wall of sentence fragments.
- **One idea per section.** If a section covers two unrelated things, split it.
- **Examples earn their keep.** A concrete example is worth more than a paragraph of description. Show the command, the request/response, the config snippet — then explain.
- **Diagrams when topology matters.** Use ASCII diagrams or Mermaid for data flow, component relationships, and protocol sequences. Don't diagram things that are obvious from a list.
- **Name things precisely.** Use the same term for the same concept throughout. Define terms on first use if they're not obvious.

## Structure guidance

### README

1. One-line description of what this is.
2. Why it exists (1-2 sentences — the problem it solves).
3. Quick start: install, configure, run.
4. Key concepts (only if the reader needs them to use the tool).
5. Configuration reference (table or annotated example).
6. Development: build, test, lint.
7. Links to deeper docs if they exist.

### Design doc / DESIGN.md

1. **Status** — Draft, Active, Superseded, etc.
2. **Goal** — What problem are we solving and why now.
3. **Constraints** — Non-negotiable requirements, compatibility, performance targets.
4. **Options considered** — Brief description of each with trade-offs.
5. **Chosen approach** — What we're building, with enough detail that an implementer can start.
6. **Key decisions** — Anything non-obvious, with rationale.
7. **Open questions** — What's still unresolved.
8. **Follow-ups** — Deferred work, future improvements.

### Protocol spec

1. **Overview** — What the protocol does, transport assumptions, participants.
2. **Message format** — Wire layout with field names, types, sizes, byte order.
3. **State machine** — Valid transitions, who initiates, error states.
4. **Sequences** — Typical flows shown as numbered steps or sequence diagrams.
5. **Error handling** — How errors are signaled, what the receiver should do.
6. **Versioning** — How the protocol evolves without breaking existing peers.

### ADR (Architecture Decision Record)

1. **Title** — Short noun phrase (e.g., "Use SQLite for local session storage").
2. **Status** — Proposed, Accepted, Deprecated, Superseded by ADR-NNN.
3. **Context** — The situation and forces at play.
4. **Decision** — What we decided.
5. **Consequences** — What follows, both good and bad.

## Style rules

- Use present tense. "The server sends a HELLO frame" — not "will send."
- Use active voice. "The client retries" — not "a retry is performed."
- Keep sentences short. If a sentence has two clauses joined by "and", consider splitting.
- Code literals in backticks. File paths, command names, config keys, type names.
- Tables for structured comparisons. Prose for narrative. Don't force one into the other.
- Don't explain what the reader can see. If you show a code block, explain *why*, not *what each line does* (unless it's non-obvious).
- No "Note:" or "Important:" callout prefixes unless there's a genuine trap the reader would otherwise miss.
- Link to source when referencing specific behavior. Use `file:line` format for in-repo references.
