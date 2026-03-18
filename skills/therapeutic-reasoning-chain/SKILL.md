---
name: therapeutic-reasoning-chain
description: Multi-step therapeutic reasoning inspired by TxAgent (Harvard MIMS, 2026). Chains ToolUniverse tool calls with clinical reasoning to analyze drug interactions, contraindications, and personalized treatment strategies. Goes beyond single-step database lookups to perform sequential reasoning across patient profile, pharmacology, guidelines, and safety data. Use when users ask about treatment recommendations, drug interactions for specific patients, personalized therapy, or "X 怎么治" with patient-specific context (age, comorbidities, concurrent medications). Enhances the existing clinical-query and target-validation recipes.
---

# Therapeutic Reasoning Chain

Multi-step clinical reasoning that chains ToolUniverse tool calls with pharmacological logic. Inspired by TxAgent's approach of reasoning across 211 biomedical tools rather than making isolated lookups.

## When to Use

- Patient-specific treatment questions: "65岁糖尿病患者新确诊 NSCLC，推荐方案"
- Drug interaction analysis: "二甲双胍和帕博利珠单抗有相互作用吗"
- Personalized therapy: "EGFR L858R 突变的 NSCLC 怎么治"
- Comparative therapy: "奥西替尼 vs 吉非替尼 在 EGFR+ NSCLC 的比较"
- Contraindication check: "肝功能不全患者能用索拉非尼吗"

**NOT for** (use other skills):
- General disease overview → use `clinical-query` recipe
- Drug target validation → use `tooluniverse-drug-target-validation`
- Pure literature search → use `literature-review` recipe

---

## Reasoning Chain Architecture

Every therapeutic query follows a structured chain. Each step produces evidence that feeds the next.

```
Step 1: PARSE      → Extract patient profile and clinical question
Step 2: PROFILE    → Gather drug/target background via ToolUniverse
Step 3: INTERACT   → Check drug-drug and drug-disease interactions
Step 4: GUIDELINE  → Match against current clinical guidelines
Step 5: PERSONALIZE → Adjust for patient-specific factors
Step 6: SYNTHESIZE → Produce ranked recommendations with evidence levels
```

---

## Step 1: PARSE — Extract Patient Profile

From the user query, extract structured parameters:

```json
{
  "patient": {
    "age": 65,
    "sex": "male",
    "comorbidities": ["type 2 diabetes mellitus"],
    "current_medications": ["metformin 500mg BID"],
    "allergies": [],
    "organ_function": {"renal": "unknown", "hepatic": "unknown"},
    "genomic_markers": {}
  },
  "diagnosis": {
    "primary": "non-small cell lung cancer",
    "stage": "unknown",
    "histology": "unknown",
    "biomarkers": {}
  },
  "question_type": "treatment_recommendation"
}
```

If critical information is missing (e.g., cancer stage, biomarker status), note it as a limitation but proceed with available data. Do NOT ask the user to fill every field — provide the best answer with what you have, and note what additional information would refine the recommendation.

---

## Step 2: PROFILE — Drug/Target Background

Query ToolUniverse for relevant drug and target information:

```bash
bash: python3 << 'PYEOF'
from tooluniverse import ToolUniverse
import json

tu = ToolUniverse()
tu.load_tools()

# Drug profile
drug_info = tu.run({
    "name": "DrugBank_search_drug",
    "arguments": {"query": "metformin", "limit": 3}
})
print("=== DrugBank: metformin ===")
print(json.dumps(drug_info, indent=2, ensure_ascii=False)[:2000])

# Disease targets
targets = tu.run({
    "name": "OpenTargets_search_disease",
    "arguments": {"query": "non-small cell lung cancer", "limit": 5}
})
print("\n=== OpenTargets: NSCLC ===")
print(json.dumps(targets, indent=2, ensure_ascii=False)[:2000])
PYEOF
```

If ToolUniverse is not installed, fall back to `curl` API calls:

```bash
bash: echo "=== DrugBank (via web) ===" && \
curl -s "https://go.drugbank.com/unearth/q?searcher=drugs&query=metformin" 2>/dev/null && \
echo -e "\n=== OpenTargets ===" && \
curl -s -X POST "https://api.platform.opentargets.org/api/v4/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ search(queryString:\"non-small cell lung cancer\", entityNames:[\"disease\"]) { total hits { id name } } }"}'
```

---

## Step 3: INTERACT — Drug Interaction Analysis

For each candidate treatment, check interactions with existing medications:

```bash
bash: python3 << 'PYEOF'
from tooluniverse import ToolUniverse
import json

tu = ToolUniverse()
tu.load_tools()

# Check interactions between metformin and candidate drugs
candidates = ["pembrolizumab", "osimertinib", "carboplatin", "pemetrexed"]

for drug in candidates:
    result = tu.run({
        "name": "DrugBank_get_interactions",
        "arguments": {"drug_name": drug, "limit": 20}
    })
    interactions = [i for i in result.get("data", [])
                    if "metformin" in json.dumps(i).lower()]
    if interactions:
        print(f"⚠️  {drug} ↔ metformin: {json.dumps(interactions, ensure_ascii=False)[:500]}")
    else:
        print(f"✅ {drug} ↔ metformin: No known interaction")
PYEOF
```

**Interaction severity classification**:
- **Contraindicated**: Do not co-administer. Find alternative.
- **Major**: Use with extreme caution. Document risk-benefit.
- **Moderate**: Monitor closely. Adjust doses if needed.
- **Minor**: Generally safe. Standard monitoring.

---

## Step 4: GUIDELINE — Clinical Guideline Matching

Search for current treatment guidelines:

```bash
bash: echo "=== NCCN/ESMO Guidelines ===" && \
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=10&sort=pub_date&term=(NSCLC+OR+%22non-small+cell+lung+cancer%22)+AND+(guideline+OR+%22clinical+practice%22+OR+NCCN+OR+ESMO)+AND+2024:2026[pdat]" && \
echo -e "\n=== ClinicalTrials.gov ===" && \
curl -s "https://clinicaltrials.gov/api/v2/studies?query.term=NSCLC+first-line&filter.overallStatus=COMPLETED&pageSize=10&sort=LastUpdatePostDate:desc"
```

Extract first-line, second-line, and third-line recommendations. Note evidence level for each (1A, 1B, 2A, etc.).

---

## Step 5: PERSONALIZE — Patient-Specific Adjustment

Apply patient factors to modify recommendations:

| Factor | Impact | Action |
|--------|--------|--------|
| Age ≥ 75 | Toxicity risk ↑ | Prefer less toxic regimens; consider dose reduction |
| Renal impairment | Drug clearance ↓ | Adjust renally-cleared drugs (cisplatin → carboplatin) |
| Hepatic impairment | Metabolism ↓ | Avoid hepatotoxic drugs; reduce CYP-metabolized drug doses |
| Diabetes + metformin | Lactic acidosis risk | Monitor renal function with platinum agents |
| EGFR mutation | Targeted therapy | First-line osimertinib (FLAURA trial) |
| PD-L1 ≥ 50% | Immunotherapy | First-line pembrolizumab monotherapy (KEYNOTE-024) |
| ALK/ROS1 fusion | Targeted therapy | First-line crizotinib/alectinib |

If genomic markers are unknown, recommend testing and provide conditional recommendations:
- "If EGFR+: osimertinib first-line"
- "If EGFR-/ALK-/PD-L1≥50%: pembrolizumab monotherapy"
- "If EGFR-/ALK-/PD-L1<50%: pembrolizumab + chemotherapy"

---

## Step 6: SYNTHESIZE — Ranked Recommendations

Output format:

```markdown
## 治疗推荐

### 患者画像
- 65岁男性，T2DM（二甲双胍 500mg BID），新确诊 NSCLC（分期/病理/分子标志物待确认）

### 推荐检查
- [ ] EGFR/ALK/ROS1/BRAF 分子检测
- [ ] PD-L1 (22C3) 表达检测
- [ ] 肾功能评估（肌酐清除率）— 影响铂类选择
- [ ] 肝功能评估 — 影响 TKI 选择

### 条件化治疗方案

#### 情景 A: EGFR 突变阳性
| 线数 | 方案 | 证据级别 | 关键试验 | 注意事项 |
|-----|------|---------|---------|---------|
| 一线 | Osimertinib 80mg QD | 1A | FLAURA (HR=0.80) | 与 metformin 无已知相互作用 |
| 二线 | Carboplatin + Pemetrexed | 1A | PROFILE 1014 | 监测肾功能（metformin + carboplatin） |

#### 情景 B: EGFR 野生型，PD-L1 ≥ 50%
| 线数 | 方案 | 证据级别 | 关键试验 | 注意事项 |
|-----|------|---------|---------|---------|
| 一线 | Pembrolizumab 200mg Q3W | 1A | KEYNOTE-024 (HR=0.60) | 监测甲状腺功能和血糖 |

#### 情景 C: EGFR 野生型，PD-L1 < 50%
| 线数 | 方案 | 证据级别 | 关键试验 | 注意事项 |
|-----|------|---------|---------|---------|
| 一线 | Pembrolizumab + Carboplatin + Pemetrexed | 1A | KEYNOTE-189 (HR=0.49) | Carboplatin 优于 cisplatin（肾安全） |

### 药物相互作用摘要
| 候选药 | 与 Metformin 交互 | 严重度 | 建议 |
|--------|-----------------|--------|------|
| Osimertinib | 无已知交互 | — | 可安全联用 |
| Pembrolizumab | 无已知交互 | — | 可安全联用 |
| Carboplatin | 肾功能影响 | Moderate | 监测 CrCl，必要时调 metformin 剂量 |

### 局限性
- 未获得分期和分子检测结果，方案为条件化推荐
- 药物相互作用数据来自 DrugBank，可能不涵盖所有文献报道的交互
- 本分析不替代肿瘤科医生的临床判断

### 数据来源
- DrugBank (accessed 2026-03-18)
- OpenTargets Platform (v24.12)
- ClinicalTrials.gov
- PubMed guidelines search
```

---

## Evidence Level Classification

| Level | Description | Source Type |
|-------|-------------|------------|
| 1A | Strong evidence, meta-analysis/RCT | Cochrane, Phase 3 RCT |
| 1B | Good evidence, well-designed RCT | Single Phase 3 |
| 2A | Moderate evidence, controlled study | Phase 2, cohort |
| 2B | Limited evidence, observational | Case-control, registry |
| 3 | Expert opinion / case reports | Case series, reviews |

Always state evidence level for each recommendation.

---

## Safety Flags

When any of these conditions are detected, prominently flag at the top of the output:

- **🔴 Contraindicated combination**: Drug pair has a contraindication
- **🟠 Major interaction**: Dose adjustment or enhanced monitoring required
- **🟡 Organ function concern**: Impaired organ may affect drug metabolism/clearance
- **🔵 Genomic implication**: Pharmacogenomic variant affects drug choice/dose
