---
name: research-alerts
description: Monitor research topics and alert the user when new papers are published. Use when user says "/watch", "监控", "关注这个课题", "有新文献告诉我", "monitor this topic", "alert me on new papers", "track new publications". Stores watch configurations and checks for new results at session start.
---

# Research Alerts

Monitor research topics and notify the user when new relevant papers appear on PubMed or bioRxiv.

## When to Use

- User says "/watch TOPIC" or "监控 X 的最新文献"
- User says "有新文献告诉我" or "关注这个课题"
- User says "/watches" to list active watches
- User says "/unwatch TOPIC" to stop monitoring

## How It Works

### Watch Storage

Watches are stored as individual JSON files in `~/.scienceclaw/watches/`:

```json
{
  "topic": "THBS2 immunotherapy",
  "query": "THBS2 AND (immunotherapy OR immune checkpoint)",
  "created": "2026-03-10",
  "last_check": "2026-03-10",
  "interval_days": 7,
  "last_count": 47,
  "channel": "telegram"
}
```

File naming: `~/.scienceclaw/watches/<slug>.json` (e.g., `thbs2-immunotherapy.json`)

### Creating a Watch

When the user says `/watch TOPIC`:

1. Parse the topic into a PubMed search query (add appropriate MeSH terms or Boolean operators)
2. Run an initial search to get the baseline count
3. Save the watch configuration
4. Confirm: "已设置监控「TOPIC」，每周检查 PubMed 新文献。当前共 N 篇。"

```bash
mkdir -p ~/.scienceclaw/watches
cat > ~/.scienceclaw/watches/SLUG.json << 'EOF'
{"topic":"TOPIC","query":"PUBMED_QUERY","created":"DATE","last_check":"DATE","interval_days":7,"last_count":N,"channel":"current"}
EOF
```

### Checking Watches at Session Start

At the start of each session (as part of Session Greeting):

1. List files in `~/.scienceclaw/watches/`
2. For each watch, check if `today - last_check >= interval_days`
3. For due watches, run a PubMed search with `mindate=last_check`:

```bash
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=5&sort=pub_date&term=QUERY&mindate=LAST_CHECK&maxdate=TODAY&datetype=pdat"
```

4. If new results found, fetch brief summaries and report:

```
📩 文献监控更新 — TOPIC
  发现 N 篇新文献（自 LAST_CHECK 以来）：
  1. "Title..." (Authors, Journal, Year) PMID: xxx
  2. "Title..." (Authors, Journal, Year) PMID: xxx
  
  要详细了解哪篇？或回复 /unwatch TOPIC 停止监控。
```

5. Update `last_check` and `last_count` in the watch file

### Listing Watches

When the user says `/watches`:

```bash
for f in ~/.scienceclaw/watches/*.json; do
  python3 -c "import json; d=json.load(open('$f')); print(f\"  📡 {d['topic']}  (每{d['interval_days']}天, 上次检查: {d['last_check']}, 累计: {d['last_count']}篇)\")"
done
```

### Removing a Watch

When the user says `/unwatch TOPIC`:

1. Find the matching watch file by topic
2. Delete it
3. Confirm: "已停止监控「TOPIC」。"

## Custom Intervals

Users can specify interval: `/watch TOPIC --daily`, `/watch TOPIC --monthly`

| Flag | interval_days |
|------|--------------|
| `--daily` | 1 |
| `--weekly` (default) | 7 |
| `--biweekly` | 14 |
| `--monthly` | 30 |

## Integration with Telegram/Discord

When the watch `channel` is set to "telegram" or "discord", the alert is sent proactively at session start via the configured channel. For terminal sessions, the alert appears as part of the greeting.
