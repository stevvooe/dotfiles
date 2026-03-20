---
name: opencode-db-inspect
description: Inspect local OpenCode session data safely with the `opencode db` command
---

## Scope

- Local OpenCode SQLite data accessed via `opencode db`
- Session, project, workspace, message, part, and todo inspection
- Read-only troubleshooting and reporting workflows

## Rules

- Use `opencode db path` to discover the active database path instead of hardcoding `~/.local/share/opencode/opencode.db`.
- Prefer one-shot queries like `opencode db "<sql>" --format json` over the interactive shell.
- Inspect `sqlite_master` and `pragma table_info(...)` before assuming schema details.
- Treat `data` columns as JSON and use `json_extract(...)` for summaries.
- Do not run `opencode db migrate` unless the user explicitly asks for database migration work.
- Keep queries read-only; never use `insert`, `update`, `delete`, `alter`, `drop`, or `pragma` settings that mutate state.

## When to use

- Finding recent OpenCode sessions
- Mapping sessions to projects or workspaces
- Inspecting messages and parts inside a session
- Debugging OpenCode persistence, session history, or agent behavior

## Core workflows

### Locate the database

```bash
opencode db path
```

### Inspect the schema first

```bash
opencode db "select name, type from sqlite_master where type in ('table', 'index') order by type, name;"
opencode db "pragma table_info(session);"
opencode db "pragma table_info(message);"
opencode db "pragma table_info(part);"
```

### List recent sessions

```bash
opencode db "select id, title, directory, time_created from session order by time_created desc limit 20;" --format json
```

### Join sessions to project and workspace context

```bash
opencode db "
select
  s.id,
  s.title,
  s.directory,
  p.worktree,
  w.name as workspace_name,
  s.time_created
from session s
join project p on p.id = s.project_id
left join workspace w on w.id = s.workspace_id
order by s.time_created desc
limit 20;
" --format json
```

### Inspect messages in one session

```bash
opencode db "
select
  id,
  json_extract(data, '$.role') as role,
  json_extract(data, '$.model') as model,
  time_created
from message
where session_id = 'SESSION_ID'
order by time_created, id;
" --format json
```

### Inspect parts in one session or message

```bash
opencode db "
select
  id,
  message_id,
  json_extract(data, '$.type') as type,
  time_created
from part
where session_id = 'SESSION_ID'
order by time_created, id;
" --format json
```

### Count session volume

```bash
opencode db "
select
  s.id,
  count(distinct m.id) as messages,
  count(distinct p.id) as parts
from session s
left join message m on m.session_id = s.id
left join part p on p.session_id = s.id
where s.id = 'SESSION_ID'
group by s.id;
" --format json
```

## Notes

- `--format json` is best when the result will be summarized by an agent.
- `--format tsv` is useful for quick terminal inspection.
- Use the interactive `opencode db` shell only for ad hoc exploration that does not fit a one-shot query.

## References

- CLI help: `opencode db --help`
- Related repo guidance: `.opencode/skills/opencode-config/SKILL.md`
