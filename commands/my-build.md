---
description: Implement a spec's Design Details task by task — TDD + incremental, conforming to project conventions, confirm & commit per task
argument-hint: [spec title or path]
model: opus
---

# /my-build

Build from the spec: **$ARGUMENTS**

Implement the spec's **Design Details** one task at a time. Output must conform to the project's conventions —
the spec's **Code Style** and **Boundaries**, `CLAUDE.md`, and the surrounding code. Verify before you commit.

**Language convention.** Keep the channels separate:
- **Talking to the user** (questions, confirmations, summaries, status) → use the user's configured language.
- **Writing the spec** (idea write-ins, task check-offs, any spec edits) → write the content in **English**.
- **Other artifacts** (code, comments, commit messages, docs) → follow the project's existing conventions.

**Source lookup.** When you need to read or trace existing source code, consult sources in this order:
**GitNexus** (if available) → **DeepWiki** → `grep` / `find`.

## Phase 1 — Resolve the spec

1. Resolve the target spec from `$ARGUMENTS` (a title → `specs/<title>.md`; a path → use it; empty → if
   `specs/` holds one spec use it, else list them and ask which).
2. **If the spec file does not exist, stop and hand back to `/my-spec`** to initialize it (offer to run it
   now). Do not invent requirements.
3. **If the spec isn't planned yet** — the Implementation Plan still shows its `> TODO` (no `[ ]` tasks), or
   the Test Plan still has a `TODO` or any `<…>` placeholder — recommend running `/my-plan` first, and ask
   before proceeding.

## Phase 2 — Set the baseline & route skills

1. Read the spec's **Design Details** — its **Implementation Plan** is your ordered task list.
2. **Establish a clean git baseline.** Run `git status --porcelain`; if there are unrelated uncommitted
   changes, ask the user how to handle them before per-task commits. If on the default branch, create a
   feature branch named after the spec title first.
3. **Backbone for the whole build:** `agent-skills:incremental-implementation` +
   `agent-skills:test-driven-development`.
4. **Extra skills, engaged by the nature of each task:**
   - **Refactoring** (rename / extract / split / move / restructure) → invoke `gitnexus-refactoring` **first**
     if available.
   - **API / interface design** needed → `agent-skills:api-and-interface-design`.
   - **Risk items** (flagged in the spec's Risks and Mitigations) → `agent-skills:doubt-driven-development`.
   - **Frontend / UI** work → `agent-skills:frontend-ui-engineering`.

## Phase 3 — Build the next task (loop)

Take the next pending task from the Implementation Plan and do **one** task:

1. Read its acceptance criteria; load the relevant existing code, patterns, and types.
2. **TDD:** write a failing test (RED) → implement the minimum to pass (GREEN) → run the full suite for
   regressions → run the build.
3. **Conform to conventions:** follow the spec's Code Style & Boundaries and `CLAUDE.md`; match the
   surrounding code; run the project's lint/format commands (from the spec's Commands section).
4. **When a spec detail is unclear or needs adjusting, ask the user** — don't guess. You may also suggest
   delegating the question to the `codex:codex-rescue` subagent (or another model).
5. **If the user interrupts with a new idea:** confirm the change, write it into the spec file, then continue
   building against the updated spec.

## Phase 4 — Review & impact analysis

Before committing the task:

1. Invoke `agent-skills:code-review-and-quality` to review this task's changes across correctness,
   readability, architecture, security, and performance.
2. If the task changed exported/shared symbols and `gitnexus-impact-analysis` is available, run one round of
   impact analysis on them — what depends on them, what could break.
3. If review or impact analysis surfaces problems, fix them (back to Phase 3) before moving on.

## Phase 5 — Confirm, commit, then continue

1. When the task is reviewed and verified, **present it to the user and wait for confirmation.**
2. On confirmation, **check off the task `[x]`** in the spec's Implementation Plan, then **commit** — staging
   only this task's files plus that spec change — with a descriptive message.
3. Return to Phase 3 for the next pending task. When all tasks are done, **summarize:** tasks completed, tests
   added, commits made, and anything skipped, flagged, or left for the user.
4. **Ask the user whether to run `/my-ship` now.** If yes, continue into `/my-ship` with this spec as its target.
