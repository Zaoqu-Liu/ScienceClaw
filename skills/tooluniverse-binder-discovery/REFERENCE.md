# tooluniverse-binder-discovery — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 4: Compound Expansion

### 4.1 Similarity Search

Starting from top actives, expand chemical space:

```
1. ChEMBL_search_similar_molecules(molecule=top_active_smiles, similarity=70)
   └─ Extract: Similar compounds not yet tested on target
   
2. PubChem_search_compounds_by_similarity(smiles, threshold=0.7)
   └─ Extract: PubChem CIDs with similar structures
```

**Strategy**:
- Use 3-5 diverse actives as seeds
- Similarity threshold: 70-85% (balance novelty vs. activity)
- Prioritize compounds NOT in ChEMBL bioactivity for target

### 4.2 Substructure Search

```
1. ChEMBL_search_substructure(smiles=core_scaffold)
   └─ Extract: Compounds containing scaffold
   
2. PubChem_search_compounds_by_substructure(smiles=core_scaffold)
   └─ Extract: Additional scaffold-containing compounds
```

### 4.3 Cross-Database Mining

```
1. STITCH_get_chemical_protein_interactions(identifier=target_gene)
   └─ Extract: Additional chemical-protein links
   
2. DGIdb_get_drug_gene_interactions(genes=[gene_symbol])
   └─ Extract: Approved/investigational drugs
```

**Output for Report**:
```markdown
### 4. Compound Expansion Results

**Starting Seeds**: 5 diverse actives (IC50 < 100 nM)
**Similarity Expansion**: 847 compounds (70% threshold)
**Substructure Search**: 234 scaffold matches
**Cross-Database**: 45 additional hits

**After Deduplication**: 923 unique candidate compounds

| Source | Compounds | Already Tested | Novel Candidates |
|--------|-----------|----------------|------------------|
| ChEMBL similarity | 456 | 234 | 222 |
| PubChem similarity | 391 | 156 | 235 |
| ChEMBL substructure | 178 | 89 | 89 |
| STITCH | 45 | 23 | 22 |
| **Total Unique** | **923** | **355** | **568** |
```

### 4.4 De Novo Molecule Generation (NVIDIA NIM)

When database mining yields insufficient candidates, generate novel molecules.

**Requires**: `NVIDIA_API_KEY` environment variable

**Option A: GenMol (Scaffold Hopping with Masked Regions)**
```
NvidiaNIM_genmol(
    smiles="COc1cc2ncnc(Nc3ccc([*{3-8}])c([*{1-3}])c3)c2cc1OCCCN1CCOCC1",
    num_molecules=100,
    temperature=2.0,
    scoring="QED"
)
└─ Input: SMILES with [*{min-max}] masked regions
└─ Output: Generated molecules with QED/LogP scores
└─ Use: Explore specific positions while keeping scaffold
```

**Mask Design Strategy**:
| Position | Mask | Purpose |
|----------|------|---------|
| Aniline substituent | `[*{1-3}]` | Small groups (halogen, methyl) |
| Solubilizing group | `[*{5-10}]` | Morpholine, piperazine variants |
| Linker region | `[*{3-6}]` | Spacer variations |

**Example Masked SMILES for EGFR**:
```
# Keep quinazoline core, vary aniline and tail
COc1cc2ncnc(Nc3ccc([*{1-3}])c([*{1-3}])c3)c2cc1[*{5-12}]
```

**Option B: MolMIM (Controlled Generation from Reference)**
```
NvidiaNIM_molmim(
    smi="COc1cc2ncnc(Nc3ccc(Cl)cc3)c2cc1OCCN1CCOCC1",
    num_molecules=50,
    algorithm="CMA-ES"
)
└─ Input: Reference SMILES (known active)
└─ Output: Optimized analogs with property scores
└─ Use: Generate close analogs of top actives
```

**Generation Workflow**:
1. Identify top 3-5 actives from Phase 2
2. Design masked SMILES for GenMol OR use as reference for MolMIM
3. Generate 50-100 molecules per seed
4. Pass generated molecules to Phase 5 (ADMET filtering)
5. Dock survivors in Phase 6 for final ranking

**Report Format**:
```markdown
### 4.4 De Novo Generation Results

**Method**: GenMol via NVIDIA NIM
**Seed Scaffold**: 4-anilinoquinazoline (from erlotinib)
**Masked Positions**: Aniline (3,4), solubilizing tail

| Metric | Value |
|--------|-------|
| Molecules Generated | 100 |
| Passing Lipinski | 95 (95%) |
| Mean QED Score | 0.72 |
| Unique Scaffolds | 12 |

**Top Generated Compounds**:
| ID | SMILES | QED | LogP | Novelty |
|----|--------|-----|------|---------|
| GEN-001 | COc1cc2ncnc(Nc3ccc(Cl)c(Cl)c3)c2cc1OCCCN1CCOCC1 | 0.81 | 4.2 | Novel substitution |
| GEN-002 | COc1cc2ncnc(Nc3ccc(C#N)c(F)c3)c2cc1OCCCN1CCOCC1 | 0.78 | 3.8 | Novel substitution |

*Source: NVIDIA NIM via `NvidiaNIM_genmol`*
```

---

## Phase 5: ADMET Filtering

### 5.1 Physicochemical Properties

```
ADMETAI_predict_physicochemical_properties(smiles=[compound_list])
└─ Filter: Lipinski violations ≤ 1
└─ Filter: QED > 0.3
└─ Filter: MW 200-600
```

### 5.2 ADMET Endpoints

```
1. ADMETAI_predict_bioavailability(smiles=[compound_list])
   └─ Filter: Oral bioavailability > 0.3
   
2. ADMETAI_predict_toxicity(smiles=[compound_list])
   └─ Filter: AMES < 0.5, hERG < 0.5, DILI < 0.5
   
3. ADMETAI_predict_CYP_interactions(smiles=[compound_list])
   └─ Flag: CYP3A4 inhibitors (drug interaction risk)
```

### 5.3 Structural Alerts

```
ChEMBL_search_compound_structural_alerts(smiles=compound_smiles)
└─ Flag: PAINS, reactive groups, toxicophores
```

**ADMET Filter Summary**:
```markdown
### 5. ADMET Filtering Results

| Filter Stage | Input | Passed | Failed | Pass Rate |
|--------------|-------|--------|--------|-----------|
| Physicochemical (Lipinski) | 568 | 456 | 112 | 80% |
| Drug-likeness (QED > 0.3) | 456 | 398 | 58 | 87% |
| Bioavailability (> 0.3) | 398 | 312 | 86 | 78% |
| Toxicity filters | 312 | 267 | 45 | 86% |
| Structural alerts | 267 | 234 | 33 | 88% |
| **Final Candidates** | **568** | **234** | **334** | **41%** |

**Common Failure Reasons**:
1. High molecular weight (>600): 67 compounds
2. Low predicted bioavailability: 86 compounds
3. hERG liability: 28 compounds
4. PAINS alerts: 18 compounds
```

---

## Phase 6: Candidate Prioritization

### 6.1 Scoring Framework

Score each candidate on multiple dimensions:

| Dimension | Weight | Scoring Criteria |
|-----------|--------|------------------|
| **Structural Similarity** | 25% | Tanimoto to actives (0.7-1.0 → 1-5) |
| **Novelty** | 20% | Not in ChEMBL bioactivity = +2; Novel scaffold = +3 |
| **ADMET Score** | 25% | Composite of property predictions |
| **Synthesis Feasibility** | 15% | SA score (1-10), commercial availability |
| **Scaffold Diversity** | 15% | Cluster representative bonus |

### 6.2 Synthesis Feasibility

```markdown
### 6.2 Synthesis Feasibility Assessment

| Candidate | SA Score | Commercial | Estimated Steps | Flag |
|-----------|----------|------------|-----------------|------|
| Compound-1 | 2.3 | Yes (Enamine) | 0 | ★★★ |
| Compound-2 | 3.5 | Building block | 2-3 | ★★☆ |
| Compound-3 | 5.8 | No | 6-8 | ★☆☆ |

**SA Score Interpretation**:
- 1-3: Easy synthesis
- 3-5: Moderate complexity
- 5-10: Challenging synthesis
```

### 6.3 Final Prioritized List

```markdown
### 6.3 Top 20 Candidate Compounds

| Rank | ID | SMILES | Sim. Score | ADMET | Novelty | Overall | Rationale |
|------|-----|--------|------------|-------|---------|---------|-----------|
| 1 | CPD-001 | Cc1ccc... | 0.82 | 4.5 | Novel scaffold | 4.2 | High similarity, clean ADMET |
| 2 | CPD-002 | COc1cc... | 0.78 | 4.3 | Not tested | 4.0 | Quinazoline analog |
| 3 | CPD-003 | Nc1ccc... | 0.75 | 4.1 | Novel core | 3.9 | New chemotype |
| ... | ... | ... | ... | ... | ... | ... | ... |

**Scaffold Diversity**: 7 distinct scaffolds in top 20
**Commercial Availability**: 12/20 available for purchase
**Estimated Hit Rate**: 15-25% (based on similarity to actives)
```

---

## Phase 6.5: Literature Evidence (NEW)

### 6.5.1 Literature Search for Validation

Search literature to validate candidate compounds and understand target context.

```python
def search_binder_literature(tu, target_name, compound_scaffolds):
    """Search literature for compound and target evidence."""
    
    # PubMed: Published SAR studies
    sar_papers = tu.tools.PubMed_search_articles(
        query=f"{target_name} inhibitor SAR structure-activity",
        limit=30
    )
    
    # BioRxiv: Latest unpublished findings
    preprints = tu.tools.BioRxiv_search_preprints(
        query=f"{target_name} small molecule discovery",
        limit=15
    )
    
    # MedRxiv: Clinical data on inhibitors
    clinical = tu.tools.MedRxiv_search_preprints(
        query=f"{target_name} inhibitor clinical trial",
        limit=10
    )
    
    # Citation analysis for key papers
    key_papers = sar_papers[:10]
    for paper in key_papers:
        citation = tu.tools.openalex_search_works(
            query=paper['title'],
            limit=1
        )
        paper['citations'] = citation[0].get('cited_by_count', 0) if citation else 0
    
    return {
        'published_sar': sar_papers,
        'preprints': preprints,
        'clinical_preprints': clinical,
        'high_impact_papers': sorted(key_papers, key=lambda x: x.get('citations', 0), reverse=True)
    }
```

### 6.5.2 Output for Report

```markdown
## 6.5 Literature Evidence

### Published SAR Studies

| PMID | Title | Year | Key Insight |
|------|-------|------|-------------|
| 34567890 | Discovery of novel EGFR inhibitors... | 2024 | C7 substitution critical |
| 33456789 | Structure-activity relationship of... | 2023 | Fluorine improves potency |

### Recent Preprints (⚠️ Not Peer-Reviewed)

| Source | Title | Posted | Relevance |
|--------|-------|--------|-----------|
| BioRxiv | Novel scaffolds for EGFR... | 2024-02 | New chemotype discovery |
| MedRxiv | Clinical activity of... | 2024-01 | Phase 2 results |

### High-Impact References

| PMID | Citations | Title |
|------|-----------|-------|
| 32123456 | 523 | Landmark EGFR inhibitor study... |
| 31234567 | 312 | Comprehensive SAR analysis... |

*Source: PubMed, BioRxiv, MedRxiv, OpenAlex*
```

---

## Report Template

**File**: `[TARGET]_binder_discovery_report.md`

```markdown
# Small Molecule Binder Discovery: [TARGET]

**Generated**: [Date] | **Query**: [Original query] | **Status**: In Progress

---

## Executive Summary
[Researching...]

---

## 1. Target Validation
### 1.1 Target Identifiers
[Researching...]
### 1.2 Druggability Assessment
[Researching...]
### 1.3 Binding Site Analysis
[Researching...]

---

## 2. Known Ligand Landscape
### 2.1 ChEMBL Bioactivity Summary
[Researching...]
### 2.2 Approved Drugs & Clinical Compounds
[Researching...]
### 2.3 Chemical Probes
[Researching...]
### 2.4 SAR Insights
[Researching...]

---

## 3. Structural Information
### 3.1 Available Structures
[Researching...]
### 3.2 Binding Pocket Analysis
[Researching...]
### 3.3 Key Interactions
[Researching...]

---

## 4. Compound Expansion
### 4.1 Similarity Search Results
[Researching...]
### 4.2 Substructure Search Results
[Researching...]
### 4.3 Cross-Database Mining
[Researching...]

---

## 5. ADMET Filtering
### 5.1 Physicochemical Filters
[Researching...]
### 5.2 ADMET Predictions
[Researching...]
### 5.3 Structural Alerts
[Researching...]
### 5.4 Filter Summary
[Researching...]

---

## 6. Candidate Prioritization
### 6.1 Scoring Methodology
[Researching...]
### 6.2 Synthesis Feasibility
[Researching...]
### 6.3 Top 20 Candidates
[Researching...]

---

## 7. Recommendations
### 7.1 Immediate Actions
[Researching...]
### 7.2 Experimental Validation Plan
[Researching...]
### 7.3 Backup Strategies
[Researching...]

---

## 8. Data Gaps & Limitations
[Researching...]

---

## 9. Data Sources
[Will be populated as research progresses...]

---

## 10. Methods Summary

| Step | Tool | Purpose |
|------|------|---------|
| Sequence retrieval | UniProt_search | Get protein sequence |
| Structure prediction | NvidiaNIM_alphafold2 / NvidiaNIM_esmfold | 3D structure with pLDDT |
| Docking validation | NvidiaNIM_diffdock / NvidiaNIM_boltz2 | Validate binding pocket |
| Known ligands | ChEMBL_get_target_activities | Bioactivity data |
| Similarity search | ChEMBL_search_similar_molecules | Expand chemical space |
| De novo generation | NvidiaNIM_genmol / NvidiaNIM_molmim | Novel molecule design |
| ADMET filtering | ADMETAI_predict_* | Drug-likeness assessment |
| Candidate docking | NvidiaNIM_diffdock / NvidiaNIM_boltz2 | Final scoring |
```

---

## Evidence Grading

| Tier | Symbol | Description | Example |
|------|--------|-------------|---------|
| **T0** | ★★★★ | Docking score > reference inhibitor | Better than erlotinib |
| **T1** | ★★★ | Experimental IC50/Ki < 100 nM | ChEMBL bioactivity |
| **T2** | ★★☆ | Docking within 5% of reference OR IC50 100-1000 nM | High priority |
| **T3** | ★☆☆ | Structural similarity > 80% to T1 | Predicted active |
| **T4** | ☆☆☆ | Similarity 70-80%, scaffold match | Lower confidence |
| **T5** | ○○○ | Generated molecule, ADMET-passed, no docking | Speculative |

**Docking-Enhanced Grading**: When NVIDIA NIM docking is available, compounds gain evidence:
- Docking > reference → upgrade to T0 (★★★★)
- Docking within 5% → upgrade to T2 (★★☆)
- Docking within 20% → maintain current tier
- Docking >20% worse → downgrade one tier

Apply to all candidate compounds:
```markdown
| Compound | Evidence | Docking vs Ref | Rationale |
|----------|----------|----------------|-----------|
| CPD-001 | ★★★★ | +8.3% | 85% similar, docking > erlotinib |
| CPD-002 | ★★★ | -2.1% | IC50=45nM, validated by docking |
| CPD-003 | ★★☆ | -4.5% | 78% similar, good docking |
| GEN-001 | ★☆☆ | -15% | Generated, ADMET-passed |
```

---

## Mandatory Completeness Checklist

### Phase 1: Target Validation
- [ ] UniProt accession resolved
- [ ] ChEMBL target ID obtained
- [ ] Druggability assessed (≥2 sources)
- [ ] Target class identified
- [ ] Binding site information (or "No structural data")

### Phase 2: Known Ligands
- [ ] ChEMBL activities queried (≥100 or all available)
- [ ] Activity statistics (count, potency range)
- [ ] Top 10 actives listed with IC50
- [ ] Chemical probes identified (or "None available")
- [ ] SAR insights summarized

### Phase 3: Structure
- [ ] PDB structures listed (or "No experimental structure")
- [ ] Best structure for docking identified
- [ ] Binding pocket described (or "Predicted from AlphaFold")

### Phase 4: Expansion
- [ ] ≥3 seed compounds used
- [ ] Similarity search completed (≥100 results or exhausted)
- [ ] Substructure search completed
- [ ] Deduplicated candidate count reported

### Phase 5: ADMET
- [ ] Physicochemical filters applied
- [ ] Toxicity predictions run
- [ ] Structural alerts checked
- [ ] Filter funnel table included

### Phase 6: Prioritization
- [ ] ≥20 candidates ranked (or all if fewer)
- [ ] Scoring methodology explained
- [ ] Synthesis feasibility assessed
- [ ] Scaffold diversity noted

### Phase 7: Recommendations
- [ ] ≥3 immediate actions listed
- [ ] Experimental validation plan outlined
- [ ] Data gaps aggregated

---

## Tool Reference by Phase

### Phase 1: Target Validation
| Tool | Purpose |
|------|---------|
| `UniProt_search` | Resolve UniProt accession |
| `MyGene_query_genes` | Get Ensembl/NCBI IDs |
| `ChEMBL_search_targets` | Get ChEMBL target ID |
| `OpenTargets_get_target_tractability_by_ensemblID` | Tractability assessment |
| `DGIdb_get_gene_druggability` | Druggability categories |
| `ChEMBL_search_binding_sites` | Binding site info |
| `InterPro_get_protein_domains` | Domain architecture |

### Phase 2: Known Ligands
| Tool | Purpose |
|------|---------|
| `ChEMBL_get_target_activities` | Bioactivity data |
| `ChEMBL_get_molecule` | Molecule details |
| `GtoPdb_get_target_interactions` | Pharmacology data |
| `OpenTargets_get_chemical_probes_by_target_ensemblID` | Chemical probes |
| `OpenTargets_get_associated_drugs_by_target_ensemblID` | Known drugs |

### Phase 1.4: Structure Prediction (NVIDIA NIM)
| Tool | Purpose |
|------|---------|
| `NvidiaNIM_alphafold2` | High-accuracy structure prediction with pLDDT |
| `NvidiaNIM_esmfold` | Fast structure prediction (max 1024 AA) |
| `NvidiaNIM_msa_search` | MSA generation for AlphaFold |

### Phase 3: Structure
| Tool | Purpose |
|------|---------|
| `PDB_search_similar_structures` | Find PDB structures |
| `get_protein_metadata_by_pdb_id` | Structure metadata |
| `get_binding_affinity_by_pdb_id` | Ligand affinities |
| `alphafold_get_prediction` | Predicted structure (AlphaFold DB) |
| `get_ligand_smiles_by_chem_comp_id` | Ligand structures |
| `emdb_search` | Search cryo-EM structures (NEW) |
| `emdb_get_entry` | Get EMDB entry details (NEW) |

### Phase 3.5: Docking Validation (NVIDIA NIM)
| Tool | Purpose |
|------|---------|
| `NvidiaNIM_diffdock` | Blind molecular docking (PDB + SDF) |
| `NvidiaNIM_boltz2` | Protein-ligand complex (sequence + SMILES) |

### Phase 4: Expansion
| Tool | Purpose |
|------|---------|
| `ChEMBL_search_similar_molecules` | Similarity search |
| `PubChem_search_compounds_by_similarity` | PubChem similarity |
| `ChEMBL_search_substructure` | Substructure search |
| `PubChem_search_compounds_by_substructure` | PubChem substructure |
| `STITCH_get_chemical_protein_interactions` | Cross-database |

### Phase 4.4: De Novo Generation (NVIDIA NIM)
| Tool | Purpose |
|------|---------|
| `NvidiaNIM_genmol` | Scaffold hopping with masked regions |
| `NvidiaNIM_molmim` | Controlled generation from reference |

### Phase 5: ADMET
| Tool | Purpose |
|------|---------|
| `ADMETAI_predict_physicochemical_properties` | Drug-likeness |
| `ADMETAI_predict_bioavailability` | Oral absorption |
| `ADMETAI_predict_toxicity` | Toxicity flags |
| `ADMETAI_predict_CYP_interactions` | CYP liabilities |
| `ChEMBL_search_compound_structural_alerts` | PAINS, alerts |

### Phase 6: Candidate Docking (NVIDIA NIM)
| Tool | Purpose |
|------|---------|
| `NvidiaNIM_diffdock` | Score all candidates by docking |
| `NvidiaNIM_boltz2` | Alternative docking from SMILES |

### Phase 6.5: Literature Evidence (NEW)
| Tool | Purpose |
|------|---------|
| `PubMed_search_articles` | Published SAR studies |
| `BioRxiv_search_preprints` | Latest biology preprints |
| `MedRxiv_search_preprints` | Clinical preprints |
| `openalex_search_works` | Citation analysis |
| `SemanticScholar_search` | AI-ranked papers |

---

## Fallback Chains

| Primary Tool | Fallback 1 | Fallback 2 | Use When |
|--------------|------------|------------|----------|
| `ChEMBL_get_target_activities` | `GtoPdb_get_target_interactions` | `PubChem_search_assays` | No ChEMBL data |
| `ChEMBL_search_similar_molecules` | `PubChem_search_compounds_by_similarity` | `STITCH_get_chemical_protein_interactions` | ChEMBL exhausted |
| `PDB_search_similar_structures` | `NvidiaNIM_alphafold2` | `alphafold_get_prediction` | No PDB structure |
| `alphafold_get_prediction` | `NvidiaNIM_alphafold2` | `NvidiaNIM_esmfold` | AlphaFold DB unavailable |
| `NvidiaNIM_alphafold2` | `NvidiaNIM_esmfold` | `alphafold_get_prediction` | AlphaFold2 NIM error |
| `NvidiaNIM_diffdock` | `NvidiaNIM_boltz2` | Skip docking, use similarity | Docking error |
| `NvidiaNIM_genmol` | `NvidiaNIM_molmim` | Manual scaffold hopping | Generation error |
| `OpenTargets_get_target_tractability` | `DGIdb_get_gene_druggability` | Document "Unknown" | Open Targets error |
| `ADMETAI_*` | SwissADME tools | Basic Lipinski | Invalid SMILES |
| `PDB_search_similar_structures` | `emdb_search` + PDB | `NvidiaNIM_alphafold2` | Membrane proteins |
| `PubMed_search_articles` | `openalex_search_works` | `SemanticScholar_search` | Literature search |
| `BioRxiv_search_preprints` | `MedRxiv_search_preprints` | Skip preprints | Preprint sources |

**NVIDIA NIM API Key Required**: Tools with `NvidiaNIM_` prefix require `NVIDIA_API_KEY` environment variable. Check availability at start:
```python
import os
nvidia_available = bool(os.environ.get("NVIDIA_API_KEY"))
# If not available, fall back to non-NIM alternatives
```

---

## Common Use Cases

### Well-Characterized Target
User: "Find novel binders for EGFR"
→ Rich ChEMBL data; focus on novel scaffolds, selectivity, ADMET

### Novel Target
User: "Find small molecules for [new target with no known ligands]"
→ Limited bioactivity; rely on structure-based assessment, similar target ligands

### Lead Optimization
User: "Find analogs of compound X for target Y"
→ Deep similarity search around specific compound; focus on SAR

### Selectivity Challenge
User: "Find selective inhibitors for kinase X vs kinase Y"
→ Include selectivity analysis; filter by off-target predictions

---

## When NOT to Use This Skill

- **Drug research** → Use tooluniverse-drug-research (existing drug profiling)
- **Target research only** → Use tooluniverse-target-research
- **Single compound ADMET** → Call ADMET tools directly
- **Literature search** → Use tooluniverse-literature-deep-research
- **Protein structure only** → Use tooluniverse-protein-structure-retrieval

Use this skill for **discovering new compounds** for a protein target.

---

## Additional Resources

- **Checklist**: [CHECKLIST.md](CHECKLIST.md) - Pre-delivery verification
- **Examples**: [EXAMPLES.md](EXAMPLES.md) - Detailed workflow examples
- **Tool corrections**: [TOOLS_REFERENCE.md](TOOLS_REFERENCE.md) - Parameter corrections
