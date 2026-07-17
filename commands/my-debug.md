---
description: Diagnose a bug and plan its fix — root-cause it (codex/kimi adversarial cross-check when complex), then write a debug artifact (Background / PoC / Fix Plan / Test Plan) to .claude/debugs/; hands off to /my-build
argument-hint: [bug description, error, or repro] [--assist codex|kimi]
---

# /my-debug

Diagnose and plan a fix for: **$ARGUMENTS**

```
my-spec-from-issue ┐
                   ├─ my-spec → my-plan → my-build → my-ship
(direct ask) ──────┘                        ↑
my-debug ───────────────────────────────────┘   (bug quick-fix lane)
```

Like `/my-plan`, this command **only writes one artifact** — a debug doc under `.claude/debugs/` — then hands to
`/my-build`. Stay read-only otherwise (only Phase 5 writes).

**Lane vs `/my-spec`.** `/my-debug` is the **lightweight, local** bug lane (throwaway artifact → build). A bug
that deserves a **versioned, tracked** spec goes through `/my-spec`'s Bug-fix path instead.

- **Language.** Talk to the user in their configured language; write the artifact in **English**.
- **Source lookup.** Read/trace source: **GitNexus** (if available) → **DeepWiki** → `grep`/`find`.
- **Memory.** Capture durable, non-obvious learnings (project constraints, user habits); don't duplicate the
  repo / `CLAUDE.md`; retire what this work supersedes.

## Artifact — `.claude/debugs/<yyyy-mm-dd>-<title>.md`

Always **local**, never staged. `Status:` lifecycle `Diagnosed → Building → Built → Shipped` (this command sets
`Diagnosed`; `/my-build` and `/my-ship` advance it). Branch (in `/my-build`): always **`fix/<title>`**.

```markdown
# Debug: <Title>

Status: Diagnosed
Type: Bug fix

## Background
<Symptom, error text, environment, affected code/paths. The "what & where".>

## Reproduction / PoC
<The failing test or repro script that proves the bug — the concrete trigger.>

## Root Cause
<The confirmed underlying cause (not the symptom). If a cross-check ran, record which toolchain and its verdict.>

## Fix Plan
<Ordered `[ ]` tasks, vertically sliced, each with acceptance criteria + verification steps.
This IS /my-build's task list.>

## Test Plan
<Regression guard (fails without the fix, passes with it) + verification steps.>
```

## Phase 1 — Frame the bug (read-only)

- Collect the symptom / error / repro hints from `$ARGUMENTS` and context.
- Make **no edits** until Phase 5.
- **Kick off the adversarial diagnosis early (gated, background) — apply `crosscheck`.** If the
  framing already shows complexity (multi-component, intermittent, high-risk, or an obviously
  non-obvious cause), background a **read-only** rescue subagent (`codex:codex-rescue` or
  `kimi:kimi-rescue`, per the selected toolchain) for an independent root-cause diagnosis **seeded
  from the symptom + reproduction only** — never your hypothesis, so it stays an independent second
  voice. It runs while you investigate in Phase 2; collect it in Phase 3.
  Borderline / looks simple → don't spend yet, decide in Phase 3.

## Phase 2 — Find the root cause

| Available | Use |
| --- | --- |
| `gitnexus-debugging` | invoke it first |
| otherwise | `agent-skills:debugging-and-error-recovery` |

**Reproduce reliably first, then localize.** Fix the underlying cause, not where it manifests. (Same routing as
`/my-spec`'s Bug-fix path.)

## Phase 3 — Adversarial cross-check (complexity-gated)

- **Trigger:** the bug is **complex** — multi-component, intermittent, non-obvious root cause, or high-risk.
- **Barrier & reconcile — apply `crosscheck`.** Collect the diagnosis kicked off in Phase 1
  (`/<tool>:status` → `/<tool>:result`). If none was launched but Phase 2 revealed complexity, run one
  now (the rescue subagent — `codex:codex-rescue` or `kimi:kimi-rescue` — read-only, seeded from
  symptom + repro). Reconcile its verdict against yours per the skill (Step 7): lock the Root Cause
  only once you agree or can explain the divergence; surface any unresolved disagreement to the user.
  **Record its verdict in the artifact's Root Cause.**
- **Simple bug / neither tool available:** skip and note it.

## Phase 4 — Write the artifact

- **Background / PoC / Root Cause** from Phases 1–3.
- **Fix Plan** — ordered `[ ]` tasks, sliced **vertically** (one complete path per task), each carrying
  acceptance criteria + verification steps; order so every step leaves the system working.
- **Pin the build/test environment** — **local or remote** (if remote, its access method); **confirm with the
  user** (it decides how every command runs). A read-only smoke check is fine (write nothing to the tree).
- **Test Plan** — a regression guard that fails without the fix and passes with it, plus verification steps.

## Phase 5 — Present, confirm, write

1. Present the drafted artifact for **human review**.
2. **Wait for explicit confirmation** — the one pivotal question of this command.
3. Write `.claude/debugs/<yyyy-mm-dd>-<title>.md` (`date +%Y-%m-%d`; create the dir; **never stage it**). Confirm
   the saved path.
4. **Offer the next step** (user may decline both):
   - **Compact, then build** — emit one copyable block (in English): `/compact <focus>`, then `/model opus`
     (build's executor — `/model sonnet` when the fix is small and well-patterned), then `/my-build <title>`.
     Switching right after compaction keeps the model-switch re-read minimal (prompt caches are per-model).
     Focus **keeps:** artifact path, Fix Plan (tasks + acceptance) + Test Plan, reusable codebase landings
     (paths), the Root Cause, next step `/my-build <title>`; **drops:** verbose debugging transcripts.
   - **Build now** — continue into `/my-build` with this artifact as its target, keeping the current model.
