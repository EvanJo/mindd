# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This file also serves as the **schema** — the governing document that tells Claude how the wiki is structured, what conventions to follow, and what workflows to use when ingesting sources, answering queries, or maintaining the wiki.

## Project Overview

**mindd** is a personal knowledge base built on the LLM Wiki pattern. The LLM incrementally builds and maintains a persistent wiki — a structured, interlinked collection of markdown files — rather than re-deriving knowledge from raw sources on every query. The wiki is a compounding artifact: cross-references, contradictions, and synthesis accumulate over time.

Obsidian is the IDE for browsing. Claude is the maintainer. The wiki is the codebase.

## Setup

Run `./setup.sh` from the repo root to set up the environment on a new Mac. The key step: `wiki/` is a **symlink** into the Obsidian vault at `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/mindd/wiki`. This means Claude writes wiki pages in the repo, and Obsidian renders them in real time (synced via iCloud). The symlink is gitignored — each machine recreates it via setup.sh.

## Architecture — Three Layers

### 1. Raw Sources (`raw/`)
Immutable source documents — articles, papers, notes, images, data files. Claude reads from these but **never modifies them**. Subdirectories can organize by type or topic. Images and attachments go in `raw/assets/`.

### 2. The Wiki (`wiki/`)
LLM-generated markdown files. Claude owns this layer entirely — creating pages, updating them when new sources arrive, maintaining cross-references, and keeping everything consistent. The user reads; Claude writes.

Page types:
- **Source summaries** (`wiki/sources/`) — one per ingested source
- **Entity pages** (`wiki/entities/`) — people, organizations, products, places
- **Concept pages** (`wiki/concepts/`) — ideas, theories, frameworks, themes
- **Analyses** (`wiki/analyses/`) — comparisons, syntheses, answers to queries worth keeping

### 3. The Schema (this file)
Governs structure, conventions, and workflows. Co-evolved by the user and Claude over time.

## Special Files

### `wiki/index.md`
Content-oriented catalog of every wiki page. Each entry: wikilink, one-line summary, optional metadata. Organized by category (sources, entities, concepts, analyses). Updated on every ingest. **Read this first** when answering queries to find relevant pages.

### `wiki/log.md`
Append-only chronological record. Each entry uses the format:
```
## [YYYY-MM-DD] operation | Title
Brief description of what happened.
```
Operations: `ingest`, `query`, `lint`, `update`. Parseable with grep.

## Wiki Page Conventions

- Use `[[wikilinks]]` for cross-references between wiki pages (Obsidian-style)
- Add YAML frontmatter to every wiki page:
  ```yaml
  ---
  title: Page Title
  type: source | entity | concept | analysis
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  tags: [relevant, tags]
  sources: [list of source filenames]
  ---
  ```
- Use Obsidian-compatible markdown (standard CommonMark + wikilinks + callouts)
- When referencing claims, cite the source summary page via wikilink

## Operations

### Ingest
When the user adds a new source to `raw/` and asks to process it:
1. Read the source document fully
2. Discuss key takeaways with the user
3. Create a source summary page in `wiki/sources/`
4. Update or create relevant entity and concept pages across the wiki
5. Add cross-references (wikilinks) between new and existing pages
6. Update `wiki/index.md`
7. Append an entry to `wiki/log.md`

A single source may touch 10-15 wiki pages. Ingest one source at a time unless the user requests batch processing.

### Query
When the user asks a question:
1. Read `wiki/index.md` to find relevant pages
2. Read those pages and synthesize an answer with citations
3. If the answer is valuable and reusable, offer to file it as a new analysis page in `wiki/analyses/`

### Lint
When the user requests a health check:
- Flag contradictions between pages
- Identify stale claims superseded by newer sources
- Find orphan pages with no inbound wikilinks
- Note important concepts mentioned but lacking their own page
- Suggest missing cross-references
- Recommend new questions to investigate or sources to seek

## Search (qmd)

At small scale, `wiki/index.md` is sufficient for navigation. As the wiki grows, use [qmd](https://github.com/tobi/qmd) — a local search engine for markdown with hybrid search, all on-device.

**CLI commands:**
- `qmd search "query"` — fast BM25 keyword search
- `qmd vsearch "query"` — semantic vector search using embeddings
- `qmd query "query"` — hybrid search (BM25 + vector + LLM reranking)
- `qmd get "wiki/concepts/some-page.md"` — retrieve a specific document

**Claude Code plugin** is installed via `claude plugin install qmd@qmd` (see setup.sh). This gives Claude native access to qmd's search tools without shelling out.

**Re-index after changes:** Run `qmd embed` after ingesting new sources to update the vector index.

## Key Principles

- The user curates sources, directs analysis, and asks questions. Claude does all bookkeeping — summarizing, cross-referencing, filing, maintaining consistency.
- Good query answers should be filed back into the wiki as analysis pages so explorations compound.
- When new information contradicts existing wiki content, flag the contradiction explicitly and update affected pages.
- Never modify files in `raw/`. That directory is the source of truth.
