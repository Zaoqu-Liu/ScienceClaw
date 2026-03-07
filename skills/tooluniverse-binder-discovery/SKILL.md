---
name: tooluniverse-binder-discovery
description: Discover novel small molecule binders for protein targets using structure-based and ligand-based approaches. Creates actionable reports with candidate compounds, ADMET profiles, and synthesis feasibility. Use when users ask to find small molecules for a target, identify novel binders, perform virtual screening, or need hit-to-lead compound identification.
---

# Small Molecule Binder Discovery Strategy

Systematic discovery of novel small molecule binders using 60+ ToolUniverse tools across druggability assessment, known ligand mining, similarity expansion, ADMET filtering, and synthesis feasibility.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create report file FIRST, then populate progressively
2. **Target validation FIRST** - Confirm druggability before compound searching
3. **Multi-strategy approach** - Combine structure-based and ligand-based methods
4. **ADMET-aware filtering** - Eliminate poor compounds early
5. **Evidence grading** - Grade candidates by supporting evidence
6. **Actionable output** - Provide prioritized candidates with rationale
7. **English-first queries** - Always use English terms in tool calls, even if the user writes in another language. Only try original-language terms as a fallback. Respond in the user's language

---

## Critical Workflow Requirements

### 1. Report-First Approach (MANDATORY)

**DO NOT** show search process or tool outputs to the user. Instead:

1. **Create the report file FIRST** - Before any data collection:
   - File name: `[TARGET]_binder_discovery_report.md`
   - Initialize with all section headers from the template
   - Add placeholder text: `[Researching...]` in each section

2. **Progressively update the report** - As you gather data:
   - Update each section with findings immediately
   - The user sees the report growing, not the search process

3. **Output separate data files**:
   - `[TARGET]_candidate_compounds.csv` - Prioritized compounds with SMILES, scores
   - `[TARGET]_bibliography.json` - Literature references (optional)

### 2. Citation Requirements (MANDATORY)

Every piece of information MUST include its source:

```markdown
### 3.2 Known Inhibitors
| Compound | ChEMBL ID | IC50 (nM) | Selectivity | Source |
|----------|-----------|-----------|-------------|--------|
| Imatinib | CHEMBL941 | 38 | ABL-selective | ChEMBL |
| Dasatinib | CHEMBL1421 | 0.5 | Multi-kinase | ChEMBL |

*Source: ChEMBL via `ChEMBL_get_target_activities` (CHEMBL1862)*
```

---

## Workflow Overview

```
Phase 0: Tool Verification (check parameter names)
    ↓
Phase 1: Target Validation
    ├─ 1.1 Resolve identifiers (UniProt, Ensembl, ChEMBL target ID)
    ├─ 1.2 Assess druggability/tractability
    │   └─ 1.2.5 Check therapeutic antibodies (Thera-SAbDab) [NEW]
    ├─ 1.3 Identify binding sites
    └─ 1.4 Predict structure (NvidiaNIM_alphafold2/esmfold)
    ↓
Phase 2: Known Ligand Mining
    ├─ Extract ChEMBL bioactivity data
    ├─ Get GtoPdb interactions
    ├─ Identify chemical probes
    ├─ BindingDB affinity data (NEW - Ki/IC50/Kd)
    ├─ PubChem BioAssay HTS data (NEW - screening hits)
    └─ Analyze SAR from known actives
    ↓
Phase 3: Structure Analysis
    ├─ Get PDB structures with ligands
    ├─ Check EMDB for cryo-EM structures (NEW - for membrane targets)
    ├─ Analyze binding pocket
    └─ Identify key interactions
    ↓
Phase 3.5: Docking Validation (NvidiaNIM_diffdock/boltz2) [NEW]
    ├─ Dock reference inhibitor
    └─ Validate binding pocket geometry
    ↓
Phase 4: Compound Expansion
    ├─ 4.1-4.3 Similarity/substructure search
    └─ 4.4 De novo generation (NvidiaNIM_genmol/molmim) [NEW]
    ↓
Phase 5: ADMET Filtering
    ├─ Predict physicochemical properties
    ├─ Predict ADMET endpoints
    └─ Flag liabilities
    ↓
Phase 6: Candidate Docking & Prioritization
    ├─ Dock all candidates (NvidiaNIM_diffdock/boltz2) [UPDATED]
    ├─ Score by docking + ADMET + novelty
    ├─ Assess synthesis feasibility
    └─ Generate final ranked list
    ↓
Phase 7: Report Synthesis
```

---

## Phase 0: Tool Verification

**CRITICAL**: Verify tool parameters before calling unfamiliar tools.

```python
# Check tool params to prevent silent failures
tool_info = tu.tools.get_tool_info(tool_name="ChEMBL_get_target_activities")
```

### Known Parameter Corrections

| Tool | WRONG Parameter | CORRECT Parameter |
|------|-----------------|-------------------|
| `OpenTargets_get_target_tractability_by_ensemblID` | `ensembl_id` | `ensemblId` |
| `ChEMBL_get_target_activities` | `chembl_target_id` | `target_chembl_id` |
| `ChEMBL_search_similar_molecules` | `smiles` | `molecule` (accepts SMILES, ChEMBL ID, or name) |
| `alphafold_get_prediction` | `uniprot` | `accession` |

---

## Phase 1: Target Validation

### 1.1 Identifier Resolution Chain

```
1. UniProt_search(query=target_name, organism="human")
   └─ Extract: UniProt accession, gene name, protein name

2. MyGene_query_genes(q=gene_symbol, species="human")
   └─ Extract: Ensembl gene ID, NCBI gene ID

3. ChEMBL_search_targets(query=target_name, organism="Homo sapiens")
   └─ Extract: ChEMBL target ID, target type

4. GtoPdb_get_targets(query=target_name)
   └─ Extract: GtoPdb target ID (if GPCR/ion channel/enzyme)
```

**Store all IDs for downstream queries**:
```
ids = {
    'uniprot': 'P00533',
    'ensembl': 'ENSG00000146648',
    'chembl_target': 'CHEMBL203',
    'gene_symbol': 'EGFR',
    'gtopdb': '1797'  # if available
}
```

### 1.2 Druggability Assessment

**Multi-Source Triangulation**:

```
1. OpenTargets_get_target_tractability_by_ensemblID(ensemblId)
   └─ Extract: Small molecule tractability score, bucket
   
2. DGIdb_get_gene_druggability(genes=[gene_symbol])
   └─ Extract: Druggability categories, known drug count
   
3. OpenTargets_get_target_classes_by_ensemblID(ensemblId)
   └─ Extract: Target class (kinase, GPCR, etc.)

4. GPCRdb_get_protein(protein=entry_name)  # NEW - for GPCRs
   └─ Extract: GPCR family, receptor state, ligand binding data
```

### 1.2a GPCRdb Integration (NEW - for GPCR Targets)

~35% of all approved drugs target GPCRs. For GPCR targets, use specialized data:

```python
def check_if_gpcr_and_enrich(tu, target_name, uniprot_id):
    """Check if target is GPCR and get specialized data."""
    
    # Build GPCRdb entry name (e.g., "adrb2_human")
    entry_name = f"{target_name.lower()}_human"
    
    # Check if it's a GPCR
    gpcr_info = tu.tools.GPCRdb_get_protein(
        operation="get_protein",
        protein=entry_name
    )
    
    if gpcr_info.get('status') == 'success':
        # It's a GPCR - get specialized data
        
        # Get known structures (active/inactive states)
        structures = tu.tools.GPCRdb_get_structures(
            operation="get_structures",
            protein=entry_name
        )
        
        # Get known ligands
        ligands = tu.tools.GPCRdb_get_ligands(
            operation="get_ligands",
            protein=entry_name
        )
        
        # Get mutation data (important for SAR)
        mutations = tu.tools.GPCRdb_get_mutations(
            operation="get_mutations",
            protein=entry_name
        )
        
        return {
            'is_gpcr': True,
            'gpcr_family': gpcr_info['data'].get('family'),
            'gpcr_class': gpcr_info['data'].get('receptor_class'),
            'structures': structures['data'].get('structures', []),
            'ligands': ligands['data'].get('ligands', []),
            'mutation_data': mutations['data'].get('mutations', [])
        }
    
    return {'is_gpcr': False}
```

**GPCRdb Advantages**:
- GPCR-specific sequence alignments (Ballesteros-Weinstein numbering)
- Active vs. inactive state structures
- Curated ligand binding data
- Experimental mutation effects on ligand binding

**Druggability Scorecard**:

| Factor | Assessment | Score |
|--------|------------|-------|
| Known small molecule drugs | Yes (3+) | ★★★ |
| Tractability bucket | 1-3 | ★★☆-★★★ |
| Target class | Enzyme/GPCR/Ion channel | ★★★ |
| Binding site known | Yes (X-ray) | ★★★ |
| GPCRdb ligands available | Yes (10+) | ★★★ (GPCR only) |
| Therapeutic antibodies exist | Check Thera-SAbDab | See 1.2.5 |

**Decision Point**: If druggability score < ★★☆, warn user about challenges.

### 1.2.5 Therapeutic Antibody Landscape (NEW)

Check if therapeutic antibodies already target this protein - important for:
- Understanding competitive landscape
- Validating target tractability (if antibodies work, target is validated)
- Identifying potential combination approaches

```python
def check_therapeutic_antibodies(tu, target_name):
    """
    Check Thera-SAbDab for therapeutic antibodies against target.
    """
    # Search by target name
    results = tu.tools.TheraSAbDab_search_by_target(
        target=target_name
    )
    
    if results.get('status') == 'success':
        antibodies = results['data'].get('therapeutics', [])
        
        # Categorize by clinical stage
        by_phase = {'Approved': [], 'Phase 3': [], 'Phase 2': [], 'Phase 1': [], 'Preclinical': []}
        for ab in antibodies:
            phase = ab.get('phase', 'Unknown')
            for key in by_phase.keys():
                if key.lower() in phase.lower():
                    by_phase[key].append(ab)
                    break
        
        return {
            'total_antibodies': len(antibodies),
            'by_phase': by_phase,
            'antibodies': antibodies[:10],  # Top 10
            'competitive_alert': len(by_phase.get('Approved', [])) > 0
        }
    return None

def get_antibody_landscape(tu, target_name, uniprot_id=None):
    """
    Comprehensive antibody competitive landscape.
    """
    # Thera-SAbDab search
    therasabdab = check_therapeutic_antibodies(tu, target_name)
    
    # Also search by common synonyms
    synonyms = [target_name]
    if target_name != uniprot_id:
        synonyms.append(uniprot_id)
    
    all_antibodies = []
    for synonym in synonyms:
        results = tu.tools.TheraSAbDab_search_therapeutics(query=synonym)
        if results.get('status') == 'success':
            all_antibodies.extend(results['data'].get('therapeutics', []))
    
    # Deduplicate
    seen = set()
    unique = []
    for ab in all_antibodies:
        inn = ab.get('inn_name')
        if inn and inn not in seen:
            seen.add(inn)
            unique.append(ab)
    
    return {
        'antibodies': unique,
        'count': len(unique),
        'has_approved': any(ab.get('phase', '').lower() == 'approved' for ab in unique),
        'source': 'Thera-SAbDab'
    }
```

**Report Output**:
```markdown
### 1.2.5 Therapeutic Antibody Landscape (NEW)

**Thera-SAbDab Search Results**:

| Antibody (INN) | Target | Format | Phase | PDB |
|----------------|--------|--------|-------|-----|
| Pembrolizumab | PD-1 | IgG4 | Approved | 5DK3 |
| Nivolumab | PD-1 | IgG4 | Approved | 5WT9 |
| Cemiplimab | PD-1 | IgG4 | Approved | 7WVM |

**Competitive Landscape**: ⚠️ 3 approved antibodies target this protein
**Strategic Implication**: Small molecule approach offers differentiation (oral dosing, CNS penetration, cost)

*Source: Thera-SAbDab via `TheraSAbDab_search_by_target`*
```

**Why Include Antibody Landscape**:
- **Validation**: Approved antibodies = validated target
- **Competition**: Understand what's already in market/clinic
- **Strategy**: Identify gaps (no oral, no CNS-penetrant)
- **Synergy**: Potential combination opportunities

### 1.3 Binding Site Analysis

```
1. ChEMBL_search_binding_sites(target_chembl_id)
   └─ Extract: Binding site names, types
   
2. get_binding_affinity_by_pdb_id(pdb_id)  # For each PDB with ligand
   └─ Extract: Kd, Ki, IC50 values for co-crystallized ligands
   
3. InterPro_get_protein_domains(uniprot_accession)
   └─ Extract: Domain architecture, active sites
```

**Output for Report**:
```markdown
### 1.3 Binding Site Assessment

**Known Binding Sites**: 
| Site | Type | Evidence | Key Residues | Source |
|------|------|----------|--------------|--------|
| ATP pocket | Orthosteric | X-ray (23 PDBs) | K745, E762, M793 | PDB/ChEMBL |
| Allosteric pocket | Allosteric | X-ray (3 PDBs) | T790, C797 | PDB |

**Binding Site Druggability**: ★★★ (well-defined pocket, multiple co-crystal structures)

*Source: ChEMBL via `ChEMBL_search_binding_sites`, PDB structures*
```

### 1.4 Structure Prediction (NVIDIA NIM)

When no experimental structure is available, or for custom domain predictions.

**Requires**: `NVIDIA_API_KEY` environment variable

**Option A: AlphaFold2 (High accuracy, async)**
```
NvidiaNIM_alphafold2(
    sequence=kinase_domain_sequence,
    algorithm="mmseqs2",
    relax_prediction=False
)
└─ Returns: PDB structure with pLDDT confidence scores
└─ Use when: Accuracy is critical, time is available (~5-15 min)
```

**Option B: ESMFold (Fast, synchronous)**
```
NvidiaNIM_esmfold(sequence=kinase_domain_sequence)
└─ Returns: PDB structure (max 1024 AA)
└─ Use when: Quick assessment needed (~30 sec)
```

**Report pLDDT Confidence**:
```markdown
### 1.4 Structure Prediction Quality

**Method**: AlphaFold2 via NVIDIA NIM
**Mean pLDDT**: 90.94 (very high confidence)

| Confidence Level | Range | Fraction | Interpretation |
|------------------|-------|----------|----------------|
| Very High | ≥90 | 74.3% | Highly reliable |
| Confident | 70-90 | 16.0% | Reliable |
| Low | 50-70 | 9.0% | Use caution |
| Very Low | <50 | 0.7% | Unreliable |

**Key Binding Residue Confidence**:
| Residue | Function | pLDDT |
|---------|----------|-------|
| K745 | ATP binding | 90.0 |
| T790 | Gatekeeper | 92.3 |
| M793 | Hinge region | 95.3 |
| D855 | DFG motif | 89.5 |

*Source: NVIDIA NIM via `NvidiaNIM_alphafold2`*
```

---

## Phase 2: Known Ligand Mining

### 2.1 ChEMBL Bioactivity Data

```
1. ChEMBL_get_target_activities(target_chembl_id, limit=500)
   └─ Filter: standard_type in ["IC50", "Ki", "Kd", "EC50"]
   └─ Filter: standard_value < 10000 nM
   └─ Extract: ChEMBL molecule IDs, SMILES, potency values

2. ChEMBL_get_molecule(molecule_chembl_id)  # For top actives
   └─ Extract: Full molecular data, max_phase, oral flag
```

**Activity Summary Table**:
```markdown
### 2.1 Known Active Compounds (ChEMBL)

**Total Bioactivity Points**: 2,847 (IC50: 1,234 | Ki: 892 | Kd: 456 | EC50: 265)
**Compounds with IC50 < 100 nM**: 156
**Approved Drugs for This Target**: 5

| Compound | ChEMBL ID | IC50 (nM) | Max Phase | SMILES (truncated) |
|----------|-----------|-----------|-----------|-------------------|
| Erlotinib | CHEMBL553 | 2 | 4 | COc1cc2ncnc(Nc3ccc... |
| Gefitinib | CHEMBL939 | 5 | 4 | COc1cc2ncnc(Nc3ccc... |
| [Novel] | CHEMBL123 | 12 | 0 | c1ccc(NC(=O)c2ccc... |

*Source: ChEMBL via `ChEMBL_get_target_activities` (CHEMBL203)*
```

### 2.2 GtoPdb Interactions

```
GtoPdb_get_target_interactions(target_id)
└─ Extract: Ligands with pKi/pIC50, selectivity data
```

### 2.3 Chemical Probes

```
OpenTargets_get_chemical_probes_by_target_ensemblID(ensemblId)
└─ Extract: Validated chemical probes with ratings
```

**Output for Report**:
```markdown
### 2.3 Chemical Probes

| Probe | Target | Rating | Use | Caveat | Source |
|-------|--------|--------|-----|--------|--------|
| Probe-X | EGFR | ★★★★ | In vivo | None | Chemical Probes Portal |
| Probe-Y | EGFR | ★★★☆ | In vitro | Off-target kinase activity | Open Targets |

**Recommended Probe for Target Validation**: Probe-X (highest rating, validated in vivo)
```

### 2.4 SAR Analysis from Actives

Identify common scaffolds and SAR trends:

```markdown
### 2.4 Structure-Activity Relationships

**Core Scaffolds Identified**:
1. **4-Anilinoquinazoline** (34 compounds, IC50 range: 2-500 nM)
   - N1 position: Aryl preferred
   - C6/C7: Methoxy groups improve potency
   
2. **Pyrimidine-amine** (12 compounds, IC50 range: 15-800 nM)
   - Less potent than quinazolines
   - Better selectivity profile

**Key SAR Insights**:
- Halogen at meta position of aniline increases potency 3-5x
- C7 ethoxy group critical for binding (H-bond to M793)
```

### 2.5 BindingDB Affinity Data (NEW)

BindingDB provides experimental binding affinity data complementary to ChEMBL:

```python
def get_bindingdb_ligands(tu, uniprot_id, affinity_cutoff=10000):
    """
    Get ligands from BindingDB with measured affinities.
    
    BindingDB advantages:
    - May have compounds not in ChEMBL
    - Different affinity types (Ki, IC50, Kd)
    - Direct literature links
    """
    
    result = tu.tools.BindingDB_get_ligands_by_uniprot(
        uniprot=uniprot_id,
        affinity_cutoff=affinity_cutoff  # nM
    )
    
    if result:
        ligands = []
        for entry in result:
            ligands.append({
                'smiles': entry.get('smile'),
                'affinity_type': entry.get('affinity_type'),
                'affinity_nM': entry.get('affinity'),
                'pmid': entry.get('pmid'),
                'monomer_id': entry.get('monomerid')
            })
        
        # Sort by potency
        ligands.sort(key=lambda x: float(x['affinity_nM']) if x['affinity_nM'] else 1e6)
        return ligands[:50]  # Top 50
    
    return []

def find_compound_polypharmacology(tu, smiles, similarity_cutoff=0.85):
    """Find off-target interactions for selectivity analysis."""
    
    targets = tu.tools.BindingDB_get_targets_by_compound(
        smiles=smiles,
        similarity_cutoff=similarity_cutoff
    )
    
    return targets  # Other proteins this compound may bind
```

**BindingDB Output for Report**:
```markdown
### 2.5 Additional Ligands (BindingDB) (NEW)

**Total Unique Ligands**: 89 (non-overlapping with ChEMBL)
**Most Potent**: 0.3 nM Ki

| SMILES | Affinity Type | Value (nM) | PMID | BindingDB ID |
|--------|---------------|------------|------|--------------|
| CC(C)Cc1ccc... | Ki | 0.3 | 15737014 | 12345 |
| COc1cc2ncnc... | IC50 | 2.1 | 16460808 | 12346 |

**Novel Scaffolds from BindingDB**: 3 scaffolds not seen in ChEMBL data

*Source: BindingDB via `BindingDB_get_ligands_by_uniprot`*
```

### 2.6 PubChem BioAssay Screening Data (NEW)

PubChem BioAssay provides HTS screening results and dose-response data:

```python
def get_pubchem_assays_for_target(tu, gene_symbol):
    """
    Get bioassays and active compounds from PubChem.
    
    Advantages:
    - HTS data not in ChEMBL
    - NIH-funded screening programs (MLPCN)
    - Dose-response curves for IC50 calculation
    """
    
    # Search assays targeting this gene
    assays = tu.tools.PubChem_search_assays_by_target_gene(
        gene_symbol=gene_symbol
    )
    
    results = {
        'assays': [],
        'total_active_compounds': 0
    }
    
    if assays.get('data', {}).get('aids'):
        for aid in assays['data']['aids'][:10]:  # Top 10 assays
            # Get assay summary
            summary = tu.tools.PubChem_get_assay_summary(aid=aid)
            
            # Get active compounds
            actives = tu.tools.PubChem_get_assay_active_compounds(aid=aid)
            active_cids = actives.get('data', {}).get('cids', [])
            
            results['assays'].append({
                'aid': aid,
                'summary': summary.get('data', {}),
                'active_count': len(active_cids)
            })
            results['total_active_compounds'] += len(active_cids)
    
    return results

def get_dose_response_data(tu, aid):
    """Get dose-response curves for IC50/EC50 determination."""
    
    dr_data = tu.tools.PubChem_get_assay_dose_response(aid=aid)
    return dr_data

def get_compound_bioactivity_profile(tu, cid):
    """Get all bioactivity data for a compound."""
    
    profile = tu.tools.PubChem_get_compound_bioactivity(cid=cid)
    return profile
```

**PubChem BioAssay Output for Report**:
```markdown
### 2.6 PubChem HTS Screening Data (NEW)

**Assays Found**: 45
**Total Active Compounds Across Assays**: ~1,200

| AID | Assay Type | Active Compounds | Target | Description |
|-----|------------|------------------|--------|-------------|
| 504526 | HTS | 234 | EGFR | qHTS inhibition screen |
| 1053104 | Dose-response | 12 | EGFR kinase | Confirmatory IC50 |
| 651564 | Cellular | 8 | EGFR | Cell proliferation assay |

**Novel Actives** (not in ChEMBL/BindingDB):
- CID 12345678: Active in AID 504526, IC50 = 45 nM
- CID 23456789: Active in AID 1053104, IC50 = 120 nM

*Source: PubChem via `PubChem_search_assays_by_target_gene`, `PubChem_get_assay_active_compounds`*
```

**Why Use Both BindingDB and PubChem**:
| Source | Strengths | Best For |
|--------|-----------|----------|
| **ChEMBL** | Curated, standardized, SAR data | Primary ligand source |
| **BindingDB** | Direct affinity measurements | Ki/Kd values, PMIDs |
| **PubChem BioAssay** | HTS data, NIH screens | Novel scaffolds, broad coverage |

---

## Phase 3: Structure Analysis

### 3.1 PDB Structure Retrieval

```
1. PDB_search_similar_structures(query=uniprot_accession, type="sequence")
   └─ Extract: PDB IDs with ligands
   
2. get_protein_metadata_by_pdb_id(pdb_id)
   └─ Extract: Resolution, method, ligand codes
   
3. alphafold_get_prediction(accession=uniprot_accession)
   └─ Extract: Predicted structure (if no experimental)
```

### 3.1b EMDB Cryo-EM Structures (NEW)

**Prioritize EMDB for**: Membrane proteins (GPCRs, ion channels), large complexes, targets with multiple conformational states.

```python
def get_cryoem_structures(tu, target_name, uniprot_accession):
    """Get cryo-EM structures for membrane targets."""
    
    # Search EMDB
    emdb_results = tu.tools.emdb_search(
        query=f"{target_name} membrane receptor"
    )
    
    structures = []
    for entry in emdb_results[:5]:
        details = tu.tools.emdb_get_entry(entry_id=entry['emdb_id'])
        
        # Get associated PDB model (essential for docking)
        pdb_models = details.get('pdb_ids', [])
        
        structures.append({
            'emdb_id': entry['emdb_id'],
            'resolution': entry.get('resolution', 'N/A'),
            'title': entry.get('title', 'N/A'),
            'conformational_state': details.get('state', 'Unknown'),
            'pdb_models': pdb_models
        })
    
    return structures
```

**When to use cryo-EM over X-ray**:
| Target Type | Prefer cryo-EM? | Reason |
|-------------|-----------------|--------|
| GPCR | Yes | Native membrane conformation |
| Ion channel | Yes | Multiple functional states |
| Receptor-ligand complex | Yes | Physiological state |
| Kinase | Usually X-ray | Higher resolution typically |

**Structure Summary**:
```markdown
### 3.1 Available Structures

| PDB ID | Resolution | Method | Ligand | Affinity | State |
|--------|------------|--------|--------|----------|-------|
| 1M17 | 2.6 Å | X-ray | Erlotinib | Ki=0.4 nM | Active |
| 4HJO | 2.1 Å | X-ray | Lapatinib | Ki=3 nM | Inactive |
| AF-P00533 | - | Predicted | None | - | - |

### 3.1b Cryo-EM Structures (EMDB)

| EMDB ID | Resolution | PDB Model | Conformation | Ligand |
|---------|------------|-----------|--------------|--------|
| EMD-12345 | 3.2 Å | 7ABC | Active | Agonist |
| EMD-23456 | 3.5 Å | 8DEF | Inactive | Antagonist |

**Best Structure for Docking**: 1M17 (high resolution, relevant ligand)
*Source: RCSB PDB, EMDB, AlphaFold DB*
```

### 3.2 Binding Pocket Analysis

```
get_binding_affinity_by_pdb_id(pdb_id)
└─ Extract: Binding affinities for co-crystallized ligands
```

**Output for Report**:
```markdown
### 3.2 Binding Pocket Characterization

**Pocket Volume**: ~850 Å³ (well-defined)
**Key Interaction Residues**:
- **Hinge region**: M793 (backbone H-bond donor/acceptor)
- **Gatekeeper**: T790 (small residue, allows access)
- **DFG motif**: D855 (active conformation)
- **Selectivity pocket**: L788, G796 (unique to EGFR)

**Druggability Assessment**: High (enclosed pocket, conserved interactions)
```

---

## Phase 3.5: Docking Validation (NVIDIA NIM)

Validate structure and score compounds using molecular docking.

**Requires**: `NVIDIA_API_KEY` environment variable

### 3.5.1 Reference Compound Docking

Dock a known inhibitor to validate the structure captures the binding pocket correctly.

**Option A: DiffDock (Blind docking, PDB + SDF input)**
```
NvidiaNIM_diffdock(
    protein=pdb_content,        # PDB text content
    ligand=reference_sdf,       # SDF/MOL2 content
    num_poses=10
)
└─ Returns: Docking poses with confidence scores
└─ Use: When you have PDB structure and ligand SDF file
```

**Option B: Boltz2 (From sequence + SMILES)**
```
NvidiaNIM_boltz2(
    polymers=[{"molecule_type": "protein", "sequence": kinase_sequence}],
    ligands=[{"smiles": "COc1cc2ncnc(Nc3ccc(C#C)cc3)c2cc1OCCOC"}],
    sampling_steps=50,
    diffusion_samples=1
)
└─ Returns: Protein-ligand complex structure
└─ Use: When starting from SMILES, no SDF needed
```

### 3.5.2 Docking Score Interpretation

| Score vs Reference | Priority | Symbol |
|--------------------|----------|--------|
| Higher than reference | Top priority | ★★★★ |
| Within 5% of reference | High priority | ★★★ |
| Within 20% of reference | Moderate priority | ★★☆ |
| >20% lower | Low priority | ★☆☆ |

**Report Format**:
```markdown
### 3.5 Docking Validation Results

**Reference Compound**: Erlotinib
**Method**: DiffDock via NVIDIA NIM

| Metric | Value | Interpretation |
|--------|-------|----------------|
| Best Pose Confidence | 0.906 | Excellent |
| Steric Clashes | None | Clean binding pose |

**Validation Status**: ✓ Structure captures binding pocket correctly

*Source: NVIDIA NIM via `NvidiaNIM_diffdock`*
```

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-binder-discovery/REFERENCE.md`
