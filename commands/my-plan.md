---
description: Refine a spec's Design Details and fill its Test Plan (KEP format) via task breakdown — writes back the spec only
argument-hint: [spec title or path] [--assist codex|kimi]
---

# /my-plan

Refine the plan inside a spec: **$ARGUMENTS**

```
my-spec-from-issue ┐
                   ├─ my-spec → my-plan → my-build → my-ship
(direct ask) ──────┘                        ↑
my-debug ───────────────────────────────────┘   (bug quick-fix lane)
```

This command **only ever writes back the one spec file** — no other edits. Stay read-only otherwise.

- **Language.** Talk to the user in their configured language; write the spec in **English**.
- **Source lookup.** Read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.
- **Memory.** Capture durable, non-obvious learnings (project constraints, user habits); don't duplicate the
  spec / `CLAUDE.md` / repo; retire what this work supersedes.
- **Planning mindset** — deliberate, not a race:
  - See clearly first — read the requirement *and* the current code before deciding.
  - Write down what you're sure of *and* what you're not; revise as you learn (no one-shot perfect pass).
  - Keep the plan legible; when stuck or backtracking, check related past specs in `specs/` and `.claude/specs/`
    first; resolve uncertainty with a test where you can, else ask.
  - After each new piece, re-read the earlier parts so the whole stays self-consistent.

## Phase 1 — Resolve the spec

1. Resolve from `$ARGUMENTS` (`specs/` committed or `.claude/specs/` local — search both):
   - path / full filename → as-is.
   - bare title → match `{specs,.claude/specs}/*-<title>.md` (date/issue prefix); also legacy `<dir>/<title>.md`.
     Several → list and ask.
   - empty → exactly one spec across the two dirs → use it; else list and ask.
2. **Missing file → stop and hand back to `/my-spec`** to initialize it first (offer to run it now). Don't
   fabricate a spec here.
3. `Status:` is a lifecycle trace, **not** a gate — judge state from content (spec exists; its Plan/Test
   placeholders). If it contradicts content, trust content and fix the line in passing.

## Phase 2 — Re-ground (read-only)

1. **Strictly read-only** — the only write is the Phase 5 write-back.
2. Re-read the spec end-to-end.
3. Re-ground the design in the real codebase: `gitnexus-exploring` if available, else `grep`/`find`. External
   libs/frameworks not in the dependency tree → **DeepWiki**; a JS-rendered doc DeepWiki can't reach →
   `crawl4ai-search`. **Frontend** spec → a screenshot of the current rendered screen (`crawl4ai-search`, PNG to
   the scratchpad) keeps this phase read-only on project files. Broad sweeps (at the `grep`/`find` tier) —
   multi-file inventories, usage surveys, naming-convention scans → delegate to the built-in **Explore**
   subagent, conclusions only (keeps the main context lean); pivotal files you still read yourself.
4. **Learn the build/package system** — `Makefile` / build scripts, `package.json` scripts, CI config, any
   **overview** / **development** docs: exactly how it builds, tests, lints, packages. This grounds **Commands**
   in Phase 3 (what the project actually uses, not guesses). Reading only.
5. **Kick off a design cross-check (gated, background) — apply `crosscheck`.** As early as
   item 2 lets you, if the gate authorizes (novel / high-stakes / Risk-flagged design), background a
   **read-only** rescue subagent (`codex:codex-rescue` or `kimi:kimi-rescue`, per the selected
   toolchain) seeded from the spec's **existing Proposal / Goals / Design Details** (the raw design
   intent, *not* your refinements) to red-team the approach and surface design risks + test scenarios.
   It runs while you re-ground (items 3–4) and draft Phase 3 — an independent second voice, one turn,
   no wait. Gate skips (or neither tool available) → note it and move on. Collect it at Phase 4.

## Phase 3 — Plan the implementation (Design Details)

Deepen the spec's **Design Details**:

- Sharpen **Commands / Project Structure / Code Style** with concrete specifics grounded in the codebase and the
  build system from Phase 2. In **Commands**, also pin the build/test **environment** — **local or remote** (if
  remote, the access method: host / SSH / kubectl context / container) — and **confirm it with the user**
  (pivotal: it decides how every command runs). A **read-only smoke check** (invoke build/test once to confirm
  the environment is reachable) is fine — write no code, keep artifacts out of the tree.
- **Fill the Implementation Plan** (replace its TODO) with:
  - the dependency graph between components;
  - work sliced **vertically** — one complete path per task, not horizontal layers;
  - each task a **`[ ]` checkbox line** carrying **acceptance criteria + verification steps**;
  - an order where every step leaves the system working, with **checkpoints** between phases.
- **Flag risks as you plan** — **compatibility** (breaking changes, version skew, migrations) or **reliability**
  (data loss, races, failure modes). **Raise with the user before locking in**; if agreed, record in **Risks and
  Mitigations** as `Risk → Mitigation`.
- **De-risk the hard parts first (PoC).** For key/difficult items (uncertain feasibility, or Risk-flagged),
  confirm the environment (see Commands), then **order a small PoC / spike as the first task(s)**. Validating the
  riskiest assumptions early keeps the spec from churning late (→ small `/my-ship` history fold). `/my-build`
  runs these first.
- **Reconcile upstream when planning contradicts it.** A **Goal / Feature / User Story** infeasible or wrong
  against the real code → don't plan around it; raise it, then fix the upstream statement at its source. Never
  leave a stale Goal/Feature above the plan.

## Phase 4 — Fill the Test Plan (KEP format)

**Barrier first — collect the design cross-check (if one was kicked off in Phase 2).** Per
`crosscheck` (Steps 5/7): `/<tool>:status` → `/<tool>:result`; fold the tool's design-risk findings
into **Design Details / Risks** (Phase 3) and its test-scenario suggestions into the Test Plan below.
Lock the plan only once reconciled; surface any unresolved disagreement to the user. Never
auto-apply — present and ask.

Replace the `Test Plan` placeholder with the structure below. **Fill every field with concrete items or
`None` — leave no `<…>` placeholders.**

```markdown
### Test Plan
[ ] I/we understand the owners of the involved components may require updates to existing tests to make this
code solid enough prior to committing the changes necessary to implement this enhancement.

#### Prerequisite testing updates
<Any base test work required before implementation.>

#### Unit tests
<Every added unit of code should have unit-test coverage. Per-package targets:>
- `<package>`: `<date>` - `<coverage %>`

#### Integration tests
<Integration scenarios; add concrete test names after the implementation PR merges.>

#### e2e tests
<End-to-end scenarios, or a justification for why e2e isn't needed.>
```

## Phase 5 — Review & write back

1. Present the proposed spec changes (enriched Design Details + filled Test Plan) for **human review**.
2. **Wait for explicit confirmation** — the one pivotal question of this command.
3. On approval, write the changes back and **set `Status:` to `Planned`** (add it under the title if missing).
   **Modify no other file.**
4. Confirm the saved path. **Consistency check:** read Goals / Features / User Stories against the Implementation
   Plan you just wrote; reconcile any upstream statement the plan now contradicts. The spec must read cleanly
   top-to-bottom — clear, logical, self-consistent.
5. **Offer the next step** (user may decline both and stop):
   - **Compact, then build** — context heavy / want a clean slate. Emit one copyable block (English):
     `/compact <focus>`, then `/model opus` (build's executor — suggest `/model sonnet` instead when the plan is
     fully specified and low-risk), then `/my-build <title>`. Switching right after compaction keeps the
     model-switch re-read minimal (prompt caches are per-model). Focus **keeps:** target spec path, finalized
     Implementation Plan (tasks + acceptance) + Test Plan, reusable codebase landings (files / functions /
     patterns with paths), flagged Risks → Mitigations, next step `/my-build <title>`; **drops:** verbose
     exploration / grep transcripts and superseded drafts. `/my-build` re-resolves the spec from disk, so it
     resumes cleanly after compaction.
   - **Build now** — continue straight into `/my-build` with this spec, keeping the current model (switching
     without compacting re-reads the full context — only suggest it if the user asks).
