---
name: github-actions-ci-debug
description: Debug broken GitHub Actions workflows with GitHub MCP first, gh fallback second
---

## Purpose

Triage failed GitHub Actions runs, identify likely root cause, and provide the smallest safe fix.

## Tool priority

1. Use GitHub MCP tools first.
2. If MCP cannot retrieve needed detail, fall back to `gh` commands.

## MCP-first workflow

1. Identify the failing run:
   - Use `github_actions_list` with `method: list_workflow_runs`.
   - Filter by branch/event/status when available.
2. Inspect run metadata:
   - Use `github_actions_get` with `method: get_workflow_run`.
   - Capture workflow name, event, SHA, actor, and conclusion.
3. Find failed jobs:
   - Use `github_actions_list` with `method: list_workflow_jobs` and the run ID.
4. Retrieve logs:
   - Preferred: `github_get_job_logs` with `run_id` + `failed_only: true` + `return_content: true`.
   - Targeted: `github_get_job_logs` with a specific `job_id`.
5. Extract root cause:
   - Focus on first actionable failing step.
   - Separate deterministic failures from infra/transient noise.

## gh fallback workflow

1. List recent runs:
   - `gh run list --limit 20`
2. Inspect a run:
   - `gh run view <run-id>`
3. Get failed logs only:
   - `gh run view <run-id> --log-failed`
4. Get one job log:
   - `gh run view <run-id> --job <job-id> --log`

## How to get logs

- MCP (preferred):
  - All failed job logs in a run:
    - `github_get_job_logs(owner, repo, run_id=<id>, failed_only=true, return_content=true)`
  - Single job logs:
    - `github_get_job_logs(owner, repo, job_id=<id>, return_content=true)`
- CLI fallback:
  - Failed jobs in run:
    - `gh run view <run-id> --log-failed`
  - Specific job:
    - `gh run view <run-id> --job <job-id> --log`

## Output format

- `Failure summary`
- `Likely root cause`
- `Evidence`
- `Recommended fix`
- `Verification`

## Rules

- Do not guess when evidence is missing; call out gaps.
- Prefer earliest actionable failure, not cascaded errors.
- Distinguish flaky infra from reproducible repo issues.
- Recommend reruns only when evidence suggests transient failure.
- Keep fixes minimal, reversible, and specific.
