#!/usr/bin/env bun
// swarm: discover and orchestrate oc-launched opencode servers on this machine.
//
// Discovery is local-only: lsof finds opencode processes with a loopback TCP
// listener (i.e. launched via `oc` or --port). Everything else goes through the
// typed opencode SDK against each server.

import { createOpencodeClient, type OpencodeClient } from "@opencode-ai/sdk"

type Server = { port: number; url: string; client: OpencodeClient; directory: string }

const HOST = "127.0.0.1"

function die(msg: string, code = 1): never {
  process.stderr.write(msg + "\n")
  process.exit(code)
}

// Ports of opencode processes listening on loopback. lsof is the one piece the
// SDK cannot do: find servers that never advertised themselves.
async function discoverPorts(): Promise<number[]> {
  const proc = Bun.spawn(
    ["lsof", "-nP", "-iTCP@127.0.0.1", "-sTCP:LISTEN"],
    { stdout: "pipe", stderr: "ignore" },
  )
  const out = await new Response(proc.stdout).text()
  const ports = new Set<number>()
  for (const line of out.split("\n")) {
    if (!/opencode/i.test(line)) continue
    const m = line.match(/:(\d+)\s*\(LISTEN\)/)
    if (m) ports.add(Number(m[1]))
  }
  return [...ports].sort((a, b) => a - b)
}

// PIDs of opencode processes WITHOUT a loopback listener (unmanaged TUIs).
async function discoverUnmanaged(): Promise<{ pid: number; cwd: string }[]> {
  const listen = Bun.spawn(["lsof", "-nP", "-iTCP@127.0.0.1", "-sTCP:LISTEN"], { stdout: "pipe", stderr: "ignore" })
  const listenOut = await new Response(listen.stdout).text()
  const ported = new Set<number>()
  for (const line of listenOut.split("\n")) {
    if (!/opencode/i.test(line)) continue
    const cols = line.trim().split(/\s+/)
    if (cols[1]) ported.add(Number(cols[1]))
  }
  const pg = Bun.spawn(["pgrep", "-x", "opencode"], { stdout: "pipe", stderr: "ignore" })
  const pids = (await new Response(pg.stdout).text()).split("\n").map(Number).filter(Boolean)
  const result: { pid: number; cwd: string }[] = []
  for (const pid of pids) {
    if (ported.has(pid)) continue
    const lc = Bun.spawn(["lsof", "-a", "-p", String(pid), "-d", "cwd", "-Fn"], { stdout: "pipe", stderr: "ignore" })
    const lcOut = await new Response(lc.stdout).text()
    const cwd = lcOut.split("\n").find((l) => l.startsWith("n"))?.slice(1) ?? ""
    if (cwd) result.push({ pid, cwd })
  }
  return result
}

// Resolve each port to a connected client + its served directory.
async function resolveServers(): Promise<Server[]> {
  const ports = await discoverPorts()
  const servers = await Promise.all(
    ports.map(async (port) => {
      const url = `http://${HOST}:${port}`
      const client = createOpencodeClient({ baseUrl: url })
      let directory = ""
      try {
        const path = await client.path.get()
        directory = (path.data as any)?.directory ?? ""
      } catch {
        /* server gone or unreachable */
      }
      return { port, url, client, directory }
    }),
  )
  return servers.filter((s) => s.directory !== "")
}

type Session = { id: string; directory: string; title: string; time: { updated: number } }

async function sessionsForDir(s: Server): Promise<Session[]> {
  try {
    const res = await s.client.session.list()
    const all = ((res as any).data ?? []) as Session[]
    return all
      .filter((x) => x.directory === s.directory)
      .sort((a, b) => (b.time?.updated ?? 0) - (a.time?.updated ?? 0))
  } catch {
    return []
  }
}

async function isBusy(s: Server): Promise<boolean> {
  try {
    const res = await s.client.session.status()
    const status = (res as any).data ?? {}
    return Object.keys(status).length > 0
  } catch {
    return false
  }
}

// Classify a server's most-recent session: busy | idle (needs input) | quiet.
type Pending = {
  id: string
  sessionID: string
  permission: string
  patterns: string[]
  filepath?: string
  diff?: string
}

// Pending permission requests for a server (bash approvals, edit/diff applies).
// GET /permission is pollable -- a blocked agent shows up here even though its
// session status still reads "busy".
async function pendingPermissions(s: Server): Promise<Pending[]> {
  try {
    const res = await fetch(`${s.url}/permission`, { signal: AbortSignal.timeout(2000) })
    if (!res.ok) return []
    const data = (await res.json()) as any[]
    return (data ?? []).map((p) => ({
      id: p.id,
      sessionID: p.sessionID,
      permission: p.permission,
      patterns: p.patterns ?? [],
      filepath: p.metadata?.filepath,
      diff: p.metadata?.diff,
    }))
  } catch {
    return []
  }
}

async function activeState(
  s: Server,
): Promise<{ state: string; session: string; recent: string; permission?: string }> {
  const sessions = await sessionsForDir(s)
  if (sessions.length === 0) return { state: "quiet", session: "", recent: "" }
  const top = sessions[0]

  // Blocked beats busy: a pending permission means it is waiting on the human,
  // even though session status reports busy.
  const perms = await pendingPermissions(s)
  if (perms.length > 0) {
    const p = perms[0]
    return {
      state: "blocked",
      session: p.sessionID || top.id,
      recent: `${p.permission}: ${p.filepath ?? p.patterns.join(",")}`,
      permission: p.id,
    }
  }

  try {
    const statusRes = await s.client.session.status()
    const status = (statusRes as any).data ?? {}
    if (status[top.id]) return { state: "busy", session: top.id, recent: "" }
  } catch {
    /* fall through */
  }
  try {
    const msgsRes = await s.client.session.messages({ path: { id: top.id }, query: { limit: 1 } })
    const msgs = ((msgsRes as any).data ?? []) as any[]
    const last = msgs[msgs.length - 1]
    const role = last?.info?.role
    const completed = last?.info?.time?.completed
    const text = (last?.parts ?? [])
      .filter((p: any) => p.type === "text")
      .map((p: any) => p.text)
      .join(" ")
      .replace(/\s+/g, " ")
      .trim()
      .slice(0, 60)
    if (role === "assistant" && completed) return { state: "idle", session: top.id, recent: text }
    return { state: "busy", session: top.id, recent: "" }
  } catch {
    return { state: "quiet", session: top.id, recent: "" }
  }
}

function pad(s: string, n: number): string {
  return s.length >= n ? s : s + " ".repeat(n - s.length)
}

async function cmdAgents(args: string[]): Promise<void> {
  const asJson = args.includes("--json")
  const showAll = args.includes("--all")
  const servers = await resolveServers()

  const rows = await Promise.all(
    servers.map(async (s) => {
      const sessions = await sessionsForDir(s)
      const busy = await isBusy(s)
      return {
        port: s.port,
        url: s.url,
        directory: s.directory,
        sessions: sessions.length,
        busy,
        recent: sessions[0]?.title ?? "",
        managed: true,
      }
    }),
  )

  const unmanaged = showAll ? await discoverUnmanaged() : []

  if (asJson) {
    const out = [...rows, ...unmanaged.map((u) => ({ pid: u.pid, directory: u.cwd, managed: false }))]
    process.stdout.write(JSON.stringify(out) + "\n")
    return
  }
  for (const r of rows) {
    process.stdout.write(
      `${pad(String(r.port), 6)} ${pad(r.busy ? "busy" : "idle", 7)} ${pad(String(r.sessions), 3)} ${pad(r.directory, 50)} ${r.recent}\n`,
    )
  }
  for (const u of unmanaged) {
    process.stdout.write(`${pad(String(u.pid), 6)} ${pad("unmgd", 7)} ${pad("-", 3)} ${pad(u.cwd, 50)} (no port; tmux only)\n`)
  }
}

async function cmdAttention(args: string[]): Promise<void> {
  if (args.includes("--wait")) return cmdAttentionWait(args)
  const asJson = args.includes("--json")
  const showAll = args.includes("--all")
  const servers = await resolveServers()

  const rows = await Promise.all(
    servers.map(async (s) => {
      const a = await activeState(s)
      return { port: s.port, directory: s.directory, ...a }
    }),
  )
  // Surface agents needing the human: idle (awaiting prompt) or blocked
  // (awaiting a permission/diff approval).
  const filtered = showAll ? rows : rows.filter((r) => r.state === "idle" || r.state === "blocked")

  if (asJson) {
    process.stdout.write(JSON.stringify(filtered) + "\n")
    return
  }
  for (const r of filtered) {
    process.stdout.write(`${pad(String(r.port), 6)} ${pad(r.state, 6)} ${pad(r.directory, 50)} ${r.recent}\n`)
  }
}

// Block on every server's event stream until one session goes idle or asks for
// permission. Prints the triggering session and exits.
async function cmdAttentionWait(args: string[]): Promise<void> {
  const asJson = args.includes("--json")
  const tIdx = args.indexOf("--timeout")
  const timeoutSec = tIdx >= 0 ? Number(args[tIdx + 1] ?? 0) : 0
  const servers = await resolveServers()
  if (servers.length === 0) die("error: no opencode servers found")

  const controller = new AbortController()
  let resolved = false

  const result = await new Promise<any | null>((resolve) => {
    const finish = (val: any | null) => {
      if (resolved) return
      resolved = true
      controller.abort()
      resolve(val)
    }

    if (timeoutSec > 0) setTimeout(() => finish(null), timeoutSec * 1000)

    for (const s of servers) {
      ;(async () => {
        try {
          const events = await s.client.event.subscribe({ signal: controller.signal } as any)
          for await (const evt of (events as any).stream) {
            if (resolved) break
            const t = evt?.type
            const p = evt?.properties ?? {}
            if (t === "session.idle") {
              finish({
                port: s.port,
                url: s.url,
                directory: s.directory,
                state: "idle",
                session: p.sessionID ?? "",
                detail: "",
              })
              break
            }
            if (t === "permission.asked") {
              // permissionID is only available here -- there is no API to list
              // pending permissions after the fact. Surface it so `respond` can
              // answer this exact session+permission.
              finish({
                port: s.port,
                url: s.url,
                directory: s.directory,
                state: "blocked",
                session: p.sessionID ?? "",
                permission: p.id ?? "",
                detail: `${p.permission ?? ""}: ${(p.patterns ?? []).join(",")}`,
              })
              break
            }
          }
        } catch {
          /* stream aborted on resolve, or server gone */
        }
      })()
    }
  })

  if (!result) die(`timeout: no session needed input within ${timeoutSec}s`, 2)

  if (asJson) {
    process.stdout.write(JSON.stringify(result) + "\n")
  } else {
    const suffix = result.permission ? `  perm=${result.permission}` : ""
    process.stdout.write(
      `${pad(String(result.port), 6)} ${pad(result.state, 7)} ${pad(result.directory, 50)} ${result.detail}${suffix}\n`,
    )
  }
  process.exit(0)
}

// --- addressing & drive verbs ------------------------------------------------

function flag(args: string[], name: string): string | undefined {
  const i = args.indexOf(name)
  return i >= 0 ? args[i + 1] : undefined
}

// Normalize --agent <url|port|basename> to a base URL.
//   http(s)://...  -> as-is (future remote/tunnel)
//   <digits>       -> http://127.0.0.1:<port>
//   <name>         -> discover local servers, match directory basename
async function resolveAgentUrl(arg: string): Promise<string> {
  if (/^https?:\/\//.test(arg)) return arg.replace(/\/$/, "")
  if (/^\d+$/.test(arg)) return `http://${HOST}:${arg}`

  const servers = await resolveServers()
  const matches = servers.filter((s) => s.directory.split("/").pop() === arg)
  if (matches.length === 1) return matches[0].url
  if (matches.length === 0) {
    die(
      `error: no agent for '${arg}'. Live agents:\n` +
        servers.map((s) => `  ${s.directory.split("/").pop()}  ${s.url}`).join("\n"),
    )
  }
  die(
    `error: '${arg}' is ambiguous. Matching agents:\n` +
      matches.map((s) => `  ${s.url}  ${s.directory}`).join("\n"),
  )
}

// Pick a session id on an agent. --session is exact; --new creates a fresh
// session in the agent's directory; otherwise the most-recent (active) session.
async function selectSession(
  client: OpencodeClient,
  directory: string,
  args: string[],
): Promise<string> {
  const explicit = flag(args, "--session")
  if (explicit) return explicit

  if (args.includes("--new")) {
    const res = await client.session.create({ query: { directory } } as any)
    const id = (res as any).data?.id
    if (!id) die("error: failed to create session")
    return id
  }

  const res = await client.session.list()
  const all = ((res as any).data ?? []) as Session[]
  const mine = all
    .filter((x) => x.directory === directory)
    .sort((a, b) => (b.time?.updated ?? 0) - (a.time?.updated ?? 0))
  if (mine.length === 0) die("error: no sessions for this agent (use --new)")
  return mine[0].id
}

function requireAgent(args: string[]): string {
  const a = flag(args, "--agent")
  if (!a) die("error: --agent <url|port|name> is required")
  return a
}

// swarm prompt --agent <a> [--session <id>|--new] -- <text...>
async function cmdPrompt(args: string[]): Promise<void> {
  const agentArg = requireAgent(args)
  const sep = args.indexOf("--")
  const text = (sep >= 0 ? args.slice(sep + 1) : []).join(" ").trim()
  if (!text) die("error: no prompt text (use: swarm prompt --agent <a> -- <text>)")

  const url = await resolveAgentUrl(agentArg)
  const client = createOpencodeClient({ baseUrl: url })
  const path = await client.path.get()
  const directory = (path.data as any)?.directory ?? ""
  const id = await selectSession(client, directory, args)

  // --model provider/modelID (e.g. anthropic/claude-opus-4-8)
  const body: any = { parts: [{ type: "text", text }] }
  const model = flag(args, "--model")
  if (model) {
    const slash = model.indexOf("/")
    if (slash < 0) die("error: --model must be provider/modelID")
    body.model = { providerID: model.slice(0, slash), modelID: model.slice(slash + 1) }
  }
  const agent = flag(args, "--agent-name")
  if (agent) body.agent = agent

  await client.session.promptAsync({ path: { id }, body } as any)
  process.stdout.write(`${url}  ${id}  prompted${model ? ` (${model})` : ""}\n`)
}

// swarm respond --agent <a> --session <id> --permission <pid> --response <r>
// Exact session+permission only -- never fuzzy. A blocked agent's session and
// permission ids come straight from a permission.asked event.
async function cmdRespond(args: string[]): Promise<void> {
  const agentArg = requireAgent(args)
  const id = flag(args, "--session")
  const permissionID = flag(args, "--permission")
  const response = (flag(args, "--response") ?? "once") as "once" | "always" | "reject"
  if (!id) die("error: respond requires exact --session <id> (no fuzzy selection)")
  if (!permissionID) die("error: respond requires --permission <permissionID>")
  if (!["once", "always", "reject"].includes(response)) {
    die("error: --response must be once | always | reject")
  }

  const url = await resolveAgentUrl(agentArg)
  const client = createOpencodeClient({ baseUrl: url })
  await (client as any).postSessionIdPermissionsPermissionId({
    path: { id, permissionID },
    body: { response },
  })
  process.stdout.write(`${url}  ${id}  permission ${permissionID} -> ${response}\n`)
}

// swarm abort --agent <a> [--session <id>]
async function cmdAbort(args: string[]): Promise<void> {
  const agentArg = requireAgent(args)
  const url = await resolveAgentUrl(agentArg)
  const client = createOpencodeClient({ baseUrl: url })
  const path = await client.path.get()
  const directory = (path.data as any)?.directory ?? ""
  const id = await selectSession(client, directory, args)
  await client.session.abort({ path: { id } } as any)
  process.stdout.write(`${url}  ${id}  aborted\n`)
}

// swarm capture --agent <a> [--session <id>] [--limit N]
// Print the most recent assistant reply text for a session.
async function cmdCapture(args: string[]): Promise<void> {
  const agentArg = requireAgent(args)
  const limit = Number(flag(args, "--limit") ?? 1)
  const url = await resolveAgentUrl(agentArg)
  const client = createOpencodeClient({ baseUrl: url })
  const path = await client.path.get()
  const directory = (path.data as any)?.directory ?? ""
  const id = await selectSession(client, directory, args)

  const res = await client.session.messages({ path: { id }, query: { limit } } as any)
  const msgs = ((res as any).data ?? []) as any[]
  for (const m of msgs) {
    const role = m?.info?.role ?? "?"
    const text = (m?.parts ?? [])
      .filter((p: any) => p.type === "text")
      .map((p: any) => p.text)
      .join("")
      .trim()
    if (text) process.stdout.write(`[${role}] ${text}\n`)
  }
}

// swarm review --agent <a> [--json]
// Show an agent's pending permission requests, including edit/diff content, so
// you can decide before `swarm respond`.
async function cmdReview(args: string[]): Promise<void> {
  const agentArg = requireAgent(args)
  const asJson = args.includes("--json")
  const url = await resolveAgentUrl(agentArg)
  const client = createOpencodeClient({ baseUrl: url })
  const dirRes = await client.path.get()
  const server: Server = { port: 0, url, client, directory: (dirRes.data as any)?.directory ?? "" }

  const perms = await pendingPermissions(server)
  if (asJson) {
    process.stdout.write(JSON.stringify(perms) + "\n")
    return
  }
  if (perms.length === 0) {
    process.stdout.write("no pending permissions\n")
    return
  }
  for (const p of perms) {
    process.stdout.write(`--- ${p.permission}  session=${p.sessionID}  permission=${p.id}\n`)
    if (p.filepath) process.stdout.write(`file: ${p.filepath}\n`)
    if (p.patterns.length) process.stdout.write(`patterns: ${p.patterns.join(", ")}\n`)
    if (p.diff) process.stdout.write(`\n${p.diff}\n`)
    process.stdout.write(`\nrespond: swarm respond --agent ${agentArg} --session ${p.sessionID} --permission ${p.id} --response once|reject\n\n`)
  }
}

function usage(): void {
  process.stdout.write(
    [
      "Usage:",
      "  swarm agents [--json] [--all]        List oc-launched opencode servers",
      "  swarm attention [--json] [--all]     Scan for agents needing input (idle/blocked)",
      "  swarm review --agent <a> [--json]    Show pending permissions + diffs",
      "  swarm attention --wait [--timeout N] [--json]",
      "                                       Block until a session goes idle or blocked",
      "",
      "  --agent <url|port|name>              Address an agent (URL canonical;",
      "                                       port -> 127.0.0.1:port; name -> dir basename)",
      "  Session selector: --session <id> (exact) | --new | default = most-recent",
      "",
      "  swarm prompt  --agent <a> [--session <id>|--new] [--model provider/id] -- <text>",
      "  swarm capture --agent <a> [--session <id>] [--limit N]",
      "  swarm abort   --agent <a> [--session <id>]",
      "  swarm respond --agent <a> --session <id> --permission <pid> [--response once|always|reject]",
      "",
    ].join("\n"),
  )
}

async function main(): Promise<void> {
  const [cmd, ...rest] = process.argv.slice(2)
  switch (cmd) {
    case "agents":
      return cmdAgents(rest)
    case "attention":
      return cmdAttention(rest)
    case "prompt":
      return cmdPrompt(rest)
    case "review":
      return cmdReview(rest)
    case "respond":
      return cmdRespond(rest)
    case "abort":
      return cmdAbort(rest)
    case "capture":
      return cmdCapture(rest)
    case undefined:
    case "-h":
    case "--help":
    case "help":
      return usage()
    default:
      usage()
      die(`error: unknown command '${cmd}'`)
  }
}

await main()
