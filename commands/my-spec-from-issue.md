---
description: Start spec-driven development from a GitHub issue — read the issue, then hand off to /my-spec carrying the issue number
argument-hint: [github issue number or URL]
---

# /my-spec-from-issue

Start spec-driven development from a GitHub issue: **$ARGUMENTS**

```
my-spec-from-issue ┐
                   ├─ my-spec → my-plan → my-build → my-ship
(direct ask) ──────┘                        ↑
my-debug ───────────────────────────────────┘   (bug quick-fix lane)
```

The issue-driven entry to the spec family. Its only job: **read the issue, distill it into a requirement, hand
off to `/my-spec`** carrying the issue number. All the real spec work happens in `/my-spec` — don't duplicate its
phases here.

**Language.** Talk to the user in their language; everything written into the spec stays **English** (handled by
`/my-spec`).

## Phase 1 — Resolve & read the issue

Upstream is always **GitHub**.

1. Resolve `owner/repo` from `origin` (`git remote get-url origin`).
2. Parse `$ARGUMENTS` into an issue number — accept: `123`, `#123`, a full URL
   `https://github.com/<owner>/<repo>/issues/123` (also **overrides** owner/repo), or `owner/repo#123`.
3. Read the issue **and its comments** via `mcp__github__issue_read` (title, body, labels, state, discussion).
   No GitHub MCP → fall back to `gh issue view <n> --comments`.
4. **Can't find/read it → stop and report** — don't fabricate requirements from the number alone.

## Phase 2 — Distill into a requirement

Condense the issue (body + substantive comments) into one clear requirement: **what to build/fix and why**, plus
any concrete acceptance hints in the thread. Don't classify feature vs. bug — `/my-spec` Phase 2 judges that.

## Phase 3 — Hand off to /my-spec

Invoke `/my-spec` with the distilled requirement, **carrying the issue number into context** so at its save step
`/my-spec`:
- saves as `<dir>/<issue-number>-<title>.md` (issue-number prefix, not date — `<dir>` per the tracking mode it
  asks for), and
- records the issue link in the spec's Summary / Motivation.

From here the normal `/my-spec` phases run to completion.
