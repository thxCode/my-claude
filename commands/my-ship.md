---
description: Finalize a branch (target-optional) — optional e2e tests (fixes written back), refresh the overview, update docs/ADRs, tidy the branch history, open a PR using the upstream PR template; conforms to project conventions
argument-hint: [spec/debug title or path, or nothing to ship the current branch] [--assist codex|kimi]
---

# /my-ship

Finalize and ship the current branch: **$ARGUMENTS**

```
my-spec-from-issue ┐
                   ├─ my-spec → my-plan → my-build → my-ship
(direct ask) ──────┘                        ↑
my-debug ───────────────────────────────────┘   (bug quick-fix lane)
```

Tidy up after the build: validate end-to-end, keep the suite green, tidy the branch history, resync the
overview and docs, open a clean PR. **Target-optional** — a **target** (spec or debug artifact) drives
finalization and gets written back; with none, ship straight from the branch diff. Every change conforms to
project conventions (target **Code Style** & **Boundaries** when present, `CLAUDE.md`, existing test/doc structure).

- **Language.** Talk to the user in their configured language; write target edits (e2e fix write-backs) in **English**;
  other artifacts (tests, overview, docs/ADRs, commits, PR body) follow the project's conventions.
- **Source lookup.** Read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.

**Target** = a **spec** (`specs/` committed, or `.claude/specs/` local) or a **debug artifact** (`.claude/debugs/`,
local). Local targets are updated on disk but **never staged**.

## Phase 1 — Resolve the ship target

1. **Branch & base.** Confirm the current branch and its base (default branch — e.g. `main`; resolve via
   `git symbolic-ref refs/remotes/origin/HEAD` when unsure). `base..HEAD` is the **ship scope**.
2. **Attach a target (optional).** Resolve from `$ARGUMENTS` across `specs/`, `.claude/specs/`, `.claude/debugs/`:
   - path / full filename → as-is.
   - bare title → match `{specs,.claude/specs,.claude/debugs}/*-<title>.md` (date/issue prefix); also legacy
     `<dir>/<title>.md`. Several → list and ask.
   - empty → exactly one target across those dirs → use it; else proceed **without** one.

   **Target-optional — never block on a missing target; any branch can ship.** Only when `$ARGUMENTS`
   **explicitly names** a target that doesn't exist, offer (don't force) `/my-spec` (or `/my-debug`) — or ship
   as-is on the user's say-so. Bare/empty with none found → **no-target mode** (ship from the branch diff). State
   the mode (**target-driven** vs **no-target**) in your first message.
3. **Run the full test suite; green before finalizing** — fix failures or surface them.
4. **Consistency scan (read-only) — target-driven only.** Read the target's upstream statements against the
   completed task list; flag any built outcome that contradicts them; on confirmation, reconcile the upstream
   text (**modifying only the target**). Sections by target type:
   - spec → Goals / Features / User Stories vs Implementation Plan.
   - debug artifact → Root Cause / Background vs Fix Plan.

   **No target → skip.**
5. **Compaction checkpoint** (ship usually follows a long build). Judge from proxies:
   - **Signals (either fires):** context looks large (~**>250K**), **or** it feels fuzzy. Neither → Phase 2.
   - **Action:** emit a copyable `/compact <focus>` block (English), ask the user to run it before continuing.
     Focus **keeps:** ship target (branch + target path if any), base branch, ship mode, finalization phases
     already done, key decisions / open questions. **Drops:** verbose diffs & tool output of committed work.
   - Ship resumes cleanly from Phase 1 after compaction.
6. **Kick off the ship-time cross-check (gated, background) — apply `crosscheck`.**
   Pre-flight `/<tool>:status`: adopt any review already in flight (e.g. after a compaction resume) —
   **never launch a second** — and barrier on any job `/my-build` left running. **De-dup:** if
   `/my-build` already reviewed exactly these commits and nothing has changed the diff, **don't spend
   now** — defer to the Phase 5 barrier, which reviews only what Phases 2–4 change (e2e fixes).
   Otherwise (no-target mode, or the branch was never reviewed) background **one** `/<tool>:review
   --scope branch --base <base>` (`/<tool>:adversarial-review <focus>` if the build was **Risk**-flagged),
   overlapping Phases 2–4; collect it at Phase 5. Neither tool available → skip and say so.

## Phase 2 — End-to-end tests (only if the project has an e2e surface)

Only if the project has an e2e surface — a project e2e skill, a bare e2e suite (make/npm/pytest target), or a
browser-drivable UI (`agent-skills:browser-testing-with-devtools`):

1. **Ask whether to run e2e now.** No → Phase 3.
2. **Route by the surface:**
   - **Project e2e skill** (in the project's `.claude/skills/`) → run it **in the main loop** as it is designed —
     such skills may orchestrate their own subagents and gate mutating steps on user confirmation, so never wrap
     one in a subagent; its own frontmatter pins its model.
   - **Otherwise** → delegate to the `test-worker` subagent (sonnet — mechanical execution, off the main
     context): pass a bare suite command + expected outcome, or the browser scenario list; it returns pass/fail
     + evidence and never edits files.
3. **Each failure:** fix it here in the main loop and cover at the cheapest layer (prefer unit over e2e);
   **target-driven → also write the fix back into the target.** Then prune obsolete e2e cases.

## Phase 3 — Overview (only if an overview skill is available)

1. Judge whether the build made the overview stale.
2. If so, **confirm with the user**, then update it to reflect reality.

## Phase 4 — Docs & ADRs

Is the change **architecturally significant** (new/changed public API, new dependency, altered data flow)?
- **Yes** → `agent-skills:documentation-and-adrs` to identify and complete the doc/ADR updates.
- **No** → quick inline check: did this make any doc stale? Update it if so; else say so and move on. No ADR.

## Phase 5 — Confirm, tidy history & commit

**Barrier first — cross-check (apply `crosscheck`), before touching history.** Collect the
ship review kicked off in Phase 1 (`/<tool>:status` → `/<tool>:result`). If it was deferred there but
Phases 2–4 changed the diff (e2e fixes / new commits), run **one** review now over that changed scope.
Spot-check findings against source (Step 7); **STOP and ask the user which to fix** (never auto-apply);
fold accepted fixes in **now**, so step 5's history-tidy squashes them into their logical commit.
Nothing warranted (de-dup skip, no changes, or neither tool available) → say so and continue.

1. **Any code changed in Phases 2–4 → re-run the full suite** (green before committing).
2. **Mark the target's terminal state — target-driven only, before any PR exists** (write in **English**):
   - Advance `Status:` (carried from `/my-build`'s `Built`) to `Shipped`; add the line if a legacy target lacks it.
   - **No PR link.** A committed spec (`specs/`) must read `Shipped` before the PR opens (PR captures it); never
     backfill a link (a pointless extra commit).
   - A local target (`.claude/specs/` or `.claude/debugs/`) takes the same edit on disk but is **never staged**.

   **No target → skip.**
3. Present everything changed (target if any, tests, overview, docs) for **review**.
4. On confirmation, **commit** the finalization changes (group logically; stage only what you changed;
   descriptive messages). Stage the `Status: Shipped` edit **only if the target is committed (`specs/`)**.
   **Nothing stageable → skip the commit and say so.**
5. **Tidy the branch history — evaluate on every ship, before pushing.** A build lands one commit per task; ship
   adds finalization commits. Fold the *noise* so the PR reads as a clean, linear story:
   - Inspect first: `git log --oneline <base>..HEAD`.
   - **Fold noise into its logical owner**, tidying messages — WIP / fixup / typo / ship micro-commits belong
     squashed into the commit they fix. **Preserve the per-task narrative** — do **not** flatten the whole branch
     into one commit (that destroys the story `/my-build` recorded). Target-driven → also check the target reads
     cleanly.
   - **Propose the rewritten history, wait for confirmation.** On approval, execute non-interactively
     (interactive rebase is unavailable here):
     ```bash
     # single commit, or all fixes belong to the tip:
     git add -A && git commit --amend --no-edit
     # fixes belong to specific earlier commits:
     git commit --fixup=<target-sha> -- <files>
     GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>
     ```
   - Use `git blame <file>` / `git log --oneline -- <file>` to find which commit a fix belongs to.
6. **Ask whether to push the branch and open a PR.** If yes, push and create it.
   - **PR body — learn the upstream template first.** Look (case-insensitive, in order) for
     `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`,
     `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/PULL_REQUEST_TEMPLATE.md`, root `PULL_REQUEST_TEMPLATE.md`.
     - **Found** → adopt its sections/format; fill each. Complex content as **bullets** — concise, forceful.
     - **None** → fall back to the default body below.
   - **Content mapped into the body:** spec → Summary + completed task list; debug artifact → Background + Root
     Cause + completed Fix Plan; no target → derive from the tidied commit log + `base..HEAD` diff.
   - **Already pushed + step 5 rewrote history → force-push (outward-facing, confirm first):**
     `git fetch origin <branch>`, then `git rev-list --left-right --oneline HEAD...FETCH_HEAD` (any `>` lines =
     remote-only commits → STOP and surface). Push with `--force-with-lease` pinned to the fetched SHA — never a
     bare `--force`.
   - Target-driven: the target is already `Shipped`, so nothing to write back afterward.
7. **Refresh the GitNexus knowledge graph** (only if the project uses GitNexus). Invoke `gitnexus-cli` to run
   `analyze --index-only`, syncing the graph to the shipped code (add `--embeddings` **only on the default
   branch**; on a feature branch — where ship normally runs — omit it to preserve the default-branch embeddings,
   which regenerate once the PR merges). Run unconditionally — no permission prompt. `--index-only` is a pure
   index pass: no skill generation, no `CLAUDE.md` / `AGENTS.md` touch.
8. Summarize what shipped and anything left for the user.
