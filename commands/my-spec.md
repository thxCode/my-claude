---
description: Spec-driven development — gather context, judge intent, then write a KEP-style spec to specs/
argument-hint: [what you want to build or fix]
---

# /my-spec

Start spec-driven development for: **$ARGUMENTS**

```
my-spec-from-issue ┐
                   ├─ my-spec → my-plan → my-build → my-ship
(direct ask) ──────┘                        ↑
my-debug ───────────────────────────────────┘   (bug quick-fix lane)
```

Work the phases **in order** — each gates the next, no skipping ahead. Ask the user only when the judgment is
genuinely pivotal; infer the rest from context.

- **Language.** Talk to the user in their configured language; write every field of the spec in **English**.
- **Source lookup.** Read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.
- **Planning mindset** — deliberate, not a race:
  - See clearly first — read the requirement *and* the current code before deciding.
  - Write down what you're sure of *and* what you're not; revise as you learn (no one-shot perfect pass).
  - Keep the spec legible; when stuck, check related past specs in `specs/` and `.claude/specs/` first; resolve
    uncertainty with a test where you can, else ask.
  - After each new piece, re-read the earlier parts so the whole stays self-consistent.

## Phase 1 — Gather context

Build enough understanding to write a grounded spec (following the Source-lookup order):

- **Project** — an `overview` skill if available; else `README.md`, `CLAUDE.md`, `docs/**/*.md`.
- **Code** — `gitnexus-exploring` if available, else `grep`/`find`. GitNexus returns nothing (index
  missing/stale) → **ask permission**, then `gitnexus-cli` → `analyze --index-only` (`--embeddings` only on the
  default branch; omit on a feature branch to preserve default-branch embeddings), and retry.
- **Broad sweeps** (at the `grep`/`find` tier — GitNexus stays first when available) — multi-file inventories,
  usage surveys, naming-convention scans → delegate to the built-in **Explore** subagent, conclusions only
  (keeps the main context lean); pivotal files you still read yourself.
- **External libs/frameworks** not in the dependency tree — **DeepWiki**; JS-rendered doc DeepWiki can't reach →
  `crawl4ai-search`. Documenting existing UI → a screenshot of the current screen (`crawl4ai-search`) is good
  grounding.

## Phase 2 — Judge intent, then route

Classify `$ARGUMENTS`: a **Feature** (build new / change behavior) or a **Bug fix** (something is broken)?
Infer it; anything not clearly a bug takes the Feature path.

### 2A. Feature path

1. **User stories first.** Ask the user for their stories (Story 1, Story 2, …); offer drafts from `$ARGUMENTS` +
   context to make it easy, but let the user provide/confirm.
2. **Stories too thin → refine** (story portion only, pick one):

   | Skill | When |
   | --- | --- |
   | `agent-skills:interview-me` | underlying intent unclear / not in context (extract it, one question at a time) |
   | `agent-skills:idea-refine` | idea present but vague (sharpen & stress-test) |
   | `auto-research` | motivation depends on external facts (competitive analysis, prior art, sizing) — fold its **research digest** into Motivation + stories' "so that `<benefit>`"; its gaps → Open Questions |

   Stories already concrete → skip refinement.
3. Carry the **finalized user stories** into Phase 3 (they pre-fill area #5 and anchor the rest).

### 2B. Bug-fix path

**For a bug that warrants a versioned, tracked spec.** A **quick, local** fix should use `/my-debug` instead
(lightweight artifact under `.claude/debugs/` → `/my-build`).

1. **Stay strictly read-only** while investigating — no edits until Phase 5.
2. Find the root cause: `gitnexus-debugging` if available, else `agent-skills:debugging-and-error-recovery`.
3. Carry the **root-cause analysis + reproduction** into Phase 3. For a bug, Phase 3 reframes: objective = fix
   the root cause; acceptance = the bug no longer reproduces + a regression guard; user story = the repro scenario.

## Phase 3 — Clarify the five areas

Nail all five before writing — **skip any already answered by Phase 2; don't re-ask.** Rule: spec-before-code —
pin *what* & *why* now, leave *how* to `/my-plan`.

1. **Objective & target users**
2. **Core features & acceptance criteria**
3. **Tech-stack preferences & constraints**
4. **Known boundaries** — what must always be done, what must be asked first, what must never be done
5. **User stories** — carry forward from Phase 2 (bug: the repro scenario); don't re-collect

## Phase 4 — Write the spec

Fill the KEP-style template below — it *is* the coverage checklist; address every section. Leave
**Implementation Plan** and **Test Plan** as placeholders (`/my-plan` completes them); no other leftover
placeholders.

Two metadata lines under the title:
- **`Status:`** — lifecycle trace; initial `Specified`, then `Planned`, next `Building` and `Built`, finally `Shipped`.
- **`Type:`** — the Phase 2 classification (`Feature` / `Bug fix`); `/my-build` reads it to pick the branch prefix.

```markdown
# Spec: <Title>

Status: Specified
Type: <Feature | Bug fix>

## Summary
<One release-note-style paragraph: what we're building/fixing and why.>

## Motivation
### Goals
<Objective, target users, measurable/testable success criteria. For a bug: the root cause and fixed behavior.>
### Non-Goals
<Explicitly out of scope.>

## Proposal
<The desired outcome, no implementation details.>

### User Stories
#### Story 1
As a <user>, I want <capability>, so that <benefit>.
#### Story 2
<…>

### Core Features & Acceptance Criteria
<Each feature with concrete, testable acceptance criteria.>

### Notes / Constraints / Caveats
<Tech-stack preferences and constraints.>

### Boundaries
- **Always:** <…>
- **Ask first:** <…>
- **Never:** <…>

### Risks and Mitigations
<Key risks, each as `Risk → Mitigation`.>

## Design Details
### Commands
<Full executable build / test / lint / dev commands.>
### Project Structure
<Directory layout with short descriptions.>
### Code Style
<One real code snippet + key conventions.>
### Implementation Plan
> TODO — completed by `/my-plan`.
### Test Plan
> TODO — completed by `/my-plan`.

## Alternatives
<Other approaches considered, and why not.>

## Open Questions
<Anything unresolved that needs human input.>
```

## Phase 5 — Save, then offer to plan

1. Derive a short, **hyphen-separated** title (e.g. `user-auth-flow`).
2. **Ask how to track the spec** — this picks its directory:
   - **Commit (default)** → `specs/` — versioned; task check-offs ride `/my-build`'s commits.
   - **Local only** → `.claude/specs/` — on disk, never committed; downstream `/my-*` won't stage it. `.claude/`
     is usually gitignored; if this project doesn't ignore it, suggest adding it.
3. **Filename prefix** so specs sort sensibly:
   - **Issue-initiated** (an issue number is in context, e.g. from `/my-spec-from-issue`) → `<dir>/<issue-number>-<title>.md`;
     also record the issue link in the spec (Summary or Motivation).
   - **Otherwise** → today's date (`date +%Y-%m-%d`) → `<dir>/<yyyy-mm-dd>-<title>.md`.
4. **Present the drafted spec and its filename; wait for confirmation** — your approval to write.
5. Save to `<dir>/<prefix>-<title>.md` (create the dir if missing). **File already exists → don't overwrite
   silently** — ask: overwrite, pick a new title, or switch to `/my-plan` on the existing one. Confirm the path.
6. **Ask whether to run `/my-plan` now.** If yes, continue into `/my-plan` with this spec.
