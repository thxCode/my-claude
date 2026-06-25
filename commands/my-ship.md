---
description: Finalize a spec — optional e2e tests (fixes written back), refresh the overview, update docs/ADRs; conforms to project conventions
argument-hint: [spec title or path]
---

# /my-ship

Finalize and ship the work behind the spec: **$ARGUMENTS**

Tidy up after the build: validate end-to-end, keep the test suite healthy, and bring the project's overview
and docs back in sync. Every change conforms to project conventions (spec **Code Style** & **Boundaries**,
`CLAUDE.md`, existing test/doc structure).

**Language.** Talk to the user in their configured language; write spec edits (e2e fix write-backs) in
**English**; for other artifacts (tests, overview, docs/ADRs, commits, PR body) follow the project's conventions.

**Source lookup.** To read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.

## Phase 1 — Resolve the spec

1. Resolve the target spec from `$ARGUMENTS` (a path/full filename → use as-is; a bare title → match
   `specs/*-<title>.md`, the prefix being a date or issue number, or a legacy `specs/<title>.md`, asking which if
   several match; empty → if `specs/` holds one spec use it, else list them and ask which).
2. **If the spec file does not exist, stop and hand back to `/my-spec`** to initialize it (offer to run it now).
3. **Run the full test suite; it must be green before finalizing** — fix failures or surface them.
4. **Consistency scan (read-only).** Read Goals / Features / User Stories against the completed Implementation
   Plan; flag any task whose built outcome contradicts an upstream statement. Surface conflicts and, on
   confirmation, reconcile the upstream text — modifying only the spec — before finalizing.

## Phase 2 — End-to-end tests (only if an e2e skill is available)

Run only if the project has an e2e-testing skill (e.g. `agent-skills:browser-testing-with-devtools`):

1. **Ask the user whether to run the e2e tests now.** If no, skip to Phase 3.
2. Run the e2e tests through that skill.
3. **For each failure:** fix it, write the fix back into the spec, and cover it at the cheapest layer (prefer
   unit over e2e). Then prune obsolete e2e cases.

## Phase 3 — Overview (only if an overview skill is available)

Run only if the project has an overview-related skill:

1. Judge whether the build changed enough that the overview is now stale.
2. If so, **confirm with the user**, then update the overview so it reflects reality.

## Phase 4 — Docs & ADRs

First judge whether the change is **architecturally significant** — new/changed public API, a new dependency, or
an altered data flow:
- **Significant** → invoke `agent-skills:documentation-and-adrs` to identify and complete the needed doc/ADR updates.
- **Otherwise** → do a quick inline check: did this change make any existing doc stale? If so, update it; if not,
  say so and move on. No ADR needed.

## Phase 5 — Confirm & commit

1. **If any code changed in Phases 2–4, re-run the full test suite** — it must be green before committing.
2. Present everything that changed (spec, tests, overview, docs) for **review**.
3. On confirmation, **commit** the finalization changes (group logically; stage only what you changed) with
   descriptive messages. **If nothing changed, skip the commit and say so.**
4. **Ask whether to push the branch and open a PR** (use the spec's Summary + completed task list as the PR
   body). If yes, push and create it.
5. **Mark the spec's terminal state.** Update the `Status:` line just under the spec's title (carried forward
   from `/my-build`'s `Built`) to `Status: Shipped` plus the PR link if one was opened — `Status: Shipped — <PR link>`.
   Add the line if a legacy spec lacks it. This leaves the spec carrying its own lifecycle trace. Write this back
   in **English**, modifying only the spec file.
6. **Refresh the GitNexus knowledge graph** (only if the project uses GitNexus). Invoke the `gitnexus-cli` skill to
   run `analyze --index-only --embeddings`, bringing the graph in sync with the shipped code. Run it
   unconditionally — no permission prompt. `--index-only` keeps this a pure index pass: it does **not** generate
   skills and does **not** touch `CLAUDE.md` / `AGENTS.md`.
7. Summarize what shipped and anything left for the user.
