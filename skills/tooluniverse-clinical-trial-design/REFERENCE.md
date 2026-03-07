# tooluniverse-clinical-trial-design — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Complete Example Workflow

### Example: EGFR L858R+ NSCLC Phase 1/2 Trial

```python
from tooluniverse import ToolUniverse

tu = ToolUniverse(use_cache=True)
tu.load_tools()

# ============================================================================
# PATH 1: PATIENT POPULATION SIZING
# ============================================================================

# Step 1.1: Get disease prevalence
disease_info = tu.tools.OpenTargets_get_disease_id_description_by_name(
    diseaseName="non-small cell lung cancer"
)
efo_id = disease_info['data']['id']

# Get phenotype data (includes prevalence if available)
phenotypes = tu.tools.OpenTargets_get_diseases_phenotypes(
    efoId=efo_id
)
# Note: May need to supplement with literature (PubMed) for specific prevalence

# Step 1.2: Estimate EGFR mutation prevalence
egfr_variants = tu.tools.ClinVar_search_variants(
    gene="EGFR",
    significance="pathogenic,likely_pathogenic"
)

# Filter to L858R specifically
l858r_variants = [v for v in egfr_variants['data']
                  if 'L858R' in v.get('name', '')]

# Also check population databases for allele frequency
gnomad_egfr = tu.tools.gnomAD_search_gene_variants(
    gene="EGFR"
)
# Filter to L858R and sum allele frequencies

# Step 1.3: Search literature for epidemiology
epi_papers = tu.tools.PubMed_search_articles(
    query="EGFR L858R prevalence non-small cell lung cancer epidemiology",
    max_results=20
)
# Extract prevalence estimates from recent papers

# ============================================================================
# PATH 2: BIOMARKER PREVALENCE & TESTING
# ============================================================================

# Step 2.1: Find FDA-approved CDx tests
# Search FDA device database (via PubMed or manual lookup)
cdx_search = tu.tools.PubMed_search_articles(
    query="FDA approved companion diagnostic EGFR L858R",
    max_results=10
)

# Step 2.2: Literature on EGFR testing in clinical practice
testing_papers = tu.tools.PubMed_search_articles(
    query="EGFR mutation testing guidelines NCCN turnaround time",
    max_results=15
)

# ============================================================================
# PATH 3: COMPARATOR SELECTION
# ============================================================================

# Step 3.1: Find current standard of care (osimertinib)
soc_drug = "osimertinib"

soc_info = tu.tools.drugbank_get_drug_basic_info_by_drug_name_or_id(
    drug_name_or_drugbank_id=soc_drug
)

soc_indications = tu.tools.drugbank_get_indications_by_drug_name_or_drugbank_id(
    drug_name_or_drugbank_id=soc_drug
)

soc_pharmacology = tu.tools.drugbank_get_pharmacology_by_drug_name_or_drugbank_id(
    drug_name_or_drugbank_id=soc_drug
)

# Step 3.2: Check FDA Orange Book for approved generics
orange_book = tu.tools.FDA_OrangeBook_search_drugs(
    ingredient=soc_drug
)

# Step 3.3: Find FDA approval details
fda_approval = tu.tools.FDA_get_drug_approval_history(
    drug_name=soc_drug
)

# ============================================================================
# PATH 4: ENDPOINT SELECTION
# ============================================================================

# Step 4.1: Search for precedent Phase 2 trials in EGFR+ NSCLC
precedent_trials = tu.tools.search_clinical_trials(
    condition="EGFR positive non-small cell lung cancer",
    phase="2",
    status="completed"
)

# Analyze which primary endpoints were used (ORR, PFS, etc.)
orr_trials = [t for t in precedent_trials['data']
              if 'response rate' in t.get('primary_outcome', '').lower()]

# Step 4.2: Find FDA approvals using ORR as primary endpoint
orr_approvals = tu.tools.PubMed_search_articles(
    query="FDA approval objective response rate NSCLC accelerated approval",
    max_results=30
)

# Step 4.3: Get detailed trial results for sample size justification
# Use ClinicalTrials.gov NCT number from precedent_trials
for trial in precedent_trials['data'][:5]:
    nct_id = trial.get('nct_number')
    trial_details = tu.tools.search_clinical_trials(
        nct_id=nct_id
    )
    # Extract: ORR, n, confidence intervals

# ============================================================================
# PATH 5: SAFETY ENDPOINTS & MONITORING
# ============================================================================

# Step 5.1: Get mechanism-based toxicity from drug class
# If testing an EGFR inhibitor, search for class effects
class_drug = "erlotinib"  # Example EGFR TKI for class effect reference

class_safety = tu.tools.drugbank_get_pharmacology_by_drug_name_or_drugbank_id(
    drug_name_or_drugbank_id=class_drug
)

class_warnings = tu.tools.FDA_get_warnings_and_cautions_by_drug_name(
    drug_name=class_drug
)

# Step 5.2: FAERS data for real-world adverse events
faers_egfr_tki = tu.tools.FAERS_search_reports_by_drug_and_reaction(
    drug_name="erlotinib",
    limit=500
)

# Summarize top adverse events
ae_summary = tu.tools.FAERS_count_reactions_by_drug_event(
    medicinalproduct="ERLOTINIB"
)

# Step 5.3: Search for DLT definitions in similar trials
dlt_papers = tu.tools.PubMed_search_articles(
    query="dose limiting toxicity Phase 1 EGFR inhibitor definition",
    max_results=20
)

# ============================================================================
# PATH 6: REGULATORY PATHWAY
# ============================================================================

# Step 6.1: Search for breakthrough therapy designations in NSCLC
breakthrough_search = tu.tools.PubMed_search_articles(
    query="FDA breakthrough therapy designation NSCLC EGFR mutation",
    max_results=20
)

# Step 6.2: Check if indication qualifies for orphan drug status
# L858R is subset of NSCLC; estimate US prevalence
us_nsclc_annual = 200000  # From epidemiology data
l858r_prevalence = 0.45 * 0.15  # 45% of EGFR+ (15% of NSCLC)
l858r_annual_us = us_nsclc_annual * l858r_prevalence  # ~13,500/year
# Note: Orphan requires <200,000 total prevalence; may not qualify if prevalent

# Step 6.3: Find relevant FDA guidance documents
fda_guidance_search = tu.tools.PubMed_search_articles(
    query="FDA guidance clinical trial endpoints oncology non-small cell lung cancer",
    max_results=15
)

# ============================================================================
# COMPILE FEASIBILITY REPORT
# ============================================================================

# Now compile all data into the 14-section report structure
# Calculate feasibility score based on findings

feasibility_scores = {
    'patient_availability': 8,  # 8/10 based on 13,500 patients/year, good access
    'endpoint_precedent': 9,    # 9/10 ORR widely accepted
    'regulatory_clarity': 7,    # 7/10 breakthrough possible, single-arm needs FDA input
    'comparator_feasibility': 9, # 9/10 osimertinib available, efficacy data clear
    'safety_monitoring': 8      # 8/10 EGFR TKI class effects well-characterized
}

weights = {
    'patient_availability': 0.30,
    'endpoint_precedent': 0.25,
    'regulatory_clarity': 0.20,
    'comparator_feasibility': 0.15,
    'safety_monitoring': 0.10
}

overall_score = sum(feasibility_scores[k] * weights[k] * 10 for k in weights.keys())
# overall_score = 81/100 → HIGH feasibility

print(f"Feasibility Score: {overall_score}/100 - HIGH")
print("Recommendation: RECOMMEND PROCEED to protocol development")
```

---

## Tool Reference by Research Path

### PATH 1: Patient Population Sizing
- `OpenTargets_get_disease_id_description_by_name` - Disease lookup
- `OpenTargets_get_diseases_phenotypes` - Prevalence data
- `ClinVar_search_variants` - Biomarker mutation frequency
- `gnomAD_search_gene_variants` - Population allele frequencies
- `PubMed_search_articles` - Epidemiology literature
- `search_clinical_trials` - Enrollment feasibility from past trials

### PATH 2: Biomarker Prevalence & Testing
- `ClinVar_get_variant_details` - Variant pathogenicity
- `COSMIC_search_mutations` - Cancer-specific mutation frequencies
- `gnomAD_get_variant_details` - Population genetics
- `PubMed_search_articles` - CDx test performance, guidelines

### PATH 3: Comparator Selection
- `drugbank_get_drug_basic_info_by_drug_name_or_id` - Drug info
- `drugbank_get_indications_by_drug_name_or_drugbank_id` - Approved indications
- `drugbank_get_pharmacology_by_drug_name_or_drugbank_id` - Mechanism
- `FDA_OrangeBook_search_drugs` - Generic availability
- `FDA_get_drug_approval_history` - Approval details
- `search_clinical_trials` - Historical control data

### PATH 4: Endpoint Selection
- `search_clinical_trials` - Precedent trials, endpoints used
- `PubMed_search_articles` - FDA acceptance history, endpoint validation
- `FDA_get_drug_approval_history` - Approved endpoints by indication

### PATH 5: Safety Endpoints & Monitoring
- `drugbank_get_pharmacology_by_drug_name_or_drugbank_id` - Mechanism toxicity
- `FDA_get_warnings_and_cautions_by_drug_name` - FDA black box warnings
- `FAERS_search_reports_by_drug_and_reaction` - Real-world adverse events
- `FAERS_count_reactions_by_drug_event` - AE frequency
- `FAERS_count_death_related_by_drug` - Serious outcomes
- `PubMed_search_articles` - DLT definitions, monitoring strategies

### PATH 6: Regulatory Pathway
- `FDA_get_drug_approval_history` - Precedent approvals
- `PubMed_search_articles` - Breakthrough designations, FDA guidance
- `search_clinical_trials` - Regulatory precedents (accelerated approval)

---

## Best Practices

### 1. Start with Report Template
Create full report structure FIRST, then populate:
```markdown
# Clinical Trial Feasibility Report: [INDICATION]
## 1. Executive Summary
[Researching...]
## 2. Disease Background
[Researching...]
[...all 14 sections...]
```

### 2. Use English for All Tool Calls
Even if user asks in another language:
- "EGFR+ NSCLC" not "EGFR+ 非小细胞肺癌"
- "breast cancer" not "cancer du sein"
- Translate results back to user's language

### 3. Validate Biomarker Prevalence Across Sources
Cross-check ClinVar, gnomAD, COSMIC, and literature:
- ClinVar: Clinical significance
- gnomAD: Population frequency (for germline)
- COSMIC: Somatic mutation frequency in cancers
- Literature: Geographic/ethnic variation

### 4. Calculate Enrollment Funnel Explicitly
Show math for patient availability:
```
US NSCLC incidence: 200,000/year
× EGFR+ prevalence: 15% = 30,000
× L858R within EGFR+: 45% = 13,500
× Eligible (age, PS, prior Tx): 60% = 8,100
÷ Competing trials: 3 = 2,700 available/year

For N=43, need 43/2,700 = 1.6% capture rate → Achievable
```

### 5. Evidence Grade Every Key Claim
```markdown
EGFR L858R prevalence is 45% of EGFR+ NSCLC [★★★: PMID:12345, large
sequencing study n=1,500]. *Source: ClinVar, COSMIC*
```

### 6. Provide Regulatory Precedent Details
Not just "ORR is accepted" but:
```markdown
ORR is FDA-accepted for accelerated approval in NSCLC [★★★: FDA approvals]:
- Osimertinib (2015): ORR 57%, n=411, Tx-resistant EGFR+ (NCT01802632)
- Dacomitinib (2018): ORR 45%, n=452, 1L EGFR+ (NCT01774721)
- [3 more examples]
```

### 7. Address Feasibility Risks Proactively
For each HIGH risk, provide mitigation:
```markdown
Risk: Biomarker screen failure rate >70%
→ Mitigation: Liquid biopsy pre-screening (ctDNA EGFR, 7-day turnaround)
```

### 8. Separate Phase 1 and Phase 2 Components
If combined Phase 1/2:
- Phase 1: Safety, DLT, RP2D (N=12-18, 3+3 or BOIN)
- Phase 2: Efficacy, ORR (N=43, Simon 2-stage)
- Distinct success criteria for each phase

---

## Common Pitfalls to Avoid

### ❌ Don't: Show Tool Outputs to User
```markdown
# BAD
OpenTargets returned:
{
  "data": {
    "id": "EFO_0003060",
    "name": "non-small cell lung carcinoma"
  }
}
```

### ✅ Do: Present Synthesized Report
```markdown
# GOOD
## Disease Background
Non-small cell lung cancer (NSCLC) represents 85% of lung cancers, with
~200,000 new cases annually in the US [★★★: CDC WONDER]. EGFR mutations
occur in 15% of Caucasian and 50% of Asian patients [★★★: PMID:23816960].
*Source: OpenTargets, ClinVar*
```

### ❌ Don't: Make Unsupported Claims
```markdown
# BAD
ORR of 60% is expected based on preclinical data.
```

### ✅ Do: Ground in Evidence
```markdown
# GOOD
ORR of 30-40% is projected [★★☆] based on:
- Similar EGFR TKI (erlotinib): 32% ORR in EGFR+ NSCLC (NCT00949650)
- Our drug's 2× IC50 potency vs. erlotinib (preclinical)
*Source: ClinicalTrials.gov, internal data*
```

### ❌ Don't: Ignore Geographic Variation
```markdown
# BAD
EGFR L858R prevalence: 7% of NSCLC
```

### ✅ Do: Specify Geography
```markdown
# GOOD
EGFR L858R prevalence [★★★: COSMIC, ClinVar]:
- Caucasian (US/EU): 6-7% of NSCLC
- East Asian: 20-25% of NSCLC
→ Trial site strategy: Include Asian sites for 2× enrollment
```

---

## Output Format Requirements

### Report File Naming
- `[INDICATION]_trial_feasibility_report.md`
- Example: `EGFR_L858R_NSCLC_trial_feasibility_report.md`

### Section Completeness
All 14 sections MUST be present:
1. Executive Summary
2. Disease Background
3. Patient Population Analysis (with funnel)
4. Biomarker Strategy
5. Endpoint Selection & Justification
6. Comparator Analysis
7. Safety Endpoints & Monitoring Plan
8. Study Design Recommendations
9. Enrollment & Site Strategy
10. Regulatory Pathway
11. Budget & Resource Considerations
12. Risk Assessment
13. Success Criteria & Go/No-Go Decision (with scorecard)
14. Recommendations & Next Steps

### Evidence Grading Required In
- Section 1 (Executive Summary): Key findings
- Section 4 (Biomarker): Prevalence claims
- Section 5 (Endpoints): Regulatory precedents
- Section 6 (Comparator): SOC efficacy data
- Section 7 (Safety): Toxicity frequencies
- Section 10 (Regulatory): Approval precedents
- Section 13 (Scorecard): All dimensions

### Feasibility Score Transparency
Show calculation:
```markdown
| Dimension | Weight | Raw Score | Weighted | Evidence |
|-----------|--------|-----------|----------|----------|
| Patient Availability | 30% | 8/10 | 24 | ★★★: Epi data |
| Endpoint Precedent | 25% | 9/10 | 22.5 | ★★★: FDA approvals |
| Regulatory Clarity | 20% | 7/10 | 14 | ★★☆: Pre-IND advised |
| Comparator Feasibility | 15% | 9/10 | 13.5 | ★★★: Generic avail |
| Safety Monitoring | 10% | 8/10 | 8 | ★★☆: Class effects |
| **TOTAL** | **100%** | - | **82/100** | **HIGH** |
```

---

## Example Use Cases

### Use Case 1: Biomarker-Selected Oncology Trial
**Query**: "Assess feasibility of Phase 2 trial for EGFR L858R+ NSCLC, ORR primary endpoint"

**Workflow**:
1. Disease prevalence: 200K NSCLC/year × 15% EGFR+ = 30K
2. Biomarker: L858R is 45% of EGFR+ → 13.5K/year
3. Eligible: 60% → 8K/year
4. Endpoint: ORR accepted (osimertinib precedent)
5. Comparator: Osimertinib (ORR 57%, generic available)
6. Feasibility: HIGH (82/100) → RECOMMEND PROCEED

### Use Case 2: Rare Disease Trial
**Query**: "Feasibility of trial in Niemann-Pick Type C (prevalence 1:120,000)"

**Workflow**:
1. US prevalence: ~2,750 patients total, ~25 new cases/year
2. Endpoint challenge: No validated clinical outcome
3. Orphan drug: QUALIFIED (7-year exclusivity)
4. Comparator: No approved drugs → single-arm feasible
5. Enrollment: Multi-year, need ALL US centers
6. Feasibility: MODERATE (58/100) → CONDITIONAL GO (requires patient registry partnership)

### Use Case 3: Superiority Trial vs. Standard of Care
**Query**: "Phase 2b design for new checkpoint inhibitor vs. pembrolizumab in PD-L1 high NSCLC"

**Workflow**:
1. Patient availability: 40K PD-L1 high NSCLC/year (HIGH)
2. Endpoint: ORR for Phase 2b, plan OS for Phase 3
3. Comparator: Pembrolizumab (ORR 45%, PFS 10mo) - readily available
4. Design: Randomized 1:1, N=120 (60/arm) for 20% ORR improvement
5. Feasibility: HIGH (78/100) → RECOMMEND PROCEED

### Use Case 4: Non-Inferiority Trial
**Query**: "Non-inferiority trial for oral anticoagulant vs. warfarin"

**Workflow**:
1. Patient availability: 2M AFib patients, 600K on warfarin (HIGH)
2. Endpoint: Stroke/SE (FDA-accepted, but requires large N)
3. Non-inferiority margin: HR <1.5 (FDA guidance)
4. Sample size: N=5,000+ for 90% power → LARGE trial
5. Comparator: Warfarin generic, INR monitoring standard
6. Feasibility: MODERATE (65/100) - large N drives cost and timeline

### Use Case 5: Basket Trial (Multiple Cancers, One Biomarker)
**Query**: "Basket trial for NTRK fusion+ solid tumors (15 histologies)"

**Workflow**:
1. Patient availability: NTRK fusions rare (<1% across cancers) → Broad screening
2. Biomarker testing: NGS required (FDA-approved FoundationOne CDx)
3. Endpoint: ORR (precedent: larotrectinib approval, ORR 75%, n=55)
4. Design: Single-arm, N=15-20 per histology × 5-10 histologies
5. Regulatory: Tissue-agnostic approval precedent (★★★: pembrolizumab MSI-H)
6. Feasibility: MODERATE (62/100) - enrollment slow but feasible with broad screening

---

## Integration with Other Skills

### Works Well With
- **tooluniverse-drug-research**: Investigate mechanism, preclinical data
- **tooluniverse-disease-research**: Deep dive on disease biology
- **tooluniverse-target-research**: Validate drug target, essentiality
- **tooluniverse-pharmacovigilance**: Post-market safety for comparator drugs
- **tooluniverse-precision-oncology**: Biomarker biology, resistance mechanisms

### Complementary Analyses
After feasibility report, consider:
1. **Budget model**: Use cost estimates to build financial model
2. **Site feasibility surveys**: Validate enrollment projections with sites
3. **Regulatory strategy document**: Detailed FDA interaction plan
4. **Statistical analysis plan (SAP)**: Translate design into statistical methods

---

## Version Information

- **Version**: 1.0.0
- **Last Updated**: February 2026
- **Compatible with**: ToolUniverse 0.5+
- **Focus**: Phase 1/2 early clinical development

---

## Support & Resources

- **ToolUniverse Docs**: https://zitniklab.hms.harvard.edu/ToolUniverse/
- **FDA Guidance Documents**: https://www.fda.gov/regulatory-information/search-fda-guidance-documents
- **ClinicalTrials.gov**: https://clinicaltrials.gov/
- **Slack Community**: https://join.slack.com/t/tooluniversehq/shared_invite/zt-3dic3eoio-5xxoJch7TLNibNQn5_AREQ
