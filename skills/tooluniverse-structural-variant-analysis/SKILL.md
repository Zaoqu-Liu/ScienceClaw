---
name: tooluniverse-structural-variant-analysis
description: Comprehensive structural variant (SV) analysis skill for clinical genomics. Classifies SVs (deletions, duplications, inversions, translocations), assesses pathogenicity using ACMG-adapted criteria, evaluates gene disruption and dosage sensitivity, and provides clinical interpretation with evidence grading. Use when analyzing CNVs, large deletions/duplications, chromosomal rearrangements, or any structural variants requiring clinical interpretation.
---

# Structural Variant Analysis Workflow

Systematic analysis of structural variants (deletions, duplications, inversions, translocations, complex rearrangements) for clinical genomics interpretation using ACMG-adapted criteria.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create SV_analysis_report.md FIRST, then populate progressively
2. **ACMG-style classification** - Pathogenic/Likely Pathogenic/VUS/Likely Benign/Benign with explicit evidence
3. **Evidence grading** - Grade all findings by confidence level (★★★/★★☆/★☆☆)
4. **Dosage sensitivity critical** - Gene dosage effects drive SV pathogenicity
5. **Breakpoint precision matters** - Exact gene disruption vs dosage-only effects
6. **Population context essential** - gnomAD SVs for frequency assessment
7. **English-first queries** - Always use English terms in tool calls

---

## Triggers

Use this skill when users:
- Ask about structural variant interpretation or CNV data
- Ask "is this deletion/duplication pathogenic?"
- Need ACMG classification for SVs or gene dosage assessment
- Have chromosomal rearrangements requiring interpretation

**NOT for**: SNV/indel interpretation → `tooluniverse-variant-interpretation`; gene enrichment → `tooluniverse-gene-enrichment`

---

## Workflow (7 Phases)

### Phase 1: SV Identity & Classification

Normalize coordinates (hg19/hg38), determine type (DEL/DUP/INV/TRA/CPX), calculate size, assess breakpoint precision.

| SV Type | Abbreviation | Molecular Effect |
|---------|-------------|------------------|
| Deletion | DEL | Haploinsufficiency, gene disruption |
| Duplication | DUP | Triplosensitivity, dosage imbalance |
| Inversion | INV | Gene disruption at breakpoints, position effects |
| Translocation | TRA | Gene fusions, disruption, position effects |
| Complex | CPX | Variable effects |

### Phase 2: Gene Content Analysis

Identify genes fully contained in SV and genes with breakpoints (disrupted). Annotate function and disease associations.

| Tool | Purpose |
|------|---------|
| `Ensembl_lookup_gene` | Gene structure, coordinates, exons |
| `NCBI_gene_search` | Official symbol, description |
| `OMIM_search` + `OMIM_get_entry` | Disease associations, inheritance |
| `DisGeNET_search_gene` | Gene-disease evidence scores |
| `Gene_Ontology_get_term_info` | Biological process, molecular function |

### Phase 3: Dosage Sensitivity Assessment

```python
from tooluniverse import ToolUniverse
tu = ToolUniverse(use_cache=True); tu.load_tools()

# ClinGen dosage (gold standard)
clingen = tu.tools.ClinGen_search_dosage_sensitivity(gene="KANSL1")
# -> hi_score: 3 = Sufficient evidence for HI

# ClinGen gene validity
validity = tu.tools.ClinGen_search_gene_validity(gene="KANSL1")
# -> Classification: Definitive

# gnomAD constraint (pLI)
gnomad = tu.tools.gnomad_get_gene_constraints(gene_symbol="KANSL1")
# -> pLI close to 1.0 = loss-of-function intolerant

# OMIM inheritance
omim = tu.tools.OMIM_search(operation="search", query="KANSL1", limit=3)
```

**Evidence grading**: HI/TS score=3 + Definitive validity = ★★★ | Score 2-3 = ★★☆ | Otherwise = ★☆☆

### Phase 4: Population Frequency Context

| Tool | Purpose |
|------|---------|
| `gnomad_search` | Population SV frequencies, overlapping SVs |
| `ClinVar_search_variants` | Known pathogenic/benign SVs (chromosome, start, stop, variant_type) |
| `DECIPHER_search` | Patient SVs with phenotypes, case reports |

**ACMG frequency codes**:
- ≥1% in gnomAD SVs → BA1 (Stand-alone Benign)
- 0.1-1% → BS1 (Strong Benign)
- <0.01% or absent → PM2 (Supporting Pathogenic)

**Reciprocal overlap**: min(overlap/SV_A_length, overlap/SV_B_length) ≥70% = "same" SV

### Phase 5: Pathogenicity Scoring (0-10)

| Component | Weight | Max Points |
|-----------|--------|-----------|
| Gene content | 40% | 4 pts: dosage-sensitive gene disrupted; 3: disease gene fully contained; 2: OMIM gene; 1: any gene |
| Dosage sensitivity | 30% | 3 pts: HI/TS score=3 + Definitive validity; 2: score 2-3; 1: predicted only |
| Population frequency | 20% | 2 pts: absent from gnomAD+DGV; 1: rare (<0.01%); 0: common |
| Clinical match | 10% | 1 pt: phenotype consistent + literature support |

**Score interpretation**:
- **9-10**: Pathogenic | **7-8.9**: Likely Pathogenic | **4-6.9**: VUS | **2-3.9**: Likely Benign | **0-1.9**: Benign

### Phase 6: Literature & Clinical Evidence

| Tool | Purpose |
|------|---------|
| `PubMed_search_articles` | Similar SVs, gene disruption studies (returns plain list) |
| `DECIPHER_search` | Developmental disorder cases with overlapping SVs |
| `EuropePMC_search_articles` | Broader literature search |

### Phase 7: ACMG-Adapted Classification

**Key pathogenic codes for SVs**:
- PVS1: Gene disruption of established HI gene (Very Strong)
- PS1: Same SV as known pathogenic in ClinVar (Strong)
- PS3: Functional studies confirm dosage sensitivity (Strong)
- PM2: Absent from population databases (Moderate)
- PP4: Patient phenotype matches gene's disease (Supporting)

**Key benign codes**:
- BA1: ≥1% frequency in gnomAD SVs (Stand-alone)
- BS1: 0.1-1% frequency (Strong)
- BP1: No known disease genes in region (Supporting)

**Classification**: 1 Very Strong + 1 Strong = Pathogenic | 1 Very Strong + 1-2 Moderate = Likely Pathogenic | Contradictory = VUS

---

## Report Template

| Section | Content |
|---------|---------|
| 1. SV Summary | Type, coordinates, size, breakpoint precision |
| 2. Gene Content | Fully contained genes, disrupted genes, regulatory elements |
| 3. Dosage Sensitivity | ClinGen HI/TS scores, pLI, validity level per gene |
| 4. Population Frequency | gnomAD/ClinVar/DECIPHER overlaps, ACMG codes |
| 5. Pathogenicity Score | 0-10 score with component breakdown |
| 6. Literature Evidence | Key publications, DECIPHER cases, functional evidence |
| 7. ACMG Classification | Evidence codes applied, final classification + rationale |
| 8. Clinical Recommendations | Immediate actions, further investigation, genetic counseling |

---

> **Extended Reference**: Full Python implementations for each phase, detailed ACMG criteria tables, example reports, and edge case handling are in `REFERENCE.md`.
