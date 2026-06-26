---
description: Start spec-driven development from a GitHub issue — read the issue, then hand off to /my-spec carrying the issue number
argument-hint: [github issue number or URL]
---

# /my-spec-from-issue

Start spec-driven development from a GitHub issue: **$ARGUMENTS**

This is the issue-driven entry to the spec family (`/my-spec` → `/my-plan` → `/my-build` → `/my-ship`). Its only
job is to **read the issue, distill it into a requirement, and hand off to `/my-spec`** carrying the issue number —
all the real spec work happens in `/my-spec`. Don't duplicate its phases here.

**Language.** Talk to the user in their configured language; everything written into the spec stays **English**
(handled by `/my-spec`).

## Phase 1 — Resolve & read the issue

The upstream repo is always **GitHub**.

1. Resolve `owner/repo` from the current repo's `origin` remote (`git remote get-url origin`).
2. Parse `$ARGUMENTS` into an issue number. Accept any of:
   - a bare number — `123`
   - `#123`
   - a full URL — `https://github.com/<owner>/<repo>/issues/123` (the URL also **overrides** owner/repo)
   - `owner/repo#123`
3. Read the issue **and its comments** via `mcp__github__issue_read` (capture title, body, labels, state, and the
   discussion). If the GitHub MCP isn't available, fall back to `gh issue view <n> --comments`.
4. **If the issue can't be found or read, stop and report it** — don't fabricate requirements from the number alone.

## Phase 2 — Distill into a requirement

Condense the issue (body + the substantive comments) into one clear requirement statement: **what to build/fix and
why**, plus any concrete acceptance hints surfaced in the thread. Don't classify feature vs. bug here — `/my-spec`
Phase 2 judges that itself.

## Phase 3 — Hand off to /my-spec

Invoke `/my-spec` with the distilled requirement as its arguments, and **carry the issue number into context** so
that, at its save step, `/my-spec`:
- saves the spec as `<dir>/<issue-number>-<title>.md` (issue-number prefix, not the date — `<dir>` is `specs/`
  or `.claude/specs/`, per the tracking mode `/my-spec` asks for at its save step), and
- records the issue link in the spec's Summary/Motivation.

From here the normal `/my-spec` phases run to completion.
