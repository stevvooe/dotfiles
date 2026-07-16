---
name: session-history
description: Recall prior work from local session stores (opencode SQLite + Claude Code JSONL)
---

## Scope

- Read-only recall of past sessions from two local stores:
  - **opencode** — SQLite, queried via `opencode db "<sql>" --format json`
  - **Claude Code** — JSONL files under `~/.claude/projects/<encoded-cwd>/*.jsonl`
- No external memory services. No writes. Durable context lives in markdown (design docs, `AGENTS.md`, skills), not a side store.
- Other stores (Claude Desktop app, etc.) are out of scope — no reliable local format.

## When to use

- Session start, to ground recommendations in what was actually done.
- When the user asks "what did we do on X" or "last time we touched Y".
- Before non-trivial work, to find prior decisions and avoid re-litigating.
- When `stephen-context` feels stale — verify against real session activity and propose updates to that skill's markdown.

## Rules

- Read-only. Never `insert`/`update`/`delete` in the opencode DB; never mutate JSONL.
- Prefer one-shot `opencode db` queries over the interactive shell.
- Inspect schema before assuming columns: `pragma table_info(...)`.
- Treat JSONL lines as one JSON object per line; filter with `rg` then parse with `jq`.
- Bias toward concise, structured summaries. Don't dump raw transcripts unless asked.
- If a store is empty or unavailable, say so — don't fabricate prior work.

## opencode (SQLite)

Locate the database (don't hardcode the path):

```bash
opencode db path
```

Inspect schema first:

```bash
opencode db "select name, type from sqlite_master where type in ('table','index') order by type, name;"
opencode db "pragma table_info(session);"
opencode db "pragma table_info(message);"
opencode db "pragma table_info(part);"
```

Recent sessions:

```bash
opencode db "select id, title, directory, time_created from session order by time_created desc limit 20;" --format json
```

Sessions joined to project + workspace:

```bash
opencode db "
select s.id, s.title, s.directory, p.worktree, w.name as workspace, s.time_created
from session s
join project p on p.id = s.project_id
left join workspace w on w.id = s.workspace_id
order by s.time_created desc limit 20;
" --format json
```

Messages in a session (data column is JSON):

```bash
opencode db "
select id, json_extract(data,'$.role') as role, json_extract(data,'$.model') as model, time_created
from message where session_id='SESSION_ID' order by time_created, id;
" --format json
```

Parts in a session:

```bash
opencode db "
select id, message_id, json_extract(data,'$.type') as type, time_created
from part where session_id='SESSION_ID' order by time_created, id;
" --format json
```

## Claude Code (JSONL)

Project dirs encode the cwd by replacing `/` with `-` (leading dash preserved):

```bash
ls ~/.claude/projects/
# e.g. -Users-sjd-claude-test
```

Each `*.jsonl` is one session; one JSON event per line. Useful `type` values: `user`, `assistant`, `mode`, `permission-mode`. User/assistant lines carry `message.content`, `cwd`, `gitBranch`, `timestamp`, `sessionId`, `version`. Subagent transcripts live in `<session-id>/subagents/*.jsonl`.

List sessions for a project (newest by mtime):

```bash
ls -t ~/.claude/projects/-Users-sjd-<project>/*.jsonl
```

First user prompt of each recent session (across all projects):

```bash
for f in $(find ~/.claude/projects -maxdepth 2 -name '*.jsonl' -print0 | xargs -0 ls -t | head -10); do
  ts=$(rg '"type":"user"' "$f" | head -1 | jq -r '.timestamp')
  msg=$(rg '"type":"user"' "$f" | head -1 | jq -r '
    if (.message.content|type)=="string" then .message.content
    else (.message.content[]?|select(.type=="text")|.text // empty) end')
  echo "[$ts] $(basename "$f")"; echo "  $msg"
done
```

Find sessions mentioning a topic:

```bash
rg -l '"type":"user"' ~/.claude/projects/ | xargs rg -l 'PATTERN'
```

Extract user prompts from one session (skip command/caveat wrappers):

```bash
rg '"type":"user"' ~/.claude/projects/-Users-sjd-<project>/<session>.jsonl \
  | jq -r 'select(.message.content|type=="string") | .message.content' \
  | grep -vE 'local-command-caveat|command-name|command-message|command-args'
```

Note: `message.content` may be a string or an array of content blocks (`text`/`tool_use`/`tool_result`). Handle both; for arrays, pull `text` fields from `type:"text"` blocks.

Global typed-prompt history:

```bash
rg 'PATTERN' ~/.claude/history.jsonl
```

## Cross-store workflow

1. Identify which store the user means. Default: opencode (current tool). Ask if unclear.
2. Find candidate sessions by time, directory, or keyword.
3. Summarize: goals, decisions, what changed, open follow-ups. Cite session id + date.
4. When prior work contradicts a static skill (e.g. `stephen-context`), flag it and propose a markdown update rather than silently overriding.

## References

- opencode CLI: `opencode db --help`
- Claude Code data dir: `~/.claude/`
- Related: `stephen-context` skill for the durable profile; `opencode-db-inspect` for opencode-only deep dives.
