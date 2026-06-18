---
name: address-pr-review
description: "Read the review feedback already left on a pull request, triage each comment against the actual source (real bug vs. false positive), fix the real ones surgically, keep the git history clean by folding fixes into the right commit, and close the loop by replying to / resolving threads and updating the PR. This CONSUMES existing review comments and acts on them — it is the counterpart to skills that GENERATE a review (e.g. gitnexus-pr-review, /review). Examples: \"address the review comments on this PR\", \"the bot left review comments, fix the real ones\", \"how do I handle the feedback on PR #1\", \"apply the reviewer's suggestions and clean up the git log\", \"triage the Copilot review and reply to the wrong ones\"."
allowed-tools: "mcp__plugin_github_github__list_pull_requests, mcp__plugin_github_github__pull_request_read, mcp__plugin_github_github__add_reply_to_pull_request_comment, mcp__plugin_github_github__pull_request_review_write, Bash(git log*), Bash(git diff*), Bash(git show*), Bash(git status*), Bash(git rev-parse*), Bash(git remote*), Bash(git fetch*), Bash(git rev-list*), Bash(git blame*), Read, Grep, Glob"
model: opus
---

# Address PR review feedback

Take the review comments **already left** on a pull request and turn them into correct, minimal,
well-tracked changes. The hard part is not editing files — it is **deciding which comments are right**
and **landing the fixes without making the git history ugly**. Bot reviewers (Copilot, CodeRabbit, etc.)
produce confident-sounding comments that are sometimes wrong; never apply a comment without verifying it
against the source first.

## Workflow

### 1. Locate the PR

Resolve `owner` / `repo` and the PR number for the current branch:

```bash
git remote get-url origin          # parse <owner>/<repo> from this
git rev-parse --abbrev-ref HEAD    # current branch name
```

- If the user named a PR number, use it directly.
- Otherwise call `list_pull_requests` with `head: "<owner>:<branch>"`, `state: "open"` to find it.

Then read the PR and its CI state with `pull_request_read` (same `owner` / `repo` / `pullNumber`):
- `method: get` — title, state, reviewDecision.
- `method: get_check_runs` (and `get_status`) — which CI checks are failing.

### 2. Read ALL three kinds of feedback

GitHub stores review feedback in three separate places. Looking at only one of them misses comments. All
three come from `pull_request_read` (same `owner` / `repo` / `pullNumber`):

- **① Top-level reviews** (`method: get_reviews`) — carries the state (APPROVED / CHANGES_REQUESTED /
  COMMENTED) and the summary body.
- **② Inline review comments** (`method: get_review_comments`) — the most actionable feedback, bound to a
  file + line. Returns review **threads** with `isResolved` / `isOutdated` **and each thread's node id
  (`PRRT_…`)** — keep that id, you need it to resolve the thread in step 8.
- **③ Issue comments** (`method: get_comments`) — the PR conversation, not tied to any line.

Page with `perPage` / `after` if there are many comments.

### 3. Triage — verify every comment against the source (the important step)

For each comment, **open the cited file/line and decide before touching anything**:

- **Real bug** → note the exact fix and which commit it belongs to.
- **False positive** → note why; you will reply on the PR instead of changing code.
- **Out of scope / opinion** → flag for the user, do not silently act.

Common false positives to watch for:
- Library-semantics claims (e.g. "this `merge`/`reduce` precedence is backwards") — confirm against the
  actual library docs/behavior; reversing a correct call *introduces* a bug.
- "This will crash on input X" — check whether input X is actually reachable / validated upstream.

While triaging, look for the **same root cause elsewhere** the reviewer missed (e.g. a rendering bug
flagged in two templates often exists in a third). Fix all instances for consistency, and say so.

Present a short triage table (id · location · verdict · action) before editing.

### 4. Fix the real issues — surgically

- Match the surrounding style and existing idioms (e.g. reuse a helper/pattern the file already uses).
- Touch only what the comment requires; no drive-by refactors.
- Add or adjust a focused test that locks in the fix, especially for logic bugs.

### 5. Verify

Run the project's own checks before committing — tests, linters, and a render/dry-run when the change is
in templates/manifests:

```bash
go test ./<pkg>/...            # or the repo's test command
<repo lint command>            # e.g. make lint
helm template ... | grep ...   # for chart/manifest changes, prove the rendered output is valid
```

### 6. Keep the git log pretty — fold fixes into the right commit

Inspect history first: `git log --oneline <base>..HEAD`.

- **Branch is a single commit** (or all fixes belong to the tip): `git add -A && git commit --amend --no-edit`.
- **Fixes belong to specific earlier commits**: make targeted fixups, then autosquash. Interactive rebase
  prompts are unavailable in this harness, so drive it non-interactively with a no-op sequence editor:
  ```bash
  git commit --fixup=<target-sha> -- <files>
  GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>
  ```
- Avoid a noisy standalone "address review comments" commit unless the user wants the review trail in history.

Use `git blame <file>` / `git log --oneline -- <file>` to find which commit a fix belongs to.

### 7. Push the fixes — confirm first

Folding fixes via amend/rebase rewrites history, so updating the PR needs a force-push. This is
outward-facing: **confirm with the user before pushing**, and guard against clobbering remote work.

```bash
git fetch origin <branch>
git rev-list --left-right --oneline HEAD...FETCH_HEAD   # ">" lines = commits only on remote — STOP and investigate
git push --force-with-lease=<branch>:<expected-remote-sha> origin HEAD:<branch>
```

- Always `--force-with-lease` pinned to the SHA you just fetched, never a bare `--force`.
- If `>` lines appear, the remote has commits the local branch lacks — surface it, do not overwrite.
- A remote ruleset may warn `Commits must have verified signatures ... violation: <sha>` when the
  rewritten commit is unsigned. The push can still succeed, but a signed-commits merge rule may later
  block the merge — flag it to the user (it's their git signing config, not something to fix silently).
- Pushing marks the affected lines' comments as outdated automatically.

### 8. Reply to comments and resolve threads

Two buckets, two behaviors:
- **Fixed** → reply explaining the fix, then **resolve** the thread.
- **Not fixed** (false positive, intentionally kept, or deferred) → reply with the reasoning and
  **leave the thread open** so a human reviewer sees it and decides. Never resolve what you did not change.

You already have each thread's id (`PRRT_…`) and its comments from step 2's `get_review_comments` — no extra
lookup needed.

- **Reply:** `add_reply_to_pull_request_comment` with `commentId` (the comment's databaseId) and `body`.
- **Resolve** (only the fixed ones): `pull_request_review_write` with `method: resolve_thread` and
  `threadId` (the `PRRT_…` id).

Finally, re-read with `pull_request_read` (`method: get_review_comments`) and confirm the end state:
fixed → resolved, not-fixed → open.

## Output

End with: what was fixed (and where), what was rejected as a false positive (and why), the resulting
git history, and any items deferred to the user. Be explicit about anything not yet pushed.
