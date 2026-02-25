---
name: opencode-config
description: Configure OpenCode agents, commands, permissions, and workflow conventions in this dotfiles repo
---

## What this skill covers

- OpenCode configuration in `config/opencode/opencode.json`
- Agent definitions in `config/opencode/agents/*.md`
- Command definitions in `config/opencode/commands/*.md`
- Workflow and coding conventions in `config/opencode/AGENTS.md`

## Repo-specific conventions

- Keep `AGENTS.md` as the source of truth for agent behavior.
- If new behavior changes workflow, update `config/opencode/AGENTS.md` first, then agent files.
- Prefer project-local OpenCode skills in `.opencode/skills/*/SKILL.md` for repo-specific workflows.
- Keep prompts concise and directive. Avoid long prose.
- Follow phase gates from `AGENTS.md`: goals -> plan -> design -> build -> verify -> update.

## When to use this skill

- Adding or tuning subagents
- Adding slash commands (`/todo`, `/design-sync`, etc.)
- Adjusting permissions to reduce noisy prompts while keeping safety boundaries
- Aligning agent prompts with `AGENTS.md`

## Safety checklist

1. Preserve read-only git policy in prompts unless explicitly changed.
2. Avoid broad `allow` permissions when a scoped permission is possible.
3. Keep hidden/specialized agents narrowly scoped.
4. Ensure command/agent names are consistent across files.
5. If behavior changes, document it in `config/opencode/AGENTS.md`.
6. For design-affecting changes, verify phase alignment and design-doc consistency before closing.

## References

- Agents: https://opencode.ai/docs/agents/
- Commands: https://opencode.ai/docs/commands/
- Permissions: https://opencode.ai/docs/permissions/
- Agent skills: https://opencode.ai/docs/skills/
