# tooluniverse-drug-target-validation — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 9: Literature Deep Dive

**Objective**: Comprehensive literature analysis with collision-aware search.

### 9A. Collision Detection

```python
# Detect naming collisions before literature search
test_results = tu.tools.PubMed_search_articles(
    query=f'"{gene_symbol}"[Title]', limit=20
)
# PubMed returns plain list of dicts
# Check if >20% of results are off-topic (no biology terms)
# If collision detected, add filters: AND (protein OR gene OR receptor OR kinase)
```

### 9B. Publication Metrics

```python
# Total publications
total = tu.tools.PubMed_search_articles(
    query=f'"{gene_symbol}" AND (protein OR gene)', limit=1
)
# Check total_count field

# Recent publications (5-year trend)
recent = tu.tools.PubMed_search_articles(
    query=f'"{gene_symbol}" AND (protein OR gene) AND ("2021"[PDAT] : "2026"[PDAT])',
    limit=50
)

# Drug-focused publications
drug_pubs = tu.tools.PubMed_search_articles(
    query=f'"{gene_symbol}" AND (drug OR therapeutic OR inhibitor OR antibody)',
    limit=30
)

# EuropePMC for broader coverage
epmc = tu.tools.EuropePMC_search_articles(
    query=f'"{gene_symbol}" AND drug target',
    limit=30
)
```

### 9C. Key Reviews and Landmark Papers

```python
# Reviews for target overview
reviews = tu.tools.PubMed_search_articles(
    query=f'"{gene_symbol}" AND drug target AND review[pt]',
    limit=10
)

# OpenAlex for citation metrics
openalex_works = tu.tools.openalex_search_works(
    query=f'{gene_symbol} drug target', limit=20
)
```

---

## Phase 10: Validation Roadmap (Synthesis)

**Objective**: Generate actionable recommendations based on all evidence.

This phase synthesizes all previous phases into:
1. **Target Validation Score** (0-100)
2. **Priority Tier** (1-4)
3. **GO/NO-GO Recommendation**
4. **Recommended Experiments**
5. **Tool Compounds for Testing**
6. **Biomarker Strategy**
7. **Key Risks & Mitigations**

### Score Calculation

```python
def calculate_validation_score(phase_results):
    """
    Calculate Target Validation Score (0-100).

    Components:
    - Disease Association: 0-30
    - Druggability: 0-25
    - Safety: 0-20
    - Clinical Precedent: 0-15
    - Validation Evidence: 0-10
    """
    score = {
        'disease_genetic': 0,      # 0-10
        'disease_literature': 0,   # 0-10
        'disease_pathway': 0,      # 0-10
        'drug_structural': 0,      # 0-10
        'drug_chemical': 0,        # 0-10
        'drug_class': 0,           # 0-5
        'safety_expression': 0,    # 0-5
        'safety_genetic': 0,       # 0-10
        'safety_adverse': 0,       # 0-5
        'clinical': 0,             # 0-15
        'validation_functional': 0, # 0-5
        'validation_models': 0,    # 0-5
    }

    # ... scoring logic from each phase ...

    total = sum(score.values())

    if total >= 80:
        tier = "Tier 1"
        recommendation = "GO - Highly validated target"
    elif total >= 60:
        tier = "Tier 2"
        recommendation = "CONDITIONAL GO - Needs focused validation"
    elif total >= 40:
        tier = "Tier 3"
        recommendation = "CAUTION - Significant validation needed"
    else:
        tier = "Tier 4"
        recommendation = "NO-GO - Consider alternatives"

    return total, tier, recommendation, score
```

---

## Report Template

**File**: `[TARGET]_[DISEASE]_validation_report.md`

```markdown
# Drug Target Validation Report: [TARGET]

**Target**: [Gene Symbol] ([Full Name])
**Disease Context**: [Disease Name] (if provided)
**Modality**: [Small molecule / Antibody / etc.] (if specified)
**Generated**: [Date]
**Status**: In Progress

---

## Executive Summary

**Target Validation Score**: [XX/100]
**Priority Tier**: [Tier X] - [Description]
**Recommendation**: [GO / CONDITIONAL GO / CAUTION / NO-GO]

**Key Findings**:
- [1-sentence disease association strength with evidence grade]
- [1-sentence druggability assessment]
- [1-sentence safety profile]
- [1-sentence clinical precedent]

**Critical Risks**:
- [Top risk 1]
- [Top risk 2]

---

## Validation Scorecard

| Dimension | Score | Max | Assessment | Key Evidence |
|-----------|-------|-----|------------|--------------|
| **Disease Association** | | 30 | | |
| - Genetic evidence | | 10 | | |
| - Literature evidence | | 10 | | |
| - Pathway evidence | | 10 | | |
| **Druggability** | | 25 | | |
| - Structural tractability | | 10 | | |
| - Chemical matter | | 10 | | |
| - Target class | | 5 | | |
| **Safety Profile** | | 20 | | |
| - Expression selectivity | | 5 | | |
| - Genetic validation | | 10 | | |
| - Known ADRs | | 5 | | |
| **Clinical Precedent** | | 15 | | |
| **Validation Evidence** | | 10 | | |
| - Functional studies | | 5 | | |
| - Disease models | | 5 | | |
| **TOTAL** | **XX** | **100** | **[Tier]** | |

---

## 1. Target Identity
[Researching...]

## 2. Disease Association Evidence
### 2.1 OpenTargets Disease Associations
[Researching...]
### 2.2 GWAS Genetic Evidence
[Researching...]
### 2.3 Constraint Scores (gnomAD)
[Researching...]
### 2.4 Literature Evidence
[Researching...]

## 3. Druggability Assessment
### 3.1 Tractability (OpenTargets)
[Researching...]
### 3.2 Target Classification
[Researching...]
### 3.3 Structural Tractability
[Researching...]
### 3.4 Chemical Probes & Enabling Packages
[Researching...]

## 4. Known Modulators & Chemical Matter
### 4.1 Approved/Clinical Drugs
[Researching...]
### 4.2 ChEMBL Bioactivity
[Researching...]
### 4.3 BindingDB Ligands
[Researching...]
### 4.4 PubChem Bioassays
[Researching...]
### 4.5 Chemical Probes
[Researching...]

## 5. Clinical Precedent
### 5.1 FDA-Approved Drugs
[Researching...]
### 5.2 Clinical Trial Landscape
[Researching...]
### 5.3 Failed Programs & Lessons
[Researching...]

## 6. Safety & Toxicity Profile
### 6.1 OpenTargets Safety Liabilities
[Researching...]
### 6.2 Expression in Critical Tissues
[Researching...]
### 6.3 Knockout Phenotypes
[Researching...]
### 6.4 Known Adverse Events
[Researching...]
### 6.5 Paralog & Off-Target Risks
[Researching...]

## 7. Pathway Context & Network Analysis
### 7.1 Biological Pathways
[Researching...]
### 7.2 Protein-Protein Interactions
[Researching...]
### 7.3 Functional Enrichment
[Researching...]
### 7.4 Pathway Redundancy Assessment
[Researching...]

## 8. Validation Evidence
### 8.1 Target Essentiality (DepMap)
[Researching...]
### 8.2 Functional Studies
[Researching...]
### 8.3 Animal Models
[Researching...]
### 8.4 Biomarker Potential
[Researching...]

## 9. Structural Insights
### 9.1 Experimental Structures (PDB)
[Researching...]
### 9.2 AlphaFold Prediction
[Researching...]
### 9.3 Binding Pocket Analysis
[Researching...]
### 9.4 Domain Architecture
[Researching...]

## 10. Literature Landscape
### 10.1 Publication Metrics
[Researching...]
### 10.2 Key Publications
[Researching...]
### 10.3 Research Trend
[Researching...]

## 11. Validation Roadmap
### 11.1 Recommended Validation Experiments
[Researching...]
### 11.2 Tool Compounds for Testing
[Researching...]
### 11.3 Biomarker Strategy
[Researching...]
### 11.4 Clinical Biomarker Candidates
[Researching...]
### 11.5 Disease Models to Test
[Researching...]

## 12. Risk Assessment
### 12.1 Key Risks
[Researching...]
### 12.2 Mitigation Strategies
[Researching...]
### 12.3 Competitive Landscape
[Researching...]

## 13. Completeness Checklist
[To be populated post-audit...]

## 14. Data Sources & Methodology
[Will be populated as research progresses...]
```

---

## Completeness Checklist (MANDATORY)

Before finalizing, verify:

```markdown
## 13. Completeness Checklist

### Phase Coverage
- [ ] Phase 0: Target disambiguation (all IDs resolved)
- [ ] Phase 1: Disease association (OT + GWAS + gnomAD + literature)
- [ ] Phase 2: Druggability (tractability + class + structure + probes)
- [ ] Phase 3: Chemical matter (ChEMBL + BindingDB + PubChem + drugs)
- [ ] Phase 4: Clinical precedent (FDA + trials + failures)
- [ ] Phase 5: Safety (OT safety + expression + KO + ADRs + paralogs)
- [ ] Phase 6: Pathway context (Reactome + STRING + GO)
- [ ] Phase 7: Validation evidence (DepMap + literature + models)
- [ ] Phase 8: Structural insights (PDB + AlphaFold + pockets + domains)
- [ ] Phase 9: Literature (collision-aware + metrics + key papers)
- [ ] Phase 10: Validation roadmap (score + recommendations)

### Data Quality
- [ ] All scores justified with specific data
- [ ] Evidence grades (T1-T4) assigned to key claims
- [ ] Negative results documented (not left blank)
- [ ] Failed tools with fallbacks documented
- [ ] Source citations for all data points

### Scoring
- [ ] All 12 score components calculated
- [ ] Total score summed correctly
- [ ] Priority tier assigned
- [ ] GO/NO-GO recommendation justified
```

---

## Fallback Chains

| Primary Tool | Fallback 1 | Fallback 2 | If All Fail |
|--------------|------------|------------|-------------|
| `OpenTargets_get_diseases_phenotypes_*` | `CTD_get_gene_diseases` | PubMed search | Note in report |
| `GTEx_get_median_gene_expression` (versioned) | GTEx (unversioned) | `HPA_search_genes_by_query` | Document gap |
| `ChEMBL_get_target_activities` | `BindingDB_get_ligands_by_uniprot` | `DGIdb_get_gene_info` | Note in report |
| `gnomad_get_gene_constraints` | `OpenTargets_get_target_constraint_info_*` | - | Note as unavailable |
| `Reactome_map_uniprot_to_pathways` | `OpenTargets_get_target_gene_ontology_*` | - | Use GO only |
| `STRING_get_protein_interactions` | `intact_get_interactions` | `OpenTargets interactions` | Note in report |
| `ProteinsPlus_predict_binding_sites` | `alphafold_get_prediction` | Literature pockets | Note as limited |

---

## Modality-Specific Considerations

### Small Molecule Focus
- Emphasize: binding pockets, ChEMBL compounds, Lipinski compliance
- Key tractability: OpenTargets SM tractability bucket
- Structure: co-crystal structures with small molecule ligands
- Chemical matter: IC50/Ki/Kd data from ChEMBL/BindingDB

### Antibody Focus
- Emphasize: extracellular domains, cell surface expression, glycosylation
- Key tractability: OpenTargets AB tractability bucket
- Structure: ectodomain structures, epitope mapping
- Expression: surface expression in disease vs normal tissue

### PROTAC Focus
- Emphasize: intracellular targets, surface lysines, E3 ligase proximity
- Key tractability: OpenTargets PROTAC tractability
- Structure: full-length structures for linker design
- Chemical matter: known binders + E3 ligase binders

---

## Quick Reference: Verified Tool Parameters

| Tool | Parameters | Notes |
|------|-----------|-------|
| `ensembl_lookup_gene` | `gene_id`, `species` | species="homo_sapiens" REQUIRED; response wrapped in `{status, data, url, content_type}` |
| `OpenTargets_get_*_by_ensemblID` | `ensemblId` | camelCase, NOT ensemblID |
| `OpenTargets_get_publications_by_target_ensemblID` | `entityId` | NOT ensemblId |
| `OpenTargets_get_associated_drugs_by_target_ensemblID` | `ensemblId`, `size` | size is REQUIRED |
| `OpenTargets_target_disease_evidence` | `efoId`, `ensemblId` | Both REQUIRED |
| `GTEx_get_median_gene_expression` | `operation`, `gencode_id` | operation="median" REQUIRED |
| `HPA_get_rna_expression_by_source` | `gene_name`, `source_type`, `source_name` | ALL 3 required |
| `PubMed_search_articles` | `query`, `limit` | Returns plain list, NOT {articles:[]} |
| `UniProt_get_function_by_accession` | `accession` | Returns list of strings |
| `alphafold_get_prediction` | `qualifier` | NOT uniprot_accession |
| `drugbank_get_safety_*` | `query`, `case_sensitive`, `exact_match`, `limit` | ALL required |
| `STRING_get_protein_interactions` | `protein_ids`, `species` | protein_ids is array; species=9606 |
| `Reactome_map_uniprot_to_pathways` | `id` | NOT uniprot_id |
| `ChEMBL_get_target_activities` | `target_chembl_id__exact` | Note double underscore |
| `search_clinical_trials` | `query_term` | REQUIRED parameter |
| `gnomad_get_gene_constraints` | `gene_symbol` | NOT gene_id |
| `DepMap_get_gene_dependencies` | `gene_symbol` | NOT gene_id |
| `BindingDB_get_ligands_by_uniprot` | `uniprot`, `affinity_cutoff` | affinity in nM |
| `Pharos_get_target` | `gene` or `uniprot` | Both optional but need one |

---

## Example Execution: EGFR for NSCLC

### Phase 0 Result
- Symbol: EGFR, Ensembl: ENSG00000146648, UniProt: P00533, ChEMBL: CHEMBL203

### Expected Scores (EGFR for NSCLC)
- Disease Association: ~28/30 (strong genetic + pathway + literature)
- Druggability: ~24/25 (kinase, many structures, abundant compounds)
- Safety: ~14/20 (widely expressed but manageable toxicity)
- Clinical Precedent: 15/15 (multiple approved drugs)
- Validation Evidence: ~9/10 (extensive functional data)
- **Total: ~90/100 = Tier 1**

### Example for Novel Target (e.g., understudied kinase)
- Disease Association: ~8/30 (limited GWAS, few publications)
- Druggability: ~15/25 (kinase family bonus, AlphaFold structure)
- Safety: ~12/20 (limited data, unknown KO phenotype)
- Clinical Precedent: 0/15 (no clinical development)
- Validation Evidence: ~2/10 (minimal functional data)
- **Total: ~37/100 = Tier 4**
