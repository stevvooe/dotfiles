---
name: distributed-systems
description: Apply a rigorous distributed-systems lens for design, debugging, and implementation
---

## When to use

- Any work involving multiple nodes/processes, replication, consensus, queues, caches, or cross-service workflows.
- Kubernetes control/data plane behavior, storage consistency, or network partition handling.
- Reliability/performance work where ordering and failure semantics matter.

## Time and ordering defaults

- Do not rely on wall-clock ordering for correctness.
- Use Lamport clocks for causality-aware total ordering needs where vector detail is unnecessary.
- Use vector clocks only when full concurrency/causality tracking is required.
- Keep identifiers monotonic and comparable where possible for replay/debug.

## Correctness checklist

- Define idempotency keys and retry semantics on every mutating path.
- Make duplicate delivery and out-of-order delivery explicit in API/state transitions.
- Specify durability points and commit/ack boundaries.
- State invariants explicitly and validate them in code/tests.

## Consistency and failure model

- Choose consistency level deliberately (linearizable, causal, eventual) and document trade-offs.
- Model partitions, crash-restart, partial writes, and stale reads as first-class cases.
- Define conflict resolution and tie-break behavior up front.
- Prefer designs that degrade predictably under partial failure.

## Operability defaults

- Instrument with high-signal metrics, structured logs, and trace correlation IDs.
- Include replay/debug hooks (event IDs, sequence numbers, clock values).
- Define SLO-impacting failure modes and expected operator actions.

## Response style

- Lead with failure modes, ordering assumptions, and invariants.
- Present 1-2 viable designs with explicit trade-offs and migration path.
- Favor practical implementation steps over abstract theory.
