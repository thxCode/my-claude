---
name: my-crew
description: Supervise a crew of agents across Orca windows — Run/Task/Dispatch, workers report worker_done, you route the next task or release them. The supervised counterpart to /my-handoff's fire-and-forget.
argument-hint: "[objective] [--agent codex|claude|kimi|opencode|gemini] [--worktree current|new]"
---

# /my-crew

Supervise a crew on: **$ARGUMENTS**

You stay the coordinator: you own the Run, route every completion, and decide when each worker is done.
Workers are **real agents in real Orca windows** — Orca gives them task/dispatch provenance and
`worker_done` authority that a subagent can't have, so never substitute one.

- **Language.** Write objectives and task specs in **English**; talk to the user in their configured language.
- **Never guess `orca` flags.** Phase 2 loads the version-matched guide first.

## 1. Is this actually supervised work?

Orca's default is the *other* thing, and picking wrong creates lifecycle obligations nobody owns.

| The ask | Goes to |
| --- | --- |
| "hand this to codex", "give it to another agent/worktree" — **including** a named model or effort | **`/my-handoff`** — full handoff, no Run, no tracking |
| "supervise", "monitor", "wait for results", "track completion", a task DAG, a decision gate, ask/reply | **here** |
| Build one repo's planned task DAG with TDD, lead owns every commit | **`/my-build … team`** — see `references/my-workflow/team-lane.md` |

Ambiguous → it's a handoff. Say which one you're running and why, in one line.

This isn't a cross-check either: crew workers **own their edits**, so `crosscheck` (read-only second
opinions, Claude keeps every edit) doesn't govern it.

## 2. Preconditions

- `ORCA_TERMINAL_HANDLE` set — otherwise there is no window to coordinate from. Stop and say so.
- `orca status --json` shows the runtime ready (`orca open --json` if not).
- `orca orchestration run-list --json` succeeds — it fails when the experimental feature is off in
  **Settings > Experimental**. Report that exact fix rather than a generic error.
- Then load the guide and follow it over anything remembered:

  ```text
  orca skills get orchestration
  ```

## 3. Plan the work

**Disjoint or serialized — Orca will not catch a collision.** It places no workers and infers no
conflicts; two workers editing one file means one silently loses. Either give each parallel task its own
worktree, or keep their file sets disjoint, exactly as the team lane requires. Overlapping work is
sequenced through `--deps`, not run side by side and hoped over.

Create the Run, then **every** independent task, *before* starting any worker:

```text
orca orchestration run-create --objective "<objective>"
orca orchestration task-create --spec "<task>" [--deps <json_array>]
```

A task spec is read cold by an agent with none of this conversation: what to do, which paths it owns,
what "done" means, how to verify, and what not to touch. Underspecified specs come back as `escalation`.

Cap the crew at **3–5** concurrent workers, and show the user the plan — objective, tasks, agent per task,
placement — **before spending anyone's quota.** Wait for a yes.

## 4. Start the crew

Start **all** independent workers, then wait. Waiting after each start serializes the crew for no reason.

**The two start paths don't support the same agents**, and that decides placement:

| Path | Placement | Agents |
| --- | --- | --- |
| `worker-start --task <id> --worktree current --agent <x>` | its own **tab** | anything Orca can launch, **including `kimi`** — the launcher knows what it started |
| `terminal split --terminal <yours> --direction vertical --command "<cmd>"` → `terminal wait --for tui-idle` → `dispatch --task <id> --to <handle> --inject` | a **pane beside you** | only detectable ones: `claude`, `codex`, `gemini`, `droid`, `cursor`, `opencode`, `omp`, `pi`, `grok` |

`dispatch --inject` has to *detect* the agent from the terminal's command string, so the binary must lead
it: `codex --flags` works, `VAR=1 codex` doesn't. **kimi is not detectable** — it can only be a worker
through `worker-start`, which means kimi always gets a tab and never a split.

`--direction vertical` is what puts a pane **beside** you; `horizontal` stacks it below.

**Launch every worker in its non-interactive mode** or it stalls on its first approval prompt with nobody
watching: `codex --dangerously-bypass-approvals-and-sandbox`, `claude --dangerously-skip-permissions`,
`kimi --auto` (`--yolo` still asks questions). For codex it's not only about prompts — **its sandbox
blocks the local RPC `orca orchestration send` needs**, so a sandboxed worker does the whole task and
then cannot report it.

Since `worker-start` can't carry env vars, anything a worker needs from the environment belongs in the
shell profile. **kimi self-updates on launch and that kills its own TUI mid-start** — the wreck below is
what follows. `export KIMI_CODE_NO_AUTO_UPDATE=1` in `~/.zshenv` is the durable fix.

The low-level path has one more cost: `worker-*` commands only manage dispatches created by
`worker-start`. A `dispatch --inject` dispatch returns `dispatch_not_found` from `worker-stop` /
`worker-release` — clean those up with `terminal close` and `task-update`.

### Then confirm each worker actually got its task

`ready` / `input_accepted` means Orca handed the input to the *terminal* — **not** that an agent took it.
Both failures below are measured, not hypothetical, and Orca reports success for both:

- **TUI still starting** → the preamble is swallowed. The worker idles forever with no task, looking
  perfectly healthy.
- **TUI failed to start** → the terminal is a bare shell, and it **executes** the preamble. The example
  `worker_done` command inside it runs for real, sending a completion built entirely of placeholders —
  which Orca accepts, marking your task done.

So `terminal read` after every start, before waiting on anything. You want the agent's own UI plus the
TASK block. A shell prompt or `command not found` means **rebuild that worker** — don't dispatch into it
again.

A nonzero exit from `worker-start` is a real failure — inspect `stage`, `effects`, `residualResources`.
**Don't auto-retry**; a half-created worker plus a retry is two workers.

## 5. The wait loop

```text
orca orchestration check --wait --types worker_done,escalation,question --timeout-ms <n>
```

**This blocks, so run it as a background Bash command** and let the completion notify you — a foreground
call dies at the 10-minute tool ceiling mid-wait. Never sleep/poll instead; `--wait` is the mechanism.

Reading the results:

- **A timeout, or `{count:0}`, is a checkpoint — not a failure.** Coding tasks routinely run 15–60
  minutes. Keep rolling the wait unless you get `worker_done`/`escalation`, the terminal exits, or the
  user stops you.
- **Heartbeats and visible activity mean alive, not done.** Never stop, close, or restart a worker for
  being quiet.
- **`question` and `escalation` are the user's to answer, not yours.** A worker blocks precisely when it
  hit a decision it has no standing to take — relay it verbatim and wait, then
  `orchestration reply --id <msg_id> --body <the user's answer>`. Answering for them defeats the gate.
- Process **every** message in the Delivery before acknowledging; `check` replays the same batch until
  `--ack <delivery_id>`.

## 6. On each `worker_done`

**Orca validates the sender's credential, never the content.** A `worker_done` proves only that something
holding that Dispatch's capability sent a message — including a shell that ran the preamble by accident.

- **Placeholder fingerprints mean it's fake**: subject `<short status>`, body `<3-sentence summary…>`,
  `files-modified` of `path/a,path/b`. That's the preamble's own example echoing back. The task never
  started: mark it `failed` with the reason and rebuild the worker.
- Otherwise run the task's own verification, and check `files-modified` against the paths it owned.
- A `failed` outcome is information, not an emergency — read the body.

**A *rejected* `worker_done` is the opposite problem.** `dispatch_capability_invalid` means real work with
no credential — the signature of a prompt hand-delivered after `--inject` was swallowed. Such an agent can
work but can never report. Orca returns the original body alongside the rejection, so the output isn't
lost: verify it yourself, record it with `task-update --status … --result …`, and settle the dispatch.
**Hand-delivery recovers content, never lifecycle.**

**Decide the terminal's next owner before acknowledging the Delivery:**

- **Same agent, immediate follow-up task** → take `worker.agent_terminal_handle` from
  `worker-show --dispatch <id>`, then `worker-start --task <next> --terminal <handle>` so Orca transfers
  cleanup ownership.
- **Otherwise** → `worker-release --dispatch <id>`. Run it after **succeeded and failed alike**; release
  is post-completion cleanup, not cancellation, and it preserves output before closing.
- **User wants the window kept** → record it with `worker-retain --dispatch <id>`. Never skip cleanup
  silently.

Never release on a timeout, idle TUI, heartbeat, question, escalation, or stale `worker_done`. If release
returns `release_pending` / `release_unknown`, follow the receipt's recovery action — **don't** substitute
`terminal close`.

## 7. Finish

Done when every Dispatch has settled — verify against `orchestration task-list`, not against your memory
of what came back. Report per task: outcome, files touched, what remains. Then say plainly what the user
now owns: merging, reviewing, or a follow-up crew.

If work accidentally ran outside orchestration, **say so** — don't describe it as orchestrated.
