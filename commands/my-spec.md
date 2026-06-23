---
description: Spec-driven development — gather context, judge intent, then write a KEP-style spec to specs/
argument-hint: [what you want to build or fix]
model: opus
---

# /my-spec

Start spec-driven development for: **$ARGUMENTS**

Work through the phases below in order. Each phase gates the next — do not skip ahead.
Ask the user only when the judgment is genuinely pivotal; infer the rest from context.

**Language.** Talk to the user in their configured language; write every field of the spec in **English**.

**Source lookup.** To read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.

**Planning mindset.** Plan deliberately, not in a race:
- See clearly first — read what the requirement says *and* the current code before deciding anything.
- Write down both what you're sure of and what you're not; revisit and adjust as you learn — no one-shot perfect pass.
- Keep the spec legible to both of us. Resolve uncertainty with a test where you can; otherwise ask.
- After each new piece, re-read the earlier parts so the whole stays self-consistent with nothing left out.

## Phase 1 — Gather context

Build enough understanding to write a grounded spec, following the **Source lookup** order above:

- **Project** — invoke an `overview` skill if available; else read `README.md`, `CLAUDE.md`, `docs/**/*.md`.
- **Code** — explore via `gitnexus-exploring` if available, else `search-first`. If GitNexus returns nothing
  (index missing/stale), **ask permission**, run `gitnexus analyze --index-only --embeddings`, then retry.
- **External libs/frameworks** not in the dependency tree — consult **DeepWiki**.

## Phase 2 — Judge intent, then route

Classify `$ARGUMENTS` against the context: a **Feature** (build something new / change behavior) or a **Bug
fix** (something is broken)? Infer it; anything that isn't a clear bug takes the Feature path.

### 2A. Feature path

1. **Get the user stories first.** Ask the user for their user stories (Story 1, Story 2, …). Offer drafts
   derived from `$ARGUMENTS` + context to make it easy, but let the user provide/confirm them.
2. **If the stories are too thin, refine them** — for the story portion only, pick one skill:
   - `agent-skills:interview-me` — when the underlying intent isn't clear yet / not in context (extract what
     the user actually wants, one question at a time).
   - `agent-skills:idea-refine` — when the idea is present but vague (sharpen and stress-test it).
   - `auto-research` — when the motivation depends on external facts the user can't supply from memory
     (competitive analysis, prior art, market/landscape sizing). Invoke it, then fold its returned **research
     digest** into Motivation and the stories' "so that `<benefit>`" clauses; its coverage gaps become Open
     Questions.
   - If the stories are already concrete, skip refinement.
3. Carry the **finalized user stories** into Phase 3 (they pre-fill clarifying area #5 and anchor the rest).

### 2B. Bug-fix path

1. **Stay strictly read-only** while investigating — make no edits until Phase 5.
2. Find the root cause:
   - If the `gitnexus-debugging` skill is available, invoke it.
   - Otherwise, invoke `agent-skills:debugging-and-error-recovery`.
3. Carry the **root-cause analysis + reproduction** into Phase 3. For a bug, Phase 3 reframes: objective = fix
   the root cause; acceptance = the bug no longer reproduces + a regression guard; user story = the repro
   scenario.

## Phase 3 — Clarify the five areas

Nail down all five before writing — **skip any already answered by Phase 2; don't re-ask**. The rule is
spec-before-code: pin down *what* and *why* now, leave *how* to `/my-plan`.

1. **Objective & target users**
2. **Core features & acceptance criteria**
3. **Tech-stack preferences & constraints**
4. **Known boundaries** — what must always be done, what must be asked first, what must never be done
5. **User stories** — carry forward from Phase 2 (bug: the repro scenario); don't re-collect

## Phase 4 — Write the spec

Fill in the KEP-style template below — it *is* the coverage checklist; every section must be addressed.
Leave **Implementation Plan** and **Test Plan** as placeholders; `/my-plan` completes them. No leftover
placeholders except those two TODOs.

```markdown
# Spec: <Title>

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

1. Derive a short, **hyphen-separated** title from the spec (e.g. `user-auth-flow`).
2. **Present the drafted spec and its title; wait for confirmation** — this is your approval to write.
3. Save to `specs/<title>.md` (create the `specs/` directory if it doesn't exist). **If a spec with that title
   already exists, don't overwrite silently** — ask the user: overwrite, pick a new title, or switch to
   `/my-plan` on the existing one. Confirm the saved path.
4. **Ask the user whether to run `/my-plan` now.** If yes, continue into `/my-plan` with this spec as its target.
