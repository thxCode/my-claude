# My Claude

Record basic plugins/skills/agents for personal Claude workspace. Less is more, KISS.

## Prerequisites

Set up the following before using this workspace. All commands assume the [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI is installed.

### 1. DeepWiki MCP

AI-powered documentation for any GitHub repository.

```bash
claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp
```

### 2. GitHub MCP

Interact with GitHub (issues, PRs, code search) via the official MCP endpoint. Requires a [personal access token](https://github.com/settings/tokens) exported as `GITHUB_PERSONAL_ACCESS_TOKEN`.

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN=<your-token>
claude mcp add -s user -t http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
```

### 3. GitNexus MCP

Code knowledge graph for exploring, debugging, and impact analysis.

```bash
npm install -g gitnexus@latest
claude mcp add gitnexus -- npx -y gitnexus@latest mcp
gitnexus setup
```

### 4. agent-skills plugin

Addy Osmani's collection of agent skills (plan, build, test, review, ...).

```bash
claude plugin marketplace add addyosmani/agent-skills
claude plugin install agent-skills@addy-agent-skills
```

### 5. open-code-review plugin

AI-powered code review CLI (`ocr`); used by `/my-build` for heavy-task review.

```bash
claude plugin marketplace add alibaba/open-code-review
claude plugin install open-code-review@open-code-review
```

> The review skill needs the `ocr` CLI and an LLM configured — on first review it self-checks and guides `npm i -g @alibaba-group/open-code-review` + `ocr llm test`. See [alibaba/open-code-review](https://github.com/alibaba/open-code-review).

### 6. Codex plugin (optional)

Hand off or cross-check tasks with OpenAI Codex from inside Claude Code (e.g. the `codex:codex-rescue` agent).

```bash
claude plugin marketplace add openai/codex-plugin-cc
claude plugin install codex@openai-codex
```

### 7. crawl4ai (optional)

Local web crawler powering the `crawl4ai-search` skill — fetch pages as clean Markdown and screenshot rendered UIs. Provides the `crwl` CLI.

```bash
uv pip install crawl4ai --system
crawl4ai-setup
crawl4ai-doctor
```

## Commands

Custom slash commands live in [`commands/`](commands).

- **`/my-spec [what you want to build or fix]`** — Spec-driven development: gathers project/code context, judges intent (feature → user-story refinement; bug → read-only root-cause), then writes a KEP-style spec to `specs/<yyyy-mm-dd>-<title>.md`.
- **`/my-spec-from-issue [github issue number or URL]`** — Issue-driven entry to the spec family: reads a GitHub issue (body + comments) from the current repo's upstream, distills it into a requirement, then hands off to `/my-spec` carrying the issue number — saving the spec as `specs/<issue-number>-<title>.md`.
- **`/my-plan [spec title]`** — Deepens a spec's Design Details and fills its Test Plan (KEP format) via task breakdown; after your review, writes back the spec only.
- **`/my-build [spec title]`** — Implements a spec's Design Details task by task (TDD + incremental, conforming to project conventions); confirms and commits after each task.
- **`/my-ship [spec title]`** — Finalizes a spec: optional e2e tests (writing fixes back to spec + the cheapest appropriate test coverage), refreshes the overview, and updates docs/ADRs; conforms to project conventions.

## Skills

Custom skills live in [`skills/`](skills); Claude invokes them automatically when a task matches, or you can call one explicitly (e.g. `/auto-research`).

- **`search-first`** — Research-before-coding workflow: searches for existing tools, libraries, and patterns before writing custom code, so you reuse instead of reinventing. Invokes the researcher agent.
- **`address-pr-review`** — Consumes the review comments **already left** on a PR: triages each one against the source (real bug vs. false positive), fixes the real ones surgically, folds the fixes into the right commit to keep history clean, then replies to / resolves the threads. The counterpart to skills that *generate* a review.
- **`auto-research`** — Autonomous research harness: decomposes a topic, fans out web searches, adversarially verifies every claim against its source, then synthesizes a Perplexity-style cited report at `.claude/reports/<title>.md`. Cost-aware (throttles on rate-limit usage) and observable (per-round digest). After showing the plan it runs unattended (**auto mode**) or pauses for per-round approval (**manual-approve mode**).
- **`crawl4ai-search`** — Fetches web pages as clean, token-efficient Markdown (`md-fit` + BM25 filter) and screenshots rendered UIs via the local [crawl4ai](#7-crawl4ai-optional) (`crwl` CLI + a small SDK script). Used in place of `WebFetch` for JavaScript-rendered/content-dense pages and by `auto-research` workers for distilled fetches; supplies frontend render/responsive/component screenshots while delegating interactive debugging to `agent-skills:browser-testing-with-devtools`. Requires the optional crawl4ai install above.


## License

MIT
