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

### 5. Codex plugin (optional)

Hand off or cross-check tasks with OpenAI Codex from inside Claude Code (e.g. the `codex:codex-rescue` agent).

```bash
claude plugin marketplace add openai/codex-plugin-cc
claude plugin install codex@openai-codex
```

## Commands

Custom slash commands live in [`commands/`](commands).

- **`/my-spec [what you want to build or fix]`** — Spec-driven development: gathers project/code context, judges intent (feature → user-story refinement; bug → read-only root-cause), then writes a KEP-style spec to `specs/<title>.md`.
- **`/my-plan [spec title]`** — Deepens a spec's Design Details and fills its Test Plan (KEP format) via task breakdown; after your review, writes back the spec only.
- **`/my-build [spec title]`** — Implements a spec's Design Details task by task (TDD + incremental, conforming to project conventions); confirms and commits after each task.
- **`/my-ship [spec title]`** — Finalizes a spec: optional e2e tests (writing fixes back to spec + the cheapest appropriate test coverage), refreshes the overview, and updates docs/ADRs; conforms to project conventions.

> **Models.** `/my-spec` and `/my-plan` run on **opus** (their heavy reasoning is front-loaded in the first turn); `/my-build` and `/my-ship` on **sonnet**. The `model:` frontmatter only applies to a command's **first turn** — for a full multi-turn build/ship session, run `/model sonnet` first.

## License

MIT
