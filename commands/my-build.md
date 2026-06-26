---
description: Implement a spec's Design Details task by task — TDD + incremental, conforming to project conventions; commit per task (confirm each, or auto-chain in auto/bypass mode), then a full end-of-build review
argument-hint: [spec title or path]
---

# /my-build

Build from the spec: **$ARGUMENTS**

Implement the spec's **Design Details** one task at a time. Output must conform to the project's conventions —
the spec's **Code Style** and **Boundaries**, `CLAUDE.md`, and the surrounding code. Verify before you commit.

**Language.** Talk to the user in their configured language; write spec edits (idea write-ins, task check-offs)
in **English**; for other artifacts (code, comments, commits, docs) follow the project's existing conventions.

**Source lookup.** To read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.

## Phase 1 — Resolve the spec

1. **First strip an optional `auto` token** from `$ARGUMENTS` (it selects the run mode in Phase 2, not the
   spec) — the remainder is the spec selector. Resolve the target spec from that remainder, searching both
   `specs/` (committed) and `.claude/specs/` (local): a path/full filename → use as-is; a bare title → match
   `{specs,.claude/specs}/*-<title>.md`, the prefix being a date or issue number, or a legacy `<dir>/<title>.md`,
   asking which if several match; empty → if the two dirs hold one spec use it, else list them and ask which.
2. **If the spec file does not exist, stop and hand back to `/my-spec`** to initialize it (offer to run it
   now). Do not invent requirements.
3. **If the spec isn't planned yet** — the Implementation Plan still shows its `> TODO` (no `[ ]` tasks), or
   the Test Plan still has a `TODO` or any `<…>` placeholder — recommend running `/my-plan` first, and ask
   before proceeding. Judge this from **content**, not the `Status:` line: that line is a lifecycle trace, not a
   gating signal; if it contradicts the content, trust the content and fix the line in passing.

## Phase 2 — Set the baseline & route skills

1. Read the spec's **Design Details** — its **Implementation Plan** is your ordered task list.
2. **Establish a clean git baseline.** Run `git status --porcelain`; if there are unrelated uncommitted
   changes, ask the user how to handle them before per-task commits. Then make sure you're on the spec's
   working branch, named from its `Type:` — **Feature → `spec/<title>`**, **Bug fix → `fix/<title>`** (`<title>`
   is the spec's hyphenated title, without the date/issue prefix). If you're not on it, create it from the
   default branch.
3. **Decide the run mode for this build:**
   - **Auto-chain** — when the session is in `acceptEdits` (auto-accept) or `bypassPermissions` mode, **or** the
     `auto` token was passed (Phase 1.1). Tasks run one after another with no per-task confirmation; the only
     stop is the final review (Phase 5.4).
   - **Per-task confirm** (default) — every other case. Each task pauses for your confirmation before commit.

   State the chosen run mode — and the spec's tracking mode (committed if it's under `specs/`, local if under
   `.claude/specs/`) — in your first message so it's on the record.
4. **Backbone for the whole build (inline discipline):** work one vertical task at a time, never a big-bang
   change; for each, drive with TDD — write a failing test first (RED), implement the minimum to pass (GREEN),
   then keep the suite green. Detailed loop in Phase 3.
5. **Extra skills, engaged by the nature of each task:**
   - **Refactoring** (rename / extract / split / move / restructure) → invoke `gitnexus-refactoring` **first**
     if available.
   - **API / interface design** needed → `agent-skills:api-and-interface-design`.
   - **Risk items** (flagged in the spec's Risks and Mitigations) → `agent-skills:doubt-driven-development`.
   - **Frontend / UI** work → `agent-skills:frontend-ui-engineering`. For a **rendered screenshot** (render
     check, responsive viewports, a component shot) → `crawl4ai-search`; for **interactive** debugging (clicks,
     console, network) → `agent-skills:browser-testing-with-devtools`.

## Phase 3 — Build the next task (loop)

Take the next pending task from the Implementation Plan and do **one** task:

1. Read its acceptance criteria; load the relevant existing code, patterns, and types. On the first task, if the
   spec's `Status:` is still `Planned`, flip it to `Building` — this write is saved with the task in Phase 5.2.
2. **TDD:** write a failing test (RED) → implement the minimum to pass (GREEN) → run the full suite for
   regressions → run the build.
3. **Conform to conventions:** follow the spec's Code Style & Boundaries and `CLAUDE.md`; match the
   surrounding code; run the project's lint/format commands (from the spec's Commands section).
4. **When a spec detail is unclear or needs adjusting, ask the user** — don't guess. You may also suggest
   delegating the question to the `codex:codex-rescue` subagent (or another model).
5. **When the build changes the spec** — a user's new idea, *or* an implementation finding that overturns a
   Goal / Feature / User Story / Risk — confirm it, then write it back **at the source**: fix the upstream
   statement itself, not just the task line. Don't let a task-level resolution leave a stale Goal/Feature above
   it. Then continue building against the reconciled spec.

## Phase 4 — Review & impact analysis

Before committing the task, review at a depth that matches the task's risk:

1. **Routine task → inline self-review.** Check this task's diff on four axes: correctness (does it meet the
   acceptance criteria, edge cases handled), readability, convention conformance (Code Style / Boundaries /
   `CLAUDE.md` / surrounding code), and security.
2. **Heavy task → full review.** When the task changed **exported/shared symbols**, is flagged as a **Risk**, or
   is a **large change**, escalate to `open-code-review:review` — it runs the `ocr` CLI on this task's working-copy
   diff (changes aren't committed until Phase 5) and may apply fixes autonomously. At the same threshold, if
   `gitnexus-impact-analysis` is available, run one round on the changed symbols — what depends on them, what
   could break.
3. If review or impact analysis surfaces problems, address them — the `open-code-review:review` skill may apply
   fixes itself; otherwise fix them — then re-verify (back to Phase 3) before moving on.

## Phase 5 — Confirm, commit, then continue

1. **Gate by run mode** (set in Phase 2.3) once the task is reviewed and verified:
   - **Per-task confirm** — **present the task to the user and wait for confirmation** before committing.
   - **Auto-chain** — skip the pause; proceed straight to the commit below and on to the next task.
2. **Check off the task `[x]`** in the spec's Implementation Plan and **advance the `Status:` line in the same
   edit** — `Building` while tasks remain, or `Built` if this was the last one — then **commit with `-s`
   (`--signoff`)**. Stage only this task's files; **also stage the spec edit if the spec is committed (under
   `specs/`) — for a local spec (`.claude/specs/`) update it on disk but never stage it.** Use this message
   shape — lowercase title, bullet body (a list, not prose; each bullet one simple, clear point), and a task
   trailer; let `-s` append the `Signed-off-by:` line itself, never hand-write it:

   ```
   <title, always lowercase>

   - <change, one simple point per bullet>
   - ...

   Task <task index> of <spec name>.

   ```

   `<task index>` is the task's ordinal in the Implementation Plan; `<spec name>` is the spec's hyphenated title
   (e.g. `Task 3 of user-auth-flow`).
3. Return to Phase 3 for the next pending task. When all tasks are done (spec `Status:` now `Built`),
   **summarize:** tasks completed, tests added, commits made, and anything skipped, flagged, or left for the user.
4. **End-of-build review** (runs in both modes — auto-chain only skips the *per-task* gate, not this one):
   1. **Let the user review the changes.** Present an overall diff overview and ask whether anything needs
      further adjustment. If so, return to Phase 3, fix it, then come back here.
   2. **Full code retrospective** — run `/agent-skills:review` over the whole build (correctness, readability,
      architecture, security, performance).
   3. **Codex cross-check (conditional)** — if codex is installed locally (verify via `codex:setup`), also run
      `/codex:review` (read-only review, applies no fixes) for an independent pass. If codex isn't available,
      skip it and say so.
   4. **Address findings** — fix the real issues the reviews surface and re-verify (back to Phase 3) before
      finalizing.
5. **Ask the user whether to run `/my-ship` now.** If yes, continue into `/my-ship` with this spec as its target.
