---
description: Implement a spec's Design Details task by task — TDD + incremental, conforming to project conventions, confirm & commit per task
argument-hint: [spec title or path]
model: opus
---

# /my-build

Build from the spec: **$ARGUMENTS**

Implement the spec's **Design Details** one task at a time. Output must conform to the project's conventions —
the spec's **Code Style** and **Boundaries**, `CLAUDE.md`, and the surrounding code. Verify before you commit.

**Language.** Talk to the user in their configured language; write spec edits (idea write-ins, task check-offs)
in **English**; for other artifacts (code, comments, commits, docs) follow the project's existing conventions.

**Source lookup.** To read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.

## Phase 1 — Resolve the spec

1. Resolve the target spec from `$ARGUMENTS` (a path/full filename → use as-is; a bare title → match
   `specs/*-<title>.md`, the prefix being a date or issue number, or a legacy `specs/<title>.md`, asking which if
   several match; empty → if `specs/` holds one spec use it, else list them and ask which).
2. **If the spec file does not exist, stop and hand back to `/my-spec`** to initialize it (offer to run it
   now). Do not invent requirements.
3. **If the spec isn't planned yet** — the Implementation Plan still shows its `> TODO` (no `[ ]` tasks), or
   the Test Plan still has a `TODO` or any `<…>` placeholder — recommend running `/my-plan` first, and ask
   before proceeding. Judge this from **content**, not the `Status:` line: that line is a lifecycle trace, not a
   gating signal; if it contradicts the content, trust the content and fix the line in passing.

## Phase 2 — Set the baseline & route skills

1. Read the spec's **Design Details** — its **Implementation Plan** is your ordered task list.
2. **Establish a clean git baseline.** Run `git status --porcelain`; if there are unrelated uncommitted
   changes, ask the user how to handle them before per-task commits. If on the default branch, create a
   feature branch named after the spec title first.
3. **Backbone for the whole build (inline discipline):** work one vertical task at a time, never a big-bang
   change; for each, drive with TDD — write a failing test first (RED), implement the minimum to pass (GREEN),
   then keep the suite green. Detailed loop in Phase 3.
4. **Extra skills, engaged by the nature of each task:**
   - **Refactoring** (rename / extract / split / move / restructure) → invoke `gitnexus-refactoring` **first**
     if available.
   - **API / interface design** needed → `agent-skills:api-and-interface-design`.
   - **Risk items** (flagged in the spec's Risks and Mitigations) → `agent-skills:doubt-driven-development`.
   - **Frontend / UI** work → `agent-skills:frontend-ui-engineering`.

## Phase 3 — Build the next task (loop)

Take the next pending task from the Implementation Plan and do **one** task:

1. Read its acceptance criteria; load the relevant existing code, patterns, and types. On the first task, if the
   spec's `Status:` is still `Planned`, flip it to `Building` — this write lands with this task's commit (Phase 5.2).
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

1. When the task is reviewed and verified, **present it to the user and wait for confirmation.**
2. On confirmation, **check off the task `[x]`** in the spec's Implementation Plan and **advance the `Status:`
   line in the same edit** — `Building` while tasks remain, or `Built` if this was the last one — then **commit**,
   staging only this task's files plus that spec change, with a descriptive message. (Status rides the task
   commit; no separate Status-only commit.)
3. Return to Phase 3 for the next pending task. When all tasks are done (spec `Status:` now `Built`),
   **summarize:** tasks completed, tests added, commits made, and anything skipped, flagged, or left for the user.
4. **Ask the user whether to run `/my-ship` now.** If yes, continue into `/my-ship` with this spec as its target.
