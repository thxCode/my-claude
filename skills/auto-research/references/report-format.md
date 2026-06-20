# Report format — Perplexity-style cited research report

Loaded at synthesis (step 6). The report reads like **a research-firm brief from a top industry analyst**: it
tells the reader *what is true*, *why*, *what the competing views are*, and *where the evidence is*. Write it to
`<cwd>/.claude/reports/<title>.md`.

## The binding rule (non-negotiable)

Every inline citation `[n]` maps to a **`verified`** `finding_id` in `findings.jsonl`. **Do not** introduce a
material claim that has no verified finding behind it. If you want to say something you couldn't verify, either
cut it or mark it explicitly as an open question — never assert it with a citation it doesn't have. The citation
list at the foot of the report is built from the verified findings you actually cite, numbered in order of first
appearance.

## Output language (non-negotiable)

Write the entire report in the **user's configured language** (per `CLAUDE.md` / user config — e.g. Chinese):
all prose, headings, the executive bottom-line, tables, the conclusion, and the Related Questions. Keep in their
original form — source titles, URLs, quoted source text, proper nouns, and technical identifiers / code (matching
the user's "technical terms stay in their original form" rule). The skeleton headings below are illustrative
**English**; translate them into the output language.

## Style (five traits)

1. **Structured long-form.** Sections, not a wall of text. Lead with the answer, then the support.
2. **High-density inline citations.** Statistics, named claims, dates, and quotes each carry a `[n]`. Aim for a
   citation on essentially every factual sentence — when in doubt, cite.
3. **Objective & multi-perspective.** On any contested point, present the sides ("According to <org A>… / others
   find…"), competing models, and pros/cons. Attribute; don't editorialize.
4. **Concrete & data-driven.** Prefer specific numbers, dates, and named examples over vague adjectives. Back an
   abstraction with a real case.
5. **Interactive close.** End with **Related Questions** that point to the natural next inquiries.

## Skeleton

```markdown
# <Title>

> **Bottom line:** <2-4 sentence executive answer to the question, with the load-bearing citations [1][2].>

## Background & Context
<Why this question matters now; the minimal context to read the rest. Cited.>

## <Dimension 1 — e.g. Technical principles / How it works>
<Analysis. Each factual claim cited. Use sub-bullets for mechanisms, specs, steps.>

## <Dimension 2 — e.g. Landscape / Market / Players>
<Specific numbers, shares, dates, named entities — all cited.>

## Competing Views & Trade-offs
| Perspective | Position | Evidence |
|-------------|----------|----------|
| <Camp / org A> | <claim> | [n] |
| <Camp / org B> | <counter-claim> | [m] |
<Then prose weighing them — where they agree, where they genuinely diverge, and how strong each side's evidence is.>

## Data & Evidence
<Key figures pulled together: a table or list of the hard numbers with their sources and dates. Note recency and
any methodology caveats.>

## Future Outlook
<Where this is heading, with cited forecasts/roadmaps. Separate well-supported projection from speculation.>

## Conclusion
<The synthesized takeaway. What the evidence best supports, and the residual uncertainty.>

## Coverage & Confidence
<Optional but recommended: overall confidence (high/mixed/low), which dimensions are thin, what was refuted or
left uncertain, and — if the run stopped early on cost — which dimensions were skipped.>

## Related Questions
- <natural follow-up 1>
- <natural follow-up 2>
- <natural follow-up 3>

## Sources
[1] <Title or publisher> — <url>  (accessed <round/date>)
[2] …
```

## Conventions

- **Numbering:** `[n]` in first-appearance order; the same source reused keeps its first number.
- **Multiple sources for one claim:** `[3][7]`.
- **Recency & methodology:** when a number is time-sensitive or contested, say when it's from and how it was
  measured ("as of Q2 2026, per <org> [4]").
- **Single-source claims:** surface the dependency ("a single report [5] claims…") rather than presenting it as
  settled — matches the verification confidence downgrade.
- **No invented precision.** If sources give a range, report the range; don't average into a fake point estimate.

## Worked micro-example

> The model context-window race accelerated sharply in 2025: context limits commonly reached 1M+ tokens across
> frontier vendors [1], though independent testing showed effective recall degrading well before the advertised
> ceiling [2]. Vendors frame the larger window as eliminating retrieval needs [1]; researchers counter that
> retrieval still outperforms raw long-context on multi-hop tasks [3].
>
> **Sources**
> [1] <Vendor release notes> — https://…
> [2] <Independent benchmark> — https://…
> [3] <Paper> — https://…

Note: three claims, three citations, two perspectives explicitly attributed, dependency surfaced — every `[n]`
traces to a verified finding.
