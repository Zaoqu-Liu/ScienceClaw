---
name: evolving-memory
description: Evolving memory system inspired by EvoScientist. Extends ScienceClaw's research memory with four record types (finding, ideation, strategy, pitfall) to enable learning from past research sessions. Recall relevant strategies and pitfalls before recipe execution, extract and persist new lessons after completion. Use at the start and end of every research recipe, and when the user asks to recall past experience or improve workflows.
---

# Evolving Memory System

ScienceClaw learns from every research session. Each completed analysis enriches a persistent memory that makes future research faster, more accurate, and less error-prone.

## Memory Record Types

All records are stored in `~/.scienceclaw/memory/findings.jsonl` (append-only, one JSON object per line).

### Type 1: Finding (existing)

A verified scientific discovery with evidence.

```json
{"type":"finding","date":"2026-03-18","gene":"THBS2","disease":"pancreatic cancer","finding":"THBS2 overexpressed in 17/33 TCGA cancer types (Wilcoxon p<0.001)","significance":"high","sources":["PMID:32273438"],"tags":["expression","pan-cancer"],"project":"thbs2-tumor-2026-03-10"}
```

### Type 2: Ideation

Records whether a research direction proved viable or not. Prevents revisiting dead ends and reinforces promising paths.

```json
{"type":"ideation","date":"2026-03-18","direction":"THBS2+CA19-9 as pancreatic cancer diagnostic panel","feasibility":"low","reason":"Prospective AUC dropped from 0.96 to 0.69; biomarker validation failed in independent cohort","tags":["diagnostic","validation-failure","liquid-biopsy"],"project":"thbs2-tumor-2026-03-10"}
```

Fields:
- `direction`: The research direction or hypothesis explored
- `feasibility`: `"high"` | `"medium"` | `"low"` | `"dead-end"`
- `reason`: Why this feasibility assessment was reached (with data)

### Type 3: Strategy

Records an analysis approach that worked well (or better than the default). Enables progressively better methodology.

```json
{"type":"strategy","date":"2026-03-18","task":"survival_analysis","strategy":"Use surv_cutpoint() for optimal expression cutoff instead of median split","outcome":"Better separation: p=0.003 vs p=0.047 with median; HR 2.31 vs 1.68","tools":["R:survival","R:survminer"],"tags":["survival","cutoff-optimization"],"project":"thbs2-tumor-2026-03-10"}
```

Fields:
- `task`: The type of analysis (e.g., `survival_analysis`, `enrichment`, `deseq2`, `literature_search`)
- `strategy`: What was done differently from the default approach
- `outcome`: Quantitative evidence that this strategy was better
- `tools`: Software/packages used

### Type 4: Pitfall

Records errors, API quirks, data issues, and their fixes. Prevents repeating the same mistakes.

```json
{"type":"pitfall","date":"2026-03-18","context":"TCGA PAAD via cBioPortal","issue":"cBioPortal API returns duplicate samples when a study has multiple cohorts (e.g., TCGA-PAAD has both 'tcga_pan_can_atlas_2018' and 'paad_tcga')","fix":"Always deduplicate by sample_id before analysis; prefer the pan_can_atlas study for cross-cancer comparisons","tags":["cbioportal","tcga","deduplication"],"project":"thbs2-tumor-2026-03-10"}
```

Fields:
- `context`: Where the problem occurred (database, API, analysis step)
- `issue`: What went wrong (specific, reproducible)
- `fix`: How to avoid or resolve it

---

## When to Write Memory

### After every Recipe completion

Extract and append records using this checklist:

1. **Findings**: Any statistically significant result (p < 0.05 with meaningful effect size), contradiction between studies, or validated pipeline
2. **Ideation**: For each research direction explored — was it viable? Record feasibility with evidence
3. **Strategy**: Did any analysis step use a non-default approach that produced better results? Record the approach and quantitative comparison
4. **Pitfalls**: Did any tool call fail, return unexpected data, or require a workaround? Record the issue and fix

### Implementation

After completing a deep task, append records:

```bash
cat >> ~/.scienceclaw/memory/findings.jsonl << 'JSONL'
{"type":"strategy","date":"2026-03-18","task":"immune_infiltration","strategy":"Use CIBERSORT absolute mode instead of relative for correlation with gene expression","outcome":"Absolute scores gave r=0.59 vs relative r=0.31 for THBS2-macrophage correlation","tools":["R:CIBERSORT"],"tags":["immune","cibersort"],"project":"thbs2-tumor-2026-03-18"}
{"type":"pitfall","date":"2026-03-18","context":"Enrichr API","issue":"Enrichr addList endpoint returns 500 if gene list exceeds 2000 genes","fix":"Limit gene list to top 500 by fold change before submitting to Enrichr","tags":["enrichr","api-limit"],"project":"thbs2-tumor-2026-03-18"}
JSONL
```

---

## When to Recall Memory

### Before every Recipe execution

Before starting any Research Recipe, search memory for relevant prior experience:

```bash
python3 -c "
import json, sys

query_terms = sys.argv[1].lower().split()
records = {'strategy': [], 'pitfall': [], 'ideation': []}

with open('$HOME/.scienceclaw/memory/findings.jsonl') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            r = json.loads(line)
        except json.JSONDecodeError:
            continue
        rtype = r.get('type', 'finding')
        if rtype not in records:
            continue
        searchable = json.dumps(r).lower()
        if any(t in searchable for t in query_terms):
            records[rtype].append(r)

for rtype in ['strategy', 'pitfall', 'ideation']:
    if records[rtype]:
        print(f'\n=== Relevant {rtype}s ({len(records[rtype])}) ===')
        for r in records[rtype][-5:]:
            if rtype == 'strategy':
                print(f'  [{r.get(\"task\",\"\")}] {r.get(\"strategy\",\"\")}')
                print(f'    Outcome: {r.get(\"outcome\",\"\")}')
            elif rtype == 'pitfall':
                print(f'  [{r.get(\"context\",\"\")}] {r.get(\"issue\",\"\")}')
                print(f'    Fix: {r.get(\"fix\",\"\")}')
            elif rtype == 'ideation':
                print(f'  [{r.get(\"feasibility\",\"\")}] {r.get(\"direction\",\"\")}')
                print(f'    Reason: {r.get(\"reason\",\"\")}')
" "GENE DISEASE KEYWORDS"
```

Replace `GENE DISEASE KEYWORDS` with terms relevant to the current task (e.g., `"TP53 liver cancer survival"`).

### How to use recalled memory

- **Strategies**: Apply proven approaches instead of defaults. Mention in progress: "基于之前的经验，使用 surv_cutpoint() 代替中位数分割..."
- **Pitfalls**: Proactively avoid known issues. Mention in progress: "注意 cBioPortal 去重（之前遇到过重复样本问题）..."
- **Ideation**: Skip dead-end directions. Mention: "之前已验证 THBS2+CA19-9 诊断组合前瞻性 AUC 不理想，跳过此方向..."

---

## User Commands

### `/recall <topic>`

Search memory for all records matching the topic. Group by type, sort by date (newest first). Show up to 10 per type.

### `/lessons`

Show the most recent 20 strategy and pitfall records across all projects. Useful for reviewing accumulated knowledge.

### `/memory stats`

Report memory statistics:
- Total records by type
- Projects with most entries
- Most common tags
- Memory file size

---

## Memory Maintenance

### Size management

When `findings.jsonl` exceeds 500 records, automatically compact on next session start:

1. Keep all records from the last 90 days
2. For older records: keep all findings and high-feasibility ideation; keep only the 100 most recent strategies and pitfalls
3. Write compacted file to `findings.jsonl`, backup original to `findings.jsonl.bak`

```bash
python3 -c "
import json, os
from datetime import datetime, timedelta

path = os.path.expanduser('~/.scienceclaw/memory/findings.jsonl')
if not os.path.exists(path):
    exit()

with open(path) as f:
    records = [json.loads(l) for l in f if l.strip()]

if len(records) <= 500:
    print(f'Memory OK: {len(records)} records (under 500 limit)')
    exit()

cutoff = (datetime.now() - timedelta(days=90)).strftime('%Y-%m-%d')
recent = [r for r in records if r.get('date', '9999') >= cutoff]
old = [r for r in records if r.get('date', '0000') < cutoff]

kept = list(recent)
for r in old:
    if r.get('type') == 'finding':
        kept.append(r)
    elif r.get('type') == 'ideation' and r.get('feasibility') in ('high', 'medium'):
        kept.append(r)

old_strat_pit = [r for r in old if r.get('type') in ('strategy', 'pitfall')]
old_strat_pit.sort(key=lambda x: x.get('date', ''), reverse=True)
kept.extend(old_strat_pit[:100])

import shutil
shutil.copy2(path, path + '.bak')
with open(path, 'w') as f:
    for r in kept:
        f.write(json.dumps(r, ensure_ascii=False) + '\n')

print(f'Compacted: {len(records)} → {len(kept)} records (backup saved)')
"
```

---

## Integration with Session Greeting

At session start, after checking for watch alerts, also run memory maintenance (if needed) and briefly report:

```
📊 研究记忆: 127 条记录 (38 findings, 22 ideation, 45 strategy, 22 pitfalls)
   最近项目: thbs2-tumor-2026-03-10 (上次: THBS2 在 17/33 癌种显著上调)
```
