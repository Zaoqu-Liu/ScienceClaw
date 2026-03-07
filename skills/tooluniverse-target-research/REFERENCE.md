# tooluniverse-target-research — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## PATH 7: Druggability & Target Validation (ENHANCED)

### 7.1 Pharos/TCRD - Target Development Level (NEW)

NIH's Illuminating the Druggable Genome (IDG) portal provides TDL classification for all human proteins:

```python
def get_pharos_target_info(tu, ids):
    """
    Get Pharos/TCRD target development level and druggability.
    
    TDL Classification:
    - Tclin: Approved drug targets
    - Tchem: Targets with small molecule activities (IC50 < 30nM)
    - Tbio: Targets with biological annotations
    - Tdark: Understudied proteins
    """
    gene_symbol = ids.get('symbol')
    uniprot = ids.get('uniprot')
    
    # Try by gene symbol first
    if gene_symbol:
        result = tu.tools.Pharos_get_target(
            gene=gene_symbol
        )
    elif uniprot:
        result = tu.tools.Pharos_get_target(
            uniprot=uniprot
        )
    else:
        return {'status': 'error', 'message': 'Need gene symbol or UniProt'}
    
    if result.get('status') == 'success' and result.get('data'):
        target = result['data']
        return {
            'name': target.get('name'),
            'symbol': target.get('sym'),
            'tdl': target.get('tdl'),  # Tclin/Tchem/Tbio/Tdark
            'family': target.get('fam'),  # Kinase, GPCR, etc.
            'novelty': target.get('novelty'),
            'description': target.get('description'),
            'publications': target.get('publicationCount'),
            'interpretation': interpret_tdl(target.get('tdl'))
        }
    return None

def interpret_tdl(tdl):
    """Interpret Target Development Level for druggability."""
    interpretations = {
        'Tclin': 'Approved drug target - highest confidence for druggability',
        'Tchem': 'Small molecule active - good chemical tractability',
        'Tbio': 'Biologically characterized - may require novel modalities',
        'Tdark': 'Understudied - limited data, high novelty potential'
    }
    return interpretations.get(tdl, 'Unknown')

def search_disease_targets(tu, disease_name):
    """Find targets associated with a disease via Pharos."""
    
    result = tu.tools.Pharos_get_disease_targets(
        disease=disease_name,
        top=50
    )
    
    if result.get('status') == 'success':
        targets = result['data'].get('targets', [])
        # Group by TDL for prioritization
        by_tdl = {'Tclin': [], 'Tchem': [], 'Tbio': [], 'Tdark': []}
        for t in targets:
            tdl = t.get('tdl', 'Unknown')
            if tdl in by_tdl:
                by_tdl[tdl].append(t)
        return by_tdl
    return None
```

**Pharos Report Section** (add to Section 9 - Druggability):

```markdown
### 9.x Pharos/TCRD Target Classification (NEW)

**Target Development Level**: Tchem  
**Protein Family**: Kinase  
**Novelty Score**: 0.35 (moderately studied)  
**Publication Count**: 12,456

**TDL Interpretation**: Target has validated small molecule activities with IC50 < 30nM. Good chemical starting points exist.

**Disease Targets Analysis** (for disease-centric queries):
| TDL | Count | Examples |
|-----|-------|----------|
| Tclin | 12 | EGFR, ALK, RET |
| Tchem | 45 | KRAS, SHP2, CDK4 |
| Tbio | 78 | Novel kinases |
| Tdark | 23 | Understudied |

*Source: Pharos/TCRD via `Pharos_get_target`*
```

### 7.2 DepMap - Target Essentiality Validation (NEW)

CRISPR knockout data from cancer cell lines to validate target essentiality:

```python
def assess_target_essentiality(tu, ids):
    """
    Is this target essential for cancer cell survival?
    
    Negative effect scores = gene is essential (cells die upon KO)
    """
    gene_symbol = ids.get('symbol')
    
    if not gene_symbol:
        return {'status': 'error', 'message': 'Need gene symbol'}
    
    deps = tu.tools.DepMap_get_gene_dependencies(
        gene_symbol=gene_symbol
    )
    
    if deps.get('status') == 'success':
        return {
            'gene': gene_symbol,
            'data': deps.get('data', {}),
            'interpretation': 'Negative scores indicate gene is essential for cell survival',
            'note': 'Score < -0.5 is strongly essential, < -1.0 is extremely essential'
        }
    return None

def get_cancer_type_essentiality(tu, gene_symbol, cancer_type):
    """Check if gene is essential in specific cancer type."""
    
    # Get cell lines for cancer type
    cell_lines = tu.tools.DepMap_get_cell_lines(
        cancer_type=cancer_type,
        page_size=20
    )
    
    return {
        'gene': gene_symbol,
        'cancer_type': cancer_type,
        'cell_lines': cell_lines.get('data', {}).get('cell_lines', []),
        'note': 'Query individual cell lines for dependency scores via DepMap portal'
    }
```

**DepMap Report Section** (add to Section 9 - Druggability):

```markdown
### 9.x Target Essentiality (DepMap) (NEW)

**Gene Essentiality Assessment**:
| Context | Effect Score | Interpretation |
|---------|--------------|----------------|
| Pan-cancer | -0.42 | Moderately essential |
| Lung cancer | -0.78 | Strongly essential |
| Breast cancer | -0.21 | Weakly essential |

**Selectivity**: Differential essentiality suggests cancer-type selective target

**Cell Lines Tested**: 1,054 cancer cell lines from DepMap

*Interpretation*: Score < -0.5 indicates strong dependency. This target is more essential in lung cancer than other cancer types - suggesting lung-selective targeting may be feasible.

*Source: DepMap via `DepMap_get_gene_dependencies`*
```

### 7.3 InterProScan - Novel Domain Prediction (NEW)

For uncharacterized proteins, run InterProScan to predict domains and function:

```python
def predict_protein_domains(tu, sequence, title="Query protein"):
    """
    Run InterProScan for de novo domain prediction.
    
    Use when:
    - Protein has no InterPro annotations
    - Novel/uncharacterized protein
    - Custom sequence analysis
    """
    
    result = tu.tools.InterProScan_scan_sequence(
        sequence=sequence,
        title=title,
        go_terms=True,
        pathways=True
    )
    
    if result.get('status') == 'success':
        data = result.get('data', {})
        
        # Job may still be running
        if data.get('job_status') == 'RUNNING':
            return {
                'job_id': data.get('job_id'),
                'status': 'running',
                'note': 'Use InterProScan_get_job_results to retrieve when ready'
            }
        
        # Parse completed results
        return {
            'domains': data.get('domains', []),
            'domain_count': data.get('domain_count', 0),
            'go_annotations': data.get('go_annotations', []),
            'pathways': data.get('pathways', []),
            'sequence_length': data.get('sequence_length')
        }
    return None

def check_interproscan_job(tu, job_id):
    """Check status and get results for InterProScan job."""
    
    status = tu.tools.InterProScan_get_job_status(job_id=job_id)
    
    if status.get('data', {}).get('is_finished'):
        results = tu.tools.InterProScan_get_job_results(job_id=job_id)
        return results.get('data', {})
    
    return status.get('data', {})
```

**When to use InterProScan**:
- Novel/uncharacterized proteins (Tdark in Pharos)
- Custom sequences (e.g., protein variants)
- Proteins with outdated/sparse InterPro annotations
- Validating domain predictions

**InterProScan Report Section** (for novel proteins):

```markdown
### Domain Prediction (InterProScan) (NEW)

*Used for uncharacterized protein analysis*

**Predicted Domains**:
| Domain | Database | Start-End | E-value | InterPro Entry |
|--------|----------|-----------|---------|----------------|
| Protein kinase domain | Pfam | 45-305 | 1.2e-89 | IPR000719 |
| SH2 domain | SMART | 320-410 | 3.4e-45 | IPR000980 |

**Predicted GO Terms**:
- GO:0004672 protein kinase activity
- GO:0005524 ATP binding

**Predicted Pathways**:
- Reactome: Signal Transduction

*Source: InterProScan via `InterProScan_scan_sequence`*
```

### 7.4 BindingDB - Known Ligands & Binding Data (NEW)

BindingDB provides experimental binding affinity data (Ki, IC50, Kd) for target-ligand pairs:

```python
def get_bindingdb_ligands(tu, uniprot_id, affinity_cutoff=10000):
    """
    Get ligands with measured binding affinities from BindingDB.
    
    Critical for:
    - Identifying chemical starting points
    - Understanding existing chemical matter
    - Assessing tractability with small molecules
    
    Args:
        uniprot_id: UniProt accession (e.g., P00533 for EGFR)
        affinity_cutoff: Maximum affinity in nM (lower = more potent)
    """
    
    # Get ligands by UniProt
    result = tu.tools.BindingDB_get_ligands_by_uniprot(
        uniprot=uniprot_id,
        affinity_cutoff=affinity_cutoff
    )
    
    if result:
        ligands = []
        for entry in result:
            ligands.append({
                'smiles': entry.get('smile'),
                'affinity_type': entry.get('affinity_type'),  # Ki, IC50, Kd
                'affinity_nM': entry.get('affinity'),
                'monomer_id': entry.get('monomerid'),
                'pmid': entry.get('pmid')
            })
        
        # Sort by affinity (most potent first)
        ligands.sort(key=lambda x: float(x['affinity_nM']) if x['affinity_nM'] else float('inf'))
        
        return {
            'total_ligands': len(ligands),
            'ligands': ligands[:20],  # Top 20 most potent
            'best_affinity': ligands[0]['affinity_nM'] if ligands else None
        }
    
    return {'total_ligands': 0, 'ligands': [], 'note': 'No ligands found in BindingDB'}

def get_ligands_by_structure(tu, pdb_id, affinity_cutoff=10000):
    """Get ligands for a protein by PDB structure ID."""
    
    result = tu.tools.BindingDB_get_ligands_by_pdb(
        pdb_ids=pdb_id,
        affinity_cutoff=affinity_cutoff,
        sequence_identity=100
    )
    
    return result

def find_compound_targets(tu, smiles, similarity_cutoff=0.85):
    """Find other targets for a compound (polypharmacology)."""
    
    result = tu.tools.BindingDB_get_targets_by_compound(
        smiles=smiles,
        similarity_cutoff=similarity_cutoff
    )
    
    return result
```

**BindingDB Report Section** (add to Section 9 - Druggability):

```markdown
### Known Ligands (BindingDB) (NEW)

**Total Ligands with Binding Data**: 156
**Best Reported Affinity**: 0.3 nM (Ki)

#### Most Potent Ligands

| SMILES | Affinity Type | Value (nM) | Source PMID |
|--------|---------------|------------|-------------|
| CC(=O)Nc1ccc(cc1)c2... | Ki | 0.3 | 15737014 |
| CN(C)C/C=C/C(=O)Nc1... | IC50 | 0.8 | 15896103 |
| COc1cc2ncnc(Nc3ccc... | Kd | 2.1 | 16460808 |

**Chemical Tractability Assessment**:
- ✅ **Tchem-level target**: Multiple ligands with <30nM affinity
- ✅ **Diverse chemotypes**: Multiple scaffolds identified
- ✅ **Published literature**: Ligands have PMID references

*Source: BindingDB via `BindingDB_get_ligands_by_uniprot`*
```

**Affinity Interpretation for Druggability**:
| Affinity Range | Interpretation | Drug Development Potential |
|----------------|----------------|---------------------------|
| <1 nM | Ultra-potent | Clinical compound likely |
| 1-10 nM | Highly potent | Drug-like |
| 10-100 nM | Potent | Good starting point |
| 100-1000 nM | Moderate | Needs optimization |
| >1000 nM | Weak | Early hit only |

### 7.5 PubChem BioAssay - Screening Data (NEW)

PubChem BioAssay provides HTS screening data and dose-response curves:

```python
def get_pubchem_assays_for_target(tu, gene_symbol):
    """
    Get bioassays targeting a gene from PubChem.
    
    Provides:
    - HTS screening results
    - Dose-response data (IC50/EC50)
    - Active compound counts
    """
    
    # Search assays by target gene
    assays = tu.tools.PubChem_search_assays_by_target_gene(
        gene_symbol=gene_symbol
    )
    
    assay_info = []
    if assays.get('data', {}).get('aids'):
        for aid in assays['data']['aids'][:10]:  # Top 10 assays
            # Get assay details
            summary = tu.tools.PubChem_get_assay_summary(aid=aid)
            targets = tu.tools.PubChem_get_assay_targets(aid=aid)
            
            assay_info.append({
                'aid': aid,
                'summary': summary.get('data', {}),
                'targets': targets.get('data', {})
            })
    
    return {
        'total_assays': len(assays.get('data', {}).get('aids', [])),
        'assay_details': assay_info
    }

def get_active_compounds_from_assay(tu, aid):
    """Get active compounds from a specific bioassay."""
    
    actives = tu.tools.PubChem_get_assay_active_compounds(aid=aid)
    
    return {
        'aid': aid,
        'active_cids': actives.get('data', {}).get('cids', []),
        'count': len(actives.get('data', {}).get('cids', []))
    }
```

**PubChem BioAssay Report Section**:

```markdown
### PubChem BioAssay Data (NEW)

**Assays Targeting This Gene**: 45

| AID | Assay Type | Active Compounds | Target Info |
|-----|------------|------------------|-------------|
| 1053104 | Dose-response | 12 | EGFR kinase |
| 504526 | HTS | 234 | EGFR binding |
| 651564 | Confirmatory | 8 | EGFR cellular |

**Total Active Compounds Across Assays**: ~500

*Source: PubChem via `PubChem_search_assays_by_target_gene`, `PubChem_get_assay_active_compounds`*
```

---

## PATH 8: Literature & Research (Collision-Aware)

### Collision-Aware Query Strategy

```python
def path_literature_collision_aware(tu, ids):
    """
    Literature search with collision detection and filtering.
    """
    symbol = ids['symbol']
    full_name = ids.get('full_name', '')
    uniprot = ids['uniprot']
    synonyms = ids.get('synonyms', [])
    
    # Step 1: Detect collisions
    collision_filter = detect_collisions(tu, symbol, full_name)
    
    # Step 2: Build high-precision seed queries
    seed_queries = [
        f'"{symbol}"[Title] AND (protein OR gene OR expression)',  # Symbol in title
        f'"{full_name}"[Title]' if full_name else None,  # Full name in title
        f'"UniProt:{uniprot}"' if uniprot else None,  # UniProt accession
    ]
    seed_queries = [q for q in seed_queries if q]
    
    # Add key synonyms
    for syn in synonyms[:3]:
        seed_queries.append(f'"{syn}"[Title]')
    
    # Step 3: Execute seed queries and collect PMIDs
    seed_pmids = set()
    for query in seed_queries:
        if collision_filter:
            query = f"({query}){collision_filter}"
        results = tu.tools.PubMed_search_articles(query=query, limit=30)
        for article in results.get('articles', []):
            seed_pmids.add(article.get('pmid'))
    
    # Step 4: Expand via citation network (for sparse targets)
    if len(seed_pmids) < 30:
        expanded_pmids = set()
        for pmid in list(seed_pmids)[:10]:  # Top 10 seeds
            # Get related articles
            related = tu.tools.PubMed_get_related(pmid=pmid, limit=20)
            for r in related.get('articles', []):
                expanded_pmids.add(r.get('pmid'))
            
            # Get citing articles
            citing = tu.tools.EuropePMC_get_citations(pmid=pmid, limit=20)
            for c in citing.get('citations', []):
                expanded_pmids.add(c.get('pmid'))
        
        seed_pmids.update(expanded_pmids)
    
    # Step 5: Classify papers by evidence tier
    papers_by_tier = {'T1': [], 'T2': [], 'T3': [], 'T4': []}
    # ... classification logic based on title/abstract keywords
    
    return {
        'total_papers': len(seed_pmids),
        'collision_filter_applied': collision_filter if collision_filter else 'None needed',
        'seed_queries': seed_queries,
        'papers_by_tier': papers_by_tier
    }
```

---

## Retry Logic & Fallback Chains

### Retry Policy

For each critical tool, implement retry with exponential backoff:

```python
def call_with_retry(tu, tool_name, params, max_retries=3):
    """
    Call tool with retry logic.
    """
    for attempt in range(max_retries):
        try:
            result = getattr(tu.tools, tool_name)(**params)
            if result and not result.get('error'):
                return result
        except Exception as e:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)  # Exponential backoff
            else:
                return {'error': str(e), 'tool': tool_name, 'attempts': max_retries}
    return None
```

### Fallback Chains (CRITICAL)

| Primary Tool | Fallback 1 | Fallback 2 | Failure Action |
|--------------|------------|------------|----------------|
| `ChEMBL_get_target_activities` | `GtoPdb_get_target_ligands` | `OpenTargets drugs` | Note in report |
| `intact_get_interactions` | `STRING_get_protein_interactions` | `OpenTargets interactions` | Note in report |
| `GO_get_annotations_for_gene` | `OpenTargets GO` | `MyGene GO` | Note in report |
| `GTEx_get_median_gene_expression` | `HPA_get_rna_expression` | Note as unavailable | Document in report |
| `gnomad_get_gene_constraints` | `OpenTargets constraint` | - | Note in report |
| `DGIdb_get_drug_gene_interactions` | `OpenTargets drugs` | `GtoPdb` | Note in report |

### Failure Surfacing Rule

**NEVER silently skip failed tools.** Always document:

```markdown
### 7.1 Tissue Expression

**GTEx Data**: Unavailable (API timeout after 3 attempts)
**Fallback Data (HPA)**:
| Tissue | Expression Level | Specificity |
|--------|-----------------|-------------|
| Liver | High | Enhanced |
| Kidney | Medium | - |

*Note: For complete GTEx data, query directly at gtexportal.org*
```

---

## Per-Section Data Minimums & Completeness Audit

### Minimum Data Requirements (Enforced)

| Section | Minimum Data | If Not Met |
|---------|--------------|------------|
| **6. PPIs** | ≥20 interactors | Document which tools failed + why |
| **7. Expression** | Top 10 tissues with TPM + HPA RNA summary | Note "limited data" with specific gaps |
| **8. Disease** | Top 10 OT diseases + gnomAD constraints + ClinVar summary | Separate SNV/CNV; note if constraint unavailable |
| **9. Druggability** | OT tractability + probes + drugs + DGIdb + GtoPdb fallback | "No drugs/probes" is valid data |
| **11. Literature** | Total count + 5-year trend + 3-5 key papers with evidence tiers | Note if sparse (<50 papers) |

### Post-Run Completeness Audit

Before finalizing the report, run this checklist:

```markdown
## Completeness Audit (REQUIRED)

### Data Minimums Check
- [ ] PPIs: ≥20 interactors OR explanation why fewer
- [ ] Expression: Top 10 tissues with values OR explicit "unavailable"
- [ ] Diseases: Top 10 associations with scores OR "no associations"
- [ ] Constraints: All 4 scores (pLI, LOEUF, missense Z, pRec) OR "unavailable"
- [ ] Druggability: All modalities assessed; probes + drugs listed OR "none"

### Negative Results Documented
- [ ] Empty tool results noted explicitly (not left blank)
- [ ] Failed tools with fallbacks documented
- [ ] "No data" sections have implications noted

### Evidence Quality
- [ ] T1-T4 grades in Executive Summary disease claims
- [ ] T1-T4 grades in Disease Associations table
- [ ] Key papers table has evidence tiers
- [ ] Per-section evidence summaries included

### Source Attribution
- [ ] Every data point has source tool/database cited
- [ ] Section-end source summaries present
```

### Data Gap Table (Required if minimums not met)

```markdown
## 15. Data Gaps & Limitations

| Section | Expected Data | Actual | Reason | Alternative Source |
|---------|---------------|--------|--------|-------------------|
| 6. PPIs | ≥20 interactors | 8 | Novel target, limited studies | Literature review needed |
| 7. Expression | GTEx TPM | None | Versioned ID not recognized | See HPA data |
| 9. Probes | Chemical probes | None | No validated probes exist | Consider tool compound dev |

**Recommendations for Data Gaps**:
1. For PPIs: Query BioGRID with broader parameters; check yeast-2-hybrid studies
2. For Expression: Query GEO directly for tissue-specific datasets
```

---

## Report Template (Initial File)

**File**: `[TARGET]_target_report.md`

```markdown
# Target Intelligence Report: [TARGET NAME]

**Generated**: [Date] | **Query**: [Original query] | **Status**: In Progress

---

## 1. Executive Summary
[Researching...]
<!-- REQUIRED: 2-3 sentences, disease claims must have T1-T4 grades -->

## 2. Target Identifiers
[Researching...]
<!-- REQUIRED: UniProt, Ensembl (versioned), Entrez, ChEMBL, HGNC, Symbol -->

## 3. Basic Information
### 3.1 Protein Description
[Researching...]
### 3.2 Protein Function
[Researching...]
### 3.3 Subcellular Localization
[Researching...]

## 4. Structural Biology
### 4.1 Experimental Structures (PDB)
[Researching...]
<!-- METHOD: 3-step chain (UniProt xrefs → sequence search → domain search) -->
### 4.2 AlphaFold Prediction
[Researching...]
### 4.3 Domain Architecture
[Researching...]
### 4.4 Key Structural Features
[Researching...]

## 5. Function & Pathways
### 5.1 Gene Ontology Annotations
[Researching...]
<!-- REQUIRED: Evidence codes mapped to T1-T4 -->
### 5.2 Pathway Involvement
[Researching...]

## 6. Protein-Protein Interactions
[Researching...]
<!-- MINIMUM: ≥20 interactors OR explanation -->

## 7. Expression Profile
### 7.1 Tissue Expression (GTEx/HPA)
[Researching...]
<!-- NOTE: Use versioned Ensembl ID for GTEx if needed -->
### 7.2 Tissue Specificity
[Researching...]
<!-- MINIMUM: Top 10 tissues with TPM values -->

## 8. Genetic Variation & Disease
### 8.1 Constraint Scores
[Researching...]
<!-- REQUIRED: pLI, LOEUF, missense Z, pRec with interpretations -->
### 8.2 Disease Associations
[Researching...]
<!-- REQUIRED: Top 10 with OT scores; T1-T4 evidence grades -->
### 8.3 Clinical Variants (ClinVar)
[Researching...]
<!-- REQUIRED: Separate SNV and CNV tables -->
### 8.4 Mouse Model Phenotypes
[Researching...]

## 9. Druggability & Pharmacology
### 9.1 Tractability Assessment
[Researching...]
<!-- REQUIRED: All modalities (SM, Ab, PROTAC, other) -->
### 9.2 Known Drugs
[Researching...]
### 9.3 Chemical Probes
[Researching...]
<!-- NOTE: "No probes" is valid data - document explicitly -->
### 9.4 Clinical Pipeline
[Researching...]
### 9.5 ChEMBL Bioactivity
[Researching...]

## 10. Safety Profile
### 10.1 Safety Liabilities
[Researching...]
### 10.2 Expression-Based Toxicity Risk
[Researching...]
### 10.3 Mouse KO Phenotypes
[Researching...]

## 11. Literature & Research Landscape
### 11.1 Publication Metrics
[Researching...]
<!-- REQUIRED: Total, 5y, 1y, drug-related, clinical -->
### 11.2 Research Trend
[Researching...]
### 11.3 Key Publications
[Researching...]
<!-- REQUIRED: Table with PMID, title, year, evidence tier -->
### 11.4 Evidence Summary by Theme
[Researching...]
<!-- REQUIRED: T1-T4 breakdown per research theme -->

## 12. Competitive Landscape
[Researching...]

## 13. Summary & Recommendations
### 13.1 Target Validation Scorecard
[Researching...]
<!-- REQUIRED: 6 criteria, 1-5 scores, evidence quality noted -->
### 13.2 Strengths
[Researching...]
### 13.3 Challenges & Risks
[Researching...]
### 13.4 Recommendations
[Researching...]
<!-- REQUIRED: ≥3 prioritized (HIGH/MEDIUM/LOW) -->

## 14. Data Sources & Methodology
[Will be populated as research progresses...]

## 15. Data Gaps & Limitations
[To be populated post-audit...]
```

---

## Quick Reference: Tool Parameters

| Tool | Parameter | Notes |
|------|-----------|-------|
| `Reactome_map_uniprot_to_pathways` | `id` | NOT `uniprot_id` |
| `ensembl_get_xrefs` | `id` | NOT `gene_id` |
| `GTEx_get_median_gene_expression` | `gencode_id`, `operation` | Try versioned ID if empty |
| `OpenTargets_*` | `ensemblId` | camelCase, not `ensemblID` |
| `STRING_get_protein_interactions` | `protein_ids`, `species` | List format for IDs |
| `intact_get_interactions` | `identifier` | UniProt accession |

---

## When NOT to Use This Skill

- Simple protein lookup → Use `UniProt_get_entry_by_accession` directly
- Drug information only → Use drug-focused tools
- Disease-centric query → Use disease-intelligence-gatherer skill
- Sequence retrieval → Use sequence-retrieval skill
- Structure download → Use protein-structure-retrieval skill

Use this skill for comprehensive, multi-angle target analysis with guaranteed data completeness.
