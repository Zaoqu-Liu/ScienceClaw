# tooluniverse-clinical-trial-matching — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 4: Molecular Eligibility Matching

**Goal**: Determine how well the patient's molecular profile matches each trial's requirements.

### 4.1 Parse Eligibility Text for Biomarker Requirements

```python
def extract_biomarker_requirements(eligibility_text):
    """Extract biomarker requirements from eligibility criteria text."""
    import re

    requirements = {
        'required_biomarkers': [],
        'excluded_biomarkers': [],
        'biomarker_agnostic': False
    }

    if not eligibility_text:
        return requirements

    text_upper = eligibility_text.upper()

    # Common biomarker patterns in eligibility text
    # Required biomarkers (in inclusion criteria)
    inclusion_section = eligibility_text.split('Exclusion Criteria')[0] if 'Exclusion Criteria' in eligibility_text else eligibility_text
    exclusion_section = eligibility_text.split('Exclusion Criteria')[1] if 'Exclusion Criteria' in eligibility_text else ''

    # Look for gene mutation requirements
    gene_patterns = [
        r'(?:EGFR|KRAS|BRAF|ALK|ROS1|RET|MET|NTRK|HER2|ERBB2|PIK3CA|BRCA|PD-?L1|MSI|TMB|dMMR)',
    ]

    for pattern in gene_patterns:
        # In inclusion section
        for match in re.finditer(pattern, inclusion_section, re.IGNORECASE):
            gene = match.group(0).upper()
            context = inclusion_section[max(0, match.start()-100):match.end()+100]
            requirements['required_biomarkers'].append({
                'gene': gene,
                'context': context.strip()
            })

        # In exclusion section
        for match in re.finditer(pattern, exclusion_section, re.IGNORECASE):
            gene = match.group(0).upper()
            context = exclusion_section[max(0, match.start()-100):match.end()+100]
            requirements['excluded_biomarkers'].append({
                'gene': gene,
                'context': context.strip()
            })

    # Check for biomarker-agnostic / basket trial language
    basket_terms = ['tumor-agnostic', 'histology-independent', 'basket', 'any solid tumor', 'all comers', 'biomarker-selected']
    if any(term in text_upper.lower() for term in basket_terms):
        requirements['biomarker_agnostic'] = True

    return requirements
```

### 4.2 Score Molecular Match

```python
def score_molecular_match(patient_biomarkers, trial_requirements):
    """Score molecular match between patient and trial (0-40 points)."""
    if not trial_requirements['required_biomarkers'] and not trial_requirements['excluded_biomarkers']:
        # No molecular criteria - could be open to any
        return 10, 'No specific molecular criteria (general trial)'

    patient_genes = {b['gene'].upper() for b in patient_biomarkers}
    required_genes = {b['gene'].upper() for b in trial_requirements['required_biomarkers']}
    excluded_genes = {b['gene'].upper() for b in trial_requirements['excluded_biomarkers']}

    # Check exclusions first
    excluded_match = patient_genes & excluded_genes
    if excluded_match:
        return 0, f'Patient biomarker(s) {excluded_match} are in exclusion criteria'

    if not required_genes:
        return 10, 'No specific biomarker requirements found'

    # Check for exact gene match
    matched_genes = patient_genes & required_genes
    if matched_genes:
        # Check for specific variant match
        # Look for specific mutation mentions in context
        exact_variant_match = False
        for req in trial_requirements['required_biomarkers']:
            for pb in patient_biomarkers:
                if pb['gene'].upper() == req['gene'].upper():
                    alt = pb.get('alteration', '').upper()
                    if alt and alt in req.get('context', '').upper():
                        exact_variant_match = True
                        break

        if exact_variant_match:
            return 40, f'Exact biomarker match: {matched_genes} with specific variant'
        else:
            return 30, f'Gene-level match: {matched_genes} (specific variant match unclear)'

    # Check for pathway-level match (e.g., trial targets EGFR pathway, patient has EGFR mutation)
    # This requires domain knowledge mapping
    return 5, 'No direct biomarker match found'
```

---

## Phase 5: Drug-Biomarker Alignment

**Goal**: Verify that trial drugs actually target the patient's biomarkers.

### 5.1 Identify Trial Drugs and Mechanisms

```python
def get_drug_mechanism_info(tu, drug_name):
    """Get drug mechanism, targets, and approval status."""
    # Step 1: Resolve drug in OpenTargets
    result = tu.tools.OpenTargets_get_drug_id_description_by_name(drugName=drug_name)
    hits = result.get('data', {}).get('search', {}).get('hits', [])

    if not hits:
        return {'drug_name': drug_name, 'chembl_id': None, 'mechanisms': [], 'is_approved': False}

    drug_info = hits[0]
    chembl_id = drug_info.get('id')

    # Step 2: Get mechanisms of action
    moa_result = tu.tools.OpenTargets_get_drug_mechanisms_of_action_by_chemblId(chemblId=chembl_id)
    moa_rows = moa_result.get('data', {}).get('drug', {}).get('mechanismsOfAction', {}).get('rows', [])

    mechanisms = []
    for row in moa_rows:
        targets = row.get('targets', [])
        mechanisms.append({
            'mechanism': row.get('mechanismOfAction'),
            'action_type': row.get('actionType'),
            'target_name': row.get('targetName'),
            'target_genes': [t.get('approvedSymbol') for t in targets]
        })

    # Step 3: Check approval
    approval_result = tu.tools.OpenTargets_get_drug_approval_status_by_chemblId(chemblId=chembl_id)

    return {
        'drug_name': drug_name,
        'chembl_id': chembl_id,
        'description': drug_info.get('description'),
        'mechanisms': mechanisms,
        'is_approved': 'approved' in drug_info.get('description', '').lower()
    }
```

### 5.2 Score Drug-Biomarker Alignment

```python
def score_drug_biomarker_alignment(patient_gene_symbols, drug_mechanisms):
    """Check if trial drug targets patient's biomarkers."""
    patient_genes_upper = {g.upper() for g in patient_gene_symbols}

    for mech in drug_mechanisms:
        target_genes = {g.upper() for g in mech.get('target_genes', [])}
        if patient_genes_upper & target_genes:
            return True, f"Drug targets {patient_genes_upper & target_genes} via {mech.get('mechanism')}"

    return False, "No direct target overlap with patient biomarkers"
```

---

## Phase 6: Evidence Assessment

**Goal**: Assess evidence strength for drug efficacy in similar patient populations.

### 6.1 FDA Approval Evidence

```python
def check_fda_approval(tu, drug_name, disease_name):
    """Check FDA approval status and labeled indications."""
    result = tu.tools.FDA_get_indications_by_drug_name(drug_name=drug_name, limit=3)

    indications = result.get('results', [])
    for ind in indications:
        ind_text = str(ind.get('indications_and_usage', ''))
        # Check if disease is mentioned in indications
        if any(term.lower() in ind_text.lower() for term in disease_name.split()):
            return {
                'approved': True,
                'indication_text': ind_text[:500],
                'brand_name': ind.get('openfda.brand_name', []),
                'evidence_tier': 'T1'
            }

    return {'approved': False, 'indication_text': '', 'brand_name': [], 'evidence_tier': 'T3'}
```

### 6.2 Literature Evidence

```python
def get_literature_evidence(tu, gene, alteration, drug_name, disease_name):
    """Search PubMed for evidence of drug efficacy for this biomarker."""
    query = f'{gene} {alteration} {drug_name} {disease_name} clinical trial'
    result = tu.tools.PubMed_search_articles(query=query, max_results=5)

    articles = result if isinstance(result, list) else result.get('articles', [])
    return articles
```

### 6.3 CIViC Evidence (if available)

```python
def get_civic_evidence(tu, gene_symbol, civic_gene_id):
    """Get CIViC clinical evidence for gene variants."""
    if not civic_gene_id:
        return []

    result = tu.tools.civic_get_variants_by_gene(gene_id=civic_gene_id, limit=100)
    variants = result.get('data', {}).get('gene', {}).get('variants', {}).get('nodes', [])
    return variants
```

### 6.4 Evidence Tier Classification

| Tier | Symbol | Criteria | Score Impact |
|------|--------|----------|-------------|
| **T1** | [T1] | FDA-approved biomarker-drug, NCCN guideline | 20 points |
| **T2** | [T2] | Phase III positive, clinical evidence | 15 points |
| **T3** | [T3] | Phase I/II results, preclinical | 10 points |
| **T4** | [T4] | Computational, mechanism inference | 5 points |

---

## Phase 7: Geographic & Feasibility Analysis

**Goal**: Assess practical feasibility of trial enrollment.

### 7.1 Location Analysis

```python
def analyze_trial_locations(locations_data, patient_location=None):
    """Analyze trial site locations and proximity."""
    if not locations_data:
        return {'total_sites': 0, 'countries': [], 'us_states': [], 'nearest': None}

    locations = locations_data.get('locations', [])
    countries = list(set(loc.get('country', '') for loc in locations if loc.get('country')))
    us_states = list(set(loc.get('state', '') for loc in locations if loc.get('country') == 'United States' and loc.get('state')))

    return {
        'total_sites': len(locations),
        'countries': countries,
        'us_states': us_states,
        'has_us_sites': 'United States' in countries,
        'locations': locations[:10]  # First 10 for display
    }
```

### 7.2 Geographic Scoring

| Criterion | Points |
|-----------|--------|
| Trial sites in patient's state/city | 5 |
| Trial sites within 100 miles | 3 |
| Trial sites in same country | 1 |
| No location info or far away | 0 |

---

## Phase 8: Alternative Options

**Goal**: Identify basket trials, expanded access, and related studies.

### 8.1 Basket Trial Search

**IMPORTANT**: ClinicalTrials.gov search is sensitive to query complexity. Overly specific queries like "NTRK fusion tumor agnostic" may return zero results. Use simpler queries and combine results.

```python
def search_basket_trials(tu, biomarker, page_size=10):
    """Search for basket/biomarker-driven trials.

    NOTE: Use simpler queries first (e.g., 'NTRK solid tumor'),
    then more specific ones. Complex multi-word queries often fail.
    """
    # Start with simpler queries (more likely to return results)
    query_terms = [
        f'{biomarker} solid tumor',
        f'{biomarker}',
        f'{biomarker} basket',
    ]

    all_trials = []
    for query in query_terms:
        result = tu.tools.search_clinical_trials(
            query_term=query,
            pageSize=page_size
        )
        if not isinstance(result, str):
            all_trials.extend(result.get('studies', []))

    return deduplicate_trials([all_trials])
```

### 8.2 Expanded Access Search

```python
def search_expanded_access(tu, drug_name):
    """Search for expanded access / compassionate use programs."""
    result = tu.tools.search_clinical_trials(
        query_term=f'{drug_name} expanded access',
        pageSize=5
    )

    if isinstance(result, str):
        return []

    return result.get('studies', [])
```

---

## Phase 9: Trial Match Scoring System

### Score Components (Total: 0-100)

**Molecular Match** (0-40 points):
| Criterion | Points | Description |
|-----------|--------|-------------|
| Exact biomarker match | 40 | Trial requires patient's specific variant |
| Gene-level match | 30 | Trial requires gene mutation, patient has specific variant |
| Pathway match | 20 | Trial targets same pathway as patient's biomarker |
| No molecular criteria | 10 | General disease trial |
| Excluded biomarker | 0 | Patient's biomarker is in exclusion criteria |

**Clinical Eligibility** (0-25 points):
| Criterion | Points | Description |
|-----------|--------|-------------|
| All criteria met | 25 | Disease, stage, prior treatment all match |
| Most criteria met | 18 | 1-2 criteria unclear |
| Some criteria met | 10 | Several criteria unclear |
| Clearly ineligible | 0 | Fails major criterion |

**Evidence Strength** (0-20 points):
| Criterion | Points | Description |
|-----------|--------|-------------|
| FDA-approved combination | 20 | T1 evidence |
| Phase III positive | 15 | T2 evidence |
| Phase II promising | 10 | T3 evidence |
| Phase I or no results | 5 | T4 evidence |

**Trial Phase** (0-10 points):
| Phase | Points |
|-------|--------|
| Phase III | 10 |
| Phase II | 8 |
| Phase I/II | 6 |
| Phase I | 4 |

**Geographic Feasibility** (0-5 points):
| Criterion | Points |
|-----------|--------|
| Patient's city/state | 5 |
| Same country | 3 |
| International only | 1 |
| Unknown | 0 |

### Recommendation Tiers

| Score | Tier | Label | Action |
|-------|------|-------|--------|
| **80-100** | Tier 1 | Optimal Match | Strongly recommend - contact site immediately |
| **60-79** | Tier 2 | Good Match | Recommend - discuss with care team |
| **40-59** | Tier 3 | Possible Match | Consider - needs further eligibility review |
| **0-39** | Tier 4 | Exploratory | Backup option - consider if Tier 1-3 unavailable |

---

## Phase 10: Report Synthesis

### Report Template

The final report should follow this structure:

```markdown
# Clinical Trial Matching Report

**Patient**: [Disease type] with [biomarker(s)]
**Date**: [Current date]
**Trials Analyzed**: [N total] | **Top Matches**: [N with score >= 60]

---

## Executive Summary

**Top 3 Trial Recommendations**:

1. **[NCT ID]** - [Brief title] (Score: XX/100, Tier N)
   - Phase: [Phase], Status: [Status]
   - Why: [Key reason for match]

2. **[NCT ID]** - [Brief title] (Score: XX/100, Tier N)
   ...

3. **[NCT ID]** - [Brief title] (Score: XX/100, Tier N)
   ...

---

## Patient Profile Summary

| Parameter | Value | Standardized |
|-----------|-------|-------------|
| Disease | [input] | [EFO name] (EFO_XXXX) |
| Biomarker(s) | [input] | [gene: variant, type] |
| Stage | [input] | [standardized] |
| Prior Treatment | [input] | [standardized] |
| Performance Status | [input] | [ECOG score] |
| Location | [input] | [city, state] |

### Biomarker Actionability
| Biomarker | Actionability Level | FDA-Approved Drugs | Evidence |
|-----------|--------------------|--------------------|----------|
| [gene variant] | [FDA-approved/investigational] | [drugs] | [T1/T2/T3/T4] |

---

## Ranked Trial Matches

### Trial 1: [NCT ID] - [Title]

**Trial Match Score: XX/100** (Tier N: [Label])

| Component | Score | Details |
|-----------|-------|---------|
| Molecular Match | XX/40 | [explanation] |
| Clinical Eligibility | XX/25 | [explanation] |
| Evidence Strength | XX/20 | [explanation] |
| Trial Phase | XX/10 | [phase] |
| Geographic | XX/5 | [location info] |

**Trial Details**:
- **Phase**: [Phase]
- **Status**: [Recruiting/Active/etc.]
- **Sponsor**: [Sponsor]
- **Start Date**: [Date]
- **Estimated Completion**: [Date]

**Interventions**:
- [Drug name]: [Mechanism] | [Dosing info if available]
- [Comparator]: [Description]

**Molecular Eligibility Match**:
- Required biomarkers: [list]
- Patient match: [Exact/Gene-level/Pathway/None]
- Notes: [details]

**Clinical Eligibility Assessment**:
- Disease type: [Match/Mismatch]
- Stage: [Match/Mismatch/Unclear]
- Prior treatment: [Match/Mismatch/Unclear]
- Performance status: [Match/Mismatch/Unclear]

**Evidence for Efficacy**:
- FDA approval: [Yes/No for this indication]
- Clinical results: [Phase III/II/I data if available]
- Mechanism alignment: [Drug targets patient's biomarker: Yes/No]
- Literature: [Key references]

**Trial Sites** (first 5):
- [City, State, Country]
- ...

**Next Steps**: [Contact info, enrollment instructions]

[Repeat for each matched trial]

---

## Trials by Category

### Targeted Therapy Trials
[List trials with targeted agents matching patient's biomarkers]

### Immunotherapy Trials
[List immunotherapy trials, noting PD-L1/TMB/MSI requirements]

### Combination Therapy Trials
[List trials with drug combinations]

### Basket/Platform Trials
[List biomarker-agnostic or multi-arm trials]

---

## Additional Testing Recommendations

If the patient has not been tested for certain biomarkers, these trials would become relevant:

| Biomarker | Test Needed | Trials Unlocked | Priority |
|-----------|-------------|----------------|----------|
| [e.g., TMB] | [NGS panel] | [NCT IDs] | [High/Medium/Low] |

---

## Alternative Options

### Expanded Access Programs
[List any expanded access or compassionate use programs]

### Off-Label Options
[FDA-approved drugs for other indications with same biomarker]

---

## Evidence Grading Summary

| Evidence Tier | Count | Description |
|--------------|-------|-------------|
| T1 (FDA/Guideline) | N | FDA-approved biomarker-drug, clinical guideline |
| T2 (Clinical) | N | Phase III data, robust clinical evidence |
| T3 (Emerging) | N | Phase I/II, preclinical evidence |
| T4 (Exploratory) | N | Computational, mechanism inference |

---

## Completeness Checklist

| Analysis Step | Status | Source |
|--------------|--------|--------|
| Disease standardization | [Done/Partial/Failed] | [OpenTargets/OLS] |
| Gene resolution | [Done/Partial/Failed] | [MyGene] |
| Biomarker actionability | [Done/Partial/Failed] | [FDA biomarkers] |
| Disease trial search | [Done/Partial/Failed] | [ClinicalTrials.gov] |
| Biomarker trial search | [Done/Partial/Failed] | [ClinicalTrials.gov] |
| Intervention trial search | [Done/Partial/Failed] | [ClinicalTrials.gov] |
| Eligibility parsing | [Done/Partial/Failed] | [ClinicalTrials.gov] |
| Drug mechanism analysis | [Done/Partial/Failed] | [OpenTargets/ChEMBL] |
| Evidence assessment | [Done/Partial/Failed] | [FDA/PubMed/CIViC] |
| Location analysis | [Done/Partial/Failed] | [ClinicalTrials.gov] |
| Basket trial search | [Done/Partial/Failed] | [ClinicalTrials.gov] |
| Expanded access search | [Done/Partial/Failed] | [ClinicalTrials.gov] |
| Scoring & ranking | [Done/Partial/Failed] | [Composite] |

---

## Disclaimer

This report is for informational and research purposes only. Clinical trial eligibility is ultimately determined by the trial investigators based on complete medical records. Patients should discuss all options with their healthcare team. Trial availability and status may change; verify current status at [ClinicalTrials.gov](https://clinicaltrials.gov).

## Sources

All data sourced from:
- ClinicalTrials.gov (trial search, eligibility, locations, status)
- OpenTargets Platform (drug-target associations, disease ontology)
- CIViC (clinical variant interpretations)
- ChEMBL (drug mechanisms, targets)
- FDA (approved indications, pharmacogenomic biomarkers, drug labels)
- DrugBank (drug targets, indications)
- PharmGKB (pharmacogenomics)
- PubMed/NCBI (literature evidence)
- OLS/EFO (disease ontology)
- MyGene (gene identifier resolution)
```

---

## Execution Strategy

### Parallelization Opportunities

Many tool calls can be executed in parallel to speed up the workflow:

**Parallel Group 1** (Phase 1 - can all run simultaneously):
- `MyGene_query_genes` for each gene
- `OpenTargets_get_disease_id_description_by_name` for disease
- `ols_search_efo_terms` for disease
- `fda_pharmacogenomic_biomarkers` (no params)

**Parallel Group 2** (Phase 2 - can all run simultaneously):
- `search_clinical_trials` with disease condition
- `search_clinical_trials` with biomarker query
- `search_clinical_trials` with intervention query
- `clinical_trials_search` as alternative

**Parallel Group 3** (Phase 3 - can all run simultaneously):
- `get_clinical_trial_eligibility_criteria` for all NCT IDs
- `get_clinical_trial_conditions_and_interventions` for all NCT IDs
- `get_clinical_trial_locations` for all NCT IDs
- `get_clinical_trial_status_and_dates` for all NCT IDs
- `get_clinical_trial_descriptions` for all NCT IDs

**Parallel Group 4** (Phases 5-6 - for each drug):
- `OpenTargets_get_drug_id_description_by_name` for drug
- `OpenTargets_get_drug_mechanisms_of_action_by_chemblId` for drug
- `FDA_get_indications_by_drug_name` for drug
- `PubMed_search_articles` for evidence

### Error Handling

For each tool call:
1. Wrap in try/except
2. Check for empty results
3. Use fallback tools when primary fails
4. Document what failed in completeness checklist
5. Never let one failure block the entire analysis

### Performance Optimization

- Batch NCT IDs in groups of 10 for detail tools
- Limit initial search to 20-30 trials per search strategy
- Focus detailed analysis on top 15-20 candidates after initial filtering
- Cache gene/disease resolution results for reuse across phases

---

## Common Use Patterns

### Pattern 1: Targeted Therapy Matching (Most Common)

**Input**: "NSCLC patient with EGFR L858R, failed platinum chemotherapy"

1. Resolve: NSCLC -> EFO_0003060, EGFR -> ENSG00000146648
2. Search: "non-small cell lung cancer" + "EGFR mutation" + "EGFR L858R"
3. Filter: Recruiting trials with EGFR molecular requirements
4. Match: Score trials by EGFR L858R specificity
5. Drugs: Identify TKIs (osimertinib, erlotinib, etc.) in trial arms
6. Evidence: Check FDA approval of EGFR TKIs for NSCLC
7. Report: Prioritize targeted therapy trials, include immunotherapy options

### Pattern 2: Immunotherapy Selection

**Input**: "Melanoma, TMB-high, PD-L1 positive, failed ipilimumab"

1. Resolve: Melanoma -> EFO_0000756
2. Search: "melanoma" + "TMB" + "PD-L1" + "immunotherapy"
3. Filter: Trials requiring PD-L1 or TMB testing
4. Match: Score by TMB/PD-L1 requirements
5. Drugs: Identify checkpoint inhibitors (pembrolizumab, nivolumab)
6. Evidence: Check FDA approval for TMB-high indications
7. Report: Focus on anti-PD-1/PD-L1 trials, combination immunotherapy

### Pattern 3: Basket Trial Identification

**Input**: "Any solid tumor with NTRK fusion"

1. Resolve: NTRK genes (NTRK1, NTRK2, NTRK3)
2. Search: "NTRK fusion" + "tumor agnostic" + "basket"
3. Filter: Biomarker-agnostic trials
4. Match: Score by NTRK-specific inclusion criteria
5. Drugs: Identify larotrectinib, entrectinib
6. Evidence: FDA tissue-agnostic approval for larotrectinib
7. Report: Highlight tumor-agnostic approval, broad eligibility

### Pattern 4: Post-Progression Options

**Input**: "Breast cancer, failed CDK4/6 inhibitors, ESR1 mutation"

1. Resolve: Breast cancer -> EFO_0000305, ESR1 -> ENSG00000091831
2. Search: "breast cancer" + "ESR1" + "CDK4/6 resistance"
3. Filter: Trials for post-CDK4/6 setting
4. Match: Score by ESR1 mutation and prior treatment requirements
5. Drugs: Identify novel endocrine agents, SERDs, ESR1-targeting drugs
6. Evidence: Check clinical data for post-CDK4/6 options
7. Report: Focus on resistance-overcoming strategies

### Pattern 5: Geographic Search

**Input**: "Lung cancer trials within 100 miles of Boston"

1. Search: "lung cancer" (broad)
2. Get locations for all candidate trials
3. Filter: Sites in Massachusetts and nearby states
4. Score: High geographic feasibility for Boston-area sites
5. Report: Prioritize by proximity, include contact info

---

## Edge Case Handling

### No Matching Trials Found

If no trials match the patient's biomarker:
1. Broaden search to gene-level (remove specific variant)
2. Search for pathway-level trials
3. Search basket trials
4. Suggest additional biomarker testing
5. Report alternative options (off-label, compassionate use)

### Rare Biomarkers

For uncommon mutations (e.g., unusual EGFR variants):
1. Search gene-level trials (any EGFR mutation)
2. Search mechanism-level trials (TKI trials)
3. Check CIViC for any evidence on this specific variant
4. Note variant rarity in report
5. Suggest discussion with molecular tumor board

### Multiple Biomarkers

For complex molecular profiles:
1. Search for each biomarker independently
2. Search for combination biomarker trials
3. Identify trials that require multiple biomarkers
4. Score based on most actionable biomarker
5. Flag potential synergistic drug targets

### Conflicting Eligibility

When patient meets some criteria but not others:
1. Score partial match transparently
2. Highlight which criteria are met/unmet
3. Note if unmet criteria are waivable
4. Suggest contacting PI for edge cases
5. Provide alternative trials without conflicting criteria

---

## Known CIViC Gene IDs

For direct CIViC lookups without search:

| Gene | CIViC ID | Gene | CIViC ID |
|------|----------|------|----------|
| ALK | 1 | MET | 52 |
| ABL1 | 4 | PIK3CA | 37 |
| BRAF | 5 | ROS1 | 118 |
| EGFR | 19 | RET | 122 |
| ERBB2 | 20 | NTRK1 | 197 |
| KRAS | 30 | NTRK2 | 560 |
| TP53 | 45 | NTRK3 | 561 |

---

## Report File Naming Convention

Save reports as:
```
clinical_trial_matching_[DISEASE]_[BIOMARKER]_[DATE].md
```
Example: `clinical_trial_matching_NSCLC_EGFR_L858R_2026-02-15.md`
