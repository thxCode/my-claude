---
description: Refine a spec's Design Details and fill its Test Plan (KEP format) via task breakdown — writes back the spec only
argument-hint: [spec title or path]
---

# /my-plan

Refine the plan inside a spec: **$ARGUMENTS**

This command **only ever writes back the one spec file** — it makes no other edits. Stay read-only otherwise.

**Language.** Talk to the user in their configured language; write the spec content in **English**.

**Source lookup.** To read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.

**Planning mindset.** Plan deliberately, not in a race:
- See clearly first — read what the requirement says *and* the current code before deciding anything.
- Write down both what you're sure of and what you're not; revisit and adjust as you learn — no one-shot perfect pass.
- Keep the plan legible to both of us. Resolve uncertainty with a test where you can; otherwise ask.
- After each new piece, re-read the earlier parts so the whole stays self-consistent with nothing left out.

## Phase 1 — Resolve the spec

1. Resolve the target spec from `$ARGUMENTS`:
   - A path or full filename → use it as-is.
   - A bare title → match `specs/*-<title>.md` (specs are prefixed with a date or an issue number); also accept
     a legacy `specs/<title>.md`. If several match, list them and ask which.
   - If `$ARGUMENTS` is empty: if `specs/` holds exactly one spec, use it; otherwise list them and ask which.
2. **If the spec file does not exist, stop and hand back to `/my-spec`** to initialize it first (offer to run
   `/my-spec` now). Do not fabricate a spec here.
3. The `Status:` line under the title is a lifecycle trace, **not** a gating signal — judge state from content
   (the spec exists; its Plan/Test placeholders). If `Status:` contradicts the content, trust the content and
   fix the line in passing.

## Phase 2 — Re-ground (read-only)

1. **Stay strictly read-only** — the only write permitted is the final spec write-back in Phase 5.
2. Re-read the spec end-to-end.
3. Re-ground the design in the real codebase: use `gitnexus-exploring` if available, else `search-first`.
   For external libraries/frameworks not in the dependency tree, consult the **DeepWiki MCP**; for a
   JavaScript-rendered doc/site DeepWiki can't reach, fetch it as markdown via `crawl4ai-search`. For a
   **frontend** spec, a screenshot of the current rendered screen (`crawl4ai-search`) is good grounding —
   writing a PNG to the scratchpad keeps this phase read-only on project files.

## Phase 3 — Plan the implementation (Design Details)

Deepen the spec's **Design Details**:

- Sharpen **Commands / Project Structure / Code Style** with concrete specifics grounded in the codebase.
- **Fill the Implementation Plan** subsection (replace its TODO): the dependency graph between components, work
  sliced **vertically** (one complete path per task, not horizontal layers), each task a **`[ ]` checkbox
  line** with **acceptance criteria + verification steps**, ordered so every step leaves the system working,
  with **checkpoints** between phases.
- **Flag risks as you plan.** If a planned item looks risky — **compatibility** (breaking changes, version
  skew, migrations) or **reliability** (data loss, races, failure modes) — **raise it with the user before
  locking it in.** If the user agrees it's a risk, record it in the spec's **Risks and Mitigations** section
  as `Risk → Mitigation`.
- **Reconcile upstream when planning contradicts it.** If grounding the plan reveals a **Goal / Feature / User
  Story** that's infeasible or wrong against the real code, **don't just plan around it** — raise it with the
  user, then fix the upstream statement at its source. Never leave a stale Goal/Feature above the plan that
  contradicts it.

## Phase 4 — Fill the Test Plan (KEP format)

Replace the `Test Plan` placeholder with the KEP-style structure below. **Fill every field with concrete
items or `None` — leave no `<…>` placeholders.**

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
2. **Wait for explicit user confirmation** — this is the one pivotal question of the command.
3. On approval, write the changes back to the spec file, and **set the `Status:` line under the title to
   `Planned`** (add it just under the title if missing). **Modify no other file.**
4. Confirm the saved path. **Consistency check:** read Goals / Features / User Stories against the
   Implementation Plan you just wrote; reconcile any upstream statement the plan now contradicts before
   finalizing. The spec must read cleanly top-to-bottom — clear, logical, self-consistent.
5. **Ask the user whether to run `/my-build` now. Then continue with this spec as its target.
