---
description: Finalize a spec — optional e2e tests (fixes written back), refresh the overview, update docs/ADRs; conforms to project conventions
argument-hint: [spec title or path]
model: sonnet
---

# /my-ship

Finalize and ship the work behind the spec: **$ARGUMENTS**

Tidy up after the build: validate end-to-end, keep the test suite healthy, and bring the project's overview
and docs back in sync. Every change conforms to project conventions (spec **Code Style** & **Boundaries**,
`CLAUDE.md`, existing test/doc structure).

**Language convention.** Keep the channels separate:
- **Talking to the user** (questions, confirmations, review summaries, status) → use the user's configured language.
- **Writing the spec** (e2e fix write-backs, any spec edits) → write the content in **English**.
- **Other artifacts** (tests, overview, docs/ADRs, commit messages, PR body) → follow the project's existing
  conventions.

**Source lookup.** When you need to read or trace existing source code, consult sources in this order:
**GitNexus** (if available) → **DeepWiki** → `grep` / `find`.

## Phase 1 — Resolve the spec

1. Resolve the target spec from `$ARGUMENTS` (a title → `specs/<title>.md`; a path → use it; empty → if
   `specs/` holds one spec use it, else list them and ask which).
2. **If the spec file does not exist, stop and hand back to `/my-spec`** to initialize it (offer to run it now).
3. **Run the full test suite; it must be green before finalizing** — fix failures or surface them.

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

Invoke `agent-skills:documentation-and-adrs`. Identify whether any documentation or architectural decision
records need updating given what was built/changed, and complete the necessary updates.

## Phase 5 — Confirm & commit

1. **If any code changed in Phases 2–4, re-run the full test suite** — it must be green before committing.
2. Present everything that changed (spec, tests, overview, docs) for **review**.
3. On confirmation, **commit** the finalization changes (group logically; stage only what you changed) with
   descriptive messages. **If nothing changed, skip the commit and say so.**
4. **Ask whether to push the branch and open a PR** (use the spec's Summary + completed task list as the PR
   body). If yes, push and create it.
5. Summarize what shipped and anything left for the user.
