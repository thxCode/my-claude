---
description: Refine a spec's Design Details and fill its Test Plan (KEP format) via task breakdown — writes back the spec only
argument-hint: [spec title or path]
model: opus
---

# /my-plan

Refine the plan inside a spec: **$ARGUMENTS**

This command **only ever writes back the one spec file** — it makes no other edits. Stay read-only otherwise.

**Language convention.** Two distinct channels — keep them separate:
- **Talking to the user** (questions, confirmations, review summaries, status) → use the user's configured language.
- **Writing the spec** (the enriched Design Details and filled Test Plan written back to the spec) → write the
  content in **English**, regardless of the conversation language.

## Phase 1 — Resolve the spec

1. Resolve the target spec from `$ARGUMENTS`:
   - A title → `specs/<title>.md`; a path → use it as-is.
   - If `$ARGUMENTS` is empty: if `specs/` holds exactly one spec, use it; otherwise list them and ask which.
2. **If the spec file does not exist, stop and hand back to `/my-spec`** to initialize it first (offer to run
   `/my-spec` now). Do not fabricate a spec here.

## Phase 2 — Re-ground (read-only)

1. **Stay strictly read-only** — the only write permitted is the final spec write-back in Phase 5.
2. Re-read the spec end-to-end.
3. Re-ground the design in the real codebase: use `gitnexus-exploring` if available, else `search-first`.
   For external libraries/frameworks not in the dependency tree, consult the **DeepWiki MCP**.

## Phase 3 — Plan the implementation (Design Details)

Invoke `agent-skills:planning-and-task-breakdown`. Then deepen the spec's **Design Details**:

- Sharpen **Commands / Project Structure / Code Style** with concrete specifics grounded in the codebase.
- **Fill the Implementation Plan** subsection (replace its TODO): the dependency graph between components, work
  sliced **vertically** (one complete path per task, not horizontal layers), each task a **`[ ]` checkbox
  line** with **acceptance criteria + verification steps**, ordered so every step leaves the system working,
  with **checkpoints** between phases.
- **Flag risks as you plan.** If a planned item looks risky — **compatibility** (breaking changes, version
  skew, migrations) or **reliability** (data loss, races, failure modes) — **raise it with the user before
  locking it in.** If the user agrees it's a risk, record it in the spec's **Risks and Mitigations** section
  as `Risk → Mitigation`.

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
3. On approval, write the changes back to the spec file. **Modify no other file.**
4. Confirm the saved path. Ensure the final spec reads cleanly top-to-bottom — clear, logical, self-consistent.
5. **Ask the user whether to run `/my-build` now.** If yes, remind them `/my-build` runs on **sonnet** — for a
   full multi-turn build session, run `/model sonnet` first — then continue with this spec as its target.
