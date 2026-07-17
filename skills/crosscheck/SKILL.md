---
name: crosscheck
description: >-
  Decision procedure for spending a second-opinion toolchain — Codex (GPT-5.x) or Kimi (K2/K3) —
  anywhere in a session: the my-* command family (/my-plan, /my-debug, /my-build, /my-ship) is the
  primary consumer, and ad-hoc use outside it is governed too. Consult BEFORE any Codex/Kimi use.
  Decides whether the change/plan/bug is complex enough to spend scarce quota, which
  toolchain to use (codex vs kimi), which vehicle (`<tool>-rescue` read-only vs /<tool>:review vs
  /<tool>:adversarial-review), background-vs-wait, how to sequence around the serializing broker, how
  to reconcile the tool's verdict against Claude's, the never-auto-fix rule, and graceful skip when
  neither tool is available.
user-invocable: false
---

# Cross-check gate

A second-opinion toolchain — **Codex** (GPT-5.x) or **Kimi** (K2/K3) — is a **scarce, independent
second voice** to Claude (Opus), not a linter you run everywhere. Each toolchain has its **own**
per-session broker that **serializes** every one of its turns: concurrent calls to the *same* tool
either fail with `BROKER_BUSY` or *silently* degrade to a standalone app-server against the **same**
account quota. So there is no speedup from parallelism, and every turn spends real usage limits.

**Bind exactly one toolchain per command invocation** (`<T>`); the broker/sequencing discipline below
applies to `<T>`'s own broker.

**Default to SKIP.** Spend a turn only to buy *adversarial diversity* at the point of highest
uncertainty. The payoff is disagreement caught, not volume of review.

Run these steps in order. Reach for this whenever a `my-*` command hits a "cross-check" point — and
before any ad-hoc Codex/Kimi use outside them.

**Ad-hoc use (outside my-* commands) — same discipline.** A user explicitly naming the tool ("ask codex", "ask kimi") counts as an explicit choice: Step 1's gate is passed and Step 1.5 binds that tool.
Steps 3 (read-only framing), 5 (broker pre-flight, one job in flight) and 8 (never auto-fix) still
apply in full.

## Step 0 — Availability (probe once per session)

The first time you reach any cross-check point, probe **both** `codex:setup` **and** `kimi:setup`, and
remember each result for the rest of the session. If **neither** is available/authenticated → **skip
every cross-check**, state plainly ("Codex/Kimi unavailable; proceeding Claude-only"), never block the
command, never improvise an auth flow. Point the user at `/codex:setup` / `/kimi:setup` if they want it.

## Step 1 — Gate: is this worth a cross-check turn?

Spend **only if ≥1 trigger fires**:

- Cross-component blast radius — touches exported/shared symbols, or spans multiple packages/modules.
- Novel or non-obvious design — no established in-repo pattern to copy.
- High-stakes domain — concurrency/races, data migration or loss, auth/security, money/billing, or a
  public API contract.
- Explicitly **Risk-flagged** in the spec/debug artifact.
- (debug) Root cause is non-obvious, intermittent, or multi-component.
- Low Claude confidence, or Claude's conclusion conflicts with the artifact.

Otherwise **SKIP** and say "cross-check skipped: low complexity" (single-file, local, well-patterned,
reversible, low-stakes).

**Hard ceilings (cost governance — never violate):**

- At most **one** cross-check turn per command invocation per stage. **Never per task**, with **one
  exception:** `/my-build`'s per-task heavy **defect review** (the reviewer that replaced OCR) may run
  one `/<T>:review` per heavy task — a reviewer pass, not an adversarial cross-check. Everywhere else,
  one turn per stage. Never launch concurrent turns.
- **De-dup across the workflow:** if a cross-check already ran over this same diff/design and nothing
  material changed since, SKIP.

## Step 1.5 — Select the toolchain (only once the gate has fired)

Reached **only** after Step 1 decides a turn is warranted — so a task that will be skipped never
prompts the user. Resolve `<T>` by priority:

1. **Explicit choice this invocation** — an `--assist codex|kimi` token, or natural language ("用 kimi
   交叉检查", "cross-check with codex"). Honor it. Named tool unavailable (Step 0) → say so and fall
   back to the other available tool; neither available → skip.
2. **Cached session choice** — if the user already chose earlier this session, reuse it, don't ask.
3. **Exactly one available** — use it silently.
4. **Both available, none of the above** — **AskUserQuestion once** (codex / kimi), then **cache the
   answer for the rest of the session** (alongside the Step 0 availability result). Don't ask again.

Bind `<T>`. Every vehicle and support skill below uses `<T>`'s counterpart.

## Step 2 — Vehicle

| Situation | Vehicle | Notes |
| --- | --- | --- |
| Critique a design/approach with **no git diff yet** (my-plan) | `<T>`-rescue (`codex:codex-rescue` / `kimi:kimi-rescue`) | read-only; focus = the design text |
| Independent root-cause diagnosis, change not yet made (my-debug) | `<T>`-rescue | read-only diagnosis |
| One bounded factual question mid-build (my-build 3.5) | `<T>`-rescue | read-only, foreground, tightly scoped |
| Defect review over a **real diff** (my-build per-task heavy + end, my-ship) | `/<T>:review` | native reviewer; **no focus text** |
| Challenge the **approach** over a real diff | `/<T>:adversarial-review` | accepts focus text |

`/<T>:review` and `/<T>:adversarial-review` **both need a git diff** — never use them before code
exists (that is why my-plan uses `<T>`-rescue, not adversarial-review).

**Vendor differences (know these when composing the call):**

- **Model control flags differ — use the selected tool's own.** codex: `--effort <none..xhigh>` +
  `--model` (alias `spark` → gpt-5.3-codex-spark). kimi: `--thinking <on|off>` + `--model` (alias
  `highspeed` → kimi-code/kimi-for-coding-highspeed). There is no shared flag; `--effort`'s scale has
  no kimi analog.
- `/codex:review` delegates to the Codex CLI's **native** reviewer; `/kimi:review` runs off the
  plugin's own editable `prompts/review.md`. Invocation surface and the review-only constraint are
  identical; the character of the findings can differ.

## Step 3 — Read-only vs write

A cross-check is **always read-only**. `<T>`-rescue defaults to `--write`; frame the request as
**review / diagnosis / research** so it stays read-only (no `--write`). **Claude owns every edit** —
single ownership, no surprise changes. (A user explicitly saying "hand this task to Codex/Kimi to
fix" is a separate write-capable delegation, not a cross-check.)

## Step 4 — Background vs wait

- **WAIT** (foreground) only when the result blocks the next decision **and** is small/bounded (one
  question, a tiny diff).
- **BACKGROUND** otherwise: kick the one turn off, do independent foreground work meanwhile (Claude's
  own review/investigation, or a non-`<T>` subagent like Explore / `agent-skills:review` /
  `gitnexus-*`), then collect at the barrier via `/<T>:status` + `/<T>:result`. Same single turn —
  background only overlaps latency, it adds no spend.

## Step 5 — Sequencing (avoid the silent BROKER_BUSY)

The collision failure mode is **silent** (degrades to a slower, costlier standalone server), so
discipline matters more than error handling:

- Before any kickoff, run `/<T>:status` to confirm **no `<T>` job is in flight**. If one is (typically
  left over at a command boundary), **barrier on it first** (`/<T>:status <id>` / `/<T>:result`)
  before launching.
- **One `<T>` job in flight per session** — never fan out a second "for speed".
- **Collect before handing off.** An upstream `my-*` command must finish and collect its cross-check
  job before offering the next command, so the downstream starts with a free broker.

## Step 6 — Seed it as an independent voice

Give `<T>` the **raw** problem — symptom + reproduction, the frozen diff, or the pre-existing
design/spec text — **not** Claude's finished hypothesis or plan. An echo of Claude's conclusion is
wasted quota; independence is the whole point. Compose the prompt per the selected tool's conventions
(codex → `codex:gpt-5-4-prompting`; kimi → `kimi:k3-prompting`) — operator-style, XML blocks; add
`grounding_rules` for review/diagnosis.

## Step 7 — Reconcile (the diversity payoff)

- Preserve `<T>`'s verdict, severity ordering, and evidence boundaries verbatim (defer to the tool's
  result-handling — codex → `codex:codex-result-handling`; kimi → `kimi:kimi-result-handling`: keep
  inference-vs-fact distinctions, exact `file:line`).
- Compare `<T>`'s conclusion to Claude's. **Agree → proceed.** **Disagree → Claude investigates only
  the specific divergence** (no new cross-check turn), forms a reconciled verdict, and **surfaces the
  disagreement to the user** rather than silently picking a side. Lock the design/root-cause only once
  reconciled or the divergence is explainable — a disagreement is signal, it is why the turn was spent.
- For a large (branch-sized) review, spot-check each finding against the real source with Read/Grep
  and drop stale / false positives before acting.

## Step 8 — Never auto-fix

After any review or critique, **STOP**. Never auto-apply the second-opinion tool's suggested fixes.
Present findings by severity, **ask the user which to fix**, then Claude implements the chosen fixes
itself. If `<T>` was never successfully invoked or returned malformed output, report that and stop —
do not fabricate a Claude-side substitute. (Defers to the tool's result-handling.)
