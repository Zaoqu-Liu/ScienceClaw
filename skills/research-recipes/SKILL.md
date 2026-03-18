---
name: research-recipes
description: Pre-built research workflow templates that execute complete multi-step analyses from a single user prompt. Triggers on gene analysis, target validation, literature review, differential expression, clinical queries, researcher profiling, drug repurposing, or molecular dynamics simulation. Use when the user's query matches a Recipe pattern defined in SCIENCE.md.
---

# Research Recipes

Complete research workflows that ScienceClaw executes autonomously. Each Recipe defines a multi-step pipeline from query to report. When a user's prompt matches a Recipe trigger, execute the full pipeline without asking for confirmation.

## When to Use

- User asks to "分析 X 在 Y 中的作用" → gene-landscape
- User asks to "评估 X 的成药性" → target-validation
- User asks to "综述 X" or "survey X" → literature-review
- User provides expression data for analysis → diff-expression
- User asks about treatment options → clinical-query
- User asks to profile a researcher → person-research
- User asks "X 的新适应症" or "drug repurposing" → drug-repurposing
- User asks "跑个 MD 模拟" or "molecular dynamics" → molecular-dynamics

## Recipe Execution Rules

1. **Detect** the matching Recipe from trigger patterns
2. **Create** a project directory: `~/.scienceclaw/workspace/projects/<slug>-<YYYY-MM-DD>/`
3. **Execute** each step, reporting substantive progress (numbers, not filler)
4. **Generate** METHODS.md at the end
5. **List** all output files and offer export options
6. **Suggest** 2-3 scientifically-motivated follow-ups

---

## Recipe 1: gene-landscape

**Trigger**: "分析 X 在 Y 中的作用", "investigate X in Y", "X 在 Y 中的角色/功能"

### Steps

**Step 1 — Literature Search (PubMed + OpenAlex + Semantic Scholar)**

```bash
bash: echo "=== PubMed ===" && \
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=30&sort=relevance&term=GENE+AND+DISEASE" && \
echo -e "\n=== OpenAlex ===" && \
curl -s "https://api.openalex.org/works?search=GENE+DISEASE&per_page=15&sort=relevance_score:desc&select=id,title,authorships,publication_year,cited_by_count,doi" && \
echo -e "\n=== Semantic Scholar ===" && \
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=GENE+DISEASE&limit=15&fields=title,authors,year,abstract,citationCount,externalIds"
```

Fetch abstracts for top 10 PMIDs. Report: "PubMed 检索到 N 篇，OpenAlex N 篇，S2 N 篇，获取前 10 篇摘要..."

**Step 2 — Pan-cancer Expression (TCGA via cBioPortal)**

Query TCGA expression data across cancer types. Use cBioPortal REST API or direct TCGA data. Generate a boxplot of expression across cancer types.

Report: "TCGA 数据获取完成，GENE 在 N/33 癌种中显著上调..."

**Step 3 — Survival Analysis**

For cancer types with significant expression changes, run Kaplan-Meier survival analysis:

```r
library(survival); library(survminer)
# Split by median/optimal cutoff
# KM plot + log-rank p-value + Cox HR with 95% CI
```

Report: "STAD 生存分析完成：HR=X.XX (95%CI: X.XX-X.XX, p=X.XXX)..."

**Step 4 — Immune Infiltration Correlation**

Query TIMER2.0 or compute from TCGA data. Correlate gene expression with immune cell infiltration scores (M1/M2 macrophages, CD8+ T cells, Tregs, etc.).

Report: "免疫浸润分析完成，与 M2 巨噬细胞最强相关 (r=X.XX, p<X.XXX)..."

**Step 5 — Pathway Enrichment**

Use co-expressed genes (top 200 by Pearson correlation) for GO/KEGG enrichment via Enrichr or local R (clusterProfiler).

Report: "通路富集分析完成，N 条 GO terms，N 条 KEGG pathways 显著..."

**Step 6 — Report Assembly**

Compile all findings into `reports/GENE_DISEASE_report.md`:
- Executive summary (key findings in 3-5 bullets)
- Expression profiling results (with boxplot figure)
- Survival analysis results (with KM figure)
- Immune microenvironment analysis
- Pathway enrichment results (with dot plot)
- Limitations and caveats
- References (GB/T 7714 format from actual search results)

Generate `METHODS.md`. List all files. Offer export options. Suggest follow-ups.

### Output

`reports/GENE_DISEASE_report.md` + `METHODS.md` + `figures/` (boxplot, KM curve, enrichment dot plot)

---

## Recipe 2: target-validation

**Trigger**: "评估 X 的成药性", "X 能不能做靶点", "druggability of X", "target validation for X"

### Steps

1. **Literature search** — PubMed + OpenAlex for target + druggability/therapeutic
2. **Protein info** — UniProt (function, domains, subcellular location) + AlphaFold (structure availability)
3. **Protein interactions** — STRING network (top 10 interactors, confidence > 0.7)
4. **Existing compounds** — ChEMBL (bioactivity data, IC50/EC50) + PubChem
5. **Drug info** — DrugBank (approved/investigational drugs targeting this protein)
6. **Clinical trials** — ClinicalTrials.gov (interventional trials mentioning the target)
7. **Patent landscape** — Quick search via web_search for patents
8. **Report** — Druggability assessment with evidence grading (Strong/Moderate/Weak/None)

### Output

`reports/GENE_target_validation_report.md` with sections for each step, evidence summary table, and overall druggability verdict.

---

## Recipe 3: literature-review (Parallel Chapter Architecture)

**Trigger**: "综述 X", "survey X", "X 的研究进展", "review the literature on X"

### Overview

Uses an **outline-first, chapter-by-chapter** deep research approach inspired by DeepResearchAgent. Instead of a linear pipeline, the review is structured as: broad scan → outline → per-chapter deep dive → cross-chapter synthesis.

### Steps

**Step 1 — Broad Scan & Outline Generation**

Search all sources (PubMed 50 + OpenAlex 30 + Semantic Scholar 30 + Asta 15 + bioRxiv/arXiv if relevant). Deduplicate by DOI > PMID > title. Read all abstracts. Cluster papers into 4–6 themes. Generate a structured outline:

```markdown
## Outline: [TOPIC] Literature Review

1. Introduction and Historical Context
2. [Theme A]: [Description] (N papers)
3. [Theme B]: [Description] (N papers)
4. [Theme C]: [Description] (N papers)
5. Current Challenges and Controversies
6. Future Directions and Emerging Opportunities
```

Report: "广搜完成：PubMed N 篇，OpenAlex N 篇，S2 N 篇，Asta N 篇。去重后 N 篇。聚类为 N 个主题，生成了 outline。"

**Step 2 — Per-Chapter Deep Dive**

For each chapter in the outline, independently:
- Run chapter-specific keyword searches (narrower, more targeted than Step 1)
- Trace citation chains from the most relevant papers in that theme
- Read full text for the top 2–3 papers per chapter (via Jina Reader or Europe PMC)
- Extract key findings, methodological approaches, contradictions, and gaps
- Write the chapter section progressively to the report file

Report per chapter: "第 N 章「[Theme]」深度搜索完成：新增 N 篇文献，阅读 N 篇全文。"

**Step 3 — Cross-Chapter Synthesis**

After all chapters are written:
- Check for contradictions or redundancies between chapters
- Ensure consistent citation numbering across the entire review
- Write Executive Summary (key findings in 5–8 bullets with numbers)
- Write "Research Gaps and Open Questions" section
- Write "Future Directions" section grounded in specific data gaps identified

**Step 4 — Publication Trend & Figures**

- Year-by-year publication count chart (matplotlib bar chart)
- Optional: citation network visualization for top papers
- Optional: keyword co-occurrence heatmap

**Step 5 — References & Finalization**

- GB/T 7714 format, numbered by order of appearance
- Verify every citation against tool results (zero fabrication)
- Generate METHODS.md

### Output

`reports/literature_review_TOPIC.md` (structured review, 4000–8000 words) + `figures/publication_trend_TOPIC.png` + `METHODS.md`

---

## Recipe 4: diff-expression

**Trigger**: "分析这个表达矩阵", "差异表达分析", "DEG analysis", "differential expression"

### Steps

1. **Read data** — Load the user's expression matrix (CSV/TSV/Excel)
2. **QC** — Sample distribution, missing values, normalization check
3. **Differential expression** — DESeq2 (count data) or limma (normalized), with fold change and adjusted p-value
4. **Volcano plot** — Highlight significantly up/down-regulated genes (NPG palette)
5. **Heatmap** — Top 50 DEGs, clustered by sample and gene
6. **GO/KEGG enrichment** — Up-regulated and down-regulated gene sets separately
7. **Report** — Summary of DEG counts, top genes, enriched pathways

### Output

`figures/volcano_plot.png`, `figures/heatmap_top50_deg.png`, `figures/go_enrichment.png`, `data/deg_results.csv`, `reports/deg_analysis_report.md`

---

## Recipe 5: clinical-query

**Trigger**: "X 的最新治疗方案", "X 怎么治", "treatment for X", "X 的临床指南"

### Steps

1. **Clinical trials** — ClinicalTrials.gov API (interventional, Phase 2-4, recruiting/completed)
2. **Treatment guidelines** — PubMed search for "X treatment guidelines" OR "X clinical practice guideline", recent 3 years
3. **Drug options** — DrugBank search for approved drugs for the disease
4. **Summary table** — Drug name, mechanism, approval status, trial phase, key efficacy data

### Output

Direct response in chat (this is a quick-to-medium task). If results are extensive, create a project and report.

---

## Recipe 6: person-research

**Trigger**: "调研 X 教授", "X 的学术背景", "profile of Dr. X", "X 发了哪些文章"

### Steps

1. **Author search** — OpenAlex author API (name match, affiliation, h-index, works count, cited_by_count)
2. **Publication list** — PubMed author search, top 10 by citation
3. **Citation metrics** — Total citations, h-index, i10-index (from OpenAlex)
4. **Research themes** — Extract top keywords/concepts from their works
5. **Report** — Academic profile with metrics, top papers, research focus areas

### Output

`reports/researcher_profile_NAME.md`

---

## Recipe 7: drug-repurposing

**Trigger**: "帮我找 X 的新适应症", "X 能不能重定位到 Y", "drug repurposing for X", "X 的老药新用", "repurpose X"

### Steps

1. **Drug profile** — DrugBank (approved indications, mechanism, targets) + ChEMBL (bioactivity data, off-target hits) + PubChem (chemical properties, similar compounds)
2. **Target network analysis** — STRING/OpenTargets: map drug targets to PPI network. Identify "unexpected targets" → map to new diseases via OpenTargets disease associations
3. **Clinical evidence mining** — ClinicalTrials.gov: ALL trials for this drug (including failed/terminated ones for off-label indications) + PubMed: case reports, retrospective studies, off-label use reports
4. **Patent landscape** — web_search: "[drug] patent expiry", "[drug] generic availability". Patent expiry = higher repurposing viability
5. **Safety profile** — OpenFDA adverse event reports. Note: some "adverse effects" may indicate therapeutic potential (e.g., metformin weight loss → obesity, metformin anti-cancer signals)
6. **Repurposing candidate ranking** — Score each candidate indication by: target evidence (0-30) × clinical evidence (0-30) × safety (0-20) × patent status (0-20). Output ranked table with evidence summaries

For detailed pipeline implementation, refer to the `drug-repurposing` skill.

### Output

`reports/drug_repurposing_DRUGNAME.md` (ranked candidates with evidence) + `figures/target_network_DRUGNAME.png`

---

## Recipe 8: molecular-dynamics

**Trigger**: "跑个分子动力学模拟", "molecular dynamics for X", "binding free energy of X", "蛋白配体模拟", "MD simulation"

### Steps

1. **Structure retrieval** — Fetch from PDB or AlphaFold by protein ID/gene name
2. **System preparation** — Force field assignment, solvation, ionization via OpenMM/AmberTools
3. **Energy minimization** — Minimize with self-correction (verify potential energy convergence)
4. **Equilibration** — NVT then NPT ensemble equilibration
5. **Production run** — Record trajectory (length depends on system size, default 10 ns)
6. **Analysis** — RMSD, RMSF, hydrogen bonds, radius of gyration, binding free energy (MM/PBSA if ligand present)
7. **Report** — Figures + structural insights + stability assessment

**Note**: Requires OpenMM or GROMACS to be installed. Check via `scienceclaw doctor`. If not available, report and suggest installation.

For detailed pipeline implementation, refer to the `molecular-dynamics` skill.

### Output

`reports/md_simulation_PROTEIN.md` + `figures/rmsd_*.png` + `figures/rmsf_*.png` + `data/trajectory_*.dcd`
