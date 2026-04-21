---
name: agent-docs
description: Write documentation consumed by LLM agents — AGENTS.md, skill files, .ai/ plans, and agent instructions
---

## When to use

- Writing or updating AGENTS.md, skill files (SKILL.md), `.ai/` plans, agent instructions, or system prompts.
- Any markdown that will be loaded into an LLM context window for planning, decision-making, or task execution.
- Do NOT use for human-facing docs (README, DESIGN.md, protocol specs, ADRs) — use `human-docs` instead.

## Principles

- **Every line is a directive or a fact.** If a line doesn't tell the agent what to do or what is true, delete it. Agents don't need motivation, narrative, or persuasion.
- **Token-conscious.** Every token in the context window competes with code, tool output, and conversation history. Earn each line.
- **Explicit over implicit.** Agents take instructions literally. Don't hint. State the rule, the condition, and the action. If there's an exception, state it.
- **Predictable structure.** Use consistent heading hierarchies and section names so agents can locate information reliably. Avoid creative formatting.
- **Scannable, not readable.** Prefer bullet lists and short declarative sentences over prose paragraphs. An agent doesn't need narrative flow — it needs extractable rules.
- **No ambiguity.** If two interpretations are possible, the agent will sometimes pick the wrong one. Eliminate ambiguity by being specific: name the file, the function, the condition.

## Structure guidance

### AGENTS.md

- Organized by concern: Communication, Workflow, Git, Subagents, Skills, Code style, Language-specific.
- Each section contains rules as bullet points. One rule per bullet.
- Rules state what to do, not why. Add rationale only when the rule would otherwise seem arbitrary and the agent might override it.
- Use imperative mood: "Use X", "Do not Y", "Prefer X over Y when Z."
- Conditional rules: state the condition first. "If auth, perf, or correctness risk is involved, run `@review`."
- Keep ordering stable. New rules append within their section. Don't reorganize without reason.

### Skill files (SKILL.md)

- Frontmatter: `name` and `description` (one-line, used for routing).
- `When to use` — conditions that trigger loading this skill. Be specific enough that the router doesn't load it unnecessarily.
- Core sections — rules, checklists, workflows. Vary by skill type.
- Keep under ~150 lines. If a skill exceeds this, it's covering too much scope — split it.
- Don't duplicate AGENTS.md content. Reference it: "Follow the Git rules in AGENTS.md."
- Include anti-patterns or "do NOT" rules when common mistakes exist.

### .ai/ plans

- **Goal** — One sentence. What are we trying to accomplish.
- **Constraints** — Bullet list. Non-negotiable requirements.
- **Approach** — Numbered steps. What to do in what order.
- **Decisions** — Bullet list. What was decided and why (brief).
- **Status** — What's done, what's in progress, what's blocked.
- **Open questions** — Bullet list. What needs resolving before continuing.
- Plans are working documents. Update them as decisions are made. Don't preserve history in the plan — that's what git and memorix are for.

### Agent instructions / system prompts

- Lead with identity and scope: what the agent is, what it should and should not do.
- Group rules by phase or concern.
- Permission gates: state them as explicit rules, not suggestions. "Do NOT run X unless the user explicitly requests it."
- Tool preferences: state which tool to use for which task. Don't leave the agent to guess.
- Output format: if you need structured output, specify the format exactly.

## Style rules

- Imperative mood. "Run X." "Check Y." "Do not Z."
- One rule per bullet. If a bullet has "and" joining two separate rules, split it.
- No hedging. Not "you should consider" — instead "do X" or "prefer X over Y."
- No filler words. Not "please note that" or "it's important to remember." Just state the rule.
- Backticks for anything the agent needs to match literally: commands, file paths, tool names, config keys.
- Use "Do NOT" (capitalized) for prohibitions that agents commonly violate. Reserve caps for emphasis that matters.
- Avoid relative terms without anchors. Not "keep it short" — instead "keep under 150 lines" or "1-2 sentences."
- Don't use markdown emphasis (bold/italic) for decoration. Use it only when the distinction between emphasized and non-emphasized text carries meaning.
