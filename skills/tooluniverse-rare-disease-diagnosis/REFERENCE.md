# tooluniverse-rare-disease-diagnosis — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 4: Variant Interpretation (If Provided)

### 4.1 ClinVar Lookup

```python
def interpret_variant(tu, variant_hgvs):
    """Get ClinVar interpretation for variant."""
    result = tu.tools.ClinVar_search_variants(query=variant_hgvs)
    
    return {
        'clinvar_id': result.get('id'),
        'classification': result.get('clinical_significance'),
        'review_status': result.get('review_status'),
        'conditions': result.get('conditions'),
        'last_evaluated': result.get('last_evaluated')
    }
```

### 4.2 Population Frequency

```python
def check_population_frequency(tu, variant_id):
    """Get gnomAD allele frequency."""
    freq = tu.tools.gnomAD_get_variant_frequencies(variant_id=variant_id)
    
    # Interpret rarity
    if freq['allele_frequency'] < 0.00001:
        rarity = "Ultra-rare"
    elif freq['allele_frequency'] < 0.0001:
        rarity = "Rare"
    elif freq['allele_frequency'] < 0.01:
        rarity = "Low frequency"
    else:
        rarity = "Common (likely benign)"
    
    return freq, rarity
```

### 4.3 Computational Pathogenicity Prediction (ENHANCED)

Use state-of-the-art prediction tools for VUS interpretation:

```python
def comprehensive_vus_prediction(tu, variant_info):
    """
    Combine multiple prediction tools for VUS classification.
    Critical for rare disease variants not in ClinVar.
    """
    predictions = {}
    
    # 1. CADD - Deleteriousness (NEW API)
    cadd = tu.tools.CADD_get_variant_score(
        chrom=variant_info['chrom'],
        pos=variant_info['pos'],
        ref=variant_info['ref'],
        alt=variant_info['alt'],
        version="GRCh38-v1.7"
    )
    if cadd.get('status') == 'success':
        predictions['cadd'] = {
            'score': cadd['data'].get('phred_score'),
            'interpretation': cadd['data'].get('interpretation'),
            'acmg': 'PP3' if cadd['data'].get('phred_score', 0) >= 20 else 'neutral'
        }
    
    # 2. AlphaMissense - DeepMind pathogenicity (NEW)
    if variant_info.get('uniprot_id') and variant_info.get('aa_change'):
        am = tu.tools.AlphaMissense_get_variant_score(
            uniprot_id=variant_info['uniprot_id'],
            variant=variant_info['aa_change']  # e.g., "E1541K"
        )
        if am.get('status') == 'success' and am.get('data'):
            classification = am['data'].get('classification')
            predictions['alphamissense'] = {
                'score': am['data'].get('pathogenicity_score'),
                'classification': classification,
                'acmg': 'PP3 (strong)' if classification == 'pathogenic' else (
                    'BP4 (strong)' if classification == 'benign' else 'neutral'
                )
            }
    
    # 3. EVE - Evolutionary prediction (NEW)
    eve = tu.tools.EVE_get_variant_score(
        chrom=variant_info['chrom'],
        pos=variant_info['pos'],
        ref=variant_info['ref'],
        alt=variant_info['alt']
    )
    if eve.get('status') == 'success':
        eve_scores = eve['data'].get('eve_scores', [])
        if eve_scores:
            predictions['eve'] = {
                'score': eve_scores[0].get('eve_score'),
                'classification': eve_scores[0].get('classification'),
                'acmg': 'PP3' if eve_scores[0].get('eve_score', 0) > 0.5 else 'BP4'
            }
    
    # 4. SpliceAI - Splice variant prediction (NEW)
    # Use for intronic, synonymous, or exonic variants near splice sites
    variant_str = f"chr{variant_info['chrom']}-{variant_info['pos']}-{variant_info['ref']}-{variant_info['alt']}"
    splice = tu.tools.SpliceAI_predict_splice(
        variant=variant_str,
        genome="38"
    )
    if splice.get('data'):
        max_score = splice['data'].get('max_delta_score', 0)
        interpretation = splice['data'].get('interpretation', '')
        
        if max_score >= 0.8:
            splice_acmg = 'PP3 (strong) - high splice impact'
        elif max_score >= 0.5:
            splice_acmg = 'PP3 (moderate) - splice impact'
        elif max_score >= 0.2:
            splice_acmg = 'PP3 (supporting) - possible splice effect'
        else:
            splice_acmg = 'BP7 (if synonymous) - no splice impact'
        
        predictions['spliceai'] = {
            'max_delta_score': max_score,
            'interpretation': interpretation,
            'scores': splice['data'].get('scores', []),
            'acmg': splice_acmg
        }
    
    # Consensus for PP3/BP4
    damaging = sum(1 for p in predictions.values() if 'PP3' in p.get('acmg', ''))
    benign = sum(1 for p in predictions.values() if 'BP4' in p.get('acmg', ''))
    
    return {
        'predictions': predictions,
        'consensus': {
            'damaging_count': damaging,
            'benign_count': benign,
            'pp3_applicable': damaging >= 2 and benign == 0,
            'bp4_applicable': benign >= 2 and damaging == 0
        }
    }
```

### 4.4 ACMG Classification Criteria

| Evidence Type | Criteria | Weight |
|---------------|----------|--------|
| **PVS1** | Null variant in gene where LOF is mechanism | Very Strong |
| **PS1** | Same amino acid change as established pathogenic | Strong |
| **PM2** | Absent from population databases | Moderate |
| **PP3** | Computational evidence supports deleterious (AlphaMissense, CADD, EVE, SpliceAI) | Supporting |
| **BA1** | Allele frequency >5% | Benign standalone |

**Enhanced PP3 Evidence** (NEW):
- **AlphaMissense pathogenic** (>0.564) = Strong PP3 support (~90% accuracy)
- **CADD ≥20** + **EVE >0.5** = Multiple concordant predictions
- Agreement from 2+ predictors strengthens PP3 evidence

### 4.5 Output for Report

```markdown
## 4. Variant Interpretation

### 4.1 Variant: FBN1 c.4621G>A (p.Glu1541Lys)

| Property | Value | Interpretation |
|----------|-------|----------------|
| Gene | FBN1 | Marfan syndrome gene |
| Consequence | Missense | Amino acid change |
| ClinVar | VUS | Uncertain significance |
| gnomAD AF | 0.000004 | Ultra-rare (PM2) |

### 4.2 Computational Predictions (NEW)

| Predictor | Score | Classification | ACMG Support |
|-----------|-------|----------------|--------------|
| **AlphaMissense** | 0.78 | Pathogenic | PP3 (strong) |
| **CADD PHRED** | 28.5 | Top 0.1% deleterious | PP3 |
| **EVE** | 0.72 | Likely pathogenic | PP3 |

**Consensus**: 3/3 predictors concordant damaging → **Strong PP3 support**

*Source: AlphaMissense, CADD API, EVE via Ensembl VEP*

### 4.3 ACMG Evidence Summary

| Criterion | Evidence | Strength |
|-----------|----------|----------|
| PM2 | Absent from gnomAD (AF < 0.00001) | Moderate |
| PP3 | AlphaMissense + CADD + EVE concordant | Supporting (strong) |
| PP4 | Phenotype highly specific for Marfan | Supporting |
| PS4 | Multiple affected family members | Strong |

**Preliminary Classification**: Likely Pathogenic (1 Strong + 1 Moderate + 2 Supporting)

*Source: ClinVar, gnomAD, AlphaMissense, CADD, EVE*
```

---

## Phase 5: Structure Analysis for VUS

### 5.1 When to Perform Structure Analysis

Perform when:
- Variant is VUS or conflicting interpretations
- Missense variant in critical domain
- Novel variant not in databases
- Additional evidence needed for classification

### 5.2 Structure Prediction (NVIDIA NIM)

```python
def analyze_variant_structure(tu, protein_sequence, variant_position):
    """Predict structure and analyze variant impact."""
    
    # Predict structure with AlphaFold2
    structure = tu.tools.NvidiaNIM_alphafold2(
        sequence=protein_sequence,
        algorithm="mmseqs2",
        relax_prediction=False
    )
    
    # Extract pLDDT at variant position
    variant_plddt = get_residue_plddt(structure, variant_position)
    
    # Check if in structured region
    confidence = "High" if variant_plddt > 70 else "Low"
    
    return {
        'structure': structure,
        'variant_plddt': variant_plddt,
        'confidence': confidence
    }
```

### 5.3 Domain Impact Assessment

```python
def assess_domain_impact(tu, uniprot_id, variant_position):
    """Check if variant affects functional domain."""
    
    # Get domain annotations
    domains = tu.tools.InterPro_get_protein_domains(accession=uniprot_id)
    
    for domain in domains:
        if domain['start'] <= variant_position <= domain['end']:
            return {
                'in_domain': True,
                'domain_name': domain['name'],
                'domain_function': domain['description']
            }
    
    return {'in_domain': False}
```

### 5.4 Output for Report

```markdown
## 5. Structural Analysis

### 5.1 Structure Prediction

**Method**: AlphaFold2 via NVIDIA NIM
**Protein**: Fibrillin-1 (FBN1)
**Sequence Length**: 2,871 amino acids

| Metric | Value | Interpretation |
|--------|-------|----------------|
| Mean pLDDT | 85.3 | High confidence overall |
| Variant position pLDDT | 92.1 | Very high confidence |
| Nearby domain | cbEGF-like domain 23 | Calcium-binding |

### 5.2 Variant Location Analysis

**Variant**: p.Glu1541Lys

| Feature | Finding | Impact |
|---------|---------|--------|
| Domain | cbEGF-like domain 23 | Critical for calcium binding |
| Conservation | 100% conserved across vertebrates | High constraint |
| Structural role | Calcium coordination residue | Likely destabilizing |
| Nearby pathogenic | p.Glu1540Lys (Pathogenic) | Adjacent residue |

### 5.3 Structural Interpretation

The variant p.Glu1541Lys:
1. **Located in cbEGF domain** - These domains are critical for fibrillin-1 function
2. **Glutamate → Lysine** - Charge reversal (negative to positive)
3. **Calcium binding** - Glutamate at this position coordinates Ca2+
4. **Adjacent pathogenic variant** - p.Glu1540Lys is classified Pathogenic

**Structural Evidence**: Strong support for pathogenicity (PM1 - critical domain)

*Source: NVIDIA NIM via `NvidiaNIM_alphafold2`, InterPro*
```

---

## Phase 6: Literature Evidence (NEW)

### 6.1 Published Literature (PubMed)

```python
def search_disease_literature(tu, disease_name, genes):
    """Search for relevant published literature."""
    
    # Disease-specific search
    disease_papers = tu.tools.PubMed_search_articles(
        query=f'"{disease_name}" AND (genetics OR mutation OR variant)',
        limit=20
    )
    
    # Gene-specific searches
    gene_papers = []
    for gene in genes[:5]:  # Top 5 genes
        papers = tu.tools.PubMed_search_articles(
            query=f'"{gene}" AND rare disease AND pathogenic',
            limit=10
        )
        gene_papers.extend(papers)
    
    return {
        'disease_literature': disease_papers,
        'gene_literature': gene_papers
    }
```

### 6.2 Preprint Literature (BioRxiv/MedRxiv)

```python
def search_preprints(tu, disease_name, genes):
    """Search preprints for cutting-edge findings."""
    
    # BioRxiv search
    biorxiv = tu.tools.BioRxiv_search_preprints(
        query=f"{disease_name} genetics",
        limit=10
    )
    
    # ArXiv for computational methods
    arxiv = tu.tools.ArXiv_search_papers(
        query=f"rare disease diagnosis {' OR '.join(genes[:3])}",
        category="q-bio",
        limit=5
    )
    
    return {
        'biorxiv': biorxiv,
        'arxiv': arxiv
    }
```

### 6.3 Citation Analysis (OpenAlex)

```python
def analyze_citations(tu, key_papers):
    """Analyze citation network for key papers."""
    
    citation_analysis = []
    for paper in key_papers[:5]:
        # Get citation data
        work = tu.tools.openalex_search_works(
            query=paper['title'],
            limit=1
        )
        if work:
            citation_analysis.append({
                'title': paper['title'],
                'citations': work[0].get('cited_by_count', 0),
                'year': work[0].get('publication_year')
            })
    
    return citation_analysis
```

### 6.4 Output for Report

```markdown
## 6. Literature Evidence

### 6.1 Key Published Studies

| PMID | Title | Year | Citations | Relevance |
|------|-------|------|-----------|-----------|
| 32123456 | FBN1 variants in Marfan syndrome... | 2023 | 45 | Direct |
| 31987654 | TGF-beta signaling in connective... | 2022 | 89 | Pathway |
| 30876543 | Novel diagnostic criteria for... | 2021 | 156 | Diagnostic |

### 6.2 Recent Preprints (Not Yet Peer-Reviewed)

| Source | Title | Posted | Relevance |
|--------|-------|--------|-----------|
| BioRxiv | Novel FBN1 splice variant causes... | 2024-01 | Case report |
| MedRxiv | Machine learning for Marfan... | 2024-02 | Diagnostic |

**⚠️ Note**: Preprints have not undergone peer review. Use with caution.

### 6.3 Evidence Summary

| Evidence Type | Count | Strength |
|---------------|-------|----------|
| Case reports | 12 | Supporting |
| Functional studies | 5 | Strong |
| Clinical trials | 2 | Strong |
| Reviews | 8 | Context |

*Source: PubMed, BioRxiv, OpenAlex*
```

---

## Report Template

**File**: `[PATIENT_ID]_rare_disease_report.md`

```markdown
# Rare Disease Diagnostic Report

**Patient ID**: [ID] | **Date**: [Date] | **Status**: In Progress

---

## Executive Summary
[Researching...]

---

## 1. Phenotype Analysis
### 1.1 Standardized HPO Terms
[Researching...]
### 1.2 Key Clinical Features
[Researching...]

---

## 2. Differential Diagnosis
### 2.1 Ranked Candidate Diseases
[Researching...]
### 2.2 Disease Details
[Researching...]

---

## 3. Recommended Gene Panel
### 3.1 Prioritized Genes
[Researching...]
### 3.2 Testing Strategy
[Researching...]

---

## 4. Variant Interpretation (if applicable)
### 4.1 Variant Details
[Researching...]
### 4.2 ACMG Classification
[Researching...]

---

## 5. Structural Analysis (if applicable)
### 5.1 Structure Prediction
[Researching...]
### 5.2 Variant Impact
[Researching...]

---

## 6. Clinical Recommendations
### 6.1 Diagnostic Next Steps
[Researching...]
### 6.2 Specialist Referrals
[Researching...]
### 6.3 Family Screening
[Researching...]

---

## 7. Data Gaps & Limitations
[Researching...]

---

## 8. Data Sources
[Will be populated as research progresses...]
```

---

## Evidence Grading

| Tier | Symbol | Criteria | Example |
|------|--------|----------|---------|
| **T1** | ★★★ | Phenotype match >80% + gene match | Marfan with FBN1 mutation |
| **T2** | ★★☆ | Phenotype match 60-80% OR likely pathogenic variant | Good phenotype fit |
| **T3** | ★☆☆ | Phenotype match 40-60% OR VUS in candidate gene | Possible diagnosis |
| **T4** | ☆☆☆ | Phenotype <40% OR uncertain gene | Low probability |

---

## Completeness Checklist

### Phase 1: Phenotype
- [ ] All symptoms converted to HPO terms
- [ ] Core vs. variable features distinguished
- [ ] Age of onset documented
- [ ] Family history noted

### Phase 2: Disease Matching
- [ ] ≥5 candidate diseases identified (or all matching)
- [ ] Phenotype overlap % calculated
- [ ] Inheritance patterns noted
- [ ] ORPHA and OMIM IDs provided

### Phase 3: Gene Panel
- [ ] ≥5 genes prioritized (or all from top diseases)
- [ ] Evidence level for each gene (ClinGen)
- [ ] Expression validation performed
- [ ] Testing strategy recommended

### Phase 4: Variant Interpretation (if applicable)
- [ ] ClinVar classification retrieved
- [ ] gnomAD frequency checked
- [ ] ACMG criteria applied
- [ ] Classification justified

### Phase 5: Structure Analysis (if applicable)
- [ ] Structure predicted (if VUS)
- [ ] pLDDT confidence reported
- [ ] Domain impact assessed
- [ ] Structural evidence summarized

### Phase 6: Recommendations
- [ ] ≥3 next steps listed
- [ ] Specialist referrals suggested
- [ ] Family screening addressed

---

## Fallback Chains

| Primary Tool | Fallback 1 | Fallback 2 |
|--------------|------------|------------|
| `Orphanet_search_by_hpo` | `OMIM_search` | PubMed phenotype search |
| `ClinVar_get_variant` | `gnomAD_get_variant` | VEP annotation |
| `NvidiaNIM_alphafold2` | `alphafold_get_prediction` | UniProt features |
| `GTEx_expression` | `HPA_expression` | Tissue-specific literature |
| `gnomAD_get_variant` | `ExAC_frequencies` | 1000 Genomes |

---

## Tool Reference

See [TOOLS_REFERENCE.md](TOOLS_REFERENCE.md) for complete tool documentation.
