# tooluniverse-precision-oncology — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 5: Clinical Trial Matching

### 5.1 Search Strategy

```python
def find_trials(tu, condition, biomarker, location=None):
    """Find matching clinical trials."""
    # Search with biomarker
    trials = tu.tools.search_clinical_trials(
        condition=condition,
        intervention=biomarker,  # e.g., "EGFR"
        status="Recruiting",
        pageSize=50
    )
    
    # Get eligibility for top matches
    nct_ids = [t['nct_id'] for t in trials[:20]]
    eligibility = tu.tools.get_clinical_trial_eligibility_criteria(nct_ids=nct_ids)
    
    return trials, eligibility
```

### 5.2 Output Format

```markdown
## Clinical Trial Options

| NCT ID | Phase | Agent | Biomarker Required | Status | Location |
|--------|-------|-------|-------------------|--------|----------|
| NCT04487080 | 2 | Amivantamab + lazertinib | EGFR T790M | Recruiting | US, EU |
| NCT05388669 | 3 | Patritumab deruxtecan | Prior osimertinib | Recruiting | US |

*Source: ClinicalTrials.gov*
```

---

## Phase 5.5: Literature Evidence (NEW)

### 5.5.1 Published Literature (PubMed)

```python
def search_treatment_literature(tu, cancer_type, biomarker, drug_name):
    """Search for treatment evidence in literature."""
    
    # Drug + biomarker combination
    drug_papers = tu.tools.PubMed_search_articles(
        query=f'"{drug_name}" AND "{biomarker}" AND "{cancer_type}"',
        limit=20
    )
    
    # Resistance mechanisms
    resistance_papers = tu.tools.PubMed_search_articles(
        query=f'"{drug_name}" AND resistance AND mechanism',
        limit=15
    )
    
    return {
        'treatment_evidence': drug_papers,
        'resistance_literature': resistance_papers
    }
```

### 5.5.2 Preprints (BioRxiv/MedRxiv)

```python
def search_preprints(tu, cancer_type, biomarker):
    """Search preprints for cutting-edge findings."""
    
    # BioRxiv cancer research
    biorxiv = tu.tools.BioRxiv_search_preprints(
        query=f"{cancer_type} {biomarker} treatment",
        limit=10
    )
    
    # MedRxiv clinical studies
    medrxiv = tu.tools.MedRxiv_search_preprints(
        query=f"{cancer_type} {biomarker}",
        limit=10
    )
    
    return {
        'biorxiv': biorxiv,
        'medrxiv': medrxiv
    }
```

### 5.5.3 Citation Analysis (OpenAlex)

```python
def analyze_key_papers(tu, key_papers):
    """Get citation metrics for key evidence papers."""
    
    analyzed = []
    for paper in key_papers[:10]:
        work = tu.tools.openalex_search_works(
            query=paper['title'],
            limit=1
        )
        if work:
            analyzed.append({
                'title': paper['title'],
                'citations': work[0].get('cited_by_count', 0),
                'year': work[0].get('publication_year'),
                'open_access': work[0].get('is_oa', False)
            })
    
    return analyzed
```

### 5.5.4 Output for Report

```markdown
## 5.5 Literature Evidence

### Key Clinical Studies

| PMID | Title | Year | Citations | Evidence Type |
|------|-------|------|-----------|---------------|
| 27959700 | AURA3: Osimertinib vs chemotherapy... | 2017 | 2,450 | Phase 3 trial |
| 30867819 | Mechanisms of osimertinib resistance... | 2019 | 680 | Review |
| 34125020 | Amivantamab + lazertinib Phase 1... | 2021 | 320 | Phase 1 trial |

### Recent Preprints (Not Peer-Reviewed)

| Source | Title | Posted | Key Finding |
|--------|-------|--------|-------------|
| MedRxiv | Novel C797S resistance strategy... | 2024-01 | Fourth-gen TKI |
| BioRxiv | scRNA-seq reveals resistance... | 2024-02 | Cell state switch |

**⚠️ Note**: Preprints have NOT undergone peer review. Interpret with caution.

### Evidence Summary

| Category | Papers Found | High-Impact (>100 citations) |
|----------|--------------|------------------------------|
| Treatment efficacy | 25 | 8 |
| Resistance mechanisms | 18 | 5 |
| Combinations | 12 | 3 |

*Source: PubMed, BioRxiv, MedRxiv, OpenAlex*
```

---

## Report Template

**File**: `[PATIENT_ID]_oncology_report.md`

```markdown
# Precision Oncology Report

**Patient ID**: [ID] | **Date**: [Date]

## Patient Profile
- **Diagnosis**: [Cancer type, stage]
- **Molecular Profile**: [Mutations, fusions]
- **Prior Therapy**: [Previous treatments]

---

## Executive Summary
[2-3 sentence summary of key findings and recommendation]

---

## 1. Variant Interpretation
[Table with variants, significance, evidence levels]

## 2. Treatment Recommendations
### First-Line Options
[Prioritized list with evidence]

### Second-Line Options
[Alternative approaches]

## 3. Resistance Analysis (if applicable)
[Mechanism explanation, strategies to overcome]

## 4. Clinical Trial Options
[Matched trials with eligibility]

## 5. Next Steps
1. [Specific actionable recommendation]
2. [Follow-up testing if needed]
3. [Referral if appropriate]

---

## Data Sources
| Source | Query | Data Retrieved |
|--------|-------|----------------|
| CIViC | [gene] [variant] | Evidence items |
| ClinicalTrials.gov | [condition] | Active trials |
```

---

## Completeness Checklist

Before finalizing report:

- [ ] All variants interpreted with evidence levels
- [ ] ≥1 first-line recommendation with ★★★ evidence (or explain why none)
- [ ] Resistance mechanism addressed (if prior therapy failed)
- [ ] ≥3 clinical trials listed (or "no matching trials")
- [ ] Executive summary is actionable (says what to DO)
- [ ] All recommendations have source citations

---

## Fallback Chains

| Primary | Fallback | Use When |
|---------|----------|----------|
| CIViC variant | OncoKB (literature) | Variant not in CIViC |
| OpenTargets drugs | ChEMBL activities | No approved drugs found |
| ClinicalTrials.gov | WHO ICTRP | US trials insufficient |
| NvidiaNIM_alphafold2 | AlphaFold DB | API unavailable |

---

## Evidence Grading

| Tier | Symbol | Criteria | Example |
|------|--------|----------|---------|
| T1 | ★★★ | FDA-approved, Level A evidence | Osimertinib for T790M |
| T2 | ★★☆ | Phase 2/3 data, Level B | Combination trials |
| T3 | ★☆☆ | Preclinical, Level D | Novel mechanisms |
| T4 | ☆☆☆ | Computational only | Docking predictions |

---

## Tool Reference

See [TOOLS_REFERENCE.md](TOOLS_REFERENCE.md) for complete tool documentation.
