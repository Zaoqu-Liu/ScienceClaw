---
name: tooluniverse-spatial-omics-analysis
description: Computational analysis framework for spatial multi-omics data integration. Given spatially variable genes (SVGs), spatial domain annotations, tissue type, and disease context from spatial transcriptomics/proteomics experiments (10x Visium, MERFISH, DBiTplus, SLIDE-seq, etc.), performs comprehensive biological interpretation including pathway enrichment, cell-cell interaction inference, druggable target identification, immune microenvironment characterization, and multi-modal integration. Produces a detailed markdown report with Spatial Omics Integration Score (0-100), domain-by-domain characterization, and validation recommendations. Uses 70+ ToolUniverse tools across 9 analysis phases. Use when users ask about spatial transcriptomics analysis, spatial omics interpretation, tissue heterogeneity, spatial gene expression patterns, tumor microenvironment mapping, tissue zonation, or cell-cell communication from spatial data.
---

# Spatial Multi-Omics Analysis Pipeline

Comprehensive biological interpretation of spatial omics data. Transforms spatially variable genes (SVGs), domain annotations, and tissue context into actionable biological insights covering pathway enrichment, cell-cell interactions, druggable targets, immune microenvironment, and multi-modal integration.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create report file FIRST, then populate progressively
2. **Domain-by-domain analysis** - Characterize each spatial region independently before comparison
3. **Gene-list-centric** - Analyze user-provided SVGs and marker genes with ToolUniverse databases
4. **Biological interpretation** - Go beyond statistics to explain biological meaning of spatial patterns
5. **Disease focus** - Emphasize disease mechanisms and therapeutic opportunities when disease context is provided
6. **Evidence grading** - Grade all evidence as T1 (human/clinical) to T4 (computational)
7. **Multi-modal thinking** - Integrate RNA, protein, and metabolite information when available
8. **Validation guidance** - Suggest experimental validation approaches for key findings
9. **Source references** - Every statement must cite tool/database source
10. **Completeness checklist** - Mandatory section showing analysis coverage
11. **English-first queries** - Always use English terms in tool calls. Respond in user's language

---

## When to Use This Skill

Apply when users:
- Provide spatially variable genes from spatial transcriptomics experiments
- Ask about biological interpretation of spatial domains/clusters
- Need pathway enrichment analysis of spatial gene expression data
- Want to understand cell-cell interactions from spatial data
- Ask about tumor microenvironment heterogeneity from spatial omics
- Need druggable targets in specific spatial regions
- Ask about tissue zonation patterns (liver, brain, kidney)
- Want to integrate spatial transcriptomics + proteomics data
- Ask about immune infiltration patterns from spatial data
- Need to compare healthy vs disease regions spatially
- Ask "What pathways are enriched in this tumor core vs tumor margin?"
- Ask "What cell-cell interactions occur in this spatial domain?"

**NOT for** (use other skills instead):
- Single gene interpretation without spatial context -> Use `tooluniverse-target-research`
- Variant interpretation -> Use `tooluniverse-variant-interpretation`
- Drug safety profiling -> Use `tooluniverse-adverse-event-detection`
- Disease-only analysis without spatial data -> Use `tooluniverse-multiomic-disease-characterization`
- GWAS analysis -> Use `tooluniverse-gwas-*` skills
- Bulk RNA-seq (non-spatial) -> Use `tooluniverse-systems-biology`

---

## Input Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| **svgs** | Yes | Spatially variable genes (gene symbols) | `['EGFR', 'CDH1', 'VIM', 'MYC', 'CD3E']` |
| **tissue_type** | Yes | Tissue/organ type | `brain`, `liver`, `lung`, `breast`, `skin` |
| **technology** | No | Spatial omics platform used | `10x Visium`, `MERFISH`, `DBiTplus`, `SLIDE-seq` |
| **disease_context** | No | Disease if applicable | `breast cancer`, `Alzheimer disease`, `liver cirrhosis` |
| **spatial_domains** | No | Dict mapping domain name to marker genes | `{'Tumor core': ['MYC','EGFR'], 'Stroma': ['VIM','COL1A1']}` |
| **cell_types** | No | Cell types identified in deconvolution | `['Epithelial', 'T cell', 'Macrophage', 'Fibroblast']` |
| **proteins** | No | Proteins detected (if multi-modal) | `['CD3', 'CD8', 'PD-L1', 'Ki67']` |
| **metabolites** | No | Metabolites detected (if SpatialMETA) | `['glutamine', 'lactate', 'ATP']` |

---

## Spatial Omics Integration Score (0-100)

### Score Components

**Data Completeness (0-30 points)**:
- SVGs provided (>10 genes): 5 points
- Disease context provided: 5 points
- Spatial domains defined: 5 points
- Cell type composition available: 5 points
- Multi-modal data (protein/metabolite): 5 points
- Literature context found: 5 points

**Biological Insight (0-40 points)**:
- Significant pathway enrichment (FDR < 0.05): 10 points
- Cell-cell interaction predictions: 10 points
- Disease mechanism identified: 10 points
- Druggable targets found in disease regions: 10 points

**Evidence Quality (0-30 points)**:
- Cross-database validation (gene found in 3+ databases): 10 points
- Clinical validation (approved drugs for spatial targets): 10 points
- Literature support (PubMed evidence for spatial patterns): 10 points

### Score Interpretation

| Score | Tier | Interpretation |
|-------|------|----------------|
| **80-100** | Excellent | Comprehensive spatial characterization, strong biological insights, druggable targets identified |
| **60-79** | Good | Good pathway and interaction analysis, some disease/therapeutic context |
| **40-59** | Moderate | Basic enrichment complete, limited spatial domain comparison or interaction analysis |
| **0-39** | Limited | Minimal data, gene-level annotation only |

### Evidence Grading System

| Tier | Symbol | Criteria | Examples |
|------|--------|----------|----------|
| **T1** | [T1] | Direct human evidence, clinical proof | FDA-approved drug for spatial target, validated biomarker |
| **T2** | [T2] | Experimental evidence | Validated spatial pattern in literature, known ligand-receptor pair |
| **T3** | [T3] | Computational/database evidence | PPI network prediction, pathway enrichment, expression correlation |
| **T4** | [T4] | Annotation/prediction only | GO annotation, text-mined association, predicted interaction |

---

## Report Template

Create this file structure at the start: `{tissue}_{disease}_spatial_omics_report.md`

```markdown
# Spatial Multi-Omics Analysis Report: {Tissue Type}

**Report Generated**: {date}
**Technology**: {platform}
**Tissue**: {tissue_type}
**Disease Context**: {disease or "Normal tissue"}
**Total SVGs Analyzed**: {count}
**Spatial Domains**: {count}
**Spatial Omics Integration Score**: (to be calculated)

---

## Executive Summary

(2-3 sentence synthesis of key spatial findings - fill after all phases complete)

---

## 1. Tissue & Disease Context

### Tissue Information
| Property | Value | Source |
|----------|-------|--------|
| Tissue type | | |
| Disease | | |
| Expected cell types | | HPA |

### Disease Identifiers (if applicable)
| System | ID | Source |
|--------|-----|--------|

**Sources**: (tools used)

---

## 2. Spatially Variable Gene Characterization

### 2.1 Gene ID Resolution
| Gene Symbol | Ensembl ID | Entrez ID | UniProt | Function | Source |
|-------------|------------|-----------|---------|----------|--------|

### 2.2 Tissue Expression Patterns
| Gene | Tissue Expression | Specificity | Source |
|------|-------------------|-------------|--------|

### 2.3 Subcellular Localization
| Gene | Location | Confidence | Source |
|------|----------|------------|--------|

### 2.4 Disease Associations
| Gene | Disease | Score | Evidence | Source |
|------|---------|-------|----------|--------|

**Sources**: (tools used)

---

## 3. Pathway Enrichment Analysis

### 3.1 STRING Functional Enrichment
| Category | Term | Description | P-value | FDR | Genes | Source |
|----------|------|-------------|---------|-----|-------|--------|

### 3.2 Reactome Pathway Analysis
| Pathway ID | Name | P-value | FDR | Genes Found | Total Genes | Source |
|------------|------|---------|-----|-------------|-------------|--------|

### 3.3 GO Biological Processes
| GO Term | Description | P-value | FDR | Genes | Source |
|---------|-------------|---------|-----|-------|--------|

### 3.4 GO Molecular Functions
| GO Term | Description | P-value | FDR | Genes | Source |
|---------|-------------|---------|-----|-------|--------|

### 3.5 GO Cellular Components
| GO Term | Description | P-value | FDR | Genes | Source |
|---------|-------------|---------|-----|-------|--------|

### Pathway Summary
- Top enriched pathways:
- Key biological processes:
- Spatial pathway implications:

**Sources**: (tools used)

---

## 4. Spatial Domain Characterization

### Domain: {domain_name}

#### Marker Genes
| Gene | Function | Pathways | Source |
|------|----------|----------|--------|

#### Enriched Pathways (domain-specific)
| Pathway | P-value | FDR | Genes | Source |
|---------|---------|-----|-------|--------|

#### Cell Type Signature
| Cell Type | Marker Genes Present | Confidence |
|-----------|---------------------|------------|

#### Biological Interpretation
(Narrative interpretation of this domain)

(Repeat for each domain)

### 4.N Domain Comparison
| Feature | Domain 1 | Domain 2 | Domain 3 |
|---------|----------|----------|----------|
| Top pathway | | | |
| Cell types | | | |
| Disease relevance | | | |

**Sources**: (tools used)

---

## 5. Cell-Cell Interaction Inference

### 5.1 Protein-Protein Interactions (STRING)
| Protein A | Protein B | Score | Type | Source |
|-----------|-----------|-------|------|--------|

### 5.2 Ligand-Receptor Pairs
| Ligand | Receptor | Domain (Ligand) | Domain (Receptor) | Evidence | Source |
|--------|----------|-----------------|-------------------|----------|--------|

### 5.3 Signaling Pathways
| Pathway | Components in Data | Spatial Distribution | Source |
|---------|--------------------|---------------------|--------|

### 5.4 Interaction Network Summary
- Key interaction hubs:
- Cross-domain interactions:
- Predicted cell-cell communication axes:

**Sources**: (tools used)

---

## 6. Disease & Therapeutic Context

### 6.1 Disease Gene Overlap
| Gene | Disease Association Score | Evidence Type | Source |
|------|--------------------------|---------------|--------|

### 6.2 Druggable Targets in Spatial Domains
| Gene | Domain | Tractability | Modality | Approved Drugs | Source |
|------|--------|-------------|----------|----------------|--------|

### 6.3 Drug Mechanisms Relevant to Spatial Targets
| Drug | Target | Mechanism | Phase | Source |
|------|--------|-----------|-------|--------|

### 6.4 Clinical Trials
| NCT ID | Title | Target Gene | Phase | Status | Source |
|--------|-------|-------------|-------|--------|--------|

### Therapeutic Summary
- Druggable genes in disease regions:
- Approved therapies:
- Pipeline drugs:
- Novel opportunities:

**Sources**: (tools used)

---

## 7. Multi-Modal Integration

### 7.1 Protein-RNA Concordance (if protein data available)
| Gene/Protein | RNA Pattern | Protein Pattern | Concordance | Source |
|-------------|-------------|-----------------|-------------|--------|

### 7.2 Subcellular Context
| Gene | mRNA Location (spatial) | Protein Location (HPA) | Concordance | Source |
|------|------------------------|----------------------|-------------|--------|

### 7.3 Metabolic Context (if metabolomics available)
| Gene | Metabolic Pathway | Metabolites Detected | Spatial Pattern | Source |
|------|-------------------|---------------------|-----------------|--------|

**Sources**: (tools used)

---

## 8. Immune Microenvironment (if relevant)

### 8.1 Immune Cell Markers
| Cell Type | Marker Genes | Spatial Domain | Source |
|-----------|-------------|----------------|--------|

### 8.2 Immune Checkpoint Expression
| Checkpoint | Gene | Expression Pattern | Source |
|------------|------|--------------------|--------|

### 8.3 Tumor-Immune Interface (if cancer)
| Feature | Finding | Evidence | Source |
|---------|---------|----------|--------|

### Immune Summary
- Immune infiltration pattern:
- Key immune checkpoints:
- Immunotherapy implications:

**Sources**: (tools used)

---

## 9. Literature & Validation Context

### 9.1 Literature Evidence
| PMID | Title | Relevance | Year | Source |
|------|-------|-----------|------|--------|

### 9.2 Known Spatial Patterns
(Known tissue architecture/zonation from literature)

### 9.3 Validation Recommendations
| Priority | Gene/Target | Method | Rationale |
|----------|-------------|--------|-----------|
| High | | IHC / smFISH | |
| Medium | | IF / ISH | |

**Sources**: (tools used)

---

## Spatial Omics Integration Score

| Component | Points | Max | Details |
|-----------|--------|-----|---------|
| SVGs provided | | 5 | |
| Disease context | | 5 | |
| Spatial domains | | 5 | |
| Cell types | | 5 | |
| Multi-modal data | | 5 | |
| Literature context | | 5 | |
| Pathway enrichment | | 10 | |
| Cell-cell interactions | | 10 | |
| Disease mechanism | | 10 | |
| Druggable targets | | 10 | |
| Cross-database validation | | 10 | |
| Clinical validation | | 10 | |
| Literature support | | 10 | |
| **TOTAL** | | **100** | |

**Score**: XX/100 - [Tier]

---

## Completeness Checklist

- [ ] Gene ID resolution complete
- [ ] Tissue expression patterns analyzed (HPA)
- [ ] Subcellular localization checked (HPA)
- [ ] Pathway enrichment complete (STRING + Reactome)
- [ ] GO enrichment complete (BP + MF + CC)
- [ ] Spatial domains characterized individually
- [ ] Domain comparison performed
- [ ] Protein-protein interactions analyzed (STRING)
- [ ] Ligand-receptor pairs identified
- [ ] Disease associations checked (OpenTargets)
- [ ] Druggable targets identified (OpenTargets tractability)
- [ ] Drug mechanisms reviewed
- [ ] Multi-modal integration performed (if data available)
- [ ] Immune microenvironment characterized (if relevant)
- [ ] Literature search completed
- [ ] Validation recommendations provided
- [ ] Spatial Omics Integration Score calculated
- [ ] Executive summary written
- [ ] All sections have source citations

---

## References

### Data Sources Used
| # | Tool | Parameters | Section | Items Retrieved |
|---|------|------------|---------|-----------------|

### Database Versions
- OpenTargets: (current)
- STRING: v12.0
- Reactome: (current)
- HPA: (current)
- GTEx: v10
```

---

## Phase 0: Input Processing & Disambiguation (ALWAYS FIRST)

**Objective**: Parse user input, resolve tissue/disease identifiers, establish analysis context.

### Tools Used

**OpenTargets_get_disease_id_description_by_name** (if disease context provided):
- **Input**: `diseaseName` (string) - Disease name
- **Output**: `{data: {search: {hits: [{id, name, description}]}}}`
- **Use**: Get MONDO/EFO IDs for disease queries

**OpenTargets_get_disease_description_by_efoId**:
- **Input**: `efoId` (string) - Disease ID (e.g., `MONDO_0007254`)
- **Output**: `{data: {disease: {id, name, description, dbXRefs}}}`
- **Use**: Get full disease description

**HPA_search_genes_by_query** (tissue cell type context):
- **Input**: `query` (string) - Search term
- **Output**: List of gene entries matching query
- **Use**: Verify tissue-relevant genes

### Workflow

1. Parse SVG list from user input (ensure valid gene symbols)
2. Identify tissue type and map to standard ontology term
3. If disease provided, resolve to MONDO/EFO ID using OpenTargets
4. Get disease description and cross-references
5. Determine analysis scope:
   - Cancer? -> Include immune microenvironment, somatic mutations, druggable targets
   - Neurological? -> Include brain region specificity, neuronal markers
   - Metabolic? -> Include metabolic zonation, enzyme distribution
   - Normal tissue? -> Focus on tissue architecture and cell type composition
6. Set up report file with header information

### Decision Logic

- **Cancer tissue**: Enable immune microenvironment phase, CIViC/cBioPortal queries, immuno-oncology analysis
- **Normal tissue**: Skip disease phases, focus on tissue zonation and cell type composition
- **Liver/kidney/brain**: Enable zonation-specific analysis
- **No disease context**: Proceed with tissue biology only
- **Small gene list (<20)**: Warn about limited enrichment power, emphasize gene-level analysis
- **Large gene list (>500)**: Suggest filtering to top SVGs by significance before enrichment

---

## Phase 1: Gene Characterization

**Objective**: Resolve gene identifiers, annotate functions, tissue specificity, and subcellular localization.

### Tools Used

**MyGene_query_genes** (gene ID resolution):
- **Input**: `query` (string) - Gene symbol
- **Output**: `{hits: [{_id, symbol, name, ensembl: {gene}, entrezgene}]}`
- **Use**: Resolve gene symbol to Ensembl ID, Entrez ID
- **NOTE**: First hit may not be exact match - filter by `symbol` field

**UniProt_get_function_by_accession** (gene function):
- **Input**: `accession` (string) - UniProt accession
- **Output**: List of function description strings
- **Use**: Get protein function annotation

**UniProt_get_subcellular_location_by_accession** (protein localization):
- **Input**: `accession` (string)
- **Output**: Subcellular location information
- **Use**: Where the protein is located in the cell

**HPA_get_subcellular_location** (validated localization):
- **Input**: `gene_name` (string) - Gene symbol
- **Output**: `{gene_name, main_locations: [], additional_locations: [], location_summary}`
- **Use**: Experimentally validated protein subcellular location

**HPA_get_rna_expression_by_source** (tissue expression):
- **Input**: `gene_name` (string), `source_type` (string: 'tissue'), `source_name` (string)
- **Output**: `{data: {gene_name, source_type, source_name, expression_value, expression_level}}`
- **Use**: Check expression in the specific tissue of interest
- **NOTE**: All 3 parameters are REQUIRED

**HPA_get_comprehensive_gene_details_by_ensembl_id** (full HPA data):
- **Input**: `ensembl_id` (string), `include_isoforms` (bool), `include_images` (bool), `include_antibodies` (bool), `include_expression` (bool) - ALL 5 parameters REQUIRED
- **Output**: `{ensembl_id, gene_name, uniprot_ids, summary, protein_classes, tissue_expression, cell_line_expression, ...}`
- **Use**: One-stop gene characterization from HPA
- **NOTE**: Use `include_expression=True` for tissue data; set others to `False` for faster response

**HPA_get_cancer_prognostics_by_gene** (cancer prognosis):
- **Input**: `ensembl_id` (string) - Ensembl gene ID (NOT gene_name)
- **Output**: `{gene_name, prognostic_cancers_count, prognostic_summary: [{cancer_type, prognostic_type, p_value}]}`
- **Use**: Prognostic significance in cancer (if cancer context)

**UniProtIDMap_gene_to_uniprot** (ID mapping):
- **Input**: `gene_name` (string), `organism` (string, default 'human')
- **Output**: UniProt accession for the gene
- **Use**: Map gene symbol to UniProt accession

### Workflow

1. For each SVG (batch if >20, sample top genes):
   a. Query MyGene to get Ensembl ID, Entrez ID
   b. Map to UniProt accession
   c. Get subcellular location from HPA
   d. Get tissue expression from HPA
   e. If cancer: check cancer prognostics
2. Compile gene characterization table
3. Identify genes with tissue-specific expression
4. Note genes with nuclear vs membrane vs secreted localization (relevant for spatial patterns)

### Batch Strategy for Large Gene Lists

- **10-50 genes**: Characterize all individually
- **50-200 genes**: Characterize top 50 by priority (known disease genes first), summarize rest
- **200+ genes**: Characterize top 30, use enrichment for the full list
- Always run pathway enrichment on the FULL list regardless

---

## Phase 2: Pathway & Functional Enrichment

**Objective**: Identify biological pathways and functions enriched in SVGs and per-domain gene sets.

### Tools Used

**STRING_functional_enrichment** (primary enrichment):
- **Input**: `protein_ids` (array of gene symbols), `species` (int, 9606 for human)
- **Output**: `{status: 'success', data: [{category, term, number_of_genes, number_of_genes_in_background, p_value, fdr, description, inputGenes, preferredNames}]}`
- **Use**: Comprehensive enrichment across GO, KEGG, Reactome, COMPARTMENTS, DISEASES
- **Categories**: `Process` (GO:BP), `Function` (GO:MF), `Component` (GO:CC), `KEGG`, `Reactome`, `COMPARTMENTS`, `DISEASES`, `Keyword`, `PMID`
- **NOTE**: This is the PRIMARY enrichment tool. Returns all categories in one call

**ReactomeAnalysis_pathway_enrichment** (Reactome-specific):
- **Input**: `identifiers` (string, space-separated gene symbols, NOT array)
- **Output**: `{data: {token, pathways_found, pathways: [{pathway_id, name, p_value, fdr, entities_found, entities_total}]}}`
- **Use**: Detailed Reactome pathway analysis with hierarchy
- **NOTE**: identifiers is a SPACE-SEPARATED STRING, not array

**Reactome_map_uniprot_to_pathways** (individual gene):
- **Input**: `id` (string) - UniProt accession
- **Output**: Plain list of pathway objects (no data wrapper)
- **Use**: Map individual proteins to Reactome pathways

**GO_get_annotations_for_gene** (individual gene GO):
- **Input**: `gene_id` (string) - Gene symbol or ID
- **Output**: Plain list of GO annotation objects
- **Use**: Get GO annotations for individual genes

**kegg_search_pathway** (KEGG pathway search):
- **Input**: `query` (string) - Pathway name or keyword
- **Output**: Pathway search results
- **Use**: Find KEGG pathways relevant to spatial findings

**WikiPathways_search** (WikiPathways):
- **Input**: `query` (string) - Search term
- **Output**: WikiPathways search results
- **Use**: Additional pathway context

### Workflow

1. **Global SVG enrichment**: Run STRING_functional_enrichment on ALL SVGs
   - Filter results by FDR < 0.05
   - Separate by category (Process, Function, Component, KEGG, Reactome)
   - Report top 10-15 per category
2. **Reactome detailed analysis**: Run ReactomeAnalysis_pathway_enrichment
   - Report top pathways with FDR < 0.05
3. **Per-domain enrichment** (if spatial domains provided):
   - Run STRING_functional_enrichment on each domain's gene set
   - Compare enriched pathways across domains
   - Identify domain-specific vs shared pathways
4. **Compile pathway tables**: Merge results from all enrichment tools

### Enrichment Interpretation

- **Signaling pathways** (RTK, Wnt, Notch, Hedgehog): Cell-cell communication
- **Metabolic pathways**: Tissue metabolic zonation
- **Immune pathways**: Immune infiltration/exclusion
- **ECM/adhesion pathways**: Tissue structure and remodeling
- **Cell cycle/proliferation**: Growth zones
- **Apoptosis/stress**: Damage zones

---

## Phase 3: Spatial Domain Characterization

**Objective**: Characterize each spatial domain biologically and compare between domains.

### Tools Used

Uses the same tools as Phase 2 (STRING_functional_enrichment, ReactomeAnalysis) applied per-domain, plus:

**HPA_get_biological_processes_by_gene** (per-gene processes):
- **Input**: `gene_name` (string)
- **Output**: Biological processes associated with the gene
- **Use**: Annotate domain marker genes

**HPA_get_protein_interactions_by_gene** (gene interactions):
- **Input**: `gene_name` (string)
- **Output**: Known protein interaction partners
- **Use**: Build domain-specific interaction context

### Workflow

1. For each spatial domain:
   a. Get marker gene list
   b. Run STRING_functional_enrichment on domain genes
   c. Identify top pathways, GO terms
   d. Assign likely cell type(s) based on marker genes:
      - Epithelial: CDH1, EPCAM, KRT18, KRT19
      - Mesenchymal/Fibroblast: VIM, COL1A1, COL3A1, FAP, ACTA2
      - Immune T cell: CD3E, CD3D, CD4, CD8A, CD8B
      - Immune B cell: CD19, CD20 (MS4A1), CD79A
      - Macrophage: CD68, CD163, CSF1R
      - Endothelial: PECAM1, VWF, CDH5
      - Neuronal: SNAP25, SYP, MAP2, NEFL
      - Hepatocyte: ALB, HNF4A, CYP3A4
   e. Generate biological interpretation narrative
2. Compare domains:
   - Differential pathways
   - Unique vs shared genes
   - Disease-relevant vs homeostatic regions
   - Transition zones (shared genes between adjacent domains)

### Cell Type Assignment Rules

When user does not provide cell type annotations, infer from marker genes:
- Check each gene against known cell type markers
- Use HPA tissue/cell type expression data for validation
- Report confidence level (high: 3+ markers match, medium: 2 markers, low: 1 marker)

---

## Phase 4: Cell-Cell Interaction Inference

**Objective**: Predict cell-cell communication from spatial gene expression patterns.

### Tools Used

**STRING_get_interaction_partners** (PPI network):
- **Input**: `protein_ids` (array), `species` (int, 9606), `limit` (int), `confidence_score` (float, 0.7)
- **Output**: `{status: 'success', data: [{preferredName_A, preferredName_B, score, nscore, fscore, pscore, ascore, escore, dscore, tscore}]}`
- **Use**: Find protein-protein interactions among SVGs
- **Score types**: nscore=neighborhood, fscore=fusion, pscore=phylogenetic, ascore=coexpression, escore=experimental, dscore=database, tscore=textmining

**STRING_get_protein_interactions** (pairwise interactions):
- **Input**: `protein_ids` (array), `species` (int, 9606)
- **Output**: Interaction data between specified proteins
- **Use**: Get interactions within a specific gene set

**intact_search_interactions** (IntAct database):
- **Input**: `query` (string), `max` (int)
- **Output**: Interaction data from IntAct
- **Use**: Complement STRING with IntAct interactions

**Reactome_get_interactor** (Reactome interactions):
- **Input**: Protein/gene identifier
- **Output**: Reactome interaction data
- **Use**: Pathway-level interaction context

**DGIdb_get_drug_gene_interactions** (drug-gene interactions):
- **Input**: `genes` (array of strings)
- **Output**: Drug-gene interaction data
- **Use**: Identify druggable interaction nodes

### Ligand-Receptor Analysis

Known ligand-receptor pairs to check in SVG list:
- **Growth factors**: EGF-EGFR, HGF-MET, VEGF-KDR, FGF-FGFR, PDGF-PDGFRA/B
- **Cytokines**: TNF-TNFR, IL6-IL6R, IFNG-IFNGR, TGFB1-TGFBR1/2
- **Chemokines**: CXCL12-CXCR4, CCL2-CCR2, CXCL10-CXCR3
- **Immune checkpoints**: CD274(PD-L1)-PDCD1(PD-1), CD80/CD86-CTLA4, LGALS9-HAVCR2(TIM-3)
- **Notch signaling**: DLL1/3/4-NOTCH1/2/3/4, JAG1/2-NOTCH1/2
- **Wnt signaling**: WNT ligands-FZD receptors
- **Adhesion**: CDH1-CDH1 (homotypic), ITGA/B integrins-ECM
- **Hedgehog**: SHH-PTCH1

### Workflow

1. Run STRING_get_interaction_partners on all SVGs
   - Filter interactions with score > 0.7
   - Identify hub genes (most connections)
2. Check for known ligand-receptor pairs in gene list
   - Cross-reference with spatial domain assignments
   - Identify potential cross-domain signaling
3. Build interaction network:
   - Intra-domain interactions (within same spatial region)
   - Inter-domain interactions (between different regions)
   - Identify signaling axes (e.g., tumor-stroma, immune-tumor)
4. Map interactions to Reactome signaling pathways

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-spatial-omics-analysis/REFERENCE.md`
