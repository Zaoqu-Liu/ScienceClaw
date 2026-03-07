# tooluniverse-spatial-omics-analysis — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 5: Disease & Therapeutic Context

**Objective**: Connect spatial findings to disease mechanisms and identify druggable targets.

### Tools Used

**OpenTargets_get_associated_targets_by_disease_efoId** (disease genes):
- **Input**: `efoId` (string), `size` (int)
- **Output**: `{data: {disease: {associatedTargets: {count, rows: [{target: {id, approvedSymbol}, score}]}}}}`
- **Use**: Get disease-associated genes, overlap with SVGs

**OpenTargets_get_target_tractability_by_ensemblID** (druggability):
- **Input**: `ensemblId` (string)
- **Output**: Tractability data (small molecule, antibody, other modalities)
- **Use**: Assess if spatial targets are druggable

**OpenTargets_get_associated_drugs_by_target_ensemblID** (drugs for target):
- **Input**: `ensemblId` (string), `size` (int)
- **Output**: Drug data for the target
- **Use**: Find approved/clinical drugs targeting spatial genes

**OpenTargets_get_drug_mechanisms_of_action_by_chemblId** (drug mechanism):
- **Input**: `chemblId` (string)
- **Output**: Mechanism of action data
- **Use**: Understand how drugs act on spatial targets

**OpenTargets_target_disease_evidence** (evidence linking target to disease):
- **Input**: `ensemblId` (string), `efoId` (string)
- **Output**: Evidence items linking target to disease
- **Use**: Specific evidence for each spatial gene in disease

**clinical_trials_search** (clinical trials):
- **Input**: `action` = `"search_studies"`, `condition` (string), `intervention` (string), `limit` (int)
- **Output**: `{total_count, studies: [{nctId, title, status, conditions}]}`
- **Use**: Find clinical trials for spatial targets
- **NOTE**: `action` MUST be `"search_studies"`

**DGIdb_get_gene_druggability** (druggability categories):
- **Input**: `genes` (array of strings)
- **Output**: `{data: {genes: {nodes: [{name, geneCategories: [{name}]}]}}}`
- **Use**: Classify genes as druggable, kinase, GPCR, etc.

**civic_search_genes** (CIViC cancer evidence, if cancer):
- **Input**: (no filter by name)
- **Output**: Gene list from CIViC
- **Use**: Check if SVGs have CIViC clinical evidence

### Workflow

1. **Disease gene overlap** (if disease context provided):
   a. Get disease-associated targets from OpenTargets
   b. Intersect with SVGs
   c. For overlapping genes, get specific evidence
2. **Druggable target identification**:
   a. Run DGIdb_get_gene_druggability on all SVGs
   b. For druggable genes, check OpenTargets tractability
   c. Get approved drugs for druggable spatial targets
3. **Clinical trials**:
   a. Search for trials targeting spatial genes in the disease context
   b. Prioritize trials for genes in disease-enriched spatial domains
4. **Cancer-specific** (if cancer):
   a. Check CIViC for clinical evidence
   b. Get mutation prevalence from cBioPortal (if specific mutations known)
   c. Check immune checkpoint genes in spatial data

---

## Phase 6: Multi-Modal Integration

**Objective**: Integrate protein, RNA, and metabolite spatial data when available.

### Tools Used

**HPA_get_subcellular_location** (protein localization):
- **Input**: `gene_name` (string)
- **Output**: `{gene_name, main_locations, additional_locations, location_summary}`
- **Use**: Compare mRNA spatial pattern with protein subcellular location

**HPA_get_rna_expression_in_specific_tissues** (tissue RNA):
- **Input**: `ensembl_id` (string), `tissue_name` (string)
- **Output**: Expression data for specific tissue
- **Use**: Validate spatial expression against bulk tissue data

**Reactome_map_uniprot_to_pathways** (metabolic pathways):
- **Input**: `id` (string) - UniProt accession
- **Output**: List of pathways
- **Use**: Map genes to metabolic pathways for metabolomics integration

**kegg_get_pathway_info** (KEGG pathway details):
- **Input**: `pathway_id` (string) - KEGG pathway ID
- **Output**: Pathway information including metabolites
- **Use**: Link spatial genes to metabolic pathways and metabolites

### Workflow

1. **RNA-Protein concordance** (if protein data provided):
   a. For each gene with both RNA and protein data:
      - Compare spatial RNA pattern with protein detection
      - Check HPA for known post-transcriptional regulation
      - Note concordant (expected) vs discordant (interesting) patterns
2. **Subcellular context**:
   a. Map spatial RNA localization to protein subcellular location (HPA)
   b. Secreted proteins -> likely paracrine signaling
   c. Membrane proteins -> cell surface markers
   d. Nuclear proteins -> transcription factors
3. **Metabolic integration** (if metabolomics available):
   a. Map genes to metabolic pathways (Reactome, KEGG)
   b. Link detected metabolites to enzyme-encoding genes
   c. Identify spatial metabolic heterogeneity
   d. Check for known metabolic zonation patterns

---

## Phase 7: Immune Microenvironment (Cancer/Inflammation)

**Objective**: Characterize immune cell composition and checkpoint expression in spatial context.

### Conditions for Activation

Only execute if:
- Disease context is cancer, autoimmune, or inflammatory
- SVGs include immune markers (CD3E, CD8A, CD68, CD163, etc.)
- User specifically asks about immune patterns

### Tools Used

**STRING_functional_enrichment** (immune pathway enrichment):
- Applied to immune-relevant SVGs
- Filter for immune-related GO terms and pathways

**OpenTargets_get_target_tractability_by_ensemblID** (checkpoint druggability):
- Applied to immune checkpoint genes
- Check for approved immunotherapies

**iedb_search_epitopes** (epitope data):
- **Input**: `organism_name` (string), `source_antigen_name` (string)
- **Output**: `{status, data, count}`
- **Use**: Check if spatial antigens have known epitopes

### Immune Cell Markers Reference

| Cell Type | Key Markers | Extended Markers |
|-----------|-------------|-----------------|
| CD8+ T cell | CD8A, CD8B | GZMA, GZMB, PRF1, IFNG |
| CD4+ T cell | CD4 | IL2, IL4, IL17A, FOXP3 (Treg) |
| Regulatory T cell | FOXP3, IL2RA | CTLA4, TIGIT |
| B cell | CD19, MS4A1, CD79A | IGHG1, IGHM |
| Plasma cell | SDC1 (CD138), XBP1 | IGHG1, MZB1 |
| M1 Macrophage | CD68, NOS2, TNF | IL1B, CXCL10 |
| M2 Macrophage | CD68, CD163, MRC1 | ARG1, IL10 |
| Dendritic cell | ITGAX (CD11c), HLA-DRA | CD80, CD86 |
| NK cell | NCAM1 (CD56), NKG7 | GNLY, KLRD1 |
| Neutrophil | FCGR3B, CXCR2 | S100A8, S100A9 |
| Mast cell | KIT, TPSAB1 | CPA3, HDC |

### Immune Checkpoint Reference

| Checkpoint | Gene | Ligand | Therapeutic Antibody |
|------------|------|--------|---------------------|
| PD-1/PD-L1 | PDCD1/CD274 | CD274, PDCD1LG2 | Pembrolizumab, Nivolumab, Atezolizumab |
| CTLA-4 | CTLA4 | CD80, CD86 | Ipilimumab |
| TIM-3 | HAVCR2 | LGALS9 | Sabatolimab |
| LAG-3 | LAG3 | HLA class II | Relatlimab |
| TIGIT | TIGIT | PVR, PVRL2 | Tiragolumab |
| VISTA | VSIR | PSGL1 | - |

### Workflow

1. Identify immune-related SVGs from marker reference
2. Classify immune cell types present per spatial domain
3. Check immune checkpoint expression
4. Assess immune infiltration patterns:
   - Hot (T cell infiltrated) vs Cold (immune desert) vs Excluded
5. Identify potential immunotherapy targets
6. Check for tertiary lymphoid structures (B cell + T cell clusters)

---

## Phase 8: Literature & Validation Context

**Objective**: Provide literature evidence for spatial findings and suggest validation experiments.

### Tools Used

**PubMed_search_articles** (literature search):
- **Input**: `query` (string), `max_results` (int)
- **Output**: List of `[{pmid, title, authors, journal, pub_date, doi}]`
- **Use**: Find published evidence for spatial patterns

**openalex_literature_search** (broader literature):
- **Input**: `query` (string), `per_page` (int)
- **Output**: List of works with titles, DOIs, abstracts
- **Use**: Complement PubMed with preprints and broader coverage

### Literature Search Strategy

1. **Tissue + spatial**: `"{tissue} spatial transcriptomics"` - e.g., "liver spatial transcriptomics"
2. **Disease + spatial**: `"{disease} spatial omics"` - e.g., "breast cancer spatial transcriptomics"
3. **Gene + tissue**: `"{top_gene} {tissue} expression"` for key SVGs
4. **Zonation** (if relevant): `"{tissue} zonation gene expression"`
5. **Technology**: `"{technology} {tissue}"` - e.g., "Visium breast cancer"

### Validation Recommendations Template

| Priority | Target | Method | Rationale | Feasibility |
|----------|--------|--------|-----------|-------------|
| **High** | Key SVG | smFISH / RNAscope | Validate spatial pattern at single-molecule level | Medium |
| **High** | Druggable target | IHC on serial sections | Confirm protein expression in spatial domain | High |
| **High** | Ligand-receptor pair | Proximity ligation assay (PLA) | Confirm physical interaction at tissue level | Medium |
| **Medium** | Domain markers | Multiplexed IF (CODEX/IBEX) | Validate multiple markers simultaneously | Low-Medium |
| **Medium** | Pathway | Spatial metabolomics (MALDI/DESI) | Confirm metabolic pathway activity | Low |
| **Low** | Novel interaction | Co-culture + conditioned media | Functional validation of predicted interaction | Medium |

### Workflow

1. Search PubMed for tissue + disease + spatial transcriptomics
2. Search for known spatial patterns in the tissue type
3. Cross-reference findings with published spatial atlas data
4. Generate validation recommendations based on:
   - Novelty of finding (novel patterns need more validation)
   - Clinical relevance (druggable targets prioritized)
   - Technical feasibility
5. Cite relevant methodology papers for each validation approach

---

## Tool Parameter Reference (CRITICAL)

### Verified Parameter Names

| Tool | Parameter | CORRECT | Common MISTAKE | Notes |
|------|-----------|---------|----------------|-------|
| `MyGene_query_genes` | query | `query` | `q` | Filter results by `symbol` field |
| `STRING_functional_enrichment` | identifiers | `protein_ids` (array) | `identifiers` | Also needs `species=9606` |
| `STRING_get_interaction_partners` | identifiers | `protein_ids` (array) | `identifiers` | `limit`, `confidence_score` optional |
| `ReactomeAnalysis_pathway_enrichment` | genes | `identifiers` (string) | Array | SPACE-SEPARATED string, NOT array |
| `HPA_get_subcellular_location` | gene | `gene_name` | `ensembl_id` | Uses gene symbol |
| `HPA_get_cancer_prognostics_by_gene` | gene | `ensembl_id` | `gene_name` | Uses Ensembl ID, NOT symbol |
| `HPA_get_rna_expression_by_source` | params | `gene_name`, `source_type`, `source_name` | - | ALL 3 required |
| `HPA_get_rna_expression_in_specific_tissues` | gene | `ensembl_id` | `gene_name` | Uses Ensembl ID |
| `OpenTargets_get_target_tractability_by_ensemblID` | target | `ensemblId` | `ensemblID` | camelCase |
| `OpenTargets_get_associated_drugs_by_target_ensemblID` | target | `ensemblId`, `size` | - | Both REQUIRED |
| `OpenTargets_get_associated_targets_by_disease_efoId` | disease | `efoId` | `diseaseId` | Returns {data: {disease: {associatedTargets}}} |
| `DGIdb_get_gene_druggability` | genes | `genes` (array) | `gene_name` | Array of strings |
| `DGIdb_get_drug_gene_interactions` | genes | `genes` (array) | `gene_name` | Array of strings |
| `clinical_trials_search` | action | `action='search_studies'` | Missing action | `action` is REQUIRED |
| `ensembl_lookup_gene` | species | `species='homo_sapiens'` | No species | REQUIRED parameter |
| GTEx tools | operation | `operation` (SOAP) | Missing | All GTEx tools need `operation` parameter |
| `HPA_get_comprehensive_gene_details_by_ensembl_id` | all params | ALL 5 required: `ensembl_id`, `include_isoforms`, `include_images`, `include_antibodies`, `include_expression` | Missing booleans | Set booleans to False except expression |
| GTEx tools | gencode | `gencode_id` (array) | `gene_id` | Requires versioned GENCODE ID |

### Response Format Reference

| Tool | Response Format | Key Fields |
|------|----------------|------------|
| `STRING_functional_enrichment` | `{status, data: [{category, term, description, p_value, fdr, inputGenes}]}` | Filter by FDR < 0.05 |
| `ReactomeAnalysis_pathway_enrichment` | `{data: {pathways: [{pathway_id, name, p_value, fdr, entities_found, entities_total}]}}` | Top 20 returned |
| `STRING_get_interaction_partners` | `{status, data: [{preferredName_A, preferredName_B, score}]}` | Score > 0.7 for high confidence |
| `MyGene_query_genes` | `{hits: [{_id, symbol, name, ensembl: {gene}, entrezgene}]}` | Filter by exact symbol match |
| `HPA_get_subcellular_location` | `{gene_name, main_locations: [], additional_locations: [], location_summary}` | Direct dict response |
| `OpenTargets_get_target_tractability_by_ensemblID` | `{data: {target: {id, tractability: [{label, modality, value}]}}}` | Check value=true |
| `DGIdb_get_gene_druggability` | `{data: {genes: {nodes: [{name, geneCategories: [{name}]}]}}}` | GraphQL response |
| `PubMed_search_articles` | Plain list of `[{pmid, title, authors, journal, pub_date}]` | No data wrapper |
| `clinical_trials_search` | `{total_count, studies: [{nctId, title, status, conditions}]}` | total_count can be None |

---

## Fallback Strategies

### Pathway Enrichment
- **Primary**: STRING_functional_enrichment (most comprehensive, one call)
- **Fallback**: ReactomeAnalysis_pathway_enrichment (Reactome-specific)
- **Default**: Individual gene GO annotations (GO_get_annotations_for_gene)

### Tissue Expression
- **Primary**: HPA_get_rna_expression_by_source
- **Fallback**: HPA_get_comprehensive_gene_details_by_ensembl_id
- **Default**: Note "tissue expression data unavailable"

### Disease Association
- **Primary**: OpenTargets_get_associated_targets_by_disease_efoId
- **Fallback**: OpenTargets_target_disease_evidence (per gene)
- **Default**: Skip disease section if no disease context

### Drug Information
- **Primary**: OpenTargets_get_associated_drugs_by_target_ensemblID
- **Fallback**: DGIdb_get_drug_gene_interactions
- **Default**: Note "no approved drugs identified"

### Literature
- **Primary**: PubMed_search_articles
- **Fallback**: openalex_literature_search
- **Default**: Note "no spatial-specific literature found"

---

## Common Use Cases

### Use Case 1: Cancer Spatial Heterogeneity

**Input**: Visium data from breast cancer with 5 spatial domains (tumor core, tumor margin, stroma, immune infiltrate, normal tissue) and 200 SVGs.

**Analysis focus**:
- Tumor-specific pathways (proliferation, DNA repair)
- Immune infiltration patterns (hot vs cold)
- Tumor-stroma interactions (CAF signaling)
- Druggable targets in tumor core
- Immune checkpoint expression patterns
- Prognostic genes per domain

### Use Case 2: Brain Tissue Zonation

**Input**: MERFISH data from hippocampus with cell-type specific genes and neuronal subtype markers.

**Analysis focus**:
- Neuronal subtype characterization
- Synaptic signaling pathways
- Neurotransmitter receptor distribution
- Known hippocampal zonation patterns (CA1, CA3, DG)
- Neurodegenerative disease gene overlap

### Use Case 3: Liver Metabolic Zonation

**Input**: Spatial transcriptomics of liver with periportal vs pericentral gene gradients.

**Analysis focus**:
- Metabolic enzyme distribution (CYP450, gluconeogenesis, lipogenesis)
- Wnt signaling gradient (known zonation regulator)
- Oxygen gradient-responsive genes
- Drug metabolism enzyme spatial patterns
- Liver disease gene overlap

### Use Case 4: Tumor-Immune Interface

**Input**: DBiTplus data from melanoma with spatial protein + RNA data showing tumor-immune boundary.

**Analysis focus**:
- Immune cell composition at boundary
- Checkpoint ligand-receptor pairs
- Immune exclusion mechanisms
- Immunotherapy target identification
- Multi-modal (RNA + protein) concordance

### Use Case 5: Developmental Spatial Patterns

**Input**: Spatial transcriptomics of embryonic tissue with developmental patterning genes.

**Analysis focus**:
- Morphogen gradients (Wnt, BMP, FGF, SHH)
- Transcription factor spatial patterns
- Cell fate determination genes
- Developmental signaling pathways
- Comparison to adult tissue patterns

### Use Case 6: Disease Progression Mapping

**Input**: Spatial data from neurodegenerative tissue showing disease gradient from affected to unaffected regions.

**Analysis focus**:
- Disease gene expression gradient
- Inflammatory response spatial pattern
- Neuronal loss markers
- Glial activation patterns
- Therapeutic window identification

---

## Limitations & Known Issues

### Database-Specific
- **Enrichment**: `enrichr_gene_enrichment_analysis` returns connectivity graph (107MB), NOT standard enrichment. Use `STRING_functional_enrichment` instead
- **GTEx**: SOAP-style tools requiring `operation` parameter; needs versioned GENCODE IDs (e.g., `ENSG00000141510.16`)
- **HPA**: Some tools use `gene_name`, others use `ensembl_id` - check parameter reference
- **OpenTargets**: Disease IDs use underscore format (`MONDO_0007254`), not colon
- **cBioPortal_get_cancer_studies**: BROKEN - has literal `{limit}` in URL causing 400 error

### Conceptual
- **No raw spatial data processing**: This skill analyzes gene LISTS, not raw spatial matrices (Seurat/Scanpy/squidpy handle raw data)
- **No spatial statistics**: Cannot perform Moran's I, spatial autocorrelation, or variogram analysis
- **No image analysis**: Cannot process H&E or fluorescence images
- **No deconvolution**: Cannot perform cell type deconvolution (use BayesSpace, cell2location, RCTD externally)
- **Ligand-receptor inference**: Based on gene co-expression + known pairs, not spatial proximity statistics (use CellChat, NicheNet, COMMOT externally)

### Technical
- **Large gene lists**: >200 genes may slow STRING queries; batch or sample
- **Response format variability**: Always check both dict and list response types
- **Rate limits**: STRING and OpenTargets may throttle frequent requests

---

## Summary

Spatial Multi-Omics Analysis skill provides:

1. Gene characterization (ID resolution, function, localization, tissue expression)
2. Pathway & functional enrichment (STRING, Reactome, GO, KEGG)
3. Spatial domain characterization (per-domain and cross-domain comparison)
4. Cell-cell interaction inference (PPI, ligand-receptor, signaling pathways)
5. Disease & therapeutic context (disease genes, druggable targets, clinical trials)
6. Multi-modal integration (RNA-protein concordance, metabolic pathways)
7. Immune microenvironment characterization (cell types, checkpoints, immunotherapy)
8. Literature context & validation recommendations

**Outputs**: Comprehensive markdown report with Spatial Omics Integration Score (0-100)
**Best for**: Biological interpretation of spatial omics experiments (post-processing after spatial data analysis tools)
**Uses**: 70+ ToolUniverse tools across 9 analysis phases
**Time**: ~10-20 minutes depending on gene list size and analysis scope
