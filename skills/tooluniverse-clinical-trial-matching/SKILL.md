---
name: tooluniverse-clinical-trial-matching
description: AI-driven patient-to-trial matching for precision medicine and oncology. Given a patient profile (disease, molecular alterations, stage, prior treatments), discovers and ranks clinical trials from ClinicalTrials.gov using multi-dimensional matching across molecular eligibility, clinical criteria, drug-biomarker alignment, evidence strength, and geographic feasibility. Produces a quantitative Trial Match Score (0-100) per trial with tiered recommendations and a comprehensive markdown report. Use when oncologists, molecular tumor boards, or patients ask about clinical trial options for specific cancer types, biomarker profiles, or post-progression scenarios.
---

# Clinical Trial Matching for Precision Medicine

Transform patient molecular profiles and clinical characteristics into prioritized clinical trial recommendations. Searches ClinicalTrials.gov and cross-references with molecular databases (CIViC, OpenTargets, ChEMBL, FDA) to produce evidence-graded, scored trial matches.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create report file FIRST, then populate progressively
2. **Patient-centric** - Every recommendation considers the individual patient's profile
3. **Molecular-first matching** - Prioritize trials targeting patient's specific biomarkers
4. **Evidence-graded** - Every recommendation has an evidence tier (T1-T4)
5. **Quantitative scoring** - Trial Match Score (0-100) for every trial
6. **Eligibility-aware** - Parse and evaluate inclusion/exclusion criteria
7. **Actionable output** - Clear next steps, contact info, enrollment status
8. **Source-referenced** - Every statement cites the tool/database source
9. **Completeness checklist** - Mandatory section showing analysis coverage
10. **English-first queries** - Always use English terms in tool calls. Respond in user's language

---

## When to Use

Apply when user asks:
- "What clinical trials are available for my NSCLC with EGFR L858R?"
- "Patient has BRAF V600E melanoma, failed ipilimumab - what trials?"
- "Find basket trials for NTRK fusion"
- "Breast cancer with HER2 amplification, post-CDK4/6 inhibitor trials"
- "KRAS G12C colorectal cancer clinical trials"
- "Immunotherapy trials for TMB-high solid tumors"
- "Clinical trials near Boston for lung cancer"
- "What are my options after failing osimertinib for EGFR+ NSCLC?"

**NOT for** (use other skills instead):
- Single variant interpretation without trial focus -> Use `tooluniverse-cancer-variant-interpretation`
- Drug safety profiling -> Use `tooluniverse-adverse-event-detection`
- Target validation -> Use `tooluniverse-drug-target-validation`
- General disease research -> Use `tooluniverse-disease-research`

---

## Input Parsing

### Required Input
- **Disease/cancer type**: Free-text disease name (e.g., "non-small cell lung cancer", "melanoma")

### Strongly Recommended
- **Molecular alterations**: One or more biomarkers (e.g., "EGFR L858R", "KRAS G12C", "PD-L1 50%", "TMB-high")
- **Stage/grade**: Disease stage (e.g., "Stage IV", "metastatic", "locally advanced")
- **Prior treatments**: Previous therapies and outcomes (e.g., "failed platinum chemotherapy", "progressed on osimertinib")

### Optional
- **Performance status**: ECOG or Karnofsky score (e.g., "ECOG 0-1")
- **Geographic location**: City/state for proximity filtering (e.g., "Boston, MA")
- **Trial phase preference**: I, II, III, IV, or "any"
- **Intervention type**: drug, biological, device, etc.
- **Recruiting status preference**: recruiting, not yet recruiting, active

### Biomarker Parsing Rules

| Input Format | Parsed As | Example |
|-------------|-----------|---------|
| Gene + amino acid change | Specific mutation | EGFR L858R |
| Gene + exon notation | Exon-level alteration | EGFR exon 19 deletion |
| Gene + fusion partner | Fusion | EML4-ALK fusion |
| Gene + amplification | Copy number gain | HER2 amplification |
| Gene + expression level | Expression biomarker | PD-L1 50% |
| Gene + status | Status biomarker | MSI-high, TMB-high |
| Gene + resistance | Resistance mutation | EGFR T790M |

### Gene Symbol Normalization

| Common Alias | Official Symbol | Notes |
|-------------|----------------|-------|
| HER2 | ERBB2 | Search both in trials |
| PD-L1 | CD274 | Often searched as "PD-L1" in trials |
| ALK | ALK | EML4-ALK is a fusion |
| VEGF | VEGFA | Often searched as "VEGF" |
| PD-1 | PDCD1 | Search as "PD-1" in trials |
| BRCA | BRCA1/BRCA2 | Specify which BRCA gene |

---

## Phase 0: Tool Parameter Reference (CRITICAL)

**BEFORE calling ANY tool**, verify its parameters from this reference table.

### Clinical Trial Tools

| Tool | Parameters | Notes |
|------|-----------|-------|
| `search_clinical_trials` | `query_term` (REQUIRED str), `condition` (str), `intervention` (str), `pageSize` (int, default 10), `pageToken` (str) | Main search. Returns `{studies: [{NCT ID, brief_title, brief_summary, overall_status, condition, phase}], nextPageToken, total_count}` |
| `clinical_trials_search` | `action` (REQUIRED, must be `"search_studies"`), `condition` (str), `intervention` (str), `limit` (int) | Alternative search. Returns `{total_count, studies: [{nctId, title, status, conditions}]}` |
| `clinical_trials_get_details` | `action` (REQUIRED, must be `"get_study_details"`), `nct_id` (REQUIRED str) | Full trial details. Returns `{nctId, title, summary, eligibility: {eligibilityCriteria}, ...}` |
| `get_clinical_trial_eligibility_criteria` | `nct_ids` (REQUIRED array), `eligibility_criteria` (REQUIRED str, use `"all"`) | Returns `[{NCT ID, eligibility_criteria}]` |
| `get_clinical_trial_locations` | `nct_ids` (REQUIRED array), `location` (REQUIRED str, use `"all"`) | Returns `[{NCT ID, locations: [{facility, city, state, country}]}]` |
| `get_clinical_trial_descriptions` | `nct_ids` (REQUIRED array), `description_type` (REQUIRED str: `"brief"` or `"full"`) | Returns `[{NCT ID, brief_title, official_title, brief_summary, detailed_description}]` |
| `get_clinical_trial_status_and_dates` | `nct_ids` (REQUIRED array), `status_and_date` (REQUIRED str, use `"all"`) | Returns `[{NCT ID, overall_status, start_date, primary_completion_date, completion_date}]` |
| `get_clinical_trial_conditions_and_interventions` | `nct_ids` (REQUIRED array), `condition_and_intervention` (REQUIRED str, use `"all"`) | Returns `[{NCT ID, condition, arm_groups, interventions}]` |
| `get_clinical_trial_outcome_measures` | `nct_ids` (REQUIRED array), `outcome_measures` (str: `"primary"`, `"secondary"`, `"all"`) | Returns `[{NCT ID, primary_outcomes, secondary_outcomes}]` |
| `extract_clinical_trial_outcomes` | `nct_ids` (REQUIRED array), `outcome_measure` (str) | Returns trial outcome results |
| `extract_clinical_trial_adverse_events` | `nct_ids` (REQUIRED array), `adverse_event_type` (str) | Returns adverse event data |

### Molecular/Disease Tools

| Tool | Parameters | Notes |
|------|-----------|-------|
| `MyGene_query_genes` | `query` (str), `species` (str) | Returns `{hits: [{symbol, entrezgene, ensembl: {gene}, name}]}` |
| `OpenTargets_get_target_id_description_by_name` | `targetName` (str) | Returns `{data: {search: {hits: [{id, name, description}]}}}` |
| `OpenTargets_get_disease_id_description_by_name` | `diseaseName` (str) | Returns `{data: {search: {hits: [{id, name, description}]}}}` |
| `OpenTargets_get_associated_drugs_by_target_ensemblID` | `ensemblId` (str), `size` (int) | Returns `{data: {target: {knownDrugs: {count, rows: [{drug: {id, name, isApproved}, phase, mechanismOfAction, disease: {id, name}}]}}}}` |
| `OpenTargets_get_associated_drugs_by_disease_efoId` | `efoId` (str), `size` (int) | Returns `{data: {disease: {knownDrugs: {count, rows: [...]}}}}` |
| `OpenTargets_get_drug_id_description_by_name` | `drugName` (str) | Returns `{data: {search: {hits: [{id, name, description}]}}}` |
| `OpenTargets_get_drug_mechanisms_of_action_by_chemblId` | `chemblId` (str) | Returns `{data: {drug: {mechanismsOfAction: {rows: [{mechanismOfAction, actionType, targetName, targets}]}}}}` |
| `OpenTargets_get_approved_indications_by_drug_chemblId` | `chemblId` (str) | Returns `{data: {drug: {approvedIndications: [efoIds]}}}` |
| `OpenTargets_target_disease_evidence` | `ensemblId` (str), `efoId` (str), `size` (int) | Returns target-disease evidence rows |

### CIViC Tools

| Tool | Parameters | Notes |
|------|-----------|-------|
| `civic_search_variants` | `query` (str), `limit` (int) | Does NOT filter by query. Returns alphabetically sorted variants |
| `civic_get_variants_by_gene` | `gene_id` (int, CIViC gene ID), `limit` (int) | Returns `{data: {gene: {variants: {nodes: [{id, name}]}}}}`. Max 100 per call |
| `civic_search_evidence_items` | `query` (str), `limit` (int) | Does NOT filter by query. Returns evidence alphabetically |
| `civic_get_variant` | `variant_id` (int) | Returns `{data: {variant: {id, name}}}` |
| `civic_search_therapies` | `query` (str), `limit` (int) | Search therapies |
| `civic_search_diseases` | `query` (str), `limit` (int) | Search diseases |

**Known CIViC Gene IDs**: EGFR=19, BRAF=5, ALK=1, ABL1=4, KRAS=30, TP53=45, ERBB2=20, NTRK1=197, NTRK2=560, NTRK3=561, PIK3CA=37, MET=52, ROS1=118, RET=122, BRCA1=2370, BRCA2=2371

### Drug Information Tools

| Tool | Parameters | Notes |
|------|-----------|-------|
| `drugbank_get_targets_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` (ALL REQUIRED) | Returns `{results: [{drug_name, drugbank_id, targets: [{name, organism, actions}]}]}` |
| `drugbank_get_indications_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` (ALL REQUIRED) | Returns drug indications |
| `ChEMBL_search_drugs` | `query` (str), `limit` (int) | Returns `{status, data: {drugs: [...]}}` |
| `ChEMBL_get_drug_mechanisms` | `drug_chembl_id__exact` (str) | Returns drug mechanisms |
| `fda_pharmacogenomic_biomarkers` | `drug_name` (opt str), `biomarker` (opt str), `limit` (opt int, default 10) | Returns `{count, shown, results: [{Drug, TherapeuticArea, Biomarker, LabelingSection}]}`. Use `limit=1000` to get all. |
| `FDA_get_indications_by_drug_name` | `drug_name` (str), `limit` (int) | Returns FDA indications text |
| `FDA_get_mechanism_of_action_by_drug_name` | `drug_name` (str), `limit` (int) | Returns FDA MoA text |
| `FDA_get_clinical_studies_info_by_drug_name` | `drug_name` (str), `limit` (int) | Returns FDA clinical study info |
| `FDA_get_adverse_reactions_by_drug_name` | `drug_name` (str), `limit` (int) | Returns adverse reactions |

### Disease Ontology Tools

| Tool | Parameters | Notes |
|------|-----------|-------|
| `ols_search_efo_terms` | `query` (str), `limit` (int) | Returns `{data: {terms: [{iri, obo_id, short_form, label, description}]}}` |
| `ols_get_efo_term` | `term_id` (str) | Get specific EFO term details |
| `ols_get_efo_term_children` | `term_id` (str) | Get child terms |

### Literature Tools

| Tool | Parameters | Notes |
|------|-----------|-------|
| `PubMed_search_articles` | `query` (str), `max_results` (int) | Returns list of `{pmid, title, abstract, authors, journal, pub_date}` |
| `openalex_literature_search` | `query` (str), `limit` (int) | Returns literature results |

### PharmGKB Tools

| Tool | Parameters | Notes |
|------|-----------|-------|
| `PharmGKB_search_genes` | `query` (str) | Returns gene pharmacogenomics data |
| `PharmGKB_get_clinical_annotations` | `query` (str) | Returns clinical annotations |

---

## Workflow Overview

```
Input: Patient profile (disease + biomarkers + stage + prior treatments)

Phase 1: Patient Profile Standardization
  - Resolve disease to EFO/ontology IDs
  - Parse molecular alterations to gene + variant
  - Resolve gene symbols to Ensembl/Entrez IDs
  - Classify biomarker actionability (FDA-approved vs investigational)

Phase 2: Broad Trial Discovery
  - Disease-based trial search (ClinicalTrials.gov)
  - Biomarker-specific trial search
  - Intervention-based search (for known drugs targeting patient's biomarkers)
  - Collect NCT IDs for detailed analysis

Phase 3: Trial Characterization
  - Get eligibility criteria for top candidate trials
  - Get conditions and interventions
  - Get locations and status
  - Get trial descriptions and phase information

Phase 4: Molecular Eligibility Matching
  - Parse eligibility criteria text for biomarker requirements
  - Match patient's molecular profile to trial requirements
  - Score molecular eligibility

Phase 5: Drug-Biomarker Alignment
  - Identify trial intervention drugs
  - Check drug mechanisms against patient biomarkers (OpenTargets, ChEMBL)
  - FDA approval status for biomarker-drug combinations
  - Classify drugs (targeted therapy, immunotherapy, chemotherapy)

Phase 6: Evidence Assessment
  - FDA-approved biomarker-drug combinations
  - Clinical trial results for similar patients (PubMed)
  - CIViC clinical evidence
  - PharmGKB pharmacogenomics
  - Drug safety profiles

Phase 7: Geographic & Feasibility Analysis
  - Trial site locations
  - Enrollment status and dates
  - Distance from patient location (if provided)

Phase 8: Alternative Options
  - Basket trials (biomarker-driven, tumor-agnostic)
  - Expanded access and compassionate use
  - Related trials with different study designs

Phase 9: Scoring & Ranking
  - Calculate Trial Match Score (0-100) for each trial
  - Tier classification (Optimal/Good/Possible/Exploratory)
  - Rank by composite score
  - Generate recommendations

Phase 10: Report Synthesis
  - Executive summary (top 3 trials)
  - Patient profile summary
  - Ranked trial list with detailed analysis
  - Alternative options
  - Evidence grading
  - Completeness checklist
```

---

## Phase 1: Patient Profile Standardization

**Goal**: Resolve all patient inputs to standardized identifiers for cross-database queries.

### 1.1 Disease Resolution

```python
def resolve_disease(tu, disease_name):
    """Resolve disease name to EFO ID and standard terminology."""
    # OpenTargets disease search
    result = tu.tools.OpenTargets_get_disease_id_description_by_name(diseaseName=disease_name)
    hits = result.get('data', {}).get('search', {}).get('hits', [])

    if hits:
        disease_info = hits[0]
        return {
            'efo_id': disease_info.get('id'),
            'name': disease_info.get('name'),
            'description': disease_info.get('description'),
            'original_input': disease_name
        }

    # Fallback: OLS EFO search
    ols_result = tu.tools.ols_search_efo_terms(query=disease_name, limit=5)
    ols_terms = ols_result.get('data', {}).get('terms', [])
    if ols_terms:
        term = ols_terms[0]
        return {
            'efo_id': term.get('short_form'),
            'name': term.get('label'),
            'description': term.get('description', [''])[0] if term.get('description') else '',
            'original_input': disease_name
        }

    return {'efo_id': None, 'name': disease_name, 'description': '', 'original_input': disease_name}
```

**Response**: `{efo_id: "EFO_0003060", name: "non-small cell lung carcinoma", description: "...", original_input: "..."}`

### 1.2 Gene/Biomarker Resolution

```python
def resolve_gene(tu, gene_symbol):
    """Resolve gene symbol to cross-database IDs."""
    # Normalize common aliases
    alias_map = {
        'HER2': 'ERBB2', 'HER-2': 'ERBB2',
        'PD-L1': 'CD274', 'PDL1': 'CD274',
        'PD-1': 'PDCD1', 'PD1': 'PDCD1',
        'VEGF': 'VEGFA',
    }
    normalized = alias_map.get(gene_symbol.upper(), gene_symbol)

    # MyGene resolution
    result = tu.tools.MyGene_query_genes(query=normalized, species='human')
    hits = result.get('hits', [])

    gene_hit = None
    for hit in hits:
        if hit.get('symbol', '').upper() == normalized.upper():
            gene_hit = hit
            break
    if not gene_hit and hits:
        gene_hit = hits[0]

    if gene_hit:
        ensembl = gene_hit.get('ensembl', {})
        ensembl_id = ensembl.get('gene') if isinstance(ensembl, dict) else (ensembl[0].get('gene') if isinstance(ensembl, list) and ensembl else None)
        return {
            'symbol': gene_hit.get('symbol'),
            'entrez_id': gene_hit.get('entrezgene'),
            'ensembl_id': ensembl_id,
            'name': gene_hit.get('name'),
            'original_input': gene_symbol
        }

    return {'symbol': gene_symbol, 'entrez_id': None, 'ensembl_id': None, 'name': None, 'original_input': gene_symbol}
```

### 1.3 Biomarker Actionability Classification

Classify each biomarker using FDA pharmacogenomic biomarkers list:

```python
def classify_biomarker_actionability(tu, gene_symbol, alteration):
    """Classify biomarker as FDA-approved, guideline, or investigational."""
    # Check FDA pharmacogenomic biomarkers
    fda_result = tu.tools.fda_pharmacogenomic_biomarkers()
    fda_biomarkers = fda_result.get('results', [])

    fda_match = [b for b in fda_biomarkers if gene_symbol.upper() in str(b.get('Biomarker', '')).upper()]

    if fda_match:
        return {
            'level': 'FDA-approved',
            'drugs': [b.get('Drug') for b in fda_match],
            'labeling_sections': [b.get('LabelingSection') for b in fda_match]
        }

    # Check OpenTargets for drugs targeting this gene
    # (done in Phase 5)

    return {'level': 'investigational', 'drugs': [], 'labeling_sections': []}
```

### 1.4 Parse Molecular Alterations

```python
def parse_biomarker(biomarker_text):
    """Parse free-text biomarker into structured components."""
    import re

    # Pattern: "GENE VARIANT" (e.g., "EGFR L858R")
    mutation_match = re.match(r'(\w+)\s+([A-Z]\d+[A-Z])', biomarker_text, re.IGNORECASE)
    if mutation_match:
        return {'gene': mutation_match.group(1), 'alteration': mutation_match.group(2), 'type': 'mutation'}

    # Pattern: "GENE exon N deletion/insertion"
    exon_match = re.match(r'(\w+)\s+exon\s+(\d+)\s+(\w+)', biomarker_text, re.IGNORECASE)
    if exon_match:
        return {'gene': exon_match.group(1), 'alteration': f'exon {exon_match.group(2)} {exon_match.group(3)}', 'type': 'exon_alteration'}

    # Pattern: "GENE1-GENE2 fusion" or "GENE1/GENE2"
    fusion_match = re.match(r'(\w+)[-/](\w+)\s*(fusion)?', biomarker_text, re.IGNORECASE)
    if fusion_match:
        return {'gene': fusion_match.group(2), 'alteration': f'{fusion_match.group(1)}-{fusion_match.group(2)}', 'type': 'fusion', 'partner': fusion_match.group(1)}

    # Pattern: "GENE amplification"
    amp_match = re.match(r'(\w+)\s+amplification', biomarker_text, re.IGNORECASE)
    if amp_match:
        return {'gene': amp_match.group(1), 'alteration': 'amplification', 'type': 'amplification'}

    # Pattern: "PD-L1 XX%"
    expression_match = re.match(r'([\w-]+)\s+(\d+%|high|low|positive|negative)', biomarker_text, re.IGNORECASE)
    if expression_match:
        return {'gene': expression_match.group(1), 'alteration': expression_match.group(2), 'type': 'expression'}

    # Pattern: "MSI-high", "TMB-high"
    status_match = re.match(r'(MSI|TMB|dMMR|MMR)[-\s]*(high|low|stable|deficient|proficient)', biomarker_text, re.IGNORECASE)
    if status_match:
        return {'gene': status_match.group(1), 'alteration': status_match.group(2), 'type': 'status'}

    # Fallback: treat as gene name
    return {'gene': biomarker_text.split()[0], 'alteration': ' '.join(biomarker_text.split()[1:]), 'type': 'unknown'}
```

---

## Phase 2: Broad Trial Discovery

**Goal**: Cast a wide net to find all potentially relevant clinical trials.

### 2.1 Disease-Based Trial Search

```python
def search_trials_by_disease(tu, disease_name, status_filter=None, phase_filter=None, page_size=20):
    """Search ClinicalTrials.gov by disease/condition."""
    query_parts = []
    if status_filter:
        query_parts.append(f'AREA[OverallStatus]{status_filter}')
    if phase_filter:
        query_parts.append(phase_filter)

    query_term = ' AND '.join(query_parts) if query_parts else disease_name

    result = tu.tools.search_clinical_trials(
        condition=disease_name,
        query_term=query_term if query_parts else disease_name,
        pageSize=page_size
    )

    # Response: {studies: [{NCT ID, brief_title, brief_summary, overall_status, condition, phase}], nextPageToken, total_count}
    if isinstance(result, str):
        return []  # No studies found

    return result.get('studies', [])
```

### 2.2 Biomarker-Specific Trial Search

```python
def search_trials_by_biomarker(tu, gene_symbol, alteration, disease_name=None, page_size=15):
    """Search trials mentioning specific biomarkers."""
    # Search 1: Gene + alteration
    biomarker_query = f'{gene_symbol} {alteration}' if alteration else gene_symbol

    result = tu.tools.search_clinical_trials(
        condition=disease_name if disease_name else '',
        query_term=biomarker_query,
        pageSize=page_size
    )

    if isinstance(result, str):
        return []

    return result.get('studies', [])
```

### 2.3 Intervention-Based Trial Search

```python
def search_trials_by_intervention(tu, drug_name, disease_name=None, page_size=10):
    """Search trials by intervention/drug name."""
    result = tu.tools.search_clinical_trials(
        condition=disease_name if disease_name else '',
        intervention=drug_name,
        query_term=drug_name,
        pageSize=page_size
    )

    if isinstance(result, str):
        return []

    return result.get('studies', [])
```

### 2.4 Alternative Search (clinical_trials_search)

Use as a complement to the main search:

```python
def search_trials_alternative(tu, condition, intervention=None, limit=10):
    """Alternative trial search with different API endpoint."""
    params = {
        'action': 'search_studies',
        'condition': condition,
        'limit': limit
    }
    if intervention:
        params['intervention'] = intervention

    result = tu.tools.clinical_trials_search(**params)

    return result.get('studies', [])
```

### 2.5 Deduplication

```python
def deduplicate_trials(trial_lists):
    """Merge and deduplicate trials from multiple searches."""
    seen_ncts = set()
    unique_trials = []

    for trials in trial_lists:
        for trial in trials:
            nct = trial.get('NCT ID') or trial.get('nctId', '')
            if nct and nct not in seen_ncts:
                seen_ncts.add(nct)
                unique_trials.append(trial)

    return unique_trials
```

---

## Phase 3: Trial Characterization

**Goal**: Get detailed information for the top candidate trials.

### 3.1 Get Eligibility Criteria (Batch)

```python
def get_trial_eligibility(tu, nct_ids):
    """Get eligibility criteria for multiple trials."""
    # Process in batches of 10
    all_criteria = []
    for i in range(0, len(nct_ids), 10):
        batch = nct_ids[i:i+10]
        result = tu.tools.get_clinical_trial_eligibility_criteria(
            nct_ids=batch,
            eligibility_criteria='all'
        )
        if isinstance(result, list):
            all_criteria.extend(result)

    return all_criteria
    # Returns: [{NCT ID, eligibility_criteria: "Inclusion Criteria:\n...\nExclusion Criteria:\n..."}]
```

### 3.2 Get Conditions and Interventions (Batch)

```python
def get_trial_interventions(tu, nct_ids):
    """Get conditions, arm groups, and interventions for multiple trials."""
    all_interventions = []
    for i in range(0, len(nct_ids), 10):
        batch = nct_ids[i:i+10]
        result = tu.tools.get_clinical_trial_conditions_and_interventions(
            nct_ids=batch,
            condition_and_intervention='all'
        )
        if isinstance(result, list):
            all_interventions.extend(result)

    return all_interventions
    # Returns: [{NCT ID, condition, arm_groups: [{label, type, description, interventionNames}], interventions: [{type, name, description}]}]
```

### 3.3 Get Locations (Batch)

```python
def get_trial_locations(tu, nct_ids):
    """Get trial site locations."""
    all_locations = []
    for i in range(0, len(nct_ids), 10):
        batch = nct_ids[i:i+10]
        result = tu.tools.get_clinical_trial_locations(
            nct_ids=batch,
            location='all'
        )
        if isinstance(result, list):
            all_locations.extend(result)

    return all_locations
    # Returns: [{NCT ID, locations: [{facility, city, state, country}]}]
```

### 3.4 Get Status and Dates (Batch)

```python
def get_trial_status(tu, nct_ids):
    """Get enrollment status and key dates."""
    all_status = []
    for i in range(0, len(nct_ids), 10):
        batch = nct_ids[i:i+10]
        result = tu.tools.get_clinical_trial_status_and_dates(
            nct_ids=batch,
            status_and_date='all'
        )
        if isinstance(result, list):
            all_status.extend(result)

    return all_status
    # Returns: [{NCT ID, overall_status, start_date, primary_completion_date, completion_date}]
```

### 3.5 Get Full Descriptions (Batch)

```python
def get_trial_descriptions(tu, nct_ids):
    """Get detailed trial descriptions."""
    all_descriptions = []
    for i in range(0, len(nct_ids), 10):
        batch = nct_ids[i:i+10]
        result = tu.tools.get_clinical_trial_descriptions(
            nct_ids=batch,
            description_type='full'
        )
        if isinstance(result, list):
            all_descriptions.extend(result)

    return all_descriptions
    # Returns: [{NCT ID, brief_title, official_title, brief_summary, detailed_description}]
```

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-clinical-trial-matching/REFERENCE.md`
