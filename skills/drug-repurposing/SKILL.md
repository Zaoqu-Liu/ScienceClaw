---
name: drug-repurposing
description: Systematic drug repurposing analysis inspired by NovusAI. Evaluates existing drugs for new therapeutic indications through multi-dimensional evidence gathering across target networks, clinical trials (including failures), patent landscape, safety profiles, and off-label literature. Produces ranked repurposing candidates with evidence scores. Use when users ask about finding new uses for existing drugs, off-label potential, "老药新用", or "drug repurposing for X". Complements target-validation (which starts from a target) by starting from a drug.
---

# Drug Repurposing Pipeline

Systematically evaluate an existing drug for new therapeutic indications by mining evidence across six dimensions: pharmacology, target networks, clinical trials, literature, patents, and safety.

## When to Use

- "帮我找 metformin 的新适应症"
- "Sorafenib 除了肝癌还能治什么"
- "Drug repurposing opportunities for thalidomide"
- "X 的老药新用潜力"
- Any query about finding new uses for existing drugs

---

## Pipeline

### Step 1: Drug Profile

Gather comprehensive drug information:

```bash
bash: echo "=== DrugBank ===" && \
curl -s "https://go.drugbank.com/unearth/q?searcher=drugs&query=DRUGNAME&button=" 2>/dev/null && \
echo -e "\n=== ChEMBL ===" && \
curl -s "https://www.ebi.ac.uk/chembl/api/data/molecule/search.json?q=DRUGNAME&limit=5" && \
echo -e "\n=== PubChem ===" && \
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/DRUGNAME/JSON"
```

Extract:
- Approved indications and year of first approval
- Primary mechanism of action
- Known molecular targets (with confidence)
- Chemical class and properties (MW, logP, PSA)
- Half-life, bioavailability, metabolism pathway (CYP enzymes)

### Step 2: Target Network Analysis

Map drug targets to disease associations:

```bash
bash: echo "=== STRING PPI Network ===" && \
curl -s "https://string-db.org/api/json/network?identifiers=TARGET_GENE&species=9606&required_score=700" && \
echo -e "\n=== OpenTargets Disease Associations ===" && \
curl -s -X POST "https://api.platform.opentargets.org/api/v4/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ target(ensemblId:\"ENSG_ID\") { id approvedSymbol associatedDiseases(page:{size:20}) { rows { disease { id name } score datatypeScores { componentId score } } } } }"}'
```

**Key analysis**:
- Primary targets → known diseases (already approved)
- Secondary/off-targets → **new disease candidates**
- PPI network neighbors → diseases associated with interacting proteins
- Pathway enrichment → which disease pathways are modulated

### Step 3: Clinical Evidence Mining

Search for ALL clinical activity of this drug, including off-label and failed trials:

```bash
bash: echo "=== ClinicalTrials.gov (all indications) ===" && \
curl -s "https://clinicaltrials.gov/api/v2/studies?query.term=DRUGNAME&pageSize=50&sort=LastUpdatePostDate:desc" && \
echo -e "\n=== PubMed (off-label + repurposing) ===" && \
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=30&sort=relevance&term=DRUGNAME+AND+(repurpos*+OR+off-label+OR+repositioning+OR+novel+indication+OR+unexpected+effect)"
```

**What to look for**:
- Trials in non-approved indications (especially Phase 2+ with positive signals)
- Failed trials that revealed unexpected beneficial effects
- Case reports of off-label use with documented outcomes
- Systematic reviews of repurposing evidence

### Step 4: Patent Landscape

```bash
bash: web_search "DRUGNAME patent expiry date generic availability"
```

Assess:
- **Patent status**: Active / Expired / Expiring soon
- **Generic availability**: Already available = lower barrier to repurposing
- **New formulation patents**: May protect specific delivery methods
- **Method-of-use patents**: Filed for new indications?

Patent scoring:
- Expired + generic available: 20/20 (immediate repurposing potential)
- Expiring within 3 years: 15/20
- Active but no method-of-use patent for new indication: 10/20
- Active with broad claims: 5/20

### Step 5: Safety Profile

```bash
bash: echo "=== OpenFDA Adverse Events ===" && \
curl -s "https://api.fda.gov/drug/event.json?search=patient.drug.openfda.generic_name:%22DRUGNAME%22&count=patient.reaction.reactionmeddrapt.exact&limit=20" && \
echo -e "\n=== PubMed Safety ===" && \
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=10&term=DRUGNAME+AND+(safety+OR+adverse+OR+toxicity)+AND+review"
```

**Dual-use signal detection**: Some adverse effects hint at therapeutic potential:
| Adverse Effect | Potential Therapeutic Use |
|---------------|--------------------------|
| Weight loss | Obesity / metabolic syndrome |
| Hypoglycemia | Type 2 diabetes (if not already indicated) |
| Immunosuppression | Autoimmune diseases |
| Anti-proliferative effects | Cancer |
| Sedation | Insomnia / anxiety |
| Hair growth | Alopecia |

Flag these "adverse effects as therapeutic signals" prominently.

### Step 6: Repurposing Candidate Ranking

Score each candidate indication across four dimensions:

| Dimension | Max Score | Criteria |
|-----------|-----------|----------|
| **Target evidence** | 30 | Direct target involvement in disease (OpenTargets score, genetic evidence, expression data) |
| **Clinical evidence** | 30 | Positive trials, case reports, off-label efficacy data |
| **Safety** | 20 | Known safety profile compatible with chronic use; no organ-specific toxicity conflict |
| **Patent/feasibility** | 20 | Patent expired, generic available, regulatory pathway clear |

**Total score interpretation**:
- ≥70: **Strong candidate** — proceed to clinical validation planning
- 50–69: **Moderate candidate** — needs more preclinical evidence
- 30–49: **Weak candidate** — interesting signal but insufficient evidence
- <30: **Not recommended** — speculative at best

---

## Output Report Structure

```markdown
# Drug Repurposing Analysis: [DRUGNAME]

## Executive Summary
- [Drug] is approved for [indication] since [year]
- Analysis identified [N] potential repurposing candidates
- Top candidate: [Disease] (score: XX/100, evidence: ...)

## 1. Drug Profile
[Mechanism, targets, pharmacology]

## 2. Target Network & New Disease Associations
[Network figure + disease mapping table]

## 3. Clinical Evidence
[Trial summaries, off-label reports, case studies]

## 4. Patent Landscape
[Patent status, generic availability, IP barriers]

## 5. Safety Profile
[AE summary + dual-use signal analysis]

## 6. Ranked Repurposing Candidates

| Rank | Indication | Target Evidence | Clinical Evidence | Safety | Patent | Total | Verdict |
|------|-----------|----------------|-------------------|--------|--------|-------|---------|
| 1 | [Disease A] | 25/30 | 20/30 | 18/20 | 20/20 | 83/100 | Strong |
| 2 | [Disease B] | 20/30 | 15/30 | 15/20 | 15/20 | 65/100 | Moderate |
| ... | ... | ... | ... | ... | ... | ... | ... |

## 7. Recommended Next Steps
[For each strong candidate: specific preclinical/clinical validation steps]

## References
[GB/T 7714 format]
```

---

## Follow-up Suggestions

After completing the repurposing analysis, suggest:

1. For the top candidate: "可以用 gene-landscape recipe 深入分析 [target] 在 [new disease] 中的角色"
2. If clinical trials exist: "可以用 clinical-query recipe 详细了解 [new disease] 的现有治疗方案，评估竞争格局"
3. If target validation needed: "可以用 target-validation recipe 全面评估 [target] 的成药性"
