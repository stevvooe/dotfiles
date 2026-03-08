# Skill: stephen-context

## Purpose

Apply Stephen's stable working context so responses start from the right assumptions.

## Core context

- Primary focus: distributed systems and systems-level engineering.
- Frequent domains: Kubernetes control/data plane behavior, storage systems, model-serving infrastructure, networking, and low-level Linux internals.
- Environment: macOS, terminal-first workflow, Neovim-heavy setup.
- Preference: direct practical solutions over abstract or ceremony-heavy approaches.

## Technical anchors

- Distributed data paths and caching (content-addressed storage, chunking, consistency semantics, cold-start/perf trade-offs).
- Kubernetes platform internals (CSI lifecycle, kubelet interactions, topology/routing behavior, reliability under failure).
- Sandbox and network systems (proxying/interception, VM/container isolation boundaries, service connectivity correctness).

## Usage rules

- Default explanations to systems-level depth and concrete implementation detail.
- Bias toward distributed-systems failure modes, correctness, and operability.
- Prefer terminal-native commands and verifiable steps.
- When making design suggestions, bias for performance, operational simplicity, and debuggability.
