---
description: Implement a spec's Design Details (or a debug artifact's Fix Plan) task by task — TDD + incremental, conforming to project conventions; commit per task (confirm each, or auto-chain in auto/bypass mode), then a full end-of-build review
argument-hint: [spec/debug title or path]
---

# /my-build

Build the target: **$ARGUMENTS**

```
my-spec-from-issue ┐
                   ├─ my-spec → my-plan → my-build → my-ship
(direct ask) ──────┘                        ↑
my-debug ───────────────────────────────────┘   (bug quick-fix lane)
```

Implement the **task list** one task at a time. Output must conform to the project's conventions — the target's
**Code Style** & **Boundaries**, `CLAUDE.md`, and surrounding code. **Verify before you commit.**

**Target** = a **spec** (`specs/` committed, or `.claude/specs/` local) or a **debug artifact** (`.claude/debugs/`,
always local). **Task list** = a spec's **Implementation Plan** / a debug artifact's **Fix Plan**.

- **Language.** Talk to the user in their language; write target edits (idea write-ins, task check-offs) in
  **English**; for other artifacts (code, comments, commits, docs) follow the project's conventions.
- **Source lookup.** Read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.
- **Memory.** Capture durable, non-obvious learnings (project constraints, user habits); don't duplicate the
  target / `CLAUDE.md` / repo; retire what this work supersedes.

## Phase 1 — Resolve the target

1. **Strip an optional `auto` token** from `$ARGUMENTS` first (it picks the run mode in Phase 2, not the target);
   the remainder is the selector. Resolve against `specs/`, `.claude/specs/`, **and `.claude/debugs/`**:
   - path / full filename → use as-is.
   - bare title → match `{specs,.claude/specs,.claude/debugs}/*-<title>.md` (prefixed by date or issue number);
     also accept legacy `<dir>/<title>.md`. Several match → list and ask.
   - empty → if exactly one target exists across those dirs, use it; else list and ask.
2. **Missing file → stop and hand back** to `/my-spec` (or `/my-debug` for a bug) to initialize it. Don't invent
   requirements.
3. **Not planned → recommend the planner first, ask before proceeding.** Judge from **content**, not the
   `Status:` line (a lifecycle trace; if it contradicts content, trust content and fix it in passing):
   - **spec** not planned (Implementation Plan still `> TODO` / no `[ ]`; or Test Plan has `TODO` / any `<…>`) →
     recommend `/my-plan`.
   - **debug artifact** not planned (Fix Plan empty/`TODO`; or Test Plan has placeholders) → recommend `/my-debug`.

## Phase 2 — Set the baseline & route skills

1. Read the target's **Design Details** — its **task list** is your ordered work.
2. **Clean git baseline:** `git status --porcelain`; unrelated uncommitted changes → ask how to handle before
   per-task commits.
3. **Be on the target's working branch** (create from default branch if not). Prefix by source:

   | Target | Branch |
   | --- | --- |
   | Feature spec (`Type: Feature`) | `spec/<title>` |
   | Bug-fix spec (`Type: Bug fix`) | `fix/<title>` |
   | Debug artifact | `fix/<title>` (always) |

   (`<title>` = hyphenated title, without the date/issue prefix.)
4. **Run mode:**

   | Mode | When | Stops |
   | --- | --- | --- |
   | **Auto-chain** | session in `acceptEdits`/`bypassPermissions`, **or** `auto` token passed | only compaction (5.3) + final review (5.5) |
   | **Per-task confirm** (default) | every other case | pauses before each commit |

   State the chosen run mode **and** the tracking mode (committed if under `specs/`; local if under
   `.claude/specs/` or `.claude/debugs/`) in your first message.
5. **Backbone (inline discipline):** one vertical task at a time, never big-bang; drive with TDD (RED → GREEN →
   keep suite green; loop in Phase 3). **PoC/spike front-loaded?** (risky items ordered first) build it first;
   if it overturns a Goal/Feature/design, reconcile the target **now** at its source (Phase 3.5) while churn is
   cheap — keeps `/my-ship`'s history folding small.
6. **Extra skills by task nature:**

   | Task nature | Skill |
   | --- | --- |
   | Refactor (rename/extract/split/move) | `gitnexus-refactoring` **first** (if available) |
   | API / interface design | `agent-skills:api-and-interface-design` |
   | Risk item (flagged in target) | `agent-skills:doubt-driven-development` |
   | Frontend / UI | `agent-skills:frontend-ui-engineering` |
   | Rendered screenshot (render/responsive/component shot) | `crawl4ai-search` |
   | Interactive UI debug (clicks/console/network) | `agent-skills:browser-testing-with-devtools` |
7. **Confirm the build/test environment before the loop.** Read the environment the target pinned in
   **Commands** — **local or remote** (if remote, its access method); if unpinned (older/unplanned target), ask.
   **Smoke-check** the build/test commands run in that environment before starting — a broken environment found
   mid-build is expensive to unwind.

## Phase 3 — Build the next task (loop)

Do **one** pending task from the task list:

1. Read its acceptance criteria; load relevant existing code, patterns, types. On the **first** task, if
   `Status:` is still `Planned` (spec) / `Diagnosed` (debug), flip it to `Building` — saved with the task in 5.2.
2. **TDD:** failing test (RED) → minimum to pass (GREEN) → full suite (regressions) → build.
3. **Conform:** follow Code Style & Boundaries + `CLAUDE.md`; match surrounding code; run lint/format (from
   Commands).
4. **Simplicity & readability discipline (continuous, while coding — never overrides `CLAUDE.md`):**
   - **Decision ladder before writing** — need this at all? → codebase already has it? → standard library? →
     native platform feature? → an installed dependency covers it? → can it be one line? → *then* minimal
     working code. **Deletion over addition; boring over clever.**
   - **Simplify anti-patterns** — deep nesting → guard clauses / extract; long function → split by
     responsibility; nested ternary → if/else; generic names → descriptive; duplicated logic → shared function;
     dead code → remove after confirming.
   - **Never simplify away** — input validation, data-loss-preventing error handling, security, accessibility,
     explicitly requested features.
   - **Heavy/at-scale simplification** → escalate to `agent-skills:code-simplification` (in Phase 4 review or
     end-of-build).
5. **Unclear spec detail → ask the user** (don't guess); you may delegate the question to `codex:codex-rescue`
   (or another model).
6. **Build changes the target?** (a new idea, or a finding that overturns a Goal / Feature / User Story / Risk)
   — confirm, then write it back **at the source** (fix the upstream statement, not just the task line). Then
   continue against the reconciled target.

## Phase 4 — Review & impact analysis

Depth matches the task's risk:

1. **Routine → inline self-review** on four axes: correctness (meets acceptance, edge cases), readability,
   convention conformance (Code Style / Boundaries / `CLAUDE.md` / surrounding code), security.
2. **Heavy → full review.** When the task changed **exported/shared symbols**, is **Risk**-flagged, or is a
   **large change**: run `open-code-review:review` (runs `ocr` on the working-copy diff — uncommitted until
   Phase 5 — may apply fixes). At the same threshold, if `gitnexus-impact-analysis` is available, run one round
   on the changed symbols (what depends on them, what could break).
3. Problems surfaced → address (the OCR skill may fix them itself; else fix) → re-verify (back to Phase 3).

## Phase 5 — Confirm, commit, continue

1. **Gate by run mode** once reviewed & verified:
   - **Per-task confirm** → present the task and **wait for confirmation** before committing.
   - **Auto-chain** → skip the pause; commit and continue.
2. **Record → stage → commit**, in order:
   - **Record:** check off `[x]` in the task list **and advance `Status:` in the same edit** — `Building` while
     tasks remain, `Built` when this was the last.
   - **Stage:** stage only this task's files. Stage the target edit **only if committed (`specs/`)**; a **local**
     target (`.claude/specs/` or `.claude/debugs/`) is updated on disk but **never staged**.
   - **Commit with `-s`** (let `-s` append `Signed-off-by:`; never hand-write it):

     ```
     <type>(optional scope): <title in lowercase>

     - <change, one simple point per bullet>
     - ...

     Task <task index> of <target name>.
     ```
     - `type` ∈ `fix|feat|build|chore|ci|docs|style|refactor|perf|test`.
     - `<task index>` = the task's ordinal; `<target name>` = the hyphenated spec/debug title (e.g.
       `Task 3 of user-auth-flow`).
3. **Compaction checkpoint** (tasks still pending). You can't read the token count — judge from proxies:
   - **Signals (either fires):** context looks large (~**>500K** — many/large files, piled tool output),
     **or** it feels fuzzy (losing track, re-reading, unsure of state). Neither → skip to next step.
   - **Action:** require a compaction in **both** run modes (`/compact` is user-only; a bloated/fuzzy context
     degrades remaining tasks). Emit a copyable `/compact <focus>` block (English) and ask the user to run it.
   - Focus **keeps:** target path, done (`[x]`) vs pending tasks, current branch, run mode, key decisions /
     patterns, open questions / risks. **Drops:** verbose diffs & tool output of committed tasks (in git now).
   - Build resumes cleanly from Phase 1 after compaction (target file + git hold the state).
4. Back to Phase 3 for the next task. All done (`Status: Built`) → **summarize:** tasks completed, tests added,
   commits made, anything skipped / flagged / left for the user.
5. **End-of-build review** (both modes — auto-chain skips only the *per-task* gate, not this):
   1. **User review** — present an overall diff overview; ask whether anything needs adjustment (yes → Phase 3,
      then back here).
   2. **Full retrospective** — `/agent-skills:review` over the whole build (correctness, readability,
      architecture, security, performance).
   3. **Codex cross-check (conditional)** — if codex is installed (verify via `codex:setup`), also run
      `/codex:review` (read-only, applies no fixes). Not available → skip and say so.
   4. **Address findings** — fix the real issues, re-verify (Phase 3) before finalizing.
6. **Ask whether to run `/my-ship` now.** If yes, continue into `/my-ship` with this target.
