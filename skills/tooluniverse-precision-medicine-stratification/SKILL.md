---
name: tooluniverse-precision-medicine-stratification
description: Comprehensive patient stratification for precision medicine by integrating genomic, clinical, and therapeutic data. Given a disease/condition, genomic data (germline variants, somatic mutations, expression), and optional clinical parameters, performs multi-phase analysis across 9 phases covering disease disambiguation, genetic risk assessment, disease-specific molecular stratification, pharmacogenomic profiling, comorbidity/DDI risk, pathway analysis, clinical evidence and guideline mapping, clinical trial matching, and integrated outcome prediction. Generates a quantitative Precision Medicine Risk Score (0-100) with risk tier assignment (Low/Intermediate/High/Very High), treatment algorithm (1st/2nd/3rd line), pharmacogenomic guidance, clinical trial matches, and monitoring plan. Use when clinicians ask about patient risk stratification, treatment selection, prognosis prediction, or personalized therapeutic strategy across cancer, metabolic, cardiovascular, neurological, or rare diseases.
---

# Precision Medicine Patient Stratification

Transform patient genomic and clinical profiles into actionable risk stratification, treatment recommendations, and personalized therapeutic strategies. Integrates germline genetics, somatic alterations, pharmacogenomics, pathway biology, and clinical evidence to produce a quantitative risk score with tiered management recommendations.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create report file FIRST, then populate progressively
2. **Disease-specific logic** - Cancer vs metabolic vs rare disease pipelines diverge at Phase 2
3. **Multi-level integration** - Germline + somatic + expression + clinical data layers
4. **Evidence-graded** - Every finding has an evidence tier (T1-T4)
5. **Quantitative output** - Precision Medicine Risk Score (0-100) with transparent components
6. **Pharmacogenomic guidance** - Drug selection AND dosing recommendations
7. **Guideline-concordant** - Reference NCCN, ACC/AHA, ADA, and other guidelines
8. **Source-referenced** - Every statement cites the tool/database source
9. **Completeness checklist** - Mandatory section showing data availability and analysis coverage
10. **English-first queries** - Always use English terms in tool calls. Respond in user's language

---

## When to Use

Apply when user asks:
- "Stratify this breast cancer patient: ER+/HER2-, BRCA1 mutation, stage II"
- "What is the risk profile for this diabetes patient with HbA1c 8.5 and CYP2C19 poor metabolizer?"
- "NSCLC patient with EGFR L858R, stage IV, TMB 25 - treatment strategy?"
- "Predict prognosis and recommend treatment for this cardiovascular patient"
- "Patient has Marfan syndrome with FBN1 mutation - risk stratification"
- "Alzheimer's risk assessment: APOE e4/e4, family history positive"
- "Personalized treatment plan for type 2 diabetes with genetic risk factors"
- "Which therapy is best for this patient's molecular profile?"

**NOT for** (use other skills instead):
- Single variant interpretation -> Use `tooluniverse-variant-interpretation` or `tooluniverse-cancer-variant-interpretation`
- Immunotherapy-specific prediction -> Use `tooluniverse-immunotherapy-response-prediction`
- Drug safety profiling only -> Use `tooluniverse-adverse-event-detection`
- Target validation -> Use `tooluniverse-drug-target-validation`
- Clinical trial search only -> Use `tooluniverse-clinical-trial-matching`
- Drug-drug interaction analysis only -> Use `tooluniverse-drug-drug-interaction`
- PRS calculation only -> Use `tooluniverse-polygenic-risk-score`

---

## Input Parsing

### Required Input
- **Disease/condition**: Free-text disease name (e.g., "breast cancer", "type 2 diabetes", "Marfan syndrome")
- **At least one of**: Germline variants, somatic mutations, gene list, or clinical biomarkers

### Strongly Recommended
- **Genomic data**: Specific variants (e.g., "BRCA1 c.68_69delAG", "EGFR L858R"), gene names, or expression changes
- **Clinical parameters**: Age, sex, disease stage, biomarkers (HbA1c, PSA, LDL-C)

### Optional (improves stratification)
- **Comorbidities**: Other conditions (e.g., "hypertension", "diabetes")
- **Prior treatments**: Previous therapies and responses
- **Family history**: Affected relatives, inheritance pattern
- **Ethnicity**: For population-specific risk calibration
- **Current medications**: For DDI and pharmacogenomic analysis
- **Stratification goal**: Risk assessment, treatment selection, prognosis, prevention

### Input Format Examples

| Format | Example | How to Parse |
|--------|---------|-------------|
| Cancer + mutations + stage | "Breast cancer, BRCA1 mut, ER+, HER2-, stage II" | disease=breast_cancer, mutations=[BRCA1], biomarkers={ER:+, HER2:-}, stage=II |
| Metabolic + biomarkers + PGx | "T2D, HbA1c 8.5, CYP2C19 *2/*2" | disease=T2D, biomarkers={HbA1c:8.5}, pgx={CYP2C19:poor_metabolizer} |
| CVD risk profile | "High LDL 190, SLCO1B1*5, family hx MI" | disease=CVD, biomarkers={LDL:190}, pgx={SLCO1B1:*5}, family_hx=positive |
| Rare disease + variant | "Marfan, FBN1 c.4082G>A" | disease=Marfan, mutations=[FBN1 c.4082G>A], disease_type=rare |
| Neuro risk | "Alzheimer risk, APOE e4/e4, age 55" | disease=AD, genotype={APOE:e4/e4}, clinical={age:55} |
| Cancer + comprehensive | "NSCLC, EGFR L858R, TMB 25, PD-L1 80%, stage IV" | disease=NSCLC, mutations=[EGFR L858R], biomarkers={TMB:25, PDL1:80}, stage=IV |

### Disease Type Classification

Classify the disease into one of these categories (determines Phase 2 routing):

| Category | Examples | Key Stratification Axes |
|----------|----------|------------------------|
| **CANCER** | Breast, lung, colorectal, melanoma, prostate | Stage, molecular subtype, TMB, driver mutations, hormone receptors |
| **METABOLIC** | Type 2 diabetes, obesity, metabolic syndrome, NAFLD | HbA1c, BMI, genetic risk, comorbidities, CYP genotypes |
| **CARDIOVASCULAR** | CAD, heart failure, atrial fibrillation, hypertension | ASCVD risk, LDL, genetic risk, statin PGx, anticoagulant PGx |
| **NEUROLOGICAL** | Alzheimer, Parkinson, epilepsy, multiple sclerosis | APOE status, genetic risk, age of onset, PGx for anticonvulsants |
| **RARE/MONOGENIC** | Marfan, CF, sickle cell, Huntington, PKU | Causal variant, penetrance, genotype-phenotype correlation |
| **AUTOIMMUNE** | RA, lupus, MS, Crohn's, ulcerative colitis | HLA associations, genetic risk, biologics PGx |

### Gene Symbol Normalization

| Common Alias | Official Symbol | Notes |
|-------------|----------------|-------|
| HER2 | ERBB2 | Breast cancer biomarker |
| PD-L1 | CD274 | Immunotherapy biomarker |
| EGFR | EGFR | Lung cancer driver |
| BRCA1/2 | BRCA1, BRCA2 | Hereditary cancer |
| CYP2D6 | CYP2D6 | Drug metabolism |
| CYP2C19 | CYP2C19 | Clopidogrel, PPIs |
| CYP3A4 | CYP3A4 | Major drug metabolism |
| VKORC1 | VKORC1 | Warfarin dosing |
| SLCO1B1 | SLCO1B1 | Statin myopathy |
| DPYD | DPYD | Fluoropyrimidine toxicity |
| UGT1A1 | UGT1A1 | Irinotecan toxicity |
| TPMT | TPMT | Thiopurine toxicity |

---

## Phase 0: Tool Parameter Reference (CRITICAL)

**BEFORE calling ANY tool**, verify parameters using this reference table.

### Verified Tool Parameters

| Tool | Parameters | Response Structure | Notes |
|------|-----------|-------------------|-------|
| `OpenTargets_get_disease_id_description_by_name` | `diseaseName` | `{data: {search: {hits: [{id, name, description}]}}}` | Disease to EFO ID |
| `OpenTargets_get_drug_id_description_by_name` | `drugName` | `{data: {search: {hits: [{id, name, description}]}}}` | Drug to ChEMBL ID |
| `OpenTargets_get_associated_drugs_by_disease_efoId` | `efoId`, `size` | `{data: {disease: {knownDrugs: {count, rows}}}}` | Drugs for disease |
| `OpenTargets_get_associated_targets_by_disease_efoId` | `efoId`, `size` | `{data: {disease: {associatedTargets: {count, rows}}}}` | Genetic associations |
| `OpenTargets_get_drug_mechanisms_of_action_by_chemblId` | `chemblId` | `{data: {drug: {mechanismsOfAction: {rows}}}}` | Drug MOA |
| `OpenTargets_get_approved_indications_by_drug_chemblId` | `chemblId` | Approved indications list | Check drug approvals |
| `OpenTargets_get_drug_adverse_events_by_chemblId` | `chemblId` | `{data: {drug: {adverseEvents: {count, rows}}}}` | Drug safety |
| `OpenTargets_get_associated_drugs_by_target_ensemblID` | `ensemblId`, `size` | Drug-target associations | Drugs targeting gene |
| `OpenTargets_get_target_safety_profile_by_ensemblID` | `ensemblId` | Safety profile data | Target safety |
| `OpenTargets_get_target_tractability_by_ensemblID` | `ensemblId` | Tractability assessment | Druggability |
| `OpenTargets_get_diseases_phenotypes_by_target_ensembl` | `ensemblId` | Disease-phenotype associations | Gene-disease links |
| `OpenTargets_target_disease_evidence` | `ensemblId`, `efoId`, `size` | Evidence for target-disease pair | Specific gene-disease evidence |
| `OpenTargets_search_gwas_studies_by_disease` | `diseaseIds` (array), `size` | `{data: {studies: {count, rows}}}` | GWAS studies |
| `OpenTargets_drug_pharmacogenomics_data` | `chemblId` | Pharmacogenomic data | Drug PGx |
| `MyGene_query_genes` | `query` (NOT `q`) | `{hits: [{_id, symbol, name, ensembl: {gene}}]}` | Gene resolution |
| `ensembl_lookup_gene` | `gene_id`, `species='homo_sapiens'` | `{data: {id, display_name, description, biotype}}` | REQUIRES species |
| `EnsemblVEP_annotate_rsid` | `variant_id` (NOT `rsid`) | VEP annotation with SIFT/PolyPhen | Variant impact |
| `EnsemblVEP_annotate_hgvs` | `hgvs_notation`, `species` | VEP annotation | HGVS variant annotation |
| `ensembl_get_variation` | `variant_id`, `species` | Variant details | rsID lookup |
| `clinvar_search_variants` | `gene`, `significance`, `limit` | Variant list | Search ClinVar |
| `clinvar_get_variant_details` | `variant_id` | Variant details with clinical significance | ClinVar details |
| `clinvar_get_clinical_significance` | `variant_id` | Clinical significance only | Quick pathogenicity |
| `civic_search_evidence_items` | `therapy_name`, `disease_name` | `{data: {evidenceItems: {nodes}}}` | Clinical evidence |
| `civic_search_variants` | `name`, `gene_name` | `{data: {variants: {nodes}}}` | Variant clinical significance |
| `civic_search_assertions` | `therapy_name`, `disease_name` | `{data: {assertions: {nodes}}}` | Clinical assertions |
| `cBioPortal_get_mutations` | `study_id`, `gene_list` (STRING, not array) | `{status, data: [{...}]}` | Somatic mutation data |
| `gwas_get_associations_for_trait` | `trait` | GWAS associations | Trait-SNP associations |
| `gwas_search_associations` | `query` | GWAS associations | Broad GWAS search |
| `gwas_get_snps_for_gene` | `gene` | SNPs associated with gene | Gene GWAS hits |
| `GWAS_search_associations_by_gene` | `gene_name` | Gene GWAS associations | Gene-trait links |
| `PharmGKB_get_clinical_annotations` | `query` | Clinical annotations | Drug-gene-phenotype |
| `PharmGKB_get_dosing_guidelines` | `query` | Dosing guidelines | PGx dosing |
| `PharmGKB_search_variants` | `query` | Variant PGx data | PGx variant search |
| `PharmGKB_get_gene_details` | `query` | Gene PGx details | PGx gene info |
| `PharmGKB_get_drug_details` | `query` | Drug PGx details | Drug PGx info |
| `fda_pharmacogenomic_biomarkers` | `drug_name`, `biomarker`, `limit` | `{count, shown, results: [{Drug, Biomarker, ...}]}` | FDA PGx biomarkers |
| `FDA_get_pharmacogenomics_info_by_drug_name` | `drug_name`, `limit` | `{meta, results}` | FDA PGx label info |
| `FDA_get_indications_by_drug_name` | `drug_name`, `limit` | `{meta, results}` | FDA indications |
| `FDA_get_clinical_studies_info_by_drug_name` | `drug_name`, `limit` | `{meta, results}` | Clinical study data |
| `FDA_get_contraindications_by_drug_name` | `drug_name`, `limit` | `{meta, results}` | Contraindications |
| `FDA_get_warnings_by_drug_name` | `drug_name`, `limit` | `{meta, results}` | Warnings |
| `FDA_get_boxed_warning_info_by_drug_name` | `drug_name`, `limit` | May return NOT_FOUND | Boxed warnings |
| `FDA_get_drug_interactions_by_drug_name` | `drug_name`, `limit` | `{meta, results}` | DDI info |
| `drugbank_get_drug_basic_info_by_drug_name_or_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Drug basic info | ALL 4 REQUIRED |
| `drugbank_get_targets_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Drug targets | ALL 4 REQUIRED |
| `drugbank_get_pharmacology_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Pharmacology | ALL 4 REQUIRED |
| `drugbank_get_indications_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Indications | ALL 4 REQUIRED |
| `drugbank_get_drug_interactions_by_drug_name_or_id` | `query`, `case_sensitive`, `exact_match`, `limit` | DDI data | ALL 4 REQUIRED |
| `drugbank_get_safety_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Safety data | ALL 4 REQUIRED |
| `enrichr_gene_enrichment_analysis` | `gene_list` (array), `libs` (array, REQUIRED) | Enrichment results | Key libs: `KEGG_2021_Human`, `Reactome_2022`, `GO_Biological_Process_2023` |
| `ReactomeAnalysis_pathway_enrichment` | `identifiers` (space-separated string) | `{data: {pathways: [{pathway_id, name, p_value, ...}]}}` | Pathway enrichment |
| `Reactome_map_uniprot_to_pathways` | `id` (UniProt accession) | List of pathways | Gene-to-pathway |
| `STRING_get_interaction_partners` | `protein_ids` (array), `species` (9606), `limit` | Interaction partners | PPI network |
| `STRING_functional_enrichment` | `protein_ids` (array), `species` (9606) | Functional enrichment | Network enrichment |
| `HPA_get_cancer_prognostics_by_gene` | `gene_name` | Cancer prognostic data | Prognostic markers |
| `HPA_get_rna_expression_by_source` | `gene_name`, `source_type`, `source_name` (ALL 3) | Expression data | Tissue expression |
| `gnomad_get_gene_constraints` | `gene_symbol` | Gene constraint metrics | LoF intolerance |
| `gnomad_get_variant` | `variant_id` | Variant frequency | Population frequency |
| `clinical_trials_search` | `action='search_studies'`, `condition`, `intervention`, `limit` | `{total_count, studies}` | Trial search |
| `search_clinical_trials` | `query_term` (REQUIRED), `condition`, `intervention`, `pageSize` | `{studies, total_count}` | Alternative trial search |
| `PubMed_search_articles` | `query`, `max_results` | Plain list of dicts | Literature |
| `PubMed_Guidelines_Search` | `query`, `limit` (REQUIRED) | List of guideline articles | Clinical guidelines (may require API key) |
| `UniProt_get_function_by_accession` | `accession` | List of strings | Protein function |
| `UniProt_get_disease_variants_by_accession` | `accession` | Disease variants | Known pathogenic variants |

### Response Format Notes

- **OpenTargets**: Always nested `{data: {entity: {field: ...}}}` structure
- **FDA label tools**: Return `{meta: {disclaimer, terms, license, ...}, results: [...]}`. Access via `result['results'][0]['field']`
- **DrugBank**: ALL tools require 4 params: `query`, `case_sensitive` (bool), `exact_match` (bool), `limit` (int)
- **PharmGKB**: Returns complex nested objects. Check for `data` wrapper
- **PubMed_search_articles**: Returns a **plain list** of dicts, NOT `{articles: [...]}`
- **ClinVar**: `clinvar_search_variants` returns list of variants with clinical significance
- **gnomAD**: May return "Service overloaded" - treat as transient, retry or skip
- **fda_pharmacogenomic_biomarkers**: Default limit=10, use `limit=1000` to get all
- **cBioPortal_get_mutations**: `gene_list` is a STRING, not array. cBioPortal tools may have URL bugs
- **ClinVar**: May return either a plain list or `{status, data: {esearchresult: {count, idlist}}}` - handle both
- **EnsemblVEP**: May return either a list `[{...}]` or `{data: {...}, metadata: {...}}` - handle both
- **PubMed_Guidelines_Search**: Requires `limit` parameter (NOT `max_results`), may require API key. Use `PubMed_search_articles` as fallback
- **gwas_get_associations_for_trait**: May return errors; use `gwas_search_associations` instead
- **MyGene CYP2D6**: First result may be LOC110740340; always filter by `symbol` match

---

## Workflow Overview

```
Input: Disease + Genomic data + Clinical parameters + Stratification goal

Phase 1: Disease Disambiguation & Profile Standardization
  - Resolve disease to EFO/MONDO IDs
  - Classify disease type (cancer/metabolic/CVD/neuro/rare/autoimmune)
  - Parse genomic data (variants, genes, expression)
  - Resolve gene IDs (Ensembl, Entrez, UniProt)

Phase 2: Genetic Risk Assessment
  - Germline variant pathogenicity (ClinVar, VEP)
  - Gene-disease association strength (OpenTargets)
  - GWAS-based polygenic risk estimation
  - Population frequency (gnomAD)
  - Gene constraint/intolerance (gnomAD)

Phase 3: Disease-Specific Molecular Stratification
  CANCER PATH:
    - Molecular subtyping (driver mutations, receptor status)
    - Prognostic markers (stage + grade + molecular)
    - TMB/MSI/HRD assessment
    - Somatic mutation landscape (cBioPortal)
  METABOLIC PATH:
    - Genetic risk + clinical risk integration
    - Complication risk (nephropathy, neuropathy, CVD)
    - Monogenic subtypes (MODY, lipodystrophy)
  CVD PATH:
    - ASCVD risk integration
    - Familial hypercholesterolemia genes
    - Statin/anticoagulant PGx
  RARE DISEASE PATH:
    - Causal variant identification
    - Genotype-phenotype correlation
    - Penetrance estimation

Phase 4: Pharmacogenomic Profiling
  - Drug-metabolizing enzyme genotypes (CYP2D6, CYP2C19, CYP3A4)
  - Drug transporter variants (SLCO1B1, ABCB1)
  - Drug target variants (VKORC1, DPYD, UGT1A1)
  - HLA alleles (drug hypersensitivity risk)
  - PharmGKB clinical annotations
  - FDA pharmacogenomic biomarkers

Phase 5: Comorbidity & Drug Interaction Risk
  - Disease-disease genetic overlap
  - Impact on treatment selection
  - Drug-drug interaction risk
  - Pharmacogenomic DDI amplification

Phase 6: Molecular Pathway Analysis
  - Dysregulated pathway identification (Reactome, KEGG)
  - Network disruption analysis (STRING)
  - Druggable pathway targets
  - Pathway-based therapeutic opportunities

Phase 7: Clinical Evidence & Guidelines
  - Guideline-based risk categories (NCCN, ACC/AHA, ADA)
  - FDA-approved therapies for patient profile
  - Literature evidence (PubMed)
  - Biomarker-guided treatment evidence

Phase 8: Clinical Trial Matching
  - Trials matching molecular profile
  - Biomarker-driven trials
  - Precision medicine basket/umbrella trials
  - Risk-adapted trials

Phase 9: Integrated Scoring & Recommendations
  - Calculate Precision Medicine Risk Score (0-100)
  - Risk tier assignment (Low/Int/High/Very High)
  - Treatment algorithm (1st/2nd/3rd line)
  - Monitoring plan
  - Outcome predictions
```

---

## Phase 1: Disease Disambiguation & Profile Standardization

### Step 1.1: Resolve Disease to EFO ID

```python
# Get disease EFO ID
result = tu.tools.OpenTargets_get_disease_id_description_by_name(diseaseName='breast cancer')
# -> {data: {search: {hits: [{id: 'EFO_0000305', name: 'breast carcinoma', description: '...'}]}}}
efo_id = result['data']['search']['hits'][0]['id']
```

**Common Disease EFO IDs** (for reference):

| Disease | EFO ID | Category |
|---------|--------|----------|
| Breast carcinoma | EFO_0000305 | CANCER |
| Non-small cell lung carcinoma | EFO_0003060 | CANCER |
| Colorectal cancer | EFO_0000365 | CANCER |
| Melanoma | EFO_0000756 | CANCER |
| Prostate carcinoma | EFO_0001663 | CANCER |
| Type 2 diabetes | EFO_0001360 | METABOLIC |
| Coronary artery disease | EFO_0001645 | CVD |
| Atrial fibrillation | EFO_0000275 | CVD |
| Alzheimer disease | MONDO_0004975 | NEUROLOGICAL |
| Parkinson disease | EFO_0002508 | NEUROLOGICAL |
| Rheumatoid arthritis | EFO_0000685 | AUTOIMMUNE |
| Marfan syndrome | Orphanet_558 | RARE |
| Cystic fibrosis | EFO_0000508 | RARE |

### Step 1.2: Classify Disease Type

Based on disease name and EFO ID, classify into: CANCER, METABOLIC, CVD, NEUROLOGICAL, RARE, AUTOIMMUNE. This determines the Phase 3 routing.

### Step 1.3: Parse Genomic Data

Parse each variant/gene into structured format:
```
"BRCA1 c.68_69delAG" -> {gene: "BRCA1", variant: "c.68_69delAG", type: "frameshift"}
"EGFR L858R" -> {gene: "EGFR", variant: "L858R", type: "missense"}
"CYP2C19 *2/*2" -> {gene: "CYP2C19", genotype: "*2/*2", metabolizer_status: "poor"}
"APOE e4/e4" -> {gene: "APOE", genotype: "e4/e4", risk_allele: "e4"}
```

### Step 1.4: Resolve Gene IDs

```python
# For each gene in profile
result = tu.tools.MyGene_query_genes(query='BRCA1')
# -> hits[0]: {_id: '672', symbol: 'BRCA1', ensembl: {gene: 'ENSG00000012048'}}
ensembl_id = result['hits'][0]['ensembl']['gene']
entrez_id = result['hits'][0]['_id']
```

**Critical Gene IDs** (pre-resolved):

| Gene | Ensembl ID | Entrez ID | Category |
|------|-----------|-----------|----------|
| BRCA1 | ENSG00000012048 | 672 | Cancer predisposition |
| BRCA2 | ENSG00000139618 | 675 | Cancer predisposition |
| TP53 | ENSG00000141510 | 7157 | Tumor suppressor |
| EGFR | ENSG00000146648 | 1956 | Cancer driver |
| BRAF | ENSG00000157764 | 673 | Cancer driver |
| KRAS | ENSG00000133703 | 3845 | Cancer driver |
| CYP2D6 | ENSG00000100197 | 1565 | Pharmacogenomics |
| CYP2C19 | ENSG00000165841 | 1557 | Pharmacogenomics |
| SLCO1B1 | ENSG00000134538 | 10599 | Pharmacogenomics |
| VKORC1 | ENSG00000167397 | 79001 | Pharmacogenomics |
| DPYD | ENSG00000188641 | 1806 | Pharmacogenomics |
| APOE | ENSG00000130203 | 348 | Neurological risk |
| LDLR | ENSG00000130164 | 3949 | CVD risk |
| PCSK9 | ENSG00000169174 | 255738 | CVD risk |
| FBN1 | ENSG00000166147 | 2200 | Marfan syndrome |
| CFTR | ENSG00000001626 | 1080 | Cystic fibrosis |

---

## Phase 2: Genetic Risk Assessment

### Step 2.1: Germline Variant Pathogenicity

For each germline variant provided:

```python
# Search ClinVar for variant pathogenicity
result = tu.tools.clinvar_search_variants(gene='BRCA1', significance='pathogenic', limit=50)
# Check if patient's specific variant is in ClinVar

# For rsID variants, get VEP annotation
result = tu.tools.EnsemblVEP_annotate_rsid(variant_id='rs80357906')
# Returns SIFT, PolyPhen predictions, consequence type

# For HGVS variants
result = tu.tools.EnsemblVEP_annotate_hgvs(hgvs_notation='ENST00000357654.9:c.5266dupC', species='homo_sapiens')
```

**Pathogenicity Classification** (ACMG-aligned):

| Classification | ClinVar Term | Risk Score Points |
|---------------|-------------|-------------------|
| Pathogenic | Pathogenic | 25 (molecular component) |
| Likely pathogenic | Likely pathogenic | 20 |
| VUS | Uncertain significance | 10 (conservative) |
| Likely benign | Likely benign | 2 |
| Benign | Benign | 0 |

### Step 2.2: Gene-Disease Association Strength

```python
# Get genetic evidence for gene-disease pair
result = tu.tools.OpenTargets_target_disease_evidence(
    ensemblId='ENSG00000012048',  # BRCA1
    efoId='EFO_0000305',         # breast cancer
    size=20
)
# Returns evidence items with scores
```

### Step 2.3: GWAS-Based Polygenic Risk

```python
# Search GWAS associations for disease
result = tu.tools.gwas_get_associations_for_trait(trait='breast cancer')
# Returns associated SNPs with effect sizes

# Search GWAS studies via OpenTargets
result = tu.tools.OpenTargets_search_gwas_studies_by_disease(
    diseaseIds=['EFO_0000305'], size=25
)

# For specific genes, check GWAS hits
result = tu.tools.GWAS_search_associations_by_gene(gene_name='BRCA1')
```

**PRS Estimation** (from available GWAS data):

| PRS Percentile | Risk Category | Score Points (0-35) |
|---------------|--------------|---------------------|
| >95th percentile | Very high genetic risk | 35 |
| 90-95th | High genetic risk | 30 |
| 75-90th | Elevated genetic risk | 25 |
| 50-75th | Average-high | 18 |
| 25-50th | Average-low | 12 |
| 10-25th | Below average | 8 |
| <10th | Low genetic risk | 5 |

**Note**: With user-provided variants only (not full genotype), estimate approximate PRS by counting known risk alleles and their effect sizes from GWAS catalog. Flag as "estimated - full genotyping recommended for precise PRS."

### Step 2.4: Population Frequency

```python
# Check variant frequency in gnomAD
result = tu.tools.gnomad_get_variant(variant_id='1-55505647-G-T')
# Returns allele frequency across populations
```

### Step 2.5: Gene Constraint

```python
# Gene intolerance to loss of function
result = tu.tools.gnomad_get_gene_constraints(gene_symbol='BRCA1')
# Returns pLI, LOEUF scores - high pLI/low LOEUF = haploinsufficiency
```

**Genetic Risk Score Component** (0-35 points):

Combine pathogenicity + gene-disease association + PRS:
- Pathogenic variant in disease gene: 25+ points
- Strong GWAS associations (multiple risk alleles): up to 35 points
- VUS in relevant gene: 10-15 points
- No known pathogenic variants but some risk alleles: 5-15 points

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-precision-medicine-stratification/REFERENCE.md`
