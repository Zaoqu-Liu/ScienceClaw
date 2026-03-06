# Case Study: THBS2 in Tumors — Full Team Research

> **User prompt:** "Investigate the role and significance of THBS2 in tumors"

---

## Agent Workflow

Monica dispatched three specialists in parallel, then auto-triggered QC and integration:

| Agent | Role | Task |
|-------|------|------|
| Phoebe | Literature | Deep search across PubMed, arXiv, Semantic Scholar, OpenAlex + 7 more sources |
| Ross | Data Analysis | Pan-cancer expression profiling, survival analysis, immune infiltration, co-expression networks |
| Mike | IP & Translation | Patent landscape, clinical trials, commercial products, competitive analysis |
| Chandler | QC (auto) | Cross-report contradiction detection, citation audit, statistical rigor check |
| Joey | Integration (auto) | Key findings synthesis across all reports |

---

## Key Findings

### Pan-Cancer Expression (Ross)

THBS2 is significantly upregulated in **17 out of 33 TCGA cancer types**, particularly in gastrointestinal tumors:

| Cancer Type | Direction | Clinical Significance |
|-------------|-----------|----------------------|
| Gastric (STAD) | Upregulated | Poor OS (p=0.003), macrophage infiltration correlation (r=0.590) |
| Colorectal (COAD/READ) | Upregulated | Independent prognostic factor: HR=0.158–0.237 (p<0.001) |
| Pancreatic (PAAD) | Upregulated | Most significantly upregulated ECM molecule |
| Lung (LUAD/LUSC) | Upregulated | Apparent contradiction: bulk RNA-seq shows upregulation, but epithelial cells are methylation-silenced |
| Breast (BRCA) | Upregulated | Same contradiction as lung — driven by CAF expression in stroma |

### Diagnostic Value (Phoebe + Mike)

| Marker Combination | AUC | Application | Status |
|--------------------|-----|-------------|--------|
| THBS2 + CA19-9 | 0.96 (retrospective) | Pancreatic cancer early detection | Validation stage |
| THBS2 + CA19-9 | 0.69 (prospective) | Pancreatic cancer screening | Significant drop from retrospective |
| Exosome THBS2 | 0.993 | Next-gen liquid biopsy | Pre-clinical |
| THBS2 methylation | Part of Cologuard | Colorectal cancer screening | **FDA approved** |
| Proclarix (contains THBS2) | — | Prostate cancer diagnosis | **CE marked** |

### Immune Microenvironment (Ross)

- THBS2 is a **CAF signature gene** (COL11A1/THBS2/INHBA) — expressed by cancer-associated fibroblasts, not tumor cells themselves
- Strong positive correlation with M2 macrophage infiltration
- Regulates CD47-SIRPa "don't eat me" signaling, promoting immune evasion
- Correlates with PD-L1 and CTLA4 in multiple cancer types

### Patent Landscape (Mike)

| Patent | Holder | Coverage |
|--------|--------|----------|
| US20200249235A1 | University of Pennsylvania (Zaret Lab) | THBS2+CA19-9 pancreatic cancer diagnosis methods and kits |
| WO2018011212 | Proteomedix AG (Switzerland) | THBS2 for prostate cancer diagnosis (Proclarix) |
| US20230266329A1 | Cornell University (Lyden Lab) | Exosome THBS2 for multi-cancer detection |

### Quality Issues Caught by Chandler

Chandler's QC review identified critical problems that would have gone unnoticed:

- **Data contradiction**: Phoebe classified lung/breast cancer as "methylation-silenced" while Ross's TCGA data showed upregulation — both correct at different cellular levels (epithelial vs stromal)
- **Selective reporting**: Phoebe's report only showed retrospective AUC (0.96) but omitted prospective validation failure (0.69)
- **Suspicious citations**: Multiple references lacked PMIDs or had unverifiable author names
- **Missing context**: ABT-510 (TSR peptide mimetic) clinical trial **failure** was not mentioned — only its entry into Phase II
- **Fundamental question**: Is THBS2 a **driver** or a **passenger** (bystander biomarker of CAF activation)? This directly impacts therapeutic targeting feasibility

---

## Summary

| Dimension | Finding |
|-----------|---------|
| Expression | Upregulated in 17/33 cancers, primarily from tumor stroma (CAFs) |
| Prognosis | Consistently poor prognosis in GI cancers (gastric, colorectal, pancreatic) |
| Diagnosis | THBS2+CA19-9 promising but prospective validation disappointing (AUC 0.96 to 0.69) |
| Treatment | Early stage — epigenetic reactivation in silenced cancers, neutralizing antibodies in overexpressing cancers |
| IP | Core patents held by UPenn (Zaret Lab); Proclarix commercially available for prostate cancer |
| Key risk | Driver vs passenger question unresolved; same team published alternative (ANPEP+PIGR) in 2026 |
