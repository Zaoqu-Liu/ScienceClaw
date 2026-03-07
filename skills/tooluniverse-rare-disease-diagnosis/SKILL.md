---
name: tooluniverse-rare-disease-diagnosis
description: Provide differential diagnosis for patients with suspected rare diseases based on phenotype and genetic data. Matches symptoms to HPO terms, identifies candidate diseases from Orphanet/OMIM, prioritizes genes for testing, interprets variants of uncertain significance. Use when clinician asks about rare disease diagnosis, unexplained phenotypes, or genetic testing interpretation.
---

# Rare Disease Diagnosis Advisor

Systematic diagnosis support for rare diseases using phenotype matching, gene panel prioritization, and variant interpretation across Orphanet, OMIM, HPO, ClinVar, and structure-based analysis.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create report file FIRST, update progressively
2. **Phenotype-driven** - Convert symptoms to HPO terms before searching
3. **Multi-database triangulation** - Cross-reference Orphanet, OMIM, OpenTargets
4. **Evidence grading** - Grade diagnoses by supporting evidence strength
5. **Actionable output** - Prioritized differential diagnosis with next steps
6. **Genetic counseling aware** - Consider inheritance patterns and family history
7. **English-first queries** - Always use English terms in tool calls (phenotype descriptions, gene names, disease names), even if the user writes in another language. Only try original-language terms as a fallback. Respond in the user's language

---

## When to Use

Apply when user asks:
- "Patient has [symptoms], what rare disease could this be?"
- "Unexplained developmental delay with [features]"
- "WES found VUS in [gene], is this pathogenic?"
- "What genes should we test for [phenotype]?"
- "Differential diagnosis for [rare symptom combination]"

---

## Critical Workflow Requirements

### 1. Report-First Approach (MANDATORY)

1. **Create the report file FIRST**:
   - File name: `[PATIENT_ID]_rare_disease_report.md`
   - Initialize with all section headers
   - Add placeholder text: `[Researching...]`

2. **Progressively update** as you gather data

3. **Output separate data files**:
   - `[PATIENT_ID]_gene_panel.csv` - Prioritized genes for testing
   - `[PATIENT_ID]_variant_interpretation.csv` - If variants provided

### 2. Citation Requirements (MANDATORY)

Every finding MUST include source:

```markdown
### Candidate Disease: Marfan Syndrome
- **ORPHA**: ORPHA:558
- **OMIM**: 154700
- **Phenotype match**: 85% (17/20 HPO terms)
- **Inheritance**: AD
- **Gene**: FBN1

*Source: Orphanet via `Orphanet_558`, OMIM via `OMIM_get_entry`*
```

---

## Phase 0: Tool Verification

**CRITICAL**: Verify tool parameters before calling.

### Known Parameter Corrections

| Tool | WRONG Parameter | CORRECT Parameter |
|------|-----------------|-------------------|
| `OpenTargets_get_associated_diseases_by_target_ensemblId` | `ensemblID` | `ensemblId` |
| `ClinVar_get_variant_by_id` | `variant_id` | `id` |
| `MyGene_query_genes` | `gene` | `q` |
| `gnomAD_get_variant_frequencies` | `variant` | `variant_id` |

---

## Workflow Overview

```
Phase 1: Phenotype Standardization
├── Convert symptoms to HPO terms
├── Identify core vs. variable features
└── Note age of onset, inheritance hints
    ↓
Phase 2: Disease Matching
├── Orphanet phenotype search
├── OMIM clinical synopsis match
├── OpenTargets disease associations
└── OUTPUT: Ranked differential diagnosis
    ↓
Phase 3: Gene Panel Identification
├── Extract genes from top diseases
├── Cross-reference expression (GTEx)
├── Prioritize by evidence strength
└── OUTPUT: Recommended gene panel
    ↓
Phase 3.5: Expression & Tissue Context (NEW)
├── CELLxGENE: Cell-type specific expression
├── ChIPAtlas: Regulatory context (TF binding)
├── Tissue-specific gene networks
└── OUTPUT: Expression validation
    ↓
Phase 3.6: Pathway Analysis (NEW)
├── KEGG: Metabolic/signaling pathways
├── Reactome: Biological processes
├── IntAct: Protein-protein interactions
└── OUTPUT: Biological context
    ↓
Phase 4: Variant Interpretation (if provided)
├── ClinVar pathogenicity lookup
├── gnomAD population frequency
├── Protein domain/function impact
├── ENCODE/ChIPAtlas: Regulatory variant impact
└── OUTPUT: Variant classification
    ↓
Phase 5: Structure Analysis (for VUS)
├── NvidiaNIM_alphafold2 → Predict structure
├── Map variant to structure
├── Assess functional domain impact
└── OUTPUT: Structural evidence
    ↓
Phase 6: Literature Evidence (NEW)
├── PubMed: Published studies
├── BioRxiv/MedRxiv: Preprints
├── OpenAlex: Citation analysis
└── OUTPUT: Literature support
    ↓
Phase 7: Report Synthesis
├── Prioritized differential diagnosis
├── Recommended genetic testing
├── Next steps for clinician
└── OUTPUT: Final report
```

---

## Phase 1: Phenotype Standardization

### 1.1 Convert Symptoms to HPO Terms

```python
def standardize_phenotype(tu, symptoms_list):
    """Convert clinical descriptions to HPO terms."""
    hpo_terms = []
    
    for symptom in symptoms_list:
        # Search HPO for matching terms
        results = tu.tools.HPO_search_terms(query=symptom)
        if results:
            hpo_terms.append({
                'original': symptom,
                'hpo_id': results[0]['id'],
                'hpo_name': results[0]['name'],
                'confidence': 'exact' if symptom.lower() in results[0]['name'].lower() else 'partial'
            })
    
    return hpo_terms
```

### 1.2 Phenotype Categories

| Category | Examples | Weight |
|----------|----------|--------|
| **Core features** | Always present in disease | High |
| **Variable features** | Present in >50% | Medium |
| **Occasional features** | Present in <50% | Low |
| **Age-specific** | Onset-dependent | Context |

### 1.3 Output for Report

```markdown
## 1. Phenotype Analysis

### 1.1 Standardized HPO Terms

| Clinical Feature | HPO Term | HPO ID | Category |
|------------------|----------|--------|----------|
| Tall stature | Tall stature | HP:0000098 | Core |
| Long fingers | Arachnodactyly | HP:0001166 | Core |
| Heart murmur | Cardiac murmur | HP:0030148 | Variable |
| Joint hypermobility | Joint hypermobility | HP:0001382 | Core |

**Total HPO Terms**: 8
**Onset**: Childhood
**Family History**: Father with similar features (AD suspected)

*Source: HPO via `HPO_search_terms`*
```

---

## Phase 2: Disease Matching

### 2.1 Orphanet Disease Search (NEW TOOLS)

```python
def match_diseases_orphanet(tu, symptom_keywords):
    """Find rare diseases matching symptoms using Orphanet."""
    candidate_diseases = []
    
    # Search Orphanet by disease keywords
    for keyword in symptom_keywords:
        results = tu.tools.Orphanet_search_diseases(
            operation="search_diseases",
            query=keyword
        )
        if results.get('status') == 'success':
            candidate_diseases.extend(results['data']['results'])
    
    # Get genes for each disease
    for disease in candidate_diseases:
        orpha_code = disease.get('ORPHAcode')
        genes = tu.tools.Orphanet_get_genes(
            operation="get_genes",
            orpha_code=orpha_code
        )
        disease['genes'] = genes.get('data', {}).get('genes', [])
    
    return deduplicate_and_rank(candidate_diseases)
```

### 2.2 OMIM Cross-Reference (NEW TOOLS)

```python
def cross_reference_omim(tu, orphanet_diseases, gene_symbols):
    """Get OMIM details for diseases and genes."""
    omim_data = {}
    
    # Search OMIM for each disease/gene
    for gene in gene_symbols:
        search_result = tu.tools.OMIM_search(
            operation="search",
            query=gene,
            limit=5
        )
        if search_result.get('status') == 'success':
            for entry in search_result['data'].get('entries', []):
                mim_number = entry.get('mimNumber')
                
                # Get detailed entry
                details = tu.tools.OMIM_get_entry(
                    operation="get_entry",
                    mim_number=str(mim_number)
                )
                
                # Get clinical synopsis (phenotype features)
                synopsis = tu.tools.OMIM_get_clinical_synopsis(
                    operation="get_clinical_synopsis",
                    mim_number=str(mim_number)
                )
                
                omim_data[gene] = {
                    'mim_number': mim_number,
                    'details': details.get('data', {}),
                    'clinical_synopsis': synopsis.get('data', {})
                }
    
    return omim_data
```

### 2.3 DisGeNET Gene-Disease Associations (NEW TOOLS)

```python
def get_gene_disease_associations(tu, gene_symbols):
    """Get gene-disease associations from DisGeNET."""
    associations = {}
    
    for gene in gene_symbols:
        # Get diseases associated with gene
        result = tu.tools.DisGeNET_search_gene(
            operation="search_gene",
            gene=gene,
            limit=20
        )
        
        if result.get('status') == 'success':
            associations[gene] = result['data'].get('associations', [])
    
    return associations

def get_disease_genes_disgenet(tu, disease_name):
    """Get all genes associated with a disease."""
    result = tu.tools.DisGeNET_search_disease(
        operation="search_disease",
        disease=disease_name,
        limit=30
    )
    return result.get('data', {}).get('associations', [])
```

### 2.4 Phenotype Overlap Scoring

| Match Level | Score | Criteria |
|-------------|-------|----------|
| **Excellent** | >80% | Most core + variable features match |
| **Good** | 60-80% | Core features match, some variable |
| **Possible** | 40-60% | Some overlap, needs consideration |
| **Unlikely** | <40% | Poor phenotype fit |

### 2.5 Output for Report

```markdown
## 2. Differential Diagnosis

### Top Candidate Diseases (Ranked by Phenotype Match)

| Rank | Disease | ORPHA | OMIM | Match | Inheritance | Key Gene(s) |
|------|---------|-------|------|-------|-------------|-------------|
| 1 | Marfan syndrome | 558 | 154700 | 85% | AD | FBN1 |
| 2 | Loeys-Dietz syndrome | 60030 | 609192 | 72% | AD | TGFBR1, TGFBR2 |
| 3 | Ehlers-Danlos, vascular | 286 | 130050 | 65% | AD | COL3A1 |
| 4 | Homocystinuria | 394 | 236200 | 58% | AR | CBS |

### DisGeNET Gene-Disease Evidence

| Gene | Associated Diseases | GDA Score | Evidence |
|------|---------------------|-----------|----------|
| FBN1 | Marfan syndrome, MASS phenotype | 0.95 | ★★★ Curated |
| TGFBR1 | Loeys-Dietz syndrome | 0.89 | ★★★ Curated |
| COL3A1 | vascular EDS | 0.91 | ★★★ Curated |

*Source: DisGeNET via `DisGeNET_search_gene`*

### Disease Details

#### 1. Marfan Syndrome (★★★)

**ORPHA**: 558 | **OMIM**: 154700 | **Prevalence**: 1-5/10,000

**Phenotype Match Analysis**:
| Patient Feature | Disease Feature | Match |
|-----------------|-----------------|-------|
| Tall stature | Present in 95% | ✓ |
| Arachnodactyly | Present in 90% | ✓ |
| Joint hypermobility | Present in 85% | ✓ |
| Cardiac murmur | Aortic root dilation (70%) | Partial |

**OMIM Clinical Synopsis** (via `OMIM_get_clinical_synopsis`):
- **Cardiovascular**: Aortic root dilation, mitral valve prolapse
- **Skeletal**: Scoliosis, pectus excavatum, tall stature
- **Ocular**: Ectopia lentis, myopia

**Diagnostic Criteria**: Ghent nosology (2010)
- Aortic root dilation/dissection + FBN1 mutation = Diagnosis
- Without genetic testing: systemic score ≥7 + ectopia lentis

**Inheritance**: Autosomal dominant (25% de novo)

*Source: Orphanet via `Orphanet_get_disease`, OMIM via `OMIM_get_entry`, DisGeNET*
```

---

## Phase 3: Gene Panel Identification

### 3.1 Extract Disease Genes

```python
def build_gene_panel(tu, candidate_diseases):
    """Build prioritized gene panel from candidate diseases."""
    genes = {}
    
    for disease in candidate_diseases:
        for gene in disease['genes']:
            if gene not in genes:
                genes[gene] = {
                    'symbol': gene,
                    'diseases': [],
                    'evidence_level': 'unknown'
                }
            genes[gene]['diseases'].append(disease['name'])
    
    return genes
```

### 3.1.1 ClinGen Gene-Disease Validity Check (NEW)

**Critical**: Always verify gene-disease validity through ClinGen before including in panel.

```python
def get_clingen_gene_evidence(tu, gene_symbol):
    """
    Get ClinGen gene-disease validity and dosage sensitivity.
    ESSENTIAL for rare disease gene panel prioritization.
    """
    
    # 1. Gene-disease validity classification
    validity = tu.tools.ClinGen_search_gene_validity(gene=gene_symbol)
    
    validity_levels = []
    diseases_with_validity = []
    if validity.get('data'):
        for entry in validity.get('data', []):
            validity_levels.append(entry.get('Classification'))
            diseases_with_validity.append({
                'disease': entry.get('Disease Label'),
                'mondo_id': entry.get('Disease ID (MONDO)'),
                'classification': entry.get('Classification'),
                'inheritance': entry.get('Inheritance')
            })
    
    # 2. Dosage sensitivity (critical for CNV interpretation)
    dosage = tu.tools.ClinGen_search_dosage_sensitivity(gene=gene_symbol)
    
    hi_score = None
    ts_score = None
    if dosage.get('data'):
        for entry in dosage.get('data', []):
            hi_score = entry.get('Haploinsufficiency Score')
            ts_score = entry.get('Triplosensitivity Score')
            break
    
    # 3. Clinical actionability (return of findings context)
    actionability = tu.tools.ClinGen_search_actionability(gene=gene_symbol)
    is_actionable = (actionability.get('adult_count', 0) > 0 or 
                     actionability.get('pediatric_count', 0) > 0)
    
    # Determine best evidence level
    level_priority = ['Definitive', 'Strong', 'Moderate', 'Limited', 'Disputed', 'Refuted']
    best_level = 'Not curated'
    for level in level_priority:
        if level in validity_levels:
            best_level = level
            break
    
    return {
        'gene': gene_symbol,
        'evidence_level': best_level,
        'diseases_curated': diseases_with_validity,
        'haploinsufficiency_score': hi_score,
        'triplosensitivity_score': ts_score,
        'is_actionable': is_actionable,
        'include_in_panel': best_level in ['Definitive', 'Strong', 'Moderate']
    }

def prioritize_genes_with_clingen(tu, gene_list):
    """Prioritize genes using ClinGen evidence levels."""
    
    prioritized = []
    for gene in gene_list:
        evidence = get_clingen_gene_evidence(tu, gene)
        
        # Score based on ClinGen classification
        score = 0
        if evidence['evidence_level'] == 'Definitive':
            score = 5
        elif evidence['evidence_level'] == 'Strong':
            score = 4
        elif evidence['evidence_level'] == 'Moderate':
            score = 3
        elif evidence['evidence_level'] == 'Limited':
            score = 1
        # Disputed/Refuted get 0
        
        # Bonus for haploinsufficiency score 3
        if evidence['haploinsufficiency_score'] == '3':
            score += 1
        
        # Bonus for actionability
        if evidence['is_actionable']:
            score += 1
        
        prioritized.append({
            **evidence,
            'priority_score': score
        })
    
    # Sort by priority score
    return sorted(prioritized, key=lambda x: x['priority_score'], reverse=True)
```

**ClinGen Classification Impact on Panel**:
| Classification | Include in Panel? | Priority |
|----------------|-------------------|----------|
| **Definitive** | YES - mandatory | Highest |
| **Strong** | YES - highly recommended | High |
| **Moderate** | YES | Medium |
| **Limited** | Include but flag | Low |
| **Disputed** | Exclude or separate | Avoid |
| **Refuted** | EXCLUDE | Do not test |
| **Not curated** | Use other evidence | Variable |

### 3.2 Gene Prioritization Criteria

| Priority | Criteria | Points |
|----------|----------|--------|
| **Tier 1** | Gene causes #1 ranked disease | +5 |
| **Tier 2** | Gene causes multiple candidates | +3 |
| **Tier 3** | ClinGen "Definitive" evidence | +3 |
| **Tier 4** | Expressed in affected tissue | +2 |
| **Tier 5** | Constraint score pLI >0.9 | +1 |

### 3.3 Expression Validation

```python
def validate_expression(tu, gene_symbol, affected_tissue):
    """Check if gene is expressed in relevant tissue."""
    # Get Ensembl ID
    gene_info = tu.tools.MyGene_query_genes(q=gene_symbol, species="human")
    ensembl_id = gene_info.get('ensembl', {}).get('gene')
    
    # Check GTEx expression
    expression = tu.tools.GTEx_get_median_gene_expression(
        gencode_id=f"{ensembl_id}.latest"
    )
    
    return expression.get(affected_tissue, 0) > 1  # TPM > 1
```

### 3.4 Output for Report

```markdown
## 3. Recommended Gene Panel

### 3.1 Prioritized Genes for Testing

| Priority | Gene | Diseases | Evidence | Constraint (pLI) | Expression |
|----------|------|----------|----------|------------------|------------|
| ★★★ | FBN1 | Marfan syndrome | Definitive | 1.00 | Heart, aorta |
| ★★★ | TGFBR1 | Loeys-Dietz 1 | Definitive | 0.98 | Ubiquitous |
| ★★★ | TGFBR2 | Loeys-Dietz 2 | Definitive | 0.99 | Ubiquitous |
| ★★☆ | COL3A1 | EDS vascular | Definitive | 1.00 | Connective tissue |
| ★☆☆ | CBS | Homocystinuria | Definitive | 0.00 | Liver |

### 3.2 Panel Design Recommendation

**Minimum Panel** (high yield): FBN1, TGFBR1, TGFBR2, COL3A1
**Extended Panel** (+differential): Add CBS, SMAD3, ACTA2

**Testing Strategy**:
1. Start with FBN1 sequencing (highest pre-test probability)
2. If negative, proceed to full connective tissue panel
3. Consider WES if panel negative

*Source: ClinGen via gene-disease validity, GTEx expression*
```

---

## Phase 3.5: Expression & Tissue Context (ENHANCED)

### 3.5.1 Cell-Type Specific Expression (CELLxGENE)

```python
def get_cell_type_expression(tu, gene_symbol, affected_tissues):
    """Get single-cell expression to validate tissue relevance."""
    
    # Get expression across cell types
    expression = tu.tools.CELLxGENE_get_expression_data(
        gene=gene_symbol,
        tissue=affected_tissues[0] if affected_tissues else "all"
    )
    
    # Get cell type metadata
    cell_metadata = tu.tools.CELLxGENE_get_cell_metadata(
        gene=gene_symbol
    )
    
    # Identify high-expression cell types
    high_expression = [
        ct for ct in expression 
        if ct.get('mean_expression', 0) > 1.0  # TPM > 1
    ]
    
    return {
        'expression_data': expression,
        'high_expression_cells': high_expression,
        'total_cell_types': len(cell_metadata)
    }
```

**Why it matters**: Confirms candidate genes are expressed in disease-relevant tissues/cells.

### 3.5.2 Regulatory Context (ChIPAtlas)

```python
def get_regulatory_context(tu, gene_symbol):
    """Get transcription factor binding for candidate genes."""
    
    # Search for TF binding near gene
    tf_binding = tu.tools.ChIPAtlas_enrichment_analysis(
        gene=gene_symbol,
        cell_type="all"
    )
    
    # Get specific binding peaks
    peaks = tu.tools.ChIPAtlas_get_peak_data(
        gene=gene_symbol,
        experiment_type="TF"
    )
    
    return {
        'transcription_factors': tf_binding,
        'regulatory_peaks': peaks
    }
```

**Why it matters**: Identifies regulatory mechanisms that may be disrupted in disease.

### 3.5.3 Output for Report

```markdown
## 3.5 Expression & Regulatory Context

### Cell-Type Specific Expression (CELLxGENE)

| Gene | Top Expressing Cell Types | Expression Level | Tissue Relevance |
|------|---------------------------|------------------|------------------|
| FBN1 | Fibroblasts, Smooth muscle | High (TPM=45) | ✓ Connective tissue |
| TGFBR1 | Endothelial, Fibroblasts | Medium (TPM=12) | ✓ Vascular |
| COL3A1 | Fibroblasts, Myofibroblasts | Very High (TPM=120) | ✓ Connective tissue |

**Interpretation**: All top candidate genes show high expression in disease-relevant cell types (connective tissue, vascular cells), supporting their candidacy.

### Regulatory Context (ChIPAtlas)

| Gene | Key TF Regulators | Regulatory Significance |
|------|-------------------|------------------------|
| FBN1 | TGFβ pathway (SMAD2/3), AP-1 | TGFβ-responsive |
| TGFBR1 | STAT3, NF-κB | Inflammation-responsive |

*Source: CELLxGENE Census, ChIPAtlas*
```

---

## Phase 3.6: Pathway Analysis (NEW)

### 3.6.1 KEGG Pathway Context

```python
def get_pathway_context(tu, gene_symbols):
    """Get pathway context for candidate genes."""
    
    pathways = {}
    for gene in gene_symbols:
        # Search KEGG for gene
        kegg_genes = tu.tools.kegg_find_genes(query=f"hsa:{gene}")
        
        if kegg_genes:
            # Get pathway membership
            gene_info = tu.tools.kegg_get_gene_info(gene_id=kegg_genes[0]['id'])
            pathways[gene] = gene_info.get('pathways', [])
    
    return pathways
```

### 3.6.2 Protein-Protein Interactions (IntAct)

```python
def get_protein_interactions(tu, gene_symbol):
    """Get interaction partners for candidate genes."""
    
    # Search IntAct for interactions
    interactions = tu.tools.intact_search_interactions(
        query=gene_symbol,
        species="human"
    )
    
    # Get interaction network
    network = tu.tools.intact_get_interaction_network(
        gene=gene_symbol,
        depth=1  # Direct interactors only
    )
    
    return {
        'interactions': interactions,
        'network': network,
        'interactor_count': len(interactions)
    }
```

### 3.6.3 Output for Report

```markdown
## 3.6 Pathway & Network Context

### KEGG Pathways

| Gene | Key Pathways | Biological Process |
|------|--------------|-------------------|
| FBN1 | ECM-receptor interaction (hsa04512) | Extracellular matrix |
| TGFBR1/2 | TGF-beta signaling (hsa04350) | Cell signaling |
| COL3A1 | Focal adhesion (hsa04510) | Cell-matrix adhesion |

### Shared Pathway Analysis

**Convergent pathways** (≥2 candidate genes):
- TGF-beta signaling pathway: FBN1, TGFBR1, TGFBR2, SMAD3
- ECM organization: FBN1, COL3A1

**Interpretation**: Candidate genes converge on TGF-beta signaling and extracellular matrix pathways, consistent with connective tissue disorder etiology.

### Protein-Protein Interactions (IntAct)

| Gene | Direct Interactors | Notable Partners |
|------|-------------------|------------------|
| FBN1 | 42 | LTBP1, TGFB1, ADAMTS10 |
| TGFBR1 | 68 | TGFBR2, SMAD2, SMAD3 |

*Source: KEGG, IntAct, Reactome*
```

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-rare-disease-diagnosis/REFERENCE.md`
