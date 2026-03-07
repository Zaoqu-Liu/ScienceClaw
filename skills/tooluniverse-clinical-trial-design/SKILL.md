---
name: tooluniverse-clinical-trial-design
description: Strategic clinical trial design feasibility assessment using ToolUniverse. Evaluates patient population sizing, biomarker prevalence, endpoint selection, comparator analysis, safety monitoring, and regulatory pathways. Creates comprehensive feasibility reports with evidence grading, enrollment projections, and trial design recommendations. Use when planning Phase 1/2 trials, assessing trial feasibility, or designing biomarker-driven studies.
---

# Clinical Trial Design Feasibility Assessment

Systematically assess clinical trial feasibility by analyzing 6 research dimensions. Produces comprehensive feasibility reports with quantitative enrollment projections, endpoint recommendations, and regulatory pathway analysis.

**IMPORTANT**: Always use English terms in tool calls (drug names, disease names, biomarker names), even if the user writes in another language. Only try original-language terms as a fallback if English returns no results. Respond in the user's language.

## Core Principles

### 1. Report-First Approach (MANDATORY)
**DO NOT** show tool outputs to user. Instead:
1. Create `[INDICATION]_trial_feasibility_report.md` FIRST
2. Initialize with all section headers
3. Progressively update as data arrives
4. Present only the final report

### 2. Evidence Grading System

| Grade | Symbol | Criteria | Examples |
|-------|--------|----------|----------|
| **A** | ★★★ | Regulatory acceptance, multiple precedents | FDA-approved endpoint in same indication |
| **B** | ★★☆ | Clinical validation, single precedent | Phase 3 trial in related indication |
| **C** | ★☆☆ | Preclinical or exploratory | Phase 1 use, biomarker validation ongoing |
| **D** | ☆☆☆ | Proposed, no validation | Novel endpoint, no precedent |

### 3. Feasibility Score (0-100)
Weighted composite score:
- **Patient Availability** (30%): Population size × biomarker prevalence × geography
- **Endpoint Precedent** (25%): Historical use, regulatory acceptance
- **Regulatory Clarity** (20%): Pathway defined, precedents exist
- **Comparator Feasibility** (15%): Standard of care availability
- **Safety Monitoring** (10%): Known risks, monitoring established

---

## When to Use This Skill

Apply when users:
- Plan early-phase trials (Phase 1/2 emphasis)
- Need enrollment feasibility assessment
- Design biomarker-selected trials
- Evaluate endpoint strategies
- Assess regulatory pathways
- Compare trial design options
- Need safety monitoring plans

**Trigger phrases**: "clinical trial design", "trial feasibility", "enrollment projections", "endpoint selection", "trial planning", "Phase 1/2 design", "basket trial", "biomarker trial"

---

## Quick Start

```python
from tooluniverse import ToolUniverse

tu = ToolUniverse(use_cache=True)
tu.load_tools()

# Example: EGFR+ NSCLC trial feasibility
indication = "EGFR-mutant non-small cell lung cancer"
biomarker = "EGFR L858R"

# Step 1: Get disease prevalence
disease_info = tu.tools.OpenTargets_get_disease_id_description_by_name(
    diseaseName="non-small cell lung cancer"
)

prevalence = tu.tools.OpenTargets_get_diseases_phenotypes(
    efoId=disease_info['data']['id']
)

# Step 2: Estimate biomarker prevalence
# EGFR mutations: ~15% of NSCLC in US, ~50% in Asia
variants = tu.tools.ClinVar_search_variants(
    gene="EGFR",
    significance="pathogenic"
)

# Step 3: Find precedent trials
trials = tu.tools.search_clinical_trials(
    condition="EGFR positive non-small cell lung cancer",
    status="completed",
    phase="2"
)

# Step 4: Identify standard of care comparator
soc_drugs = tu.tools.FDA_OrangeBook_search_drugs(
    ingredient="osimertinib"  # Current SOC for EGFR+ NSCLC
)

# Compile into feasibility report...
```

---

## Core Strategy: 6 Research Paths

Execute 6 parallel research dimensions:

```
Trial Design Query (e.g., "EGFR+ NSCLC trial, Phase 2, ORR endpoint")
│
├─ PATH 1: Patient Population Sizing
│   ├─ Disease prevalence (OpenTargets_get_diseases_phenotypes)
│   ├─ Biomarker prevalence (ClinVar, gnomAD, literature)
│   ├─ Geographic distribution (clinical trials, epidemiology)
│   ├─ Eligibility criteria impact (age, comorbidities)
│   └─ Patient availability calculator
│
├─ PATH 2: Biomarker Prevalence & Testing
│   ├─ Mutation frequency (ClinVar, COSMIC, gnomAD)
│   ├─ Testing availability (CLIA labs, FDA-approved tests)
│   ├─ Test turnaround time
│   ├─ Cost and reimbursement
│   └─ Alternative biomarkers (correlates, surrogates)
│
├─ PATH 3: Comparator Selection
│   ├─ Standard of care (FDA_OrangeBook, guidelines)
│   ├─ Approved comparators (DrugBank, FDA labels)
│   ├─ Historical controls feasibility
│   ├─ Placebo appropriateness
│   └─ Combination therapy considerations
│
├─ PATH 4: Endpoint Selection
│   ├─ Primary endpoint precedents (search_clinical_trials)
│   ├─ FDA acceptance history (FDA_get_approval_history)
│   ├─ Measurement feasibility (imaging, biomarkers)
│   ├─ Time to event considerations
│   └─ Surrogate vs clinical endpoints
│
├─ PATH 5: Safety Endpoints & Monitoring
│   ├─ Mechanism-based toxicity (drugbank_get_pharmacology)
│   ├─ Class effect toxicities (FAERS_search_reports)
│   ├─ Organ-specific monitoring (liver, cardiac, etc.)
│   ├─ Dose-limiting toxicity history
│   └─ Safety monitoring plan
│
└─ PATH 6: Regulatory Pathway
    ├─ Regulatory precedents (505(b)(1), 505(b)(2))
    ├─ Breakthrough therapy potential
    ├─ Orphan drug designation (if rare)
    ├─ Fast track eligibility
    └─ FDA guidance documents
```

---

## Report Structure (14 Sections)

Create `[INDICATION]_trial_feasibility_report.md` with:

### 1. Executive Summary
```markdown
# Clinical Trial Feasibility Report: [INDICATION]

**Date**: [YYYY-MM-DD]
**Trial Type**: [Phase 1/2, biomarker-selected, basket, etc.]
**Primary Endpoint**: [ORR, PFS, DLT, etc.]
**Feasibility Score**: [0-100] - [LOW/MODERATE/HIGH]

## Key Findings
- **Patient Availability**: [Est. enrollable patients/year in US]
- **Enrollment Timeline**: [Months to target N]
- **Endpoint Precedent**: [Grade A/B/C/D] - [Description]
- **Regulatory Pathway**: [505(b)(1), breakthrough, orphan, etc.]
- **Critical Risks**: [Top 3 feasibility risks]

## Go/No-Go Recommendation
[RECOMMEND PROCEED / RECOMMEND ADDITIONAL VALIDATION / DO NOT RECOMMEND]

Rationale: [2-3 sentence summary]
```

### 2. Disease Background
- Indication definition
- Prevalence and incidence (with sources)
- Current standard of care
- Unmet medical need
- Disease biology relevant to trial design

### 3. Patient Population Analysis
```markdown
## 3.1 Base Population Size
- **US Incidence**: [X per 100,000] [★★☆: Source]
- **Prevalence**: [Y total patients in US] [★★★: CDC/NCI data]
- **Annual new cases**: [Z patients/year]

## 3.2 Biomarker Selection Impact
- **Biomarker**: [e.g., EGFR L858R mutation]
- **Prevalence in disease**: [%] [★★★: ClinVar/COSMIC]
- **Geographic variation**: [Asian vs. Caucasian, etc.]
- **Testing availability**: [FDA-approved tests, CLIA labs]

## 3.3 Eligibility Criteria Funnel
| Criterion | Remaining Patients | % Retained |
|-----------|-------------------|------------|
| Base disease population | [N] | 100% |
| Biomarker positive | [N × biomarker %] | [%] |
| Age 18-75 | [N × age factor] | [%] |
| No prior therapy | [N × treatment-naive %] | [%] |
| ECOG 0-1 | [N × performance factor] | [%] |
| Adequate organ function | [N × eligibility factor] | [%] |
| **FINAL ELIGIBLE POOL** | **[N]** | **[%]** |

## 3.4 Geographic Distribution
- High-incidence regions: [e.g., Asia 50%, US 15% for EGFR+]
- Trial site implications
- Recruitment strategy recommendations

## 3.5 Enrollment Projections
**Assumptions**:
- Eligible pool: [N patients/year in US]
- Site activation: [M sites]
- Screening success rate: [%]
- Patients per site per month: [X]

**Target Enrollment**: [Total N]
**Projected Timeline**: [Months]
**Sites Required**: [Minimum M sites]
```

### 4. Biomarker Strategy
```markdown
## 4.1 Primary Biomarker
- **Biomarker**: [Gene mutation, protein expression, etc.]
- **Prevalence**: [%] [★★★: ClinVar data]
- **Assay Type**: [NGS, IHC, PCR, etc.]
- **FDA-Approved Tests**: [List CDx tests]
- **Turnaround Time**: [Days]
- **Cost**: [$X per test]

## 4.2 Alternative/Complementary Biomarkers
| Biomarker | Prevalence | Correlation | Testing |
|-----------|------------|-------------|---------|
| [Alt 1] | [%] | [R²] | [Method] |
| [Alt 2] | [%] | [R²] | [Method] |

## 4.3 Biomarker Testing Logistics
- Pre-screening vs. screening approach
- Central lab vs. local testing
- Tissue vs. liquid biopsy (ctDNA)
- Quality control requirements
```

### 5. Endpoint Selection & Justification
```markdown
## 5.1 Primary Endpoint
**Proposed**: [e.g., Objective Response Rate (ORR)]

**Regulatory Precedent** [★★★]:
- [N] FDA approvals in [indication] using ORR (2015-2024)
- Recent example: [Drug] approved [Year] (ORR XX%, n=YY)
- Source: search_clinical_trials, FDA_get_approval_history

**Measurement Feasibility**:
- Assessment method: [RECIST 1.1, irRECIST, etc.]
- Imaging modality: [CT, MRI, PET]
- Assessment frequency: [Every X weeks]
- Independent review: [Yes/No, cost]

**Statistical Considerations**:
- Expected ORR: [%] (based on [source])
- Null hypothesis: [%]
- Sample size: [N] (α=0.05, β=0.20, two-sided)
- Response duration: [Median months]

## 5.2 Secondary Endpoints
| Endpoint | Evidence Grade | Feasibility | Rationale |
|----------|----------------|-------------|-----------|
| Progression-Free Survival (PFS) | ★★★ | High | FDA-accepted, precedent in [trials] |
| Duration of Response (DoR) | ★★☆ | High | Standard in oncology |
| Overall Survival (OS) | ★★★ | Low (early phase) | Follow-up for long-term |
| [Biomarker response] | ★☆☆ | Medium | Exploratory, mechanistic |

## 5.3 Exploratory Endpoints
- Pharmacodynamic biomarkers (proof-of-mechanism)
- ctDNA clearance (liquid biopsy)
- Quality of life (PRO-CTCAE)
- Correlative science (tumor profiling)

## 5.4 Endpoint Risks & Mitigation
- Risk: [Low response rate → sample size inflation]
- Mitigation: [Adaptive design, interim analysis]
```

### 6. Comparator Analysis
```markdown
## 6.1 Standard of Care
**Current SOC**: [Drug name(s)]
- FDA approval: [Year] [★★★: FDA_OrangeBook]
- Efficacy: [ORR/PFS from pivotal trial]
- Limitations: [Resistance, toxicity, access]

**SOC Comparator Feasibility**: [HIGH/MEDIUM/LOW]

## 6.2 Trial Design Options
### Option A: Single-Arm vs. SOC
- **Design**: Phase 2, single-arm, N=[X]
- **Comparator**: Historical SOC data (ORR=[%])
- **Pros**: Faster enrollment, smaller N
- **Cons**: Selection bias, regulatory skepticism
- **Feasibility Score**: [0-100]

### Option B: Randomized vs. SOC
- **Design**: Phase 2, 1:1 randomization, N=[X] per arm
- **Comparator**: Active control ([SOC drug])
- **Pros**: Robust comparison, regulatory preferred
- **Cons**: 2x enrollment, comparator sourcing
- **Feasibility Score**: [0-100]

### Option C: Non-Inferiority Design
- **Rationale**: [If aiming for better safety with similar efficacy]
- **Non-inferiority margin**: [Δ = X%]
- **Sample size**: [N] (larger than superiority)

## 6.3 Comparator Drug Sourcing
- Commercial availability: [Yes/No]
- Patent status: [Generic available?]
- Cost: [$X per course]
- Stability and storage: [Requirements]
```

### 7. Safety Endpoints & Monitoring Plan
```markdown
## 7.1 Primary Safety Endpoint
**Dose-Limiting Toxicity (DLT)** [for Phase 1 component]:
- DLT definition: [Grade 3+ non-hematologic, Grade 4+ hematologic]
- DLT assessment period: [Cycle 1, 28 days]
- Dose escalation rule: [3+3, BOIN, mTPI]

## 7.2 Mechanism-Based Toxicities
**Drug Class**: [Kinase inhibitor, checkpoint inhibitor, etc.]

**Expected Toxicities** [★★★: FAERS, label data]:
| Toxicity | Incidence | Grade 3+ | Monitoring |
|----------|-----------|----------|------------|
| Diarrhea | 60% | 10% | Symptom diary, hydration |
| Rash | 40% | 5% | Dermatology consult PRN |
| Hepatotoxicity | 20% | 3% | LFTs weekly (cycle 1), then q3w |
| [Specific AE] | [%] | [%] | [Plan] |

**Data Source**: FAERS_search_reports (similar drugs), drugbank_get_pharmacology

## 7.3 Organ-Specific Monitoring
```markdown
### Hepatic
- Baseline: LFTs, hepatitis panel
- Monitoring: AST/ALT/bili weekly (cycle 1), then q3w
- Stopping rule: ALT >5× ULN or bili >3× ULN

### Cardiac
- Baseline: ECG, ECHO if anthracycline history
- Monitoring: ECG q cycle, ECHO if symptoms
- Stopping rule: QTcF >500 ms, LVEF drop >15%

### Renal
- Baseline: Cr, eGFR, urinalysis
- Monitoring: Cr/eGFR q cycle
- Stopping rule: CrCl <30 mL/min

### [Organ X]
- [Similar structure]
```

## 7.4 Safety Monitoring Committee (SMC)
- Composition: [3 independent experts: oncologist, toxicologist, biostatistician]
- Review frequency: [After every 6 patients, then quarterly]
- Stopping rules: [≥3 DLTs at dose level, ≥2 drug-related deaths]
```

### 8. Study Design Recommendations
```markdown
## 8.1 Recommended Design
**Phase**: [1/2, 1b/2, 2]
**Design Type**: [Single-arm, randomized, basket, umbrella]
**Primary Objective**: [Assess safety and preliminary efficacy]

**Schema**:
```
[Indication + Biomarker]
    ↓ Screening (Biomarker testing)
    ↓ Enrollment
    ├─ [Phase 1 dose escalation: 3+3 design, N=12-18]
    │   Dose Levels: [X mg, Y mg, Z mg QD]
    │   DLT assessment: Cycle 1 (28 days)
    └─ [Phase 2 expansion: Simon 2-stage, N=43]
        Stage 1: N=13 (≥2 responses to proceed)
        Stage 2: N=30 additional
        Target ORR: 30% (H0: 10%, α=0.05, β=0.20)
```

## 8.2 Eligibility Criteria
**Inclusion**:
- Age ≥18 years
- Histologically confirmed [disease]
- [Biomarker] positive (central lab confirmed)
- Measurable disease per RECIST 1.1
- ECOG PS 0-1
- Adequate organ function
- [≤1 prior line for advanced disease]

**Exclusion**:
- Brain metastases (unless treated and stable)
- Prior [drug class] therapy
- Active infection, immunodeficiency
- Pregnancy/nursing
- Significant cardiovascular disease

## 8.3 Treatment Plan
- **Dosing**: [X mg PO QD, 28-day cycles]
- **Dose modifications**: [20% reductions for Grade 2+]
- **Duration**: Until progression, toxicity, or 24 months
- **Concomitant meds**: Supportive care allowed, restrictions on CYP3A4 inhibitors

## 8.4 Assessment Schedule
| Assessment | Screening | Cycle 1 | Cycles 2-6 | Cycles 7+ | EOT |
|------------|-----------|---------|------------|-----------|-----|
| History & PE | X | X | X | X | X |
| ECOG PS | X | X | X | X | X |
| Labs (CBC, CMP, LFT) | X | Weekly | q3w | q3w | X |
| Tumor imaging | X | - | q6w | q9w | X |
| ECG | X | - | q3w (if abnormal) | - | X |
| Biomarker (ctDNA) | X | C1D15 | q6w | - | X |
| AE assessment | - | Continuous | Continuous | Continuous | X |
```

### 9. Enrollment & Site Strategy
```markdown
## 9.1 Site Selection Criteria
**Required Capabilities**:
- [Biomarker] testing (or central lab partnership)
- Phase 1/2 experience
- GCP compliance, IRB approval
- Access to [patient population]
- Investigator publications in [indication]

**Geographic Distribution**:
- US sites: [N] (target regions: [high-incidence areas])
- International: [Consider Asia if biomarker enriched there]

## 9.2 Enrollment Projections
**Assumptions**:
- Screening rate: [X patients/site/month]
- Screen failure rate: [30%] (biomarker negative, eligibility)
- Enrollment rate: [Y patients/site/month]

**Timeline** (N=[total]):
| Milestone | Month | Cumulative Enrolled |
|-----------|-------|---------------------|
| First site activated | 0 | 0 |
| First patient enrolled | 1 | 1 |
| 25% enrollment | [M1] | [0.25N] |
| 50% enrollment | [M2] | [0.5N] |
| 75% enrollment | [M3] | [0.75N] |
| Last patient enrolled | [M4] | [N] |
| Primary analysis | [M4 + follow-up] | - |

**Sites Required**: [Minimum M sites to achieve timeline]

## 9.3 Recruitment Strategies
- Physician outreach: Academic consortia, tumor boards
- Patient advocacy groups: [Organization names]
- ClinicalTrials.gov listing (prominent, lay summary)
- Social media: Targeted ads in [indication] communities
- Referral network: Community oncologists
```

### 10. Regulatory Pathway
```markdown
## 10.1 FDA Pathway Selection
**Recommended**: [505(b)(1) / 505(b)(2) / Breakthrough / Orphan]

**Rationale**:
- [505(b)(1)]: New molecular entity, full development program
- [505(b)(2)]: [If relying on published safety data for similar drugs]
- **Breakthrough Therapy**: [If preliminary evidence of substantial improvement on serious outcome]
  - Criteria: [X-fold ORR vs. SOC in early data]
  - Benefits: Rolling review, frequent FDA meetings
- **Orphan Designation**: [If prevalence <200,000 in US]
  - Eligible if: [Biomarker-defined subtype constitutes orphan population]
  - Benefits: 7-year exclusivity, tax credits, fee waivers

## 10.2 Regulatory Precedents
**Similar Approvals** [★★★]:
- [Drug A]: [Indication], [Year], [Endpoint used], [N=X], [ORR=Y%]
- [Drug B]: [Indication], [Year], [Accelerated approval → full]
- Source: FDA_get_approval_history, drug labels

**FDA Guidance Documents**:
- [Relevant guidance title] (Year)
- Key recommendations: [e.g., ORR acceptable for Phase 2, confirmatory trial needed]

## 10.3 Pre-IND Meeting
**Recommended Topics**:
1. Primary endpoint acceptability (ORR vs. PFS)
2. Biomarker test qualification (CDx plan)
3. Comparator arm (single-arm acceptable?)
4. Pediatric study plan waiver
5. Safety monitoring plan

**Timing**: [3-4 months before IND submission]

## 10.4 IND Timeline
| Milestone | Month | Deliverable |
|-----------|-------|-------------|
| Pre-IND meeting request | -4 | Briefing package |
| Pre-IND meeting | -3 | FDA feedback |
| IND submission | 0 | Complete IND package |
| FDA 30-day review | 1 | Clinical hold or proceed |
| First patient dosed | 1-2 | After IND clearance |
```

### 11. Budget & Resource Considerations
```markdown
## 11.1 Cost Drivers
| Item | Cost Estimate | Notes |
|------|---------------|-------|
| Protocol development | $50-100K | CRO or internal |
| IND preparation | $100-200K | CMC, toxicology reports |
| Site activation | $50K/site × [M sites] | IRB, contracts |
| Patient recruitment | $200-500K | Advertising, patient navigation |
| [Biomarker] testing | $[X]/patient | Central lab, CDx |
| Imaging (RECIST) | $3-5K/scan × [N scans] | CT, independent review |
| Drug supply | [Depends on sponsor] | If not sponsor-provided |
| CRO monitoring | $100-300/hour | Site visits, SDV |
| Data management | $150-300K | EDC, database lock |
| Statistical analysis | $50-100K | SAP, CSR |
| **TOTAL (Phase 1/2)** | **$[X-Y]M** | [N patients, M sites] |

## 11.2 Timeline & FTE Requirements
**Duration**: [X months] (enrollment) + [Y months] (follow-up)
**Team**:
- Medical monitor: 0.5 FTE
- Project manager: 0.8 FTE
- Clinical operations: 0.3 FTE
- Data manager: 0.3 FTE
- Biostatistician: 0.2 FTE
```

### 12. Risk Assessment
```markdown
## 12.1 Feasibility Risks (High Priority)
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Slow enrollment (biomarker screen fail) | HIGH | HIGH | - Expand sites to [high-prevalence regions]<br>- Allow alternative biomarkers<br>- Liquid biopsy screening |
| Low response rate (ORR <10%) | MEDIUM | CRITICAL | - Interim futility analysis (Simon stage 1)<br>- Lower null hypothesis if justified<br>- Pivot to combination if single-agent weak |
| Unexpected toxicity (>33% DLT rate) | LOW | CRITICAL | - Conservative starting dose (50% MTD from preclin)<br>- Dose escalation with BOIN (adaptive)<br>- Close SMC oversight |
| Comparator drug supply issues | MEDIUM | MEDIUM | - Secure commercial supply early<br>- Generic sourcing if available |
| Regulatory pushback on single-arm design | MEDIUM | HIGH | - Pre-IND meeting to align<br>- Plan for randomized Phase 2b if needed |

## 12.2 Scientific Risks
- Biomarker hypothesis unvalidated: [Correlative studies to de-risk]
- Patient heterogeneity: [Stratification by [factor]]
- Resistance mechanisms: [Serial biopsies for molecular profiling]
```

### 13. Success Criteria & Go/No-Go Decision
```markdown
## 13.1 Phase 1 Success Criteria (Go to Phase 2)
- [ ] ≤33% DLT rate at RP2D
- [ ] ≥50% patients achieve [PD biomarker response]
- [ ] No unexpected safety signals (Grade 5 AEs, new class effects)
- [ ] PK supports QD dosing

## 13.2 Phase 2 Interim Analysis (Simon Stage 1)
- **Enrollment**: 13 patients
- **Decision Rule**:
  - ≥2 responses (ORR ≥15%) → Proceed to Stage 2
  - <2 responses → Stop for futility

## 13.3 Phase 2 Final Success Criteria (Advance to Phase 3)
- [ ] ORR ≥30% (95% CI lower bound >10%)
- [ ] Median DoR ≥6 months
- [ ] PFS signal (HR <0.7 vs. historical SOC)
- [ ] Safety profile manageable (Grade ≥3 AE <40%)
- [ ] Biomarker correlation with response (enrichment signal)

## 13.4 Feasibility Scorecard
| Dimension | Weight | Score (0-10) | Weighted | Grade |
|-----------|--------|--------------|----------|-------|
| **Patient Availability** | 30% | [X] | [0.30×X] | [★★☆] |
| - Base population size | - | [X] | - | [Source] |
| - Biomarker prevalence | - | [X] | - | [ClinVar data] |
| - Site access | - | [X] | - | [N sites feasible] |
| **Endpoint Precedent** | 25% | [X] | [0.25×X] | [★★★] |
| - Regulatory acceptance | - | [X] | - | [FDA approvals using ORR] |
| - Measurement feasibility | - | [X] | - | [RECIST standard] |
| **Regulatory Clarity** | 20% | [X] | [0.20×X] | [★★☆] |
| - Pathway defined | - | [X] | - | [Breakthrough potential] |
| - Precedent approvals | - | [X] | - | [Similar indications] |
| **Comparator Feasibility** | 15% | [X] | [0.15×X] | [★★★] |
| - SOC availability | - | [X] | - | [FDA-approved, generic] |
| - Historical data | - | [X] | - | [Published ORR: X%] |
| **Safety Monitoring** | 10% | [X] | [0.10×X] | [★★☆] |
| - Known toxicities | - | [X] | - | [FAERS, class effects] |
| - Monitoring plan | - | [X] | - | [Defined, feasible] |
| **TOTAL FEASIBILITY SCORE** | **100%** | - | **[XX/100]** | - |

**Interpretation**:
- **≥75**: HIGH feasibility - Recommend proceed to protocol development
- **50-74**: MODERATE feasibility - Additional validation recommended
- **<50**: LOW feasibility - Significant de-risking required
```

### 14. Recommendations & Next Steps
```markdown
## 14.1 Final Recommendation
**GO / CONDITIONAL GO / NO-GO**: [Decision]

**Rationale**:
[2-3 paragraphs synthesizing feasibility analysis. Example:]

This trial demonstrates HIGH feasibility (score: 82/100) for the following reasons:
1. **Patient availability is strong** (★★★): EGFR+ NSCLC affects ~18,000 US patients/year,
   with L858R representing 45% (8,100 patients). With 20 sites, enrollment of N=43 is
   achievable in 8-10 months.
2. **Endpoint precedent is robust** (★★★): ORR is FDA-accepted for accelerated approval
   in NSCLC (18 precedents since 2015). RECIST 1.1 is standard, feasible.
3. **Regulatory pathway is clear** (★★☆): 505(b)(1) with breakthrough therapy potential
   given 2x ORR improvement vs. SOC. Pre-IND meeting advised to confirm single-arm design.

**Key Risk**: Enrollment may slow if sites lack rapid EGFR testing. Mitigation: Central
liquid biopsy with 7-day turnaround.

## 14.2 Critical Path to IND
**Immediate Next Steps** (Months 0-3):
- [ ] Request pre-IND meeting with FDA (target Month 1)
- [ ] Initiate CDx partnership for [biomarker] test (FDA clearance path)
- [ ] Secure drug supply (GMP manufacturing, stability)
- [ ] Draft protocol (v1.0) and ICF
- [ ] Site feasibility surveys (target [M] sites)

**IND Preparation** (Months 3-6):
- [ ] Complete CMC section (drug substance/product, manufacturing)
- [ ] Finalize preclinical package (toxicology, pharmacology)
- [ ] Prepare clinical protocol (incorporate FDA feedback)
- [ ] Develop CRFs and EDC database
- [ ] IND submission (Month 6)

**Post-IND** (Months 6-9):
- [ ] IRB submissions (central IRB for multi-site)
- [ ] Site contracts and budgets
- [ ] Investigator meeting
- [ ] First patient enrolled (Month 7-8)

## 14.3 Alternative Designs (If Current Design Infeasible)
**Plan B**: [If enrollment too slow]
- Broaden biomarker criteria (e.g., all EGFR mutations, not just L858R)
- Add international sites (Asia, EU)
- Basket design (multiple cancers with EGFR mutations)

**Plan C**: [If single-arm rejected by FDA]
- Randomized Phase 2 (1:1 vs. SOC)
- Increase sample size to N=86 (43/arm)
- Requires 2x sites and budget

## 14.4 Long-Term Development Strategy
**If Phase 2 Successful**:
- Phase 3 design: Randomized, OS primary endpoint, N=300-500
- Companion diagnostic (CDx): Parallel FDA submission
- Commercial readiness: Manufacturing scale-up
- Patent strategy: File composition-of-matter or method-of-use

**Market Considerations**:
- Addressable market: [8,100 EGFR L858R NSCLC patients/year in US]
- Competitive landscape: [Osimertinib, other EGFR TKIs]
- Differentiation: [e.g., Activity against T790M resistance]
- Pricing: [$10-15K/month based on comparators]
```

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-clinical-trial-design/REFERENCE.md`
