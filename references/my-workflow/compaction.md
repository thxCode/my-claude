# Compaction checkpoint

Shared by `/my-plan`, `/my-debug`, `/my-build`, `/my-ship`. `/compact` is user-only — you emit the block and
ask; the user runs it.

## When it fires

You can't read the token count. Judge from proxies — **either signal is enough**:

- the context looks large (many/large files read, tool output piled up), or
- it feels fuzzy: losing track of state, re-reading things you already read, unsure which tasks are done.

Neither fires → skip and continue. Thresholds by command: `/my-build` ~>500K, `/my-ship` ~>250K.

## What to do

Emit one copyable block in **English** and ask the user to run it before continuing:

```
/compact <focus>
```

Then resume — every command in the family re-resolves its target from disk, so the work picks up cleanly from
Phase 1. The target file and git hold the state; the conversation doesn't need to.

`/my-build` is the strict case: when a signal fires with tasks still pending, require the compaction in **every**
run mode. A bloated or fuzzy context degrades every remaining task, and neither auto-chain nor team gets to skip it.

## Focus per command

| Command | Keeps | Drops |
| --- | --- | --- |
| `/my-plan` | target spec path; finalized Implementation Plan (tasks + acceptance) + Test Plan; reusable codebase landings (files / functions / patterns, with paths); flagged Risks → Mitigations; next step `/my-build <title>` | exploration and grep transcripts; superseded drafts |
| `/my-debug` | artifact path; Root Cause; Fix Plan (tasks + acceptance) + Test Plan; reusable codebase landings (paths); next step `/my-build <title>` | verbose debugging transcripts |
| `/my-build` | target path; done (`[x]`) vs pending tasks; current branch; run mode; key decisions and patterns; open questions / risks | diffs and tool output of committed tasks — git holds them now |
| `/my-ship` | branch + target path (if any); base branch; ship mode; which finalization phases are done; key decisions / open questions | diffs and tool output of committed work |

## Handing off after a compaction

`/my-plan` and `/my-debug` end by offering the next step. When that offer is **compact, then build**, the block
is three lines in order — compact first, switch model second, then build:

```
/compact <focus>
/model opus
/my-build <title>
```

Switching right after compaction keeps the model-switch re-read minimal (prompt caches are per-model). Suggest
`/model sonnet` instead when the plan is fully specified and low-risk, or the fix is small and well-patterned.
