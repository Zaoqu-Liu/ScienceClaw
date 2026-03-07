# tooluniverse-multiomic-disease-characterization — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 5: Gene Ontology & Functional Annotation

**Objective**: Characterize biological processes, molecular functions, and cellular components.

### Tools Used

**enrichr_gene_enrichment_analysis** (GO enrichment):
- Use with `libs=['GO_Biological_Process_2023']` for BP
- Use with `libs=['GO_Molecular_Function_2023']` for MF
- Use with `libs=['GO_Cellular_Component_2023']` for CC

**GO_get_annotations_for_gene**:
- **Input**: `gene_id` (string - gene symbol or UniProt ID)
- **Output**: List of GO annotations with terms, aspects, evidence codes

**GO_search_terms**:
- **Input**: `query` (string)
- **Output**: Matching GO terms

**QuickGO_annotations_by_gene**:
- **Input**: `gene_product_id` (string - UniProt accession, e.g., 'UniProtKB:P02649'), optional `aspect` (string: 'biological_process', 'molecular_function', 'cellular_component'), `taxon_id` (int: 9606), `limit` (int: 25)
- **Output**: GO annotations with evidence codes

**OpenTargets_get_target_gene_ontology_by_ensemblID**:
- **Input**: `ensemblId` (string)
- **Output**: GO terms associated with target

### Workflow

1. Run Enrichr GO enrichment for all 3 aspects using combined gene list
2. For top 5 genes, get detailed GO annotations from QuickGO
3. For top genes, get OpenTargets GO terms
4. Summarize key biological processes, molecular functions, cellular components

---

## Phase 6: Therapeutic Landscape

**Objective**: Map approved drugs, druggable targets, repurposing opportunities, and clinical trials.

### Tools Used

**OpenTargets_get_associated_drugs_by_disease_efoId** (primary):
- **Input**: `efoId` (string), `size` (int, REQUIRED - use 100)
- **Output**: `{data: {disease: {knownDrugs: {count, rows: [{drug: {id, name, tradeNames, maximumClinicalTrialPhase, isApproved, hasBeenWithdrawn}, phase, mechanismOfAction, target: {id, approvedSymbol}, disease: {id, name}, urls: [{url, name}]}]}}}}`
- **Use**: All drugs associated with disease (approved + investigational)

**OpenTargets_get_target_tractability_by_ensemblID**:
- **Input**: `ensemblId` (string)
- **Output**: Tractability assessment (small molecule, antibody, PROTAC, etc.)

**OpenTargets_get_associated_drugs_by_target_ensemblID**:
- **Input**: `ensemblId` (string), `size` (int, REQUIRED)
- **Output**: Drugs targeting this gene/protein

**search_clinical_trials**:
- **Input**: `query_term` (string, REQUIRED), optional `condition` (string), `intervention` (string), `pageSize` (int, default 10)
- **Output**: Clinical trial results
- **NOTE**: `query_term` is REQUIRED even if `condition` is provided

**OpenTargets_get_drug_mechanisms_of_action_by_chemblId**:
- **Input**: `chemblId` (string)
- **Output**: Mechanism of action details

### Workflow

1. Get all drugs for disease from OpenTargets
2. For top disease-associated genes, check tractability
3. For top genes with no approved drugs, identify repurposing candidates
4. Search clinical trials for disease
5. For top approved drugs, get mechanism of action

### Drug Tracking

```python
drug_targets = {
    'PSEN1': {'drugs': ['Semagacestat'], 'tractability': 'small_molecule', 'clinical_phase': 3},
    'ACHE': {'drugs': ['Donepezil', 'Galantamine'], 'tractability': 'small_molecule', 'clinical_phase': 4},
    # ...
}
```

---

## Phase 7: Multi-Omics Integration

**Objective**: Integrate findings across all layers to identify cross-layer genes, calculate concordance, and generate mechanistic hypotheses.

### Cross-Layer Gene Concordance Analysis

This is the core integrative step. For each gene found in the analysis:

1. **Count layers**: In how many omics layers does this gene appear?
   - Genomics (GWAS, rare variants, genetic association)
   - Transcriptomics (DEGs, expression score)
   - Proteomics (PPI hub, protein expression)
   - Pathways (enriched pathway member)
   - Therapeutics (drug target)

2. **Score genes**: Genes appearing in 3+ layers are "multi-omics hub genes"

3. **Direction concordance**: Do genetics and expression agree?
   - Risk allele + upregulated = concordant gain-of-function
   - Risk allele + downregulated = concordant loss-of-function
   - Discordant = needs investigation

### Biomarker Identification

For each multi-omics hub gene, assess biomarker potential:
- **Diagnostic**: Gene expression distinguishes disease vs healthy
- **Prognostic**: Expression/variant predicts outcome (cancer prognostics from HPA)
- **Predictive**: Variant/expression predicts treatment response (pharmacogenomics)
- **Evidence level**: Number of supporting omics layers

### Mechanistic Hypothesis Generation

From the integrated data:
1. Identify the most supported biological processes (GO + pathways)
2. Map causal chain: genetic variant -> gene expression -> protein function -> pathway disruption -> disease
3. Identify intervention points (druggable nodes in the causal chain)
4. Generate testable hypotheses

### Confidence Score Calculation

Calculate the Multi-Omics Confidence Score (0-100) based on:
- Data availability across layers
- Cross-layer concordance
- Evidence quality
- Clinical validation

---

## Phase 8: Report Finalization

### Executive Summary

Write a 2-3 sentence synthesis covering:
- Disease mechanism in systems terms
- Key genes/pathways identified
- Therapeutic opportunities

### Final Report Quality Checklist

Before presenting to user, verify:
- [ ] All 8 sections have content (or marked as "No data available")
- [ ] Every data point has a source citation
- [ ] Executive summary reflects key findings
- [ ] Multi-Omics Confidence Score calculated
- [ ] Top 20 genes ranked by multi-omics evidence
- [ ] Top 10 enriched pathways listed
- [ ] Biomarker candidates identified
- [ ] Cross-layer concordance table complete
- [ ] Therapeutic opportunities summarized
- [ ] Mechanistic hypotheses generated
- [ ] Data Availability Checklist complete
- [ ] Completeness Checklist complete
- [ ] References section lists all tools used

---

## Tool Parameter Quick Reference

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `OpenTargets_get_disease_id_description_by_name` | `diseaseName` | Primary disambiguation |
| `OSL_get_efo_id_by_disease_name` | `disease` | Secondary disambiguation |
| `OpenTargets_get_associated_targets_by_disease_efoId` | `efoId` | Returns top 25 genes |
| `OpenTargets_get_evidence_by_datasource` | `efoId`, `ensemblId`, `datasourceIds[]`, `size` | Per-gene evidence |
| `OpenTargets_search_gwas_studies_by_disease` | `diseaseIds[]`, `size` | GWAS studies |
| `gwas_search_associations` | `disease_trait`, `size` | GWAS Catalog |
| `clinvar_search_variants` | `condition` or `gene`, `max_results` | Rare variants |
| `ExpressionAtlas_search_differential` | `condition`, `species` | DEGs |
| `expression_atlas_disease_target_score` | `efoId`, `pageSize` (REQUIRED) | Expression scores |
| `europepmc_disease_target_score` | `efoId`, `pageSize` (REQUIRED) | Literature scores |
| `HPA_get_rna_expression_by_source` | `gene_name`, `source_type`, `source_name` (ALL REQUIRED) | Tissue expression |
| `STRING_get_interaction_partners` | `protein_ids[]`, `species` (9606), `limit` | PPI partners |
| `STRING_get_network` | `protein_ids[]`, `species` | PPI network |
| `STRING_functional_enrichment` | `protein_ids[]`, `species` | Functional enrichment |
| `STRING_ppi_enrichment` | `protein_ids[]`, `species` | Network significance |
| `intact_search_interactions` | `query`, `max` | Experimental PPIs |
| `humanbase_ppi_analysis` | `gene_list[]`, `tissue`, `max_node`, `interaction`, `string_mode` (ALL REQ) | Tissue PPI |
| `enrichr_gene_enrichment_analysis` | `gene_list[]`, `libs[]` (BOTH REQUIRED) | Pathway/GO enrichment |
| `ReactomeAnalysis_pathway_enrichment` | `identifiers` (space-sep string) | Reactome enrichment |
| `Reactome_map_uniprot_to_pathways` | `id` (UniProt accession) | Protein-pathway mapping |
| `kegg_search_pathway` | `keyword` | KEGG pathway search |
| `WikiPathways_search` | `query`, `organism` | WikiPathways search |
| `GO_get_annotations_for_gene` | `gene_id` | GO annotations |
| `QuickGO_annotations_by_gene` | `gene_product_id` (e.g., 'UniProtKB:P02649') | Detailed GO |
| `OpenTargets_get_associated_drugs_by_disease_efoId` | `efoId`, `size` (REQUIRED) | Disease drugs |
| `OpenTargets_get_target_tractability_by_ensemblID` | `ensemblId` | Druggability |
| `search_clinical_trials` | `query_term` (REQUIRED), `condition`, `pageSize` | Clinical trials |
| `PubMed_search_articles` | `query`, `limit` | Literature |
| `ensembl_lookup_gene` | `gene_id`, `species` ('homo_sapiens' REQUIRED) | Gene lookup |
| `MyGene_query_genes` | `query`, `species`, `fields`, `size` | Gene info |
| `OpenTargets_get_similar_entities_by_disease_efoId` | `efoId`, `threshold`, `size` (ALL REQUIRED) | Similar diseases |

---

## Response Format Notes (Verified)

### OpenTargets Associated Targets
```json
{
  "data": {
    "disease": {
      "id": "MONDO_0004975",
      "name": "Alzheimer disease",
      "associatedTargets": {
        "count": 2456,
        "rows": [
          {
            "target": {"id": "ENSG00000080815", "approvedSymbol": "PSEN1"},
            "score": 0.87
          }
        ]
      }
    }
  }
}
```

### GWAS Catalog Associations
```json
{
  "data": [
    {
      "association_id": 216440893,
      "p_value": 2e-09,
      "or_per_copy_num": 0.94,
      "or_value": "0.94",
      "efo_traits": [{"..."}],
      "risk_frequency": "NR"
    }
  ],
  "metadata": {"pagination": {"totalElements": 1061816}}
}
```

### STRING Interactions
```json
{
  "status": "success",
  "data": [
    {
      "stringId_A": "9606.ENSP00000252486",
      "stringId_B": "9606.ENSP00000466775",
      "preferredName_A": "APOE",
      "preferredName_B": "APOC2",
      "score": 0.999
    }
  ]
}
```

### Reactome Enrichment
```json
{
  "data": {
    "token": "...",
    "pathways_found": 154,
    "pathways": [
      {
        "pathway_id": "R-HSA-1251985",
        "name": "Nuclear signaling by ERBB4",
        "species": "Homo sapiens",
        "is_disease": false,
        "is_lowest_level": true,
        "entities_found": 3,
        "entities_total": 47,
        "entities_ratio": 0.00291,
        "p_value": 4.0e-06,
        "fdr": 0.00068,
        "reactions_found": 3,
        "reactions_total": 34
      }
    ]
  }
}
```

### HPA RNA Expression
```json
{
  "status": "success",
  "data": {
    "gene_name": "APOE",
    "source_type": "tissue",
    "source_name": "brain",
    "expression_value": "2714.9",
    "expression_level": "very high",
    "expression_unit": "nTPM"
  }
}
```

### Enrichr Results
```json
{
  "status": "success",
  "data": "{\"connected_paths\": {\"Path: ...\": \"Total Weight: ...\"}}"
}
```
**NOTE**: The `data` field is a JSON string that needs parsing.

---

## Common Use Patterns

### 1. Comprehensive Disease Profiling
```
User: "Characterize Alzheimer's disease across omics layers"
-> Run all 8 phases
-> Produce full multi-omics report
```

### 2. Therapeutic Target Discovery
```
User: "What are druggable targets for rheumatoid arthritis?"
-> Emphasize Phase 1 (genomics), Phase 6 (therapeutics), Phase 7 (integration)
-> Focus on tractability and clinical precedent
```

### 3. Biomarker Identification
```
User: "Find diagnostic biomarkers for pancreatic cancer"
-> Emphasize Phase 2 (transcriptomics), Phase 3 (proteomics), Phase 7 (biomarkers)
-> Focus on tissue-specific expression and diagnostic potential
```

### 4. Mechanism Elucidation
```
User: "What pathways are dysregulated in Crohn's disease?"
-> Emphasize Phase 4 (pathways), Phase 5 (GO), Phase 7 (mechanistic hypotheses)
-> Focus on pathway enrichment and cross-pathway connections
```

### 5. Drug Repurposing
```
User: "What existing drugs could be repurposed for ALS?"
-> Emphasize Phase 1 (genetics), Phase 6 (therapeutic landscape), Phase 7 (repurposing)
-> Focus on drugs targeting disease-associated genes
```

### 6. Systems Biology
```
User: "What are the hub genes and key pathways in type 2 diabetes?"
-> Emphasize Phase 3 (PPI network), Phase 4 (pathways), Phase 7 (network analysis)
-> Focus on hub genes and network modules
```

---

## Edge Case Handling

### Rare Diseases (limited data)
- Genomics layer may dominate (single gene)
- Limited GWAS data (monogenic)
- Focus on ClinVar variants, pathway consequences
- Confidence score will be lower (less cross-layer data)

### Common Diseases (overwhelming data)
- Thousands of GWAS associations
- Prioritize by effect size and significance
- Focus on top 20-30 genes for downstream analysis
- Use strict significance thresholds (p < 5e-8)

### Cancer
- Include somatic mutations (if CIViC/cBioPortal available)
- Check cancer prognostics via HPA
- Include tumor-specific expression patterns
- Clinical trial landscape may be extensive

### Monogenic Diseases
- Single gene dominates
- ClinVar/OMIM evidence is primary
- Pathway analysis reveals downstream effects
- Therapeutic landscape may be limited (gene therapy, enzyme replacement)

### Polygenic Diseases
- Many weak genetic signals
- GWAS provides the gene list
- Pathway enrichment reveals convergent biology
- Network analysis identifies hub genes

### Tissue Ambiguity
- Diseases affecting multiple tissues
- Query HPA for all relevant tissues
- Compare tissue-specific expression patterns
- Use tissue context from disease ontology

---

## Fallback Strategies

### If disease name not found
1. Try synonyms
2. Try broader disease category
3. Try OMIM/UMLS ID mapping
4. Report disambiguation failure and ask user

### If no GWAS data
1. Check ClinVar for rare variants
2. Use OpenTargets genetic evidence
3. Note in report as "Limited genetic data"
4. Adjust confidence score accordingly

### If no expression data
1. Try different disease name/synonym
2. Check HPA for individual gene expression
3. Use OpenTargets expression evidence
4. Note as "Limited transcriptomics data"

### If no pathway enrichment
1. Reduce gene list stringency
2. Try different pathway databases
3. Map individual genes to pathways via Reactome
4. Note as "No significant pathway enrichment"

### If no drugs found
1. Check if disease is rare/orphan
2. Look for drugs targeting individual genes
3. Check clinical trials for investigational therapies
4. Note as "No approved drugs - novel therapeutic opportunity"
