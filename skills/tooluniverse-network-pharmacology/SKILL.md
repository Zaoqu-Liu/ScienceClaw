---
name: tooluniverse-network-pharmacology
description: Construct and analyze compound-target-disease networks for drug repurposing, polypharmacology discovery, and systems pharmacology. Builds multi-layer networks from ChEMBL, OpenTargets, STRING, DrugBank, Reactome, FAERS, and 60+ other ToolUniverse tools. Calculates Network Pharmacology Scores (0-100), identifies repurposing candidates, predicts mechanisms, and analyzes polypharmacology. Use when users ask about drug repurposing via network analysis, multi-target drug effects, compound-target-disease networks, systems pharmacology, or polypharmacology.
---

# Network Pharmacology Pipeline

Construct and analyze compound-target-disease (C-T-D) networks to identify drug repurposing opportunities, understand polypharmacology, and predict drug mechanisms using systems pharmacology approaches.

**IMPORTANT**: Always use English terms in tool calls (drug names, disease names, target names), even if the user writes in another language. Respond in the user's language.

---

## When to Use This Skill

Apply when users:
- Ask "Can [drug] be repurposed for [disease] based on network analysis?"
- Want to understand multi-target (polypharmacology) effects of a compound
- Need compound-target-disease network construction and analysis
- Ask about network proximity between drug targets and disease genes
- Want systems pharmacology analysis of a drug or target
- Need mechanism prediction for a drug in a new indication

**NOT for** (use other skills instead):
- Simple drug repurposing without network analysis -> `tooluniverse-drug-repurposing`
- Single target validation -> `tooluniverse-drug-target-validation`
- Adverse event detection only -> `tooluniverse-adverse-event-detection`

---

## Network Pharmacology Score (0-100)

| Component | Max Points | Criteria |
|-----------|-----------|----------|
| Network Proximity | 35 | Z<-2, p<0.01 = 35pts; Z<-1, p<0.05 = 20pts; Z<-0.5 = 10pts |
| Clinical Evidence | 25 | Approved related = 25; Active trials = 15; Completed = 10; Preclinical = 5 |
| Target-Disease Association | 20 | GWAS/rare variants = 20; Pathway/literature = 12; Computational = 5 |
| Safety Profile | 10 | FDA-approved favorable = 10; Manageable AEs = 7; Significant concerns = 3 |
| Mechanism Plausibility | 10 | Clear pathway + functional = 10; Indirect via neighbors = 6; Computational = 2 |

**Tiers**: 80-100 = Tier 1 (high potential) | 60-79 = Tier 2 (good) | 40-59 = Tier 3 (moderate) | 0-39 = Tier 4 (low)

**Evidence grades**: [T1] Human clinical proof | [T2] Functional experimental | [T3] Association/computational | [T4] Prediction/text-mining

---

## KEY PRINCIPLES

1. **Report-first approach** - Create report file FIRST, then populate progressively
2. **Entity disambiguation FIRST** - Resolve all identifiers before analysis
3. **Bidirectional network** - Construct C-T-D network from both directions
4. **Network metrics** - Calculate proximity, centrality, module overlap quantitatively
5. **Rank candidates** - Prioritize by composite Network Pharmacology Score
6. **Mechanism prediction** - Explain HOW drug could work via network paths
7. **Evidence grading** - Grade all evidence T1-T4
8. **Source references** - Every finding must cite the source tool/database
9. **Completeness checklist** - Mandatory section at end showing analysis coverage

---

## Complete Workflow

### Phase 0: Entity Disambiguation + Report Setup

1. Create `[entity]_network_pharmacology_report.md` with all section headers
2. Resolve entities to IDs:

```python
from tooluniverse import ToolUniverse
tu = ToolUniverse(use_cache=True); tu.load_tools()

# Compound -> ChEMBL ID
drug_info = tu.tools.OpenTargets_get_drug_chembId_by_generic_name(drugName="metformin")
chembl_id = drug_info['data']['search']['hits'][0]['id']

# Target -> Ensembl ID
target_info = tu.tools.OpenTargets_get_target_id_description_by_name(targetName="PSEN1")
ensembl_id = target_info['data']['search']['hits'][0]['id']

# Disease -> EFO ID
disease_info = tu.tools.OpenTargets_get_disease_id_description_by_name(diseaseName="Alzheimer disease")
disease_id = disease_info['data']['search']['hits'][0]['id']
```

### Phase 1: Network Node Identification

| Node Type | Primary Tool | Fallback |
|-----------|-------------|----------|
| Compound targets | `OpenTargets_get_drug_mechanisms_of_action_by_chemblId` | `drugbank_get_targets_by_drug_name_or_drugbank_id` |
| Disease genes | `OpenTargets_get_associated_targets_by_disease_efoId` | `CTD_get_gene_diseases` |
| PPI partners | `STRING_get_interaction_partners` (species=9606) | `OpenTargets_get_target_interactions_by_ensemblID` |

### Phase 2: Network Edge Construction

| Edge Type | Tools |
|-----------|-------|
| C-T (drug-target) | `OpenTargets_get_drug_mechanisms_of_action_by_chemblId`, `DGIdb_get_drug_gene_interactions`, `CTD_get_chemical_gene_interactions` |
| T-D (target-disease) | `OpenTargets_get_associated_targets_by_disease_efoId`, `OpenTargets_target_disease_evidence`, `GWAS_search_associations_by_gene` |
| C-D (drug-disease) | `OpenTargets_get_drug_indications_by_chemblId`, `search_clinical_trials`, `CTD_get_chemical_diseases` |
| T-T (PPI) | `STRING_get_interaction_partners`, `STRING_get_network`, `intact_search_interactions` |

### Phase 3: Network Analysis

1. **Topology**: Calculate degree centrality, betweenness, hub genes
2. **Proximity**: Shortest path distances between drug targets and disease genes → Z-score
3. **Module overlap**: Shared genes/pathways between drug module and disease module
4. **Pathway enrichment**: `ReactomeAnalysis_pathway_enrichment` (identifiers as space-separated string, NOT array), `enrichr_gene_enrichment_analysis` (gene_list + libs required)

### Phase 4: Scoring & Ranking

1. For each drug-disease pair, compute the 5-component Network Pharmacology Score
2. Rank candidates by composite score
3. For top candidates, predict mechanism via network shortest path

### Phase 5: Safety & Clinical Context

| Tool | Purpose |
|------|---------|
| `FAERS_calculate_disproportionality` | AE signal detection (PRR, ROR) |
| `FAERS_count_death_related_by_drug` | Serious outcomes (`medicinalproduct`, NOT `drug_name`) |
| `OpenTargets_get_drug_adverse_events_by_chemblId` | Known AEs |
| `OpenTargets_get_target_safety_profile_by_ensemblID` | Target safety |
| `search_clinical_trials` | Existing trials (query_term REQUIRED) |
| `PubMed_search_articles` | Literature (returns plain list, NOT `{articles: [...]}`) |

---

## Key Tool API Notes

- **DrugBank tools**: ALL require 4 params: `query`, `case_sensitive`, `exact_match`, `limit`
- **FAERS analytics tools**: ALL require `operation` parameter
- **FAERS count tools**: Use `medicinalproduct` NOT `drug_name`
- **OpenTargets**: Returns nested `{data: {entity: {field: ...}}}`
- **ReactomeAnalysis**: `identifiers` must be space-separated string, NOT list
- **STRING**: `species=9606` for human, `protein_ids` as list
- **ensembl_lookup_gene**: `species='homo_sapiens'` REQUIRED

---

## Report Template (10 sections)

1. Executive Summary (score, tier, recommendation)
2. Network Construction (nodes + edges counts, data sources)
3. Network Proximity (Z-score, direct interactions, shared PPI, shared pathways)
4. Top Repurposing Candidates (ranked by score with mechanism prediction)
5. Polypharmacology Profile (target coverage, multi-target effects)
6. Pathway Analysis (drug pathways, disease pathways, overlap = mechanism)
7. Safety Considerations (AEs, target safety flags, off-target risks)
8. Clinical Precedent (trials, literature, PGx)
9. Evidence Summary Table (finding, source, grade, confidence)
10. Completeness Checklist (phase-by-phase status)

---

> **Extended Reference**: Full code examples for each phase, complete tool parameter tables with response structures, and the full report template are in `REFERENCE.md`.
