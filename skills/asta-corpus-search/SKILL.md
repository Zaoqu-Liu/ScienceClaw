---
name: asta-corpus-search
description: Search Allen AI's Asta Scientific Corpus (225M+ papers, 12M+ full-text, 2.4B+ citations) via MCP endpoint. Provides paragraph-level semantic search across full-text publications, citation graph traversal, and author analysis. Use as a complement to PubMed/OpenAlex/Semantic Scholar for deeper literature discovery, especially when full-text search or citation network analysis is needed. Requires ASTA_API_KEY in .env (free registration at allenai.org/asta).
---

# Asta Scientific Corpus Search

Access Allen AI's massive scientific literature graph: 225M+ papers, 80M+ authors, 2.4B+ citation edges, and 12M+ full-text publications (285M+ passages).

## When to Use

- **Always** as part of multi-source literature search (Channel 4 alongside PubMed, OpenAlex, Semantic Scholar)
- **Especially useful** when you need:
  - Full-text paragraph-level search (not just title/abstract)
  - Deep citation network traversal
  - Cross-disciplinary paper discovery
  - Author relationship analysis

## API Configuration

| Parameter | Value |
|-----------|-------|
| **Endpoint** | `https://asta-tools.allen.ai/mcp/v1` |
| **Protocol** | MCP over HTTP POST (JSON-RPC style) |
| **Auth** | `x-api-key: $ASTA_API_KEY` header |
| **Rate limits** | Higher with API key; basic access without |
| **Key registration** | Free at https://allenai.org/asta/resources |

## Core Tools

### 1. search_papers — Find papers by query

```bash
curl -s "https://asta-tools.allen.ai/mcp/v1" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ASTA_API_KEY" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 1,
    "params": {
      "name": "search_papers",
      "arguments": {
        "query": "THBS2 tumor microenvironment macrophage",
        "limit": 15
      }
    }
  }'
```

Returns: paper IDs, titles, authors, year, citation count, abstract snippets.

### 2. get_papers — Retrieve paper details by ID

Supports multiple ID types: DOI, arXiv ID, PMID, Semantic Scholar CorpusId.

```bash
curl -s "https://asta-tools.allen.ai/mcp/v1" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ASTA_API_KEY" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 1,
    "params": {
      "name": "get_papers",
      "arguments": {
        "paper_ids": ["PMID:32273438", "DOI:10.1038/s41586-024-07487-w"],
        "fields": ["title", "authors", "year", "abstract", "citationCount", "references"]
      }
    }
  }'
```

### 3. get_citations — Citation graph traversal

```bash
curl -s "https://asta-tools.allen.ai/mcp/v1" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ASTA_API_KEY" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "id": 1,
    "params": {
      "name": "get_citations",
      "arguments": {
        "paper_id": "PMID:32273438",
        "direction": "citations",
        "limit": 20
      }
    }
  }'
```

Use `"direction": "references"` for backward citations.

## Integration with Multi-Source Search

Add Asta as the fourth channel in the standard literature search block:

```bash
echo "=== PubMed ===" && \
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=20&sort=relevance&term=QUERY" && \
echo -e "\n=== OpenAlex ===" && \
curl -s "https://api.openalex.org/works?search=QUERY&per_page=10&sort=relevance_score:desc&select=id,title,authorships,publication_year,cited_by_count,doi,primary_location" && \
echo -e "\n=== Semantic Scholar ===" && \
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=QUERY&limit=10&fields=title,authors,year,abstract,citationCount,externalIds,url" && \
echo -e "\n=== Asta (225M papers, full-text index) ===" && \
curl -s "https://asta-tools.allen.ai/mcp/v1" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ASTA_API_KEY" \
  -d '{"jsonrpc":"2.0","method":"tools/call","id":1,"params":{"name":"search_papers","arguments":{"query":"QUERY","limit":15}}}'
```

## When Asta Adds Unique Value

| Scenario | Why Asta helps |
|----------|---------------|
| Full-text keyword search | PubMed only searches title/abstract; Asta indexes 285M+ passages from 12M full-text papers |
| Finding methods/protocols | Search for specific techniques mentioned only in methods sections |
| Citation network depth | 2.4B+ citation edges enable deep forward/backward chain analysis |
| Cross-disciplinary discovery | 225M papers across all fields, not limited to biomedical |
| Preprint coverage | Includes arXiv, bioRxiv, medRxiv alongside published papers |

## Fallback Behavior

If `ASTA_API_KEY` is not configured or the API returns an error:
- Skip Asta silently
- Continue with PubMed + OpenAlex + Semantic Scholar
- Do NOT report the failure to the user unless they explicitly asked for Asta results

## Response Parsing

Asta MCP responses follow JSON-RPC format:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "... JSON string with paper results ..."
      }
    ]
  }
}
```

Parse `result.content[0].text` as JSON to extract paper data. Handle nested JSON strings.
