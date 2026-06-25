# Crawl4AI CLI Guide

Command-line reference for the `crwl` tool. Upstream docs: https://docs.crawl4ai.com

> Adapted (trimmed) from the community crawl4ai skill under MIT OR Apache-2.0. The full upstream SDK reference is
> intentionally not bundled here to keep this skill lean — see https://docs.crawl4ai.com for the complete API.

## Table of Contents

- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Browser Configuration](#browser-configuration)
- [Crawler Configuration](#crawler-configuration)
- [Extraction Configuration](#extraction-configuration)
- [LLM Q&A](#llm-qa)
- [Content Filtering](#content-filtering)
- [Output Formats](#output-formats)
- [Best Practices & Tips](#best-practices--tips)

---

## Installation

`crwl` ships with the library:

```bash
pip install crawl4ai
crawl4ai-setup
crawl4ai-doctor   # verify
```

---

## Basic Usage

```bash
crwl https://example.com                          # markdown to stdout
crwl https://example.com -o markdown              # explicit format
crwl https://example.com -o md-fit                # filtered markdown
crwl https://example.com -o md-fit -O out.md      # write to a file (token-friendly)
crwl https://example.com -o json -v --bypass-cache
```

---

## Browser Configuration

Browser settings via YAML (`-B file.yml`) or inline (`-b "k=v,k=v"`):

| Parameter         | Description                    |
| ----------------- | ------------------------------ |
| `headless`        | Run without GUI (true/false)   |
| `viewport_width`  | Browser width in pixels        |
| `viewport_height` | Browser height in pixels       |
| `user_agent_mode` | "random" or specific UA string |

```bash
crwl https://example.com -b "headless=true,viewport_width=1280,user_agent_mode=random"
```

## Crawler Configuration

Control crawl behavior via YAML (`-C crawler.yml`, see [`templates/crawler.yml`](../templates/crawler.yml)) or inline
(`-c "k=v,k=v"`):

| Parameter        | Description                     |
| ---------------- | ------------------------------- |
| `cache_mode`     | bypass, enabled, disabled       |
| `wait_until`     | networkidle, domcontentloaded   |
| `page_timeout`   | Max page load time (ms)         |
| `css_selector`   | Focus on specific element       |
| `scan_full_page` | Enable infinite scroll handling |

```bash
crwl https://example.com -c "wait_until=networkidle,page_timeout=60000,scan_full_page=true"
```

## Extraction Configuration

**1. CSS/XPath-based** (deterministic, no LLM) — strategy YAML [`templates/extract_css.yml`](../templates/extract_css.yml)
+ schema [`templates/css_schema.json`](../templates/css_schema.json):

```bash
crwl https://example.com -e extract_css.yml -s css_schema.json -o json
```

**2. LLM-based** — `type: "llm"`, `provider`, `instruction`, `api_token`. Pays per-URL LLM cost; prefer the CSS path
for repeat extraction.

---

## LLM Q&A

Ask a question about the crawled content (requires a configured LLM provider — see below):

```bash
crwl https://example.com -q "What is the main topic discussed?"
```

**First-time setup:** prompts for an LLM provider + API token, saved in `~/.crawl4ai/global.yml`. Any LiteLLM-supported
provider works ([LiteLLM Providers](https://docs.litellm.ai/docs/providers)); `ollama/*` needs no token. **Without a
configured provider, `-q` and LLM extraction fail** — use the no-LLM `md-fit` + BM25 path instead.

---

## Content Filtering

Filter to relevant/high-quality content, then emit `md-fit`:

```bash
crwl https://example.com -f filter_bm25.yml -o md-fit      # relevance-scored against a query
crwl https://example.com -f filter_pruning.yml -o md-fit   # quality-based, no query
```

Templates: [`filter_bm25.yml`](../templates/filter_bm25.yml) (set `query:` to your topic),
[`filter_pruning.yml`](../templates/filter_pruning.yml). BM25 `threshold` higher = stricter; pruning `threshold`
higher = more aggressive.

---

## Output Formats

| Format         | Flag                             | Description                          |
| -------------- | -------------------------------- | ------------------------------------ |
| `all`          | `-o all`                         | Full crawl result including metadata |
| `json`         | `-o json`                        | Extracted structured data            |
| `markdown`     | `-o markdown` / `-o md`          | Raw markdown                         |
| `markdown-fit` | `-o markdown-fit` / `-o md-fit`  | Filtered markdown (use with `-f`)    |

Write to a file with `-O <path>` to keep large output out of the agent context.

---

## Best Practices & Tips

1. **Prefer `md-fit` + a filter** over raw `markdown` for LLM consumption — less noise, fewer tokens.
2. **Always `-O <file>`** for anything sizable; read selectively (`grep`/offset) instead of dumping into context.
3. **`--bypass-cache`** for fresh content; enable cache during iterative dev.
4. **`scan_full_page=true`** for infinite-scroll pages; raise `page_timeout` to 60000+ for JS-heavy sites.
5. **CSS extraction** for structured/repeating data (fast, no API cost); LLM extraction only for one-off irregular content.

For the complete API and advanced features (sessions, anti-detection, deep crawl, URL seeding), see
https://docs.crawl4ai.com.
