---
name: tooluniverse-target-research
description: Gather comprehensive biological target intelligence from 9 parallel research paths covering protein info, structure, interactions, pathways, expression, variants, drug interactions, and literature. Features collision-aware searches, evidence grading (T1-T4), explicit Open Targets coverage, and mandatory completeness auditing. Use when users ask about drug targets, proteins, genes, or need target validation, druggability assessment, or comprehensive target profiling.
---

# Comprehensive Target Intelligence Gatherer

Gather complete target intelligence by exploring 9 parallel research paths. Supports targets identified by gene symbol, UniProt accession, Ensembl ID, or gene name.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create report file FIRST, then populate progressively
2. **Tool parameter verification** - Verify params via `get_tool_info` before calling unfamiliar tools
3. **Evidence grading** - Grade all claims by evidence strength (T1-T4)
4. **Citation requirements** - Every fact must have inline source attribution
5. **Mandatory completeness** - All sections must exist with data minimums or explicit "No data" notes
6. **Disambiguation first** - Resolve all identifiers before research
7. **Negative results documented** - "No drugs found" is data; empty sections are failures
8. **Collision-aware literature search** - Detect and filter naming collisions
9. **English-first queries** - Always use English terms in tool calls, even if the user writes in another language. Translate gene names, disease names, and search terms to English. Only try original-language terms as a fallback if English returns no results. Respond in the user's language

---

## Phase 0: Tool Parameter Verification (CRITICAL)

**BEFORE calling ANY tool for the first time**, verify its parameters:

```python
# Always check tool params to prevent silent failures
tool_info = tu.tools.get_tool_info(tool_name="Reactome_map_uniprot_to_pathways")
# Reveals: takes `id` not `uniprot_id`
```

### Known Parameter Corrections (Updated)

| Tool | WRONG Parameter | CORRECT Parameter |
|------|-----------------|-------------------|
| `Reactome_map_uniprot_to_pathways` | `uniprot_id` | `id` |
| `ensembl_get_xrefs` | `gene_id` | `id` |
| `GTEx_get_median_gene_expression` | `gencode_id` only | `gencode_id` + `operation="median"` |
| `OpenTargets_*` | `ensemblID` | `ensemblId` (camelCase) |

### GTEx Versioned ID Fallback (CRITICAL)

GTEx often requires versioned Ensembl IDs. If `ENSG00000123456` returns empty:

```python
# Step 1: Get gene info with version
gene_info = tu.tools.ensembl_lookup_gene(id=ensembl_id, species="human")
version = gene_info.get('version', 1)

# Step 2: Try versioned ID
versioned_id = f"{ensembl_id}.{version}"  # e.g., "ENSG00000123456.12"
result = tu.tools.GTEx_get_median_gene_expression(
    gencode_id=versioned_id,
    operation="median"
)
```

---

## When to Use This Skill

Apply when users:
- Ask about a drug target, protein, or gene
- Need target validation or assessment
- Request druggability analysis
- Want comprehensive target profiling
- Ask "what do we know about [target]?"
- Need target-disease associations
- Request safety profile for a target

---

## Critical Workflow Requirements

### 1. Report-First Approach (MANDATORY)

**DO NOT** show the search process or tool outputs to the user. Instead:

1. **Create the report file FIRST** - Before any data collection:
   - File name: `[TARGET]_target_report.md`
   - Initialize with all 14 section headers
   - Add placeholder: `[Researching...]` in each section

2. **Progressively update the report** - As you gather data:
   - Update each section immediately after retrieving data
   - Replace `[Researching...]` with actual content
   - Include "No data returned" when tools return empty results

3. **Methodology in appendix only** - If user requests methodology details, create separate `[TARGET]_methods_appendix.md`

### 2. Evidence Grading System (MANDATORY)

**CRITICAL**: Grade every claim by evidence strength.

#### Evidence Tiers

| Tier | Symbol | Criteria | Examples |
|------|--------|----------|----------|
| **T1** | ★★★ | Direct mechanistic evidence, human genetic proof | CRISPR KO, patient mutations, crystal structure with mechanism |
| **T2** | ★★☆ | Functional studies, model organism validation | siRNA phenotype, mouse KO, biochemical assay |
| **T3** | ★☆☆ | Association, screen hits, computational | GWAS hit, DepMap essentiality, expression correlation |
| **T4** | ☆☆☆ | Mention, review, text-mined, predicted | Review article, database annotation, computational prediction |

#### Required Evidence Grading Locations

Evidence grades MUST appear in:
1. **Executive Summary** - Key disease claims graded
2. **Section 8.2 Disease Associations** - Every disease link graded with source type
3. **Section 11 Literature** - Key papers table with evidence tier
4. **Section 13 Recommendations** - Scorecard items reference evidence quality

#### Per-Section Evidence Summary

```markdown
---
**Evidence Quality for this Section**: Strong
- Mechanistic (T1): 12 papers
- Functional (T2): 8 papers
- Association (T3): 15 papers
- Mention (T4): 23 papers
**Data Gaps**: No CRISPR data; mouse KO phenotypes limited
---
```

### 3. Citation Requirements (MANDATORY)

Every piece of information MUST include its source:

```markdown
EGFR mutations cause lung adenocarcinoma [★★★: PMID:15118125, activating mutations 
in patients]. *Source: ClinVar, CIViC*
```

---

## Core Strategy: 9 Research Paths

Execute 9 research paths (Path 0 is always first):

```
Target Query (e.g., "EGFR" or "P00533")
│
├─ IDENTIFIER RESOLUTION (always first)
│   └─ Check if GPCR → GPCRdb_get_protein
│
├─ PATH 0: Open Targets Foundation (ALWAYS FIRST - fills gaps in all other paths)
│
├─ PATH 1: Core Identity (names, IDs, sequence, organism)
│   └─ InterProScan_scan_sequence for novel domain prediction (NEW)
├─ PATH 2: Structure & Domains (3D structure, domains, binding sites)
│   └─ If GPCR: GPCRdb_get_structures (active/inactive states)
├─ PATH 3: Function & Pathways (GO terms, pathways, biological role)
├─ PATH 4: Protein Interactions (PPI network, complexes)
├─ PATH 5: Expression Profile (tissue expression, single-cell)
├─ PATH 6: Variants & Disease (mutations, clinical significance)
│   └─ DisGeNET_search_gene for curated gene-disease associations
├─ PATH 7: Drug Interactions (known drugs, druggability, safety)
│   ├─ Pharos_get_target for TDL classification (Tclin/Tchem/Tbio/Tdark)
│   ├─ BindingDB_get_ligands_by_uniprot for known ligands (NEW)
│   ├─ PubChem_search_assays_by_target_gene for HTS data (NEW)
│   ├─ If GPCR: GPCRdb_get_ligands (curated agonists/antagonists)
│   └─ DepMap_get_gene_dependencies for target essentiality
└─ PATH 8: Literature & Research (publications, trends)
```

---

## Identifier Resolution (Phase 1)

**CRITICAL**: Resolve ALL identifiers before any research path.

```python
def resolve_target_ids(tu, query):
    """
    Resolve target query to ALL needed identifiers.
    Returns dict with: query, uniprot, ensembl, ensembl_version, symbol, 
    entrez, chembl_target, hgnc
    """
    ids = {
        'query': query, 
        'uniprot': None, 
        'ensembl': None, 
        'ensembl_versioned': None,  # For GTEx
        'symbol': None,
        'entrez': None,
        'chembl_target': None,
        'hgnc': None,
        'full_name': None,
        'synonyms': []
    }
    
    # [Resolution logic based on input type]
    # ... (see current implementation)
    
    # CRITICAL: Get versioned Ensembl ID for GTEx
    if ids['ensembl']:
        gene_info = tu.tools.ensembl_lookup_gene(id=ids['ensembl'], species="human")
        if gene_info and gene_info.get('version'):
            ids['ensembl_versioned'] = f"{ids['ensembl']}.{gene_info['version']}"
        
        # Also get synonyms for literature collision detection
        ids['full_name'] = gene_info.get('description', '').split(' [')[0]
    
    # Get UniProt alternative names for synonyms
    if ids['uniprot']:
        alt_names = tu.tools.UniProt_get_alternative_names_by_accession(accession=ids['uniprot'])
        if alt_names:
            ids['synonyms'].extend(alt_names)
    
    return ids
```

### GPCR Target Detection (NEW)

~35% of approved drugs target GPCRs. After identifier resolution, check if target is a GPCR:

```python
def check_gpcr_target(tu, ids):
    """
    Check if target is a GPCR and retrieve specialized data.
    Call after identifier resolution.
    """
    symbol = ids.get('symbol', '')
    
    # Build GPCRdb entry name
    entry_name = f"{symbol.lower()}_human"
    
    gpcr_info = tu.tools.GPCRdb_get_protein(
        operation="get_protein",
        protein=entry_name
    )
    
    if gpcr_info.get('status') == 'success':
        # Target is a GPCR - get specialized data
        
        # Get structures with receptor state
        structures = tu.tools.GPCRdb_get_structures(
            operation="get_structures",
            protein=entry_name
        )
        
        # Get known ligands (critical for binder projects)
        ligands = tu.tools.GPCRdb_get_ligands(
            operation="get_ligands",
            protein=entry_name
        )
        
        # Get mutation data
        mutations = tu.tools.GPCRdb_get_mutations(
            operation="get_mutations",
            protein=entry_name
        )
        
        return {
            'is_gpcr': True,
            'gpcr_family': gpcr_info['data'].get('family'),
            'gpcr_class': gpcr_info['data'].get('receptor_class'),
            'structures': structures.get('data', {}).get('structures', []),
            'ligands': ligands.get('data', {}).get('ligands', []),
            'mutations': mutations.get('data', {}).get('mutations', []),
            'ballesteros_numbering': True  # GPCRdb provides this
        }
    
    return {'is_gpcr': False}
```

**GPCRdb Report Section** (add to Section 2 for GPCR targets):

```markdown
### 2.x GPCR-Specific Data (GPCRdb)

**Receptor Class**: Class A (Rhodopsin-like)  
**GPCR Family**: Adrenoceptors  

**Structures by State**:
| PDB ID | State | Resolution | Ligand | Year |
|--------|-------|------------|--------|------|
| 3SN6 | Active | 3.2Å | Agonist (BI-167107) | 2011 |
| 2RH1 | Inactive | 2.4Å | Antagonist (carazolol) | 2007 |

**Known Ligands**: 45 agonists, 32 antagonists, 8 allosteric modulators  
**Key Binding Site Residues** (Ballesteros-Weinstein): 3.32, 5.42, 6.48, 7.39
```

### Collision Detection for Literature Search

Before literature search, detect naming collisions:

```python
def detect_collisions(tu, symbol, full_name):
    """
    Detect if gene symbol has naming collisions in literature.
    Returns negative filter terms if collisions found.
    """
    # Search by symbol in title
    results = tu.tools.PubMed_search_articles(
        query=f'"{symbol}"[Title]',
        limit=20
    )
    
    # Check if >20% are off-topic
    off_topic_terms = []
    for paper in results.get('articles', []):
        title = paper.get('title', '').lower()
        # Check if title mentions biology/protein/gene context
        bio_terms = ['protein', 'gene', 'cell', 'expression', 'mutation', 'kinase', 'receptor']
        if not any(term in title for term in bio_terms):
            # Extract potential collision terms
            # e.g., "JAK" might collide with "Just Another Kinase" jokes
            # e.g., "WDR7" might collide with other WDR family members in certain contexts
            pass
    
    # Build negative filter
    collision_filter = ""
    if off_topic_terms:
        collision_filter = " NOT " + " NOT ".join(off_topic_terms)
    
    return collision_filter
```

---

## PATH 0: Open Targets Foundation (ALWAYS FIRST)

**Objective**: Populate baseline data for Sections 5, 8, 9, 10, 11 before specialized queries.

**CRITICAL**: Open Targets provides the most comprehensive aggregated data. Query ALL these endpoints:

| Endpoint | Section | Data Type |
|----------|---------|-----------|
| `OpenTargets_get_diseases_phenotypes_by_target_ensemblId` | 8 | Diseases/phenotypes |
| `OpenTargets_get_target_tractability_by_ensemblId` | 9 | Druggability assessment |
| `OpenTargets_get_target_safety_profile_by_ensemblId` | 10 | Safety liabilities |
| `OpenTargets_get_target_interactions_by_ensemblId` | 6 | PPI network |
| `OpenTargets_get_target_gene_ontology_by_ensemblId` | 5 | GO annotations |
| `OpenTargets_get_publications_by_target_ensemblId` | 11 | Literature |
| `OpenTargets_get_biological_mouse_models_by_ensemblId` | 8/10 | Mouse KO phenotypes |
| `OpenTargets_get_chemical_probes_by_target_ensemblId` | 9 | Chemical probes |
| `OpenTargets_get_associated_drugs_by_target_ensemblId` | 9 | Known drugs |

### Path 0 Implementation

```python
def path_0_open_targets(tu, ids):
    """
    Open Targets foundation data - fills gaps for sections 5, 6, 8, 9, 10, 11.
    ALWAYS run this first.
    """
    ensembl_id = ids['ensembl']
    if not ensembl_id:
        return {'status': 'skipped', 'reason': 'No Ensembl ID'}
    
    results = {}
    
    # 1. Diseases & Phenotypes (Section 8)
    diseases = tu.tools.OpenTargets_get_diseases_phenotypes_by_target_ensemblId(
        ensemblId=ensembl_id
    )
    results['diseases'] = diseases if diseases else {'note': 'No disease associations returned'}
    
    # 2. Tractability (Section 9)
    tractability = tu.tools.OpenTargets_get_target_tractability_by_ensemblId(
        ensemblId=ensembl_id
    )
    results['tractability'] = tractability if tractability else {'note': 'No tractability data returned'}
    
    # 3. Safety Profile (Section 10)
    safety = tu.tools.OpenTargets_get_target_safety_profile_by_ensemblId(
        ensemblId=ensembl_id
    )
    results['safety'] = safety if safety else {'note': 'No safety liabilities identified'}
    
    # 4. Interactions (Section 6)
    interactions = tu.tools.OpenTargets_get_target_interactions_by_ensemblId(
        ensemblId=ensembl_id
    )
    results['interactions'] = interactions if interactions else {'note': 'No interactions returned'}
    
    # 5. GO Annotations (Section 5)
    go_terms = tu.tools.OpenTargets_get_target_gene_ontology_by_ensemblId(
        ensemblId=ensembl_id
    )
    results['go_terms'] = go_terms if go_terms else {'note': 'No GO annotations returned'}
    
    # 6. Publications (Section 11)
    publications = tu.tools.OpenTargets_get_publications_by_target_ensemblId(
        ensemblId=ensembl_id
    )
    results['publications'] = publications if publications else {'note': 'No publications returned'}
    
    # 7. Mouse Models (Section 8/10)
    mouse_models = tu.tools.OpenTargets_get_biological_mouse_models_by_ensemblId(
        ensemblId=ensembl_id
    )
    results['mouse_models'] = mouse_models if mouse_models else {'note': 'No mouse model data returned'}
    
    # 8. Chemical Probes (Section 9)
    probes = tu.tools.OpenTargets_get_chemical_probes_by_target_ensemblId(
        ensemblId=ensembl_id
    )
    results['chemical_probes'] = probes if probes else {'note': 'No chemical probes available'}
    
    # 9. Associated Drugs (Section 9)
    drugs = tu.tools.OpenTargets_get_associated_drugs_by_target_ensemblId(
        ensemblId=ensembl_id
    )
    results['drugs'] = drugs if drugs else {'note': 'No approved/trial drugs found'}
    
    return results
```

### Negative Results Are Data

**CRITICAL**: Always document when a query returns empty:

```markdown
### 9.3 Chemical Probes

**Status**: No validated chemical probes available for this target.
*Source: OpenTargets_get_chemical_probes_by_target_ensemblId returned empty*

**Implication**: Tool compound development would be needed for chemical biology studies.
```

---

## PATH 2: Structure & Domains (Enhanced)

**Objective**: Robust structure coverage using 3-step chain.

### 3-Step Structure Search Chain

**Do NOT rely solely on PDB text search.** Use this chain:

```python
def path_structure_robust(tu, ids):
    """
    Robust structure search using 3-step chain.
    """
    structures = {'pdb': [], 'alphafold': None, 'domains': [], 'method_notes': []}
    
    # STEP 1: UniProt PDB Cross-References (most reliable)
    if ids['uniprot']:
        entry = tu.tools.UniProt_get_entry_by_accession(accession=ids['uniprot'])
        pdb_xrefs = [x for x in entry.get('uniProtKBCrossReferences', []) 
                    if x.get('database') == 'PDB']
        for xref in pdb_xrefs:
            pdb_id = xref.get('id')
            # Get details for each PDB
            pdb_info = tu.tools.get_protein_metadata_by_pdb_id(pdb_id=pdb_id)
            if pdb_info:
                structures['pdb'].append(pdb_info)
        structures['method_notes'].append(f"Step 1: {len(pdb_xrefs)} PDB cross-refs from UniProt")
    
    # STEP 2: Sequence-based PDB Search (catches missing annotations)
    if ids['uniprot'] and len(structures['pdb']) < 5:
        sequence = tu.tools.UniProt_get_sequence_by_accession(accession=ids['uniprot'])
        if sequence and len(sequence) < 1000:  # Reasonable length for search
            similar = tu.tools.PDB_search_similar_structures(
                sequence=sequence[:500],  # Use first 500 AA if long
                identity_cutoff=0.7
            )
            if similar:
                for hit in similar[:10]:  # Top 10 similar
                    if hit['pdb_id'] not in [s.get('pdb_id') for s in structures['pdb']]:
                        structures['pdb'].append(hit)
        structures['method_notes'].append(f"Step 2: Sequence search (identity ≥70%)")
    
    # STEP 3: Domain-based Search (for multi-domain proteins)
    if ids['uniprot']:
        domains = tu.tools.InterPro_get_protein_domains(uniprot_accession=ids['uniprot'])
        structures['domains'] = domains if domains else []
        
        # For large proteins with domains, search by domain sequence windows
        if len(structures['pdb']) < 3 and domains:
            for domain in domains[:3]:  # Top 3 domains
                domain_name = domain.get('name', '')
                # Could search PDB by domain name
                domain_hits = tu.tools.PDB_search_by_keyword(query=domain_name, limit=5)
                if domain_hits:
                    structures['method_notes'].append(f"Step 3: Domain '{domain_name}' search")
    
    # AlphaFold (always check)
    alphafold = tu.tools.alphafold_get_prediction(uniprot_accession=ids['uniprot'])
    structures['alphafold'] = alphafold if alphafold else {'note': 'No AlphaFold prediction'}
    
    # IMPORTANT: Document limitations
    if not structures['pdb']:
        structures['limitation'] = "No direct PDB hit does NOT mean no structure exists. Check: (1) structures under different UniProt entries, (2) homolog structures, (3) domain-only structures."
    
    return structures
```

### Structure Section Output Format

```markdown
### 4.1 Experimental Structures (PDB)

**Total PDB Entries**: 23 structures *(Source: UniProt cross-references)*
**Search Method**: 3-step chain (UniProt xrefs → sequence search → domain search)

| PDB ID | Resolution | Method | Ligand | Coverage | Year |
|--------|------------|--------|--------|----------|------|
| 1M17 | 2.6Å | X-ray | Erlotinib | 672-998 | 2002 |
| 3POZ | 2.8Å | X-ray | Gefitinib | 696-1022 | 2010 |

**Note**: "No direct PDB hit" ≠ "no structure exists". Check homologs and domain structures.
```

---

## PATH 5: Expression Profile (Enhanced)

### GTEx with Versioned ID Fallback

```python
def path_expression(tu, ids):
    """
    Expression data with GTEx versioned ID fallback.
    """
    results = {'gtex': None, 'hpa': None, 'failed_tools': []}
    
    # GTEx with fallback
    ensembl_id = ids['ensembl']
    versioned_id = ids.get('ensembl_versioned')
    
    # Try unversioned first
    gtex_result = tu.tools.GTEx_get_median_gene_expression(
        gencode_id=ensembl_id,
        operation="median"
    )
    
    # Fallback to versioned if empty
    if not gtex_result or gtex_result.get('data') == []:
        if versioned_id:
            gtex_result = tu.tools.GTEx_get_median_gene_expression(
                gencode_id=versioned_id,
                operation="median"
            )
            if gtex_result and gtex_result.get('data'):
                results['gtex'] = gtex_result
                results['gtex_note'] = f"Used versioned ID: {versioned_id}"
        
        if not results.get('gtex'):
            results['failed_tools'].append({
                'tool': 'GTEx_get_median_gene_expression',
                'tried': [ensembl_id, versioned_id],
                'fallback': 'See HPA data below'
            })
    else:
        results['gtex'] = gtex_result
    
    # HPA (always query as backup)
    hpa_result = tu.tools.HPA_get_rna_expression_by_source(ensembl_id=ensembl_id)
    results['hpa'] = hpa_result if hpa_result else {'note': 'No HPA RNA data'}
    
    return results
```

### Human Protein Atlas - Extended Expression (NEW)

HPA provides comprehensive protein expression data including tissue-level, cell-level, and cell line expression.

```python
def get_hpa_comprehensive_expression(tu, gene_symbol):
    """
    Get comprehensive expression data from Human Protein Atlas.
    
    Provides:
    - Tissue expression (protein and RNA)
    - Subcellular localization
    - Cell line expression comparison
    - Tissue specificity
    """
    
    # 1. Search for gene to get IDs
    gene_info = tu.tools.HPA_search_genes_by_query(search_query=gene_symbol)
    
    if not gene_info:
        return {'error': f'Gene {gene_symbol} not found in HPA'}
    
    # 2. Get tissue expression with specificity
    tissue_search = tu.tools.HPA_generic_search(
        search_query=gene_symbol,
        columns="g,gs,rnat,rnatsm,scml,scal",  # Gene, synonyms, tissue specificity, subcellular
        format="json"
    )
    
    # 3. Compare expression in cancer cell lines vs normal tissue
    cell_lines = ['a549', 'mcf7', 'hela', 'hepg2', 'pc3']
    cell_line_expression = {}
    
    for cell_line in cell_lines:
        try:
            expr = tu.tools.HPA_get_comparative_expression_by_gene_and_cellline(
                gene_name=gene_symbol,
                cell_line=cell_line
            )
            cell_line_expression[cell_line] = expr
        except:
            continue
    
    return {
        'gene_info': gene_info,
        'tissue_data': tissue_search,
        'cell_line_expression': cell_line_expression,
        'source': 'Human Protein Atlas'
    }
```

**HPA Expression Output for Report**:
```markdown
### Tissue Expression Profile (Human Protein Atlas)

| Tissue | Protein Level | RNA nTPM | Specificity |
|--------|---------------|----------|-------------|
| Brain | High | 45.2 | Enriched |
| Liver | Medium | 23.1 | Enhanced |
| Kidney | Low | 8.4 | Not detected |

**Subcellular Localization**: Cytoplasm, Plasma membrane

### Cancer Cell Line Expression

| Cell Line | Cancer Type | Expression | vs Normal |
|-----------|-------------|------------|-----------|
| A549 | Lung | High | Elevated |
| MCF7 | Breast | Medium | Similar |
| HeLa | Cervical | High | Elevated |

*Source: Human Protein Atlas via `HPA_search_genes_by_query`, `HPA_get_comparative_expression_by_gene_and_cellline`*
```

**Why HPA for Target Research**:
- **Drug target validation** - Confirm expression in target tissue
- **Safety assessment** - Expression in essential organs
- **Biomarker potential** - Tissue-specific expression
- **Cell line selection** - Choose appropriate models

---

## PATH 6: Variants & Disease (Enhanced)

### 6.1 ClinVar SNV vs CNV Separation

```markdown
### 8.3 Clinical Variants (ClinVar)

#### Single Nucleotide Variants (SNVs)
| Variant | Clinical Significance | Condition | Review Status | PMID |
|---------|----------------------|-----------|---------------|------|
| p.L858R | Pathogenic | Lung cancer | 4 stars | 15118125 |
| p.T790M | Pathogenic | Drug resistance | 4 stars | 15737014 |

**Total Pathogenic SNVs**: 47

#### Copy Number Variants (CNVs) - Reported Separately
| Type | Region | Clinical Significance | Frequency |
|------|--------|----------------------|-----------|
| Amplification | 7p11.2 | Pathogenic | Common in cancer |

*Note: CNV data separated as it represents different mutation mechanism*
```

### 6.2 DisGeNET Integration (NEW)

DisGeNET provides curated gene-disease associations with evidence scores. **Requires**: `DISGENET_API_KEY`

```python
def get_disgenet_associations(tu, ids):
    """
    Get gene-disease associations from DisGeNET.
    Complements Open Targets with curated association scores.
    """
    symbol = ids.get('symbol')
    if not symbol:
        return {'status': 'skipped', 'reason': 'No gene symbol'}
    
    # Get all disease associations for gene
    gda = tu.tools.DisGeNET_search_gene(
        operation="search_gene",
        gene=symbol,
        limit=50
    )
    
    if gda.get('status') != 'success':
        return {'status': 'error', 'message': 'DisGeNET query failed'}
    
    associations = gda.get('data', {}).get('associations', [])
    
    # Categorize by evidence strength
    strong = []     # score >= 0.7
    moderate = []   # score 0.4-0.7  
    weak = []       # score < 0.4
    
    for assoc in associations:
        score = assoc.get('score', 0)
        disease_name = assoc.get('disease_name', '')
        umls_cui = assoc.get('disease_id', '')
        
        entry = {
            'disease': disease_name,
            'umls_cui': umls_cui,
            'score': score,
            'evidence_index': assoc.get('ei'),
            'dsi': assoc.get('dsi'),  # Disease Specificity Index
            'dpi': assoc.get('dpi')   # Disease Pleiotropy Index
        }
        
        if score >= 0.7:
            strong.append(entry)
        elif score >= 0.4:
            moderate.append(entry)
        else:
            weak.append(entry)
    
    return {
        'total_associations': len(associations),
        'strong_associations': strong,
        'moderate_associations': moderate,
        'weak_associations': weak[:10],  # Limit weak
        'disease_pleiotropy': len(associations)  # How many diseases linked
    }
```

**DisGeNET Report Section** (add to Section 8 - Disease Associations):

```markdown
### 8.x DisGeNET Gene-Disease Associations (NEW)

**Total Diseases Associated**: 47  
**Disease Pleiotropy Index**: High (gene linked to many disease types)

#### Strong Associations (Score ≥0.7)
| Disease | UMLS CUI | Score | Evidence Index |
|---------|----------|-------|----------------|
| Non-small cell lung cancer | C0007131 | 0.85 | 0.92 |
| Glioblastoma | C0017636 | 0.78 | 0.88 |

#### Moderate Associations (Score 0.4-0.7)
| Disease | UMLS CUI | Score | DSI |
|---------|----------|-------|-----|
| Breast cancer | C0006142 | 0.62 | 0.45 |

*Note: DisGeNET score integrates curated databases, GWAS, animal models, and literature*
```

**Evidence Tier Assignment**:
- DisGeNET Score ≥0.7 → Consider T2 evidence (multiple validated sources)
- DisGeNET Score 0.4-0.7 → Consider T3 evidence
- DisGeNET Score <0.4 → T4 evidence only

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-target-research/REFERENCE.md`
