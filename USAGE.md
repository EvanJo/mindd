# Usage Guide

Practical examples for working with the mindd wiki. Open Obsidian on one side, Claude Code on the other.

## Ingest a source

1. **Clip an article** using [Obsidian Web Clipper](https://obsidian.md/clipper) or drop a PDF/markdown file into `raw/`.

2. **Ask Claude to process it:**
   ```
   ingest raw/article-on-transformer-architectures.md
   ```
   Claude will: read the source, create a summary in `wiki/sources/`, update or create entity/concept pages, add cross-references, update `wiki/index.md`, and append to `wiki/log.md`.

3. **Stay in the loop.** Claude discusses key takeaways before filing. Guide what to emphasize — you can say things like:
   ```
   focus on the comparison between attention mechanisms, skip the training details
   ```

4. **Batch ingest** (less supervision):
   ```
   ingest everything in raw/papers/ — keep it high-level, I'll review later
   ```

## Query the wiki

Ask questions naturally. Claude reads the index, finds relevant pages, and synthesizes an answer with citations.

```
what are the main arguments for and against fine-tuning vs prompting?
```

```
compare the approaches described in the Smith 2024 and Jones 2025 papers
```

```
what do we know about scaling laws? are there any contradictions between sources?
```

If the answer is worth keeping, say:
```
file that as an analysis page
```

Claude saves it to `wiki/analyses/` so it compounds in the knowledge base.

## Lint the wiki

Periodically ask Claude to health-check:

```
lint the wiki
```

Claude will flag:
- Contradictions between pages
- Stale claims superseded by newer sources
- Orphan pages with no inbound links
- Concepts mentioned but lacking their own page
- Missing cross-references
- Suggested new questions or sources to seek

## Search with qmd

For quick searches outside of Claude:

```bash
# Keyword search
qmd search "attention mechanism"

# Semantic search (finds conceptually related pages even without exact keywords)
qmd vsearch "how do models handle long contexts"

# Hybrid search with LLM reranking (most accurate, slower)
qmd query "tradeoffs between model size and inference cost"
```

After ingesting new sources, rebuild the search index:
```bash
qmd embed
```

## Tips

- **Obsidian graph view** — open it to see the shape of the wiki. Hub pages with many connections are your most developed topics. Orphans need linking.
- **Download images locally** — In Obsidian Settings > Files and links, set attachment folder to `raw/assets/`. Bind a hotkey to "Download attachments for current file" (e.g. Ctrl+Shift+D). After clipping an article, hit the hotkey.
- **Dataview queries** — If you install the Dataview plugin, you can query the YAML frontmatter Claude adds to wiki pages. Example: a table of all sources sorted by date, or all concepts tagged with a specific topic.
- **Marp slides** — Install the Marp plugin in Obsidian to render markdown slide decks. Ask Claude to generate a presentation from wiki content: `create a Marp slide deck summarizing what we know about X`.
