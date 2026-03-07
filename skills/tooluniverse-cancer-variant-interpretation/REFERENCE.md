# tooluniverse-cancer-variant-interpretation — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Completeness Checklist

- [ ] Gene resolved to Ensembl, UniProt, and Entrez IDs
- [ ] Clinical variant evidence queried (CIViC or alternative)
- [ ] Mutation prevalence assessed (cBioPortal, at least 1 study)
- [ ] At least 1 therapeutic option identified with evidence tier, OR documented as "no targeted therapy available"
- [ ] FDA label information retrieved for recommended drugs
- [ ] Resistance mechanisms assessed (known patterns + literature search)
- [ ] At least 3 clinical trials listed, OR "no matching trials found"
- [ ] Prognostic literature searched
- [ ] Pathway context provided (Reactome)
- [ ] Executive summary is actionable (says what to DO)
- [ ] All recommendations have source citations
- [ ] Evidence tiers assigned to all findings
```

---

## Evidence Grading System

| Tier | Symbol | Criteria | Examples |
|------|--------|----------|---------|
| **T1** | [T1] | FDA-approved therapy, Level A CIViC evidence, phase 3 trial | Osimertinib for EGFR T790M |
| **T2** | [T2] | Phase 2/3 clinical data, Level B CIViC evidence | Combination trial data |
| **T3** | [T3] | Preclinical data, Level D CIViC, case reports | Novel mechanisms, in vitro |
| **T4** | [T4] | Computational prediction, pathway inference | Docking, pathway analysis |

---

## Clinical Actionability Scoring

| Score | Criteria |
|-------|----------|
| **HIGH** | FDA-approved targeted therapy exists for this exact mutation + cancer type |
| **MODERATE** | Approved therapy exists for different cancer type with same mutation, OR phase 2-3 trial data |
| **LOW** | Only preclinical evidence or pathway-based rationale |
| **UNKNOWN** | Insufficient data to assess actionability |

---

## Fallback Chains

| Primary Tool | Fallback | Use When |
|-------------|----------|----------|
| CIViC variant lookup | PubMed literature search | Gene not found in CIViC (search doesn't filter) |
| OpenTargets drugs | ChEMBL drug search | No OpenTargets drug hits |
| FDA indications | DrugBank drug info | Drug not in FDA database |
| cBioPortal TCGA study | cBioPortal pan-cancer | Specific cancer study not available |
| GTEx expression | Ensembl gene lookup | GTEx returns empty |
| Reactome pathways | UniProt function | Pathway mapping fails |

---

## Tool Reference (Verified Parameters)

### Gene Resolution

| Tool | Parameters | Response Key Fields |
|------|-----------|-------------------|
| `MyGene_query_genes` | `query` (required), `species` | `hits[].symbol`, `hits[].ensembl.gene`, `hits[].entrezgene` |
| `UniProt_search` | `query` (required), `organism`, `limit` | `results[].accession`, `results[].gene_names` |
| `OpenTargets_get_target_id_description_by_name` | `targetName` (required) | `data.search.hits[].id` (ensemblId) |
| `ensembl_lookup_gene` | `gene_id` (required), `species` (REQUIRED: 'homo_sapiens') | `data.id`, `data.display_name`, `data.version` |

### Clinical Evidence

| Tool | Parameters | Response Key Fields |
|------|-----------|-------------------|
| `civic_search_genes` | `query`, `limit` | `data.genes.nodes[].id`, `.name`, `.entrezId` |
| `civic_get_variants_by_gene` | `gene_id` (required, CIViC numeric), `limit` | `data.gene.variants.nodes[].id`, `.name` |
| `civic_get_variant` | `variant_id` (required) | `data.variant.id`, `.name` |
| `civic_get_molecular_profile` | `molecular_profile_id` (required) | `data.molecularProfile.id`, `.name` |

### Mutation Prevalence

| Tool | Parameters | Response Key Fields |
|------|-----------|-------------------|
| `cBioPortal_get_mutations` | `study_id`, `gene_list` | `data[].proteinChange`, `.mutationType`, `.sampleId` (wrapped in `{status, data}`) |
| `cBioPortal_get_cancer_studies` | `limit` | `[].studyId`, `.name`, `.cancerTypeId` |
| `cBioPortal_get_molecular_profiles` | `study_id` (required) | `[].molecularProfileId`, `.molecularAlterationType` |

### Drug Information

| Tool | Parameters | Response Key Fields |
|------|-----------|-------------------|
| `OpenTargets_get_associated_drugs_by_target_ensemblID` | `ensemblId` (required), `size` | `data.target.knownDrugs.rows[].drug.name`, `.isApproved`, `.mechanismOfAction` |
| `OpenTargets_get_drug_chembId_by_generic_name` | `drugName` (required) | `data.search.hits[].id` (ChEMBL ID), `.name` |
| `FDA_get_indications_by_drug_name` | `drug_name`, `limit` | `results[].indications_and_usage`, `.openfda.brand_name` |
| `FDA_get_mechanism_of_action_by_drug_name` | `drug_name`, `limit` | `results[].mechanism_of_action` |
| `FDA_get_boxed_warning_info_by_drug_name` | `drug_name`, `limit` | `results[].boxed_warning` |
| `drugbank_get_drug_basic_info_by_drug_name_or_id` | `query`, `case_sensitive`, `exact_match`, `limit` (ALL required) | `results[].drug_name`, `.drugbank_id`, `.description` |
| `ChEMBL_get_drug_mechanisms` | `drug_chembl_id__exact` (required), `limit` | `data.mechanisms[]` |
| `drugbank_get_pharmacology_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` (ALL required) | `results[].pharmacology` |

### Clinical Trials

| Tool | Parameters | Response Key Fields |
|------|-----------|-------------------|
| `search_clinical_trials` | `query_term` (required), `condition`, `intervention`, `pageSize` | `studies[].NCT ID`, `.brief_title`, `.overall_status`, `.phase` |

### Literature & Pathways

| Tool | Parameters | Response Key Fields |
|------|-----------|-------------------|
| `PubMed_search_articles` | `query` (required), `limit`, `include_abstract` | Returns **list** of `[{pmid, title, authors, journal, pub_date, doi, abstract}]` (NOT wrapped in dict) |
| `Reactome_map_uniprot_to_pathways` | `id` (required, UniProt accession) | Pathway mappings |
| `GTEx_get_median_gene_expression` | `gencode_id` (required), `operation="median"` | Expression by tissue |
| `UniProt_get_function_by_accession` | `accession` (required) | Protein function |
| `UniProt_get_disease_variants_by_accession` | `accession` (required) | Disease variants |

---

## Common Use Cases

### Use Case 1: Oncologist Evaluating Treatment Options

**Input**: "EGFR L858R in lung adenocarcinoma"

**Expected Output**: Report showing osimertinib as 1st-line [T1], with FDA label details, resistance pattern (T790M), clinical trials for combination therapies, and prognostic context.

### Use Case 2: Molecular Tumor Board Preparation

**Input**: "BRAF V600E, colorectal cancer"

**Expected Output**: Report noting that BRAF V600E is actionable in melanoma but requires combination therapy in CRC (encorafenib + cetuximab), with different resistance patterns than melanoma.

### Use Case 3: Clinical Trial Matching

**Input**: "KRAS G12C, any cancer type"

**Expected Output**: Report with sotorasib/adagrasib as approved options [T1], comprehensive trial listing for KRAS G12C inhibitors, resistance patterns (Y96D, etc.), and mutation prevalence across cancer types.

### Use Case 4: Resistance Mechanism Investigation

**Input**: "EGFR T790M after osimertinib failure"

**Expected Output**: Report focused on C797S resistance mutation, available 4th-generation TKI trials, amivantamab/lazertinib combinations, and bypass pathway mechanisms (MET amplification, HER2 activation).

### Use Case 5: VUS Interpretation

**Input**: "PIK3CA E545K"

**Expected Output**: Report showing this is a known hotspot oncogenic mutation (not a VUS), with alpelisib as FDA-approved therapy for HR+/HER2- breast cancer, and prevalence data across cancer types.

---

## Quantified Minimums

| Section | Requirement |
|---------|-------------|
| Gene IDs | At least Ensembl + UniProt resolved |
| Clinical evidence | CIViC queried + PubMed literature search |
| Mutation prevalence | At least 1 cBioPortal study |
| Therapeutic options | All approved drugs listed (OpenTargets) + FDA label for top drugs |
| Resistance | Literature search performed + known patterns documented |
| Clinical trials | At least 1 search query executed |
| Prognostic impact | PubMed literature search performed |
| Pathway context | Reactome pathway mapping attempted |

---

## See Also

- `QUICK_START.md` - Example usage and quick reference
- `TOOLS_REFERENCE.md` - Detailed tool parameter reference
- `EXAMPLES.md` - Complete example reports
