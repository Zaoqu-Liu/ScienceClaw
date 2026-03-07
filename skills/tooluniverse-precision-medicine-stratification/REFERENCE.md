# tooluniverse-precision-medicine-stratification — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 3: Disease-Specific Molecular Stratification

### CANCER PATH (Phase 3C)

#### Step 3C.1: Molecular Subtyping

```python
# Get somatic mutation landscape from cBioPortal
result = tu.tools.cBioPortal_get_mutations(
    study_id='brca_tcga_pub',  # breast cancer TCGA
    gene_list='BRCA1 BRCA2 TP53 PIK3CA ESR1 ERBB2'  # STRING, not array
)
# Returns mutation frequencies, types

# Check cancer prognostic markers
result = tu.tools.HPA_get_cancer_prognostics_by_gene(gene_name='ESR1')
# Returns prognostic data for breast cancer
```

**Cancer-Specific Subtype Definitions**:

| Cancer | Subtype System | Key Markers | High-Risk Features |
|--------|---------------|-------------|-------------------|
| Breast | Luminal A/B, HER2+, TNBC | ER, PR, HER2, Ki67 | TNBC, high Ki67, TP53 mut |
| NSCLC | Adenocarcinoma, squamous | EGFR, ALK, ROS1, KRAS, PD-L1 | KRAS G12C, no driver = chemoIO |
| CRC | MSI-H vs MSS, CMS1-4 | KRAS, BRAF, MSI, CMS | BRAF V600E, MSS |
| Melanoma | BRAF-mut, NRAS-mut, wild-type | BRAF, NRAS, KIT, NF1 | NRAS, uveal |
| Prostate | Luminal vs basal, BRCA status | AR, BRCA1/2, SPOP, TMPRSS2:ERG | BRCA2, neuroendocrine |

#### Step 3C.2: TMB/MSI/HRD Assessment

If TMB provided:
```python
# Check FDA TMB-H approvals
result = tu.tools.fda_pharmacogenomic_biomarkers(drug_name='pembrolizumab', limit=100)
# Look for "Tumor Mutational Burden" in Biomarker field
```

| Biomarker | High-Risk Threshold | Clinical Significance |
|-----------|-------------------|----------------------|
| TMB | >= 10 mut/Mb (FDA cutoff) | Pembrolizumab eligible (tissue-agnostic) |
| MSI-H | MSI-high or dMMR | Pembrolizumab/nivolumab eligible |
| HRD | HRD-positive | PARP inhibitor eligible |

#### Step 3C.3: Prognostic Stratification

Combine stage + molecular features:

| Stage | Low-Risk Molecular | High-Risk Molecular | Score (0-30 clinical) |
|-------|-------------------|--------------------|-----------------------|
| I | Favorable subtype | Unfavorable subtype | 5-10 |
| II | Favorable subtype | Unfavorable subtype | 10-18 |
| III | Any | Any | 18-25 |
| IV | Any | Any | 25-30 |

### METABOLIC PATH (Phase 3M)

#### Step 3M.1: Clinical Risk Integration

```python
# Check genetic risk factors for T2D
result = tu.tools.GWAS_search_associations_by_gene(gene_name='TCF7L2')
# TCF7L2 is strongest T2D risk gene

# Check monogenic diabetes genes
result = tu.tools.OpenTargets_target_disease_evidence(
    ensemblId='ENSG00000148737',  # TCF7L2
    efoId='EFO_0001360',         # T2D
    size=20
)
```

**T2D Stratification**:

| Risk Factor | Low Risk | Moderate Risk | High Risk | Score Points |
|-------------|----------|---------------|-----------|-------------|
| HbA1c | <6.5% | 6.5-8.0% | >8.0% | 5-30 |
| Genetic risk | No risk alleles | 1-3 risk alleles | MODY gene/many risk alleles | 5-25 |
| Complications | None | Microalbuminuria | Retinopathy, neuropathy | 0-20 |
| Duration | <5 years | 5-15 years | >15 years | 0-10 |

### CVD PATH (Phase 3V)

```python
# Check PCSK9 and LDLR variants
result = tu.tools.clinvar_search_variants(gene='LDLR', significance='pathogenic', limit=20)
# Familial hypercholesterolemia check

# Check statin-relevant PGx
result = tu.tools.PharmGKB_get_clinical_annotations(query='SLCO1B1')
# SLCO1B1 *5 -> increased statin myopathy risk
```

**CVD Risk Integration**:

| Factor | Score Points |
|--------|-------------|
| LDL >190 mg/dL | 15 |
| FH gene mutation (LDLR/APOB/PCSK9) | 20 |
| ASCVD >20% 10-year risk | 30 |
| Family hx premature CVD | 10 |
| Lipoprotein(a) elevated | 8 |
| Multiple GWAS risk alleles | 5-15 |

### RARE DISEASE PATH (Phase 3R)

```python
# Check causal variant in disease gene
result = tu.tools.clinvar_search_variants(gene='FBN1', significance='pathogenic', limit=50)
# Marfan syndrome - FBN1 pathogenic variants

# Genotype-phenotype correlation
result = tu.tools.UniProt_get_disease_variants_by_accession(accession='P35555')  # FBN1 UniProt
# Known disease variants and their phenotypes
```

**Rare Disease Risk Assessment**:

| Finding | Risk Level | Score Points |
|---------|-----------|-------------|
| Pathogenic variant in causal gene | Definitive | 30 |
| Likely pathogenic in causal gene | Strong | 25 |
| VUS in causal gene | Moderate | 15 |
| Family history + partial phenotype | Suggestive | 10 |
| Single phenotype feature only | Low | 5 |

---

## Phase 4: Pharmacogenomic Profiling

### Step 4.1: Drug-Metabolizing Enzyme Genotypes

```python
# PharmGKB clinical annotations for CYP2C19
result = tu.tools.PharmGKB_get_clinical_annotations(query='CYP2C19')
# Returns drug-gene pairs with clinical annotation levels

# FDA pharmacogenomic biomarkers
result = tu.tools.fda_pharmacogenomic_biomarkers(drug_name='clopidogrel', limit=50)
# CYP2C19 poor metabolizer -> reduced clopidogrel efficacy

# PharmGKB dosing guidelines
result = tu.tools.PharmGKB_get_dosing_guidelines(query='CYP2C19')
# CPIC dosing guidelines
```

**Key Pharmacogenes and Clinical Impact**:

| Gene | Star Alleles | Metabolizer Status | Clinical Impact | Score Points |
|------|-------------|-------------------|----------------|-------------|
| CYP2D6 | *4/*4, *5/*5 | Poor metabolizer | Codeine, tamoxifen, many antidepressants | 8 |
| CYP2C19 | *2/*2, *2/*3 | Poor metabolizer | Clopidogrel, voriconazole, PPIs | 8 |
| CYP2C9 | *2/*3, *3/*3 | Poor metabolizer | Warfarin, NSAIDs, phenytoin | 5 |
| SLCO1B1 | *5/*5 | Decreased function | Statin myopathy (simvastatin) | 5 |
| DPYD | *2A | DPD deficient | 5-FU/capecitabine severe toxicity | 10 |
| VKORC1 | -1639G>A | Warfarin sensitive | Lower warfarin dose needed | 5 |
| UGT1A1 | *28/*28 | Poor glucuronidator | Irinotecan toxicity | 5 |
| TPMT | *2, *3A, *3C | Poor metabolizer | Thiopurine toxicity | 8 |
| HLA-B*5701 | Present | N/A | Abacavir hypersensitivity | 10 |
| HLA-B*1502 | Present | N/A | Carbamazepine SJS/TEN | 10 |

### Step 4.2: Treatment-Specific PGx

```python
# For the specific disease, identify relevant drugs and check PGx
# Example: breast cancer -> tamoxifen -> CYP2D6
result = tu.tools.PharmGKB_get_drug_details(query='tamoxifen')
# Returns PGx annotations for tamoxifen

# Get FDA PGx biomarkers for disease area
result = tu.tools.fda_pharmacogenomic_biomarkers(biomarker='CYP2D6', limit=100)
# All drugs with CYP2D6 PGx in FDA labels
```

### Step 4.3: Drug Target Variants

```python
# Check if patient has variants in drug targets
result = tu.tools.PharmGKB_search_variants(query='VKORC1')
# VKORC1 variants affecting warfarin response
```

**Pharmacogenomic Risk Score** (0-10 points):
- Poor metabolizer for treatment-relevant CYP: 8-10 points
- Intermediate metabolizer: 4-5 points
- High-risk HLA allele: 8-10 points
- Drug target variant: 3-5 points
- Normal metabolizer, no actionable PGx: 0 points

---

## Phase 5: Comorbidity & Drug Interaction Risk

### Step 5.1: Comorbidity Analysis

```python
# Check disease-disease overlap via shared genetic targets
result = tu.tools.OpenTargets_get_associated_targets_by_disease_efoId(
    efoId='EFO_0001360',  # T2D
    size=50
)
# Compare top targets between primary disease and comorbidities

# Literature on comorbidity
result = tu.tools.PubMed_search_articles(
    query='type 2 diabetes cardiovascular comorbidity risk',
    max_results=5
)
```

### Step 5.2: Drug-Drug Interaction Risk

```python
# If current medications provided, check DDI
result = tu.tools.drugbank_get_drug_interactions_by_drug_name_or_id(
    query='metformin',
    case_sensitive=False,
    exact_match=False,
    limit=20
)

# FDA DDI data
result = tu.tools.FDA_get_drug_interactions_by_drug_name(drug_name='metformin', limit=5)
```

### Step 5.3: PGx-Amplified DDI Risk

If patient is a CYP2D6 poor metabolizer AND taking a CYP2D6 inhibitor -> compounded risk.

| Interaction Type | Risk Level | Management |
|-----------------|-----------|------------|
| PGx PM + CYP inhibitor | Very high | Alternative drug or dose reduction |
| PGx IM + CYP inhibitor | High | Monitor closely, possible dose reduction |
| PGx normal + CYP inhibitor | Moderate | Standard monitoring |
| No interacting drugs | Low | Standard care |

---

## Phase 6: Molecular Pathway Analysis

### Step 6.1: Dysregulated Pathways

```python
# Pathway enrichment for affected genes
gene_list = ['BRCA1', 'TP53', 'PIK3CA']  # from patient mutations
result = tu.tools.enrichr_gene_enrichment_analysis(
    gene_list=gene_list,
    libs=['KEGG_2021_Human', 'Reactome_2022']
)
# Returns enriched pathways with p-values

# Reactome pathway analysis
# First get UniProt IDs, then map to pathways
result = tu.tools.Reactome_map_uniprot_to_pathways(id='P38398')  # BRCA1 UniProt
# Returns list of pathways involving BRCA1
```

### Step 6.2: Network Analysis

```python
# Protein-protein interaction network
result = tu.tools.STRING_get_interaction_partners(
    protein_ids=['BRCA1', 'TP53'],
    species=9606,
    limit=20
)

# Functional enrichment of network
result = tu.tools.STRING_functional_enrichment(
    protein_ids=['BRCA1', 'TP53', 'PALB2', 'RAD51'],
    species=9606
)
```

### Step 6.3: Druggable Pathway Targets

```python
# Check tractability of pathway nodes
for gene in pathway_genes:
    result = tu.tools.OpenTargets_get_target_tractability_by_ensemblID(ensemblId=ensembl_id)
    # Returns small molecule, antibody, PROTAC tractability
```

**Key Druggable Pathways**:

| Pathway | Key Nodes | Drug Classes | Cancer Relevance |
|---------|-----------|-------------|-----------------|
| PI3K/AKT/mTOR | PIK3CA, AKT1, MTOR | PI3K inhibitors, mTOR inhibitors | Breast, endometrial |
| RAS/MAPK | KRAS, BRAF, MEK1/2 | KRAS G12C inhibitors, BRAF inhibitors | Lung, CRC, melanoma |
| DNA damage repair | BRCA1/2, ATM, PALB2 | PARP inhibitors | Breast, ovarian, prostate |
| Cell cycle | CDK4/6, RB1, CCND1 | CDK4/6 inhibitors | Breast |
| Immunocheckpoint | PD-1, PD-L1, CTLA-4 | ICIs | Pan-cancer |
| Wnt/beta-catenin | APC, CTNNB1, TCF | Wnt inhibitors (investigational) | CRC |

---

## Phase 7: Clinical Evidence & Guidelines

### Step 7.1: Guideline-Based Risk Categories

```python
# Search clinical guidelines in PubMed
result = tu.tools.PubMed_Guidelines_Search(
    query='NCCN breast cancer BRCA1 treatment guidelines',
    max_results=5
)

# Search general evidence
result = tu.tools.PubMed_search_articles(
    query='BRCA1 breast cancer treatment stratification',
    max_results=10
)
```

**Guideline References by Disease**:

| Disease Category | Guidelines | Key Stratification |
|-----------------|-----------|-------------------|
| Breast cancer | NCCN, ASCO, St. Gallen | Luminal A/B, HER2+, TNBC, BRCA status |
| NSCLC | NCCN, ESMO | Driver mutation status, PD-L1, TMB |
| CRC | NCCN | MSI, RAS/BRAF, sidedness |
| T2D | ADA Standards | HbA1c, CVD risk, CKD stage |
| CVD | ACC/AHA | ASCVD risk score, LDL goals, PGx |
| AF | ACC/AHA/HRS | CHA2DS2-VASc, anticoagulant selection |
| Rare disease | ACMG/AMP | Variant classification, genetic counseling |

### Step 7.2: FDA-Approved Therapies

```python
# Get approved drugs for disease
result = tu.tools.OpenTargets_get_associated_drugs_by_disease_efoId(
    efoId='EFO_0000305',  # breast cancer
    size=50
)
# Returns all known drugs with clinical status

# Check specific drug FDA info
result = tu.tools.FDA_get_indications_by_drug_name(drug_name='olaparib', limit=5)
# PARP inhibitor for BRCA-mutated breast cancer

# Get drug mechanism
result = tu.tools.FDA_get_mechanism_of_action_by_drug_name(drug_name='olaparib', limit=5)
```

### Step 7.3: Biomarker-Drug Evidence

```python
# CIViC evidence for biomarker-drug pair
result = tu.tools.civic_search_evidence_items(
    therapy_name='olaparib',
    disease_name='breast cancer'
)
# Returns clinical evidence items with evidence levels

# DrugBank for drug details
result = tu.tools.drugbank_get_drug_basic_info_by_drug_name_or_id(
    query='olaparib',
    case_sensitive=False,
    exact_match=False,
    limit=5
)
```

---

## Phase 8: Clinical Trial Matching

### Step 8.1: Biomarker-Driven Trials

```python
# Search trials matching molecular profile
result = tu.tools.clinical_trials_search(
    action='search_studies',
    condition='breast cancer',
    intervention='PARP inhibitor',
    limit=10
)
# Returns {total_count, studies: [{nctId, title, status, conditions}]}

# Alternative search
result = tu.tools.search_clinical_trials(
    query_term='BRCA1 breast cancer',
    condition='breast cancer',
    intervention='olaparib',
    pageSize=10
)
```

### Step 8.2: Precision Medicine Trials

```python
# Search basket/umbrella trials
result = tu.tools.search_clinical_trials(
    query_term='precision medicine biomarker-driven',
    condition='breast cancer',
    pageSize=10
)

# Search risk-adapted trials
result = tu.tools.search_clinical_trials(
    query_term='high risk BRCA1',
    condition='breast cancer',
    pageSize=10
)
```

### Step 8.3: Trial Details

```python
# Get details for promising trials
result = tu.tools.clinical_trials_get_details(
    action='get_study_details',
    nct_id='NCT03344965'
)
# Returns full study protocol
```

---

## Phase 9: Integrated Scoring & Recommendations

### Precision Medicine Risk Score (0-100)

#### Score Components

**Genetic Risk Component** (0-35 points):

| Scenario | Points |
|----------|--------|
| Pathogenic variant in high-penetrance disease gene (BRCA1, LDLR, FBN1) | 30-35 |
| Multiple moderate-risk variants (GWAS hits + moderate penetrance) | 20-28 |
| High PRS (>90th percentile) with no known pathogenic variants | 25-30 |
| Single moderate-risk variant | 12-18 |
| VUS in relevant gene | 8-12 |
| Average PRS, no pathogenic variants | 5-10 |
| Low genetic risk (low PRS, no risk alleles) | 0-5 |

**Clinical Risk Component** (0-30 points):

| Disease Type | Factor | Low (0-8) | Moderate (10-20) | High (22-30) |
|-------------|--------|-----------|------------------|-------------|
| Cancer | Stage | I | II-III | IV |
| T2D | HbA1c | <7% | 7-9% | >9% |
| CVD | ASCVD 10-yr | <10% | 10-20% | >20% |
| Neuro | Biomarker status | No biomarkers | Mild changes | Established |
| Rare | Phenotype match | Partial | Moderate | Full phenotype |

**Molecular Features Component** (0-25 points):

| Feature | Points |
|---------|--------|
| Cancer: High-risk driver mutations (TP53+PIK3CA, KRAS G12C) | 20-25 |
| Cancer: Actionable mutation (EGFR, BRAF V600E) | 15-20 |
| Cancer: High TMB or MSI-H (favorable for ICI) | 10-15 |
| Metabolic: Monogenic form (MODY, FH) | 20-25 |
| Metabolic: Multiple metabolic risk variants | 10-15 |
| CVD: FH gene mutation | 20-25 |
| Rare: Complete genotype-phenotype match | 20-25 |
| VUS requiring further workup | 5-10 |

**Pharmacogenomic Risk Component** (0-10 points):

| Finding | Points |
|---------|--------|
| Poor metabolizer for treatment-critical CYP + high-risk HLA | 10 |
| Poor metabolizer for treatment-critical CYP | 7-8 |
| Intermediate metabolizer for relevant CYP | 4-5 |
| Drug target variant (e.g., VKORC1 for warfarin) | 3-5 |
| No actionable PGx findings | 0-2 |

#### Risk Tier Assignment

| Total Score | Risk Tier | Management Intensity |
|------------|-----------|---------------------|
| 75-100 | **VERY HIGH** | Intensive treatment, subspecialty referral, clinical trial enrollment |
| 50-74 | **HIGH** | Aggressive treatment, close monitoring, molecular tumor board |
| 25-49 | **INTERMEDIATE** | Standard treatment, guideline-based care, PGx-guided dosing |
| 0-24 | **LOW** | Surveillance, prevention, risk factor modification |

### Treatment Algorithm

Based on disease type + risk tier + molecular profile + PGx:

#### Cancer Treatment Algorithm

```
IF actionable mutation present:
  1st line: Targeted therapy (e.g., EGFR TKI, BRAF inhibitor, PARP inhibitor)
  2nd line: Immunotherapy (if TMB-H or MSI-H) OR chemotherapy
  3rd line: Clinical trial OR alternative targeted therapy

IF no actionable mutation:
  IF TMB-H or MSI-H:
    1st line: Immunotherapy (pembrolizumab)
    2nd line: Chemotherapy
  ELSE:
    1st line: Standard chemotherapy (disease-specific)
    2nd line: Consider clinical trials

PGx adjustments:
  - DPYD deficient -> AVOID fluoropyrimidines or reduce dose 50%
  - UGT1A1 *28/*28 -> Reduce irinotecan dose
  - CYP2D6 PM + tamoxifen -> Switch to aromatase inhibitor
```

#### Metabolic/CVD Treatment Algorithm

```
IF monogenic form (MODY, FH):
  Disease-specific therapy (e.g., sulfonylureas for HNF1A-MODY, PCSK9i for FH)

IF polygenic risk:
  Standard guidelines (ADA, ACC/AHA)
  PGx-guided drug selection:
    - CYP2C19 PM -> Alternative to clopidogrel (ticagrelor, prasugrel)
    - SLCO1B1 *5 -> Lower statin dose or alternative statin
    - VKORC1 variant -> Warfarin dose adjustment or DOAC
```

### Monitoring Plan

| Component | Frequency | Method |
|-----------|-----------|--------|
| Molecular biomarkers | Per guideline | Liquid biopsy, tissue biopsy |
| Clinical markers | 3-6 months | Labs, imaging |
| PGx-guided drug levels | As needed | TDM |
| Disease progression | Per stage/risk | Imaging, biomarkers |
| Comorbidity screening | Annually | Labs, risk calculators |

---

## Output Report Structure

Generate a comprehensive markdown report saved to: `[PATIENT_ID]_precision_medicine_report.md`

### Required Sections

```markdown
# Precision Medicine Stratification Report

## Executive Summary
- **Patient Profile**: [Disease, key features]
- **Precision Medicine Risk Score**: [X]/100
- **Risk Tier**: [LOW / INTERMEDIATE / HIGH / VERY HIGH]
- **Key Finding**: [One-line summary of most actionable finding]
- **Primary Recommendation**: [One-line treatment recommendation]

## 1. Patient Profile
### Disease Classification
### Genomic Data Summary
### Clinical Parameters

## 2. Genetic Risk Assessment
### Germline Variant Analysis
### Gene-Disease Association Evidence
### Polygenic Risk Estimation
### Population Frequency Data

## 3. Disease-Specific Stratification
### [Cancer: Molecular Subtype / Metabolic: Risk Integration / etc.]
### Prognostic Markers
### Risk Group Assignment

## 4. Pharmacogenomic Profile
### Drug-Metabolizing Enzymes
### Drug Target Variants
### Treatment-Specific PGx Recommendations
### FDA PGx Biomarker Status

## 5. Comorbidity & Drug Interaction Risk
### Disease-Disease Overlap
### Drug-Drug Interactions
### PGx-Amplified DDI Risk

## 6. Dysregulated Pathways
### Key Pathways Affected
### Druggable Targets
### Network Analysis

## 7. Clinical Evidence & Guidelines
### Guideline-Based Classification
### FDA-Approved Therapies
### Biomarker-Drug Evidence

## 8. Clinical Trial Matches
### Biomarker-Driven Trials
### Precision Medicine Trials
### Risk-Adapted Trials

## 9. Integrated Risk Score
### Score Breakdown
| Component | Points | Max | Basis |
|-----------|--------|-----|-------|
| Genetic Risk | X | 35 | [Details] |
| Clinical Risk | X | 30 | [Details] |
| Molecular Features | X | 25 | [Details] |
| Pharmacogenomic Risk | X | 10 | [Details] |
| **TOTAL** | **X** | **100** | |

### Risk Tier: [TIER]
### Confidence Level: [HIGH/MODERATE/LOW]

## 10. Treatment Algorithm
### 1st Line Recommendation
### 2nd Line Options
### 3rd Line / Investigational
### PGx Dose Adjustments

## 11. Monitoring Plan
### Biomarker Surveillance
### Imaging Schedule
### Risk Reassessment Timeline

## 12. Outcome Predictions
### Disease-Specific Prognosis
### Treatment Response Prediction
### Projected Timeline

## Completeness Checklist
| Data Layer | Available | Analyzed | Key Finding |
|-----------|-----------|----------|-------------|
| Disease disambiguation | Y/N | Y/N | [EFO ID] |
| Germline variants | Y/N | Y/N | [Pathogenicity] |
| Somatic mutations | Y/N | Y/N | [Drivers] |
| Gene expression | Y/N | Y/N | [Subtype] |
| PGx genotypes | Y/N | Y/N | [Metabolizer status] |
| Clinical biomarkers | Y/N | Y/N | [Key values] |
| GWAS/PRS | Y/N | Y/N | [Risk percentile] |
| Pathway analysis | Y/N | Y/N | [Key pathways] |
| Clinical trials | Y/N | Y/N | [N matches] |
| Guidelines | Y/N | Y/N | [Guideline tier] |

## Evidence Sources
[List all databases and tools used with specific citations]
```

---

## Evidence Grading

All findings must be graded:

| Tier | Level | Sources | Weight |
|------|-------|---------|--------|
| **T1** | Clinical/regulatory evidence | FDA labels, NCCN guidelines, PharmGKB Level 1A/1B, ClinVar pathogenic | Highest |
| **T2** | Strong experimental evidence | CIViC Level A/B, OpenTargets high-score, GWAS p<5e-8, clinical trials | High |
| **T3** | Moderate evidence | PharmGKB Level 2, CIViC Level C, GWAS suggestive, preclinical data | Moderate |
| **T4** | Computational/predicted | VEP predictions, pathway inference, network analysis, PRS estimates | Supportive |

---

## Completeness Requirements

**Minimum deliverables** for a valid stratification report:
1. Disease resolved to EFO/ontology ID
2. At least one genetic risk assessment completed (germline OR somatic OR PRS)
3. Disease-specific stratification with risk group
4. At least one pharmacogenomic assessment (even if "no actionable findings")
5. Pathway analysis with at least one pathway identified
6. Treatment recommendation with evidence tier
7. At least one clinical trial match attempted
8. Precision Medicine Risk Score calculated with all available components
9. Risk tier assigned
10. Monitoring plan outlined

---

## Common Use Patterns

### Pattern 1: Cancer Patient with Actionable Mutation
**Input**: "Breast cancer, BRCA1 pathogenic variant, ER+/HER2-, stage IIA, age 45"
**Key phases**: Phase 1 (cancer classification) -> Phase 2 (BRCA1 pathogenicity) -> Phase 3C (molecular subtype = Luminal B, BRCA+) -> Phase 4 (check CYP2D6 for tamoxifen) -> Phase 7 (NCCN guidelines: PARP inhibitor eligible) -> Phase 8 (PARP inhibitor trials) -> Phase 9 (Risk Score ~55-65, HIGH tier)

### Pattern 2: Metabolic Disease with PGx Concern
**Input**: "Type 2 diabetes, HbA1c 8.5%, CYP2C19 *2/*2, on clopidogrel for CAD stent"
**Key phases**: Phase 1 (T2D + CAD) -> Phase 2 (T2D genetic risk) -> Phase 3M (HbA1c-based risk) -> Phase 4 (CYP2C19 PM: clopidogrel ineffective!) -> Phase 5 (T2D-CAD comorbidity) -> Phase 9 (Risk Score ~50-60, HIGH, clopidogrel switch urgent)

### Pattern 3: CVD Risk Stratification
**Input**: "LDL 190 mg/dL, SLCO1B1*5 heterozygous, family history of MI at age 48"
**Key phases**: Phase 1 (CVD/FH evaluation) -> Phase 2 (FH gene check: LDLR, APOB, PCSK9) -> Phase 3V (ASCVD risk) -> Phase 4 (SLCO1B1 *5: statin myopathy risk) -> Phase 7 (ACC/AHA guidelines) -> Phase 9 (Risk Score ~45-55, statin dose reduction or rosuvastatin)

### Pattern 4: Rare Disease Diagnosis
**Input**: "Marfan syndrome suspected, FBN1 c.4082G>A, tall stature, aortic root dilation"
**Key phases**: Phase 1 (Marfan/rare) -> Phase 2 (FBN1 variant pathogenicity) -> Phase 3R (genotype-phenotype match) -> Phase 7 (Ghent criteria) -> Phase 9 (Risk Score depends on aortic involvement)

### Pattern 5: Neurological Risk Assessment
**Input**: "Family history of Alzheimer's, APOE e4/e4, age 55"
**Key phases**: Phase 1 (AD/neuro) -> Phase 2 (APOE e4/e4 = highest genetic risk) -> Phase 3 (AD-specific risk) -> Phase 4 (PGx for potential treatments) -> Phase 7 (guidelines) -> Phase 9 (Risk Score ~60-75, HIGH)

### Pattern 6: Comprehensive Cancer with Full Molecular
**Input**: "NSCLC, EGFR L858R, TMB 25 mut/Mb, PD-L1 80%, stage IV, no EGFR T790M"
**Key phases**: All phases. Phase 3C critical: EGFR L858R = EGFR TKI eligible, high TMB + PD-L1 = ICI eligible. Treatment algorithm: 1st line osimertinib (EGFR TKI), 2nd line ICI (if progression). Risk Score ~70-80 (VERY HIGH due to stage IV).
