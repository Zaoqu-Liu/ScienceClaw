# tooluniverse-immunotherapy-response-prediction — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 11: Clinical Recommendations

### Step 11.1: ICI Drug Selection Algorithm

```
IF MSI-H:
  -> Pembrolizumab (tissue-agnostic FDA approval)
  -> Nivolumab (CRC-specific)
  -> Consider nivo+ipi combination

IF TMB-H (>=10) and not MSI-H:
  -> Pembrolizumab (tissue-agnostic for TMB-H)

IF Cancer = Melanoma:
  IF PD-L1 >= 1%: pembrolizumab or nivolumab monotherapy
  ELSE: nivolumab + ipilimumab combination
  IF BRAF V600E: consider targeted therapy first if rapid response needed

IF Cancer = NSCLC:
  IF PD-L1 >= 50% and no STK11/EGFR: pembrolizumab monotherapy
  IF PD-L1 1-49%: pembrolizumab + chemotherapy
  IF PD-L1 < 1%: ICI + chemotherapy combination
  IF STK11 loss: ICI less likely effective
  IF EGFR/ALK positive: targeted therapy preferred over ICI

IF Cancer = RCC:
  -> Nivolumab + ipilimumab (IMDC intermediate/poor risk)
  -> Pembrolizumab + axitinib (all risk)

IF Cancer = Bladder:
  -> Pembrolizumab or atezolizumab (2L)
  -> Avelumab maintenance post-platinum
```

### Step 11.2: Monitoring Plan

**During ICI treatment, monitor**:
- Tumor response (CT/MRI every 8-12 weeks)
- Circulating tumor DNA (ctDNA) for early response
- Immune-related adverse events (irAEs)
- Thyroid function (TSH every 6 weeks)
- Liver function (every 2-4 weeks initially)
- Cortisol if symptoms

**Early response biomarkers**:
- ctDNA decrease at 4-6 weeks
- PET-CT metabolic response
- Circulating immune cell phenotyping

### Step 11.3: Alternative Strategies

If ICI response predicted to be LOW:
1. **Targeted therapy** (if actionable mutations: BRAF, EGFR, ALK, ROS1)
2. **Chemotherapy** (standard of care)
3. **ICI + chemotherapy combination** (may overcome low PD-L1)
4. **ICI + anti-angiogenic** (may convert cold to hot tumor)
5. **ICI + CTLA-4 combo** (nivolumab + ipilimumab)
6. **Clinical trial enrollment** (novel combinations)

---

## Output Report Format

Save report as `immunotherapy_response_prediction_{cancer_type}.md`

### Report Structure

```markdown
# Immunotherapy Response Prediction Report

## Executive Summary
[2-3 sentence summary: cancer type, ICI Response Score, recommendation]

## ICI Response Score: XX/100
**Response Likelihood: [HIGH/MODERATE/LOW]**
**Confidence: [HIGH/MODERATE/LOW]**
**Expected ORR: XX-XX%**

### Score Breakdown
| Component | Value | Score | Max |
|-----------|-------|-------|-----|
| TMB | XX mut/Mb | XX | 30 |
| MSI Status | MSI-H/MSS | XX | 25 |
| PD-L1 | XX% | XX | 20 |
| Neoantigen Load | XX est. | XX | 15 |
| Sensitivity Bonus | +XX | XX | 10 |
| Resistance Penalty | -XX | XX | -20 |
| **TOTAL** | | **XX** | **100** |

## Patient Profile
- **Cancer Type**: [cancer]
- **Mutations**: [list]
- **TMB**: XX mut/Mb [classification]
- **MSI Status**: [MSI-H/MSS/Unknown]
- **PD-L1**: XX% [scoring method]

## Biomarker Analysis

### TMB Analysis
[TMB classification, cancer-specific context, FDA TMB-H status]

### MSI/MMR Status
[MSI status, MMR gene mutations, FDA MSI-H approvals]

### PD-L1 Expression
[PD-L1 level, cancer-specific thresholds, scoring method]

### Neoantigen Burden
[Estimated neoantigen count, quality assessment, mutation types]

## Mutation Analysis

### Driver Mutations
[Analysis of each mutation - oncogenic role, ICI implications]

### Resistance Mutations
[Any STK11, PTEN, JAK1/2, B2M, KEAP1 etc. with penalties]

### Sensitivity Mutations
[Any POLE, PBRM1, DDR genes with bonuses]

## Immune Microenvironment
[Hot/cold classification, immune gene expression data]

## ICI Drug Recommendation

### Primary Recommendation
**[Drug name]** - [monotherapy/combination]
- Evidence: [FDA approval, trial data]
- Expected response: XX-XX%
- Key trial: [trial name/NCT#]

### Alternative Options
1. [Alternative 1] - [rationale]
2. [Alternative 2] - [rationale]

### Combination Strategies
[ICI+ICI, ICI+chemo, ICI+targeted recommendations]

## Clinical Evidence
[Key trials, response rates, PFS/OS data for this cancer + biomarker profile]

## Resistance Risk
- **Risk Level**: [LOW/MODERATE/HIGH]
- **Key Factors**: [list resistance mutations/mechanisms]
- **Mitigation**: [combination strategies]

## Monitoring Plan
- **Response assessment**: [schedule]
- **Biomarkers to track**: [ctDNA, imaging, labs]
- **irAE monitoring**: [schedule]
- **Resistance monitoring**: [when to suspect progression]

## Alternative Strategies (if ICI unlikely effective)
[Targeted therapy, chemotherapy, clinical trials]

## Evidence Grading
| Finding | Evidence Tier | Source |
|---------|-------------|--------|
| [finding 1] | T1 (FDA/Guidelines) | [source] |
| [finding 2] | T2 (Clinical trial) | [source] |

## Data Completeness
| Biomarker | Status | Impact |
|-----------|--------|--------|
| TMB | Provided/Estimated/Unknown | XX points |
| MSI | Provided/Unknown | XX points |
| PD-L1 | Provided/Unknown | XX points |
| Neoantigen | Estimated | XX points |
| Mutations | X provided | +/-XX points |

## Missing Data Recommendations
[What additional tests would improve prediction accuracy]

---
*Generated by ToolUniverse Immunotherapy Response Prediction Skill*
*Sources: OpenTargets, CIViC, FDA, DrugBank, PubMed, IEDB, HPA, cBioPortal*
```

---

## Evidence Tiers

| Tier | Description | Source Examples |
|------|-------------|----------------|
| T1 | FDA-approved biomarker/indication | FDA labels, NCCN guidelines |
| T2 | Phase 2-3 clinical trial evidence | Published trial data, PubMed |
| T3 | Preclinical/computational evidence | Pathway analysis, in vitro data |
| T4 | Expert opinion/case reports | Case series, reviews |

---

## Use Case Examples

### Use Case 1: NSCLC with High TMB
**Input**: "NSCLC, TMB 25, PD-L1 80%, no STK11 mutation"
**Expected**: ICI Score 70-85, HIGH response, pembrolizumab monotherapy recommended

### Use Case 2: Melanoma with BRAF
**Input**: "Melanoma, BRAF V600E, TMB 15, PD-L1 50%"
**Expected**: ICI Score 50-65, MODERATE response, discuss ICI vs BRAF-targeted

### Use Case 3: MSI-H Colorectal
**Input**: "Colorectal cancer, MSI-high, TMB 40"
**Expected**: ICI Score 80-95, HIGH response, pembrolizumab first-line

### Use Case 4: Low Biomarker NSCLC
**Input**: "NSCLC, TMB 2, PD-L1 <1%, STK11 mutation"
**Expected**: ICI Score 5-20, LOW response, chemotherapy preferred

### Use Case 5: Bladder Cancer
**Input**: "Bladder cancer, TMB 12, PD-L1 10%, no resistance mutations"
**Expected**: ICI Score 45-55, MODERATE response, ICI+chemo or maintenance

### Use Case 6: Checkpoint Inhibitor Selection
**Input**: "Which ICI for NSCLC with PD-L1 90%?"
**Expected**: Pembrolizumab monotherapy first-line, evidence from KEYNOTE-024

---

## Completeness Checklist

Before finalizing the report, verify:

- [ ] Cancer type resolved to EFO ID
- [ ] All mutations parsed and genes resolved
- [ ] TMB classified with cancer-specific context
- [ ] MSI/MMR status assessed
- [ ] PD-L1 integrated (or flagged as unknown)
- [ ] Neoantigen burden estimated
- [ ] Resistance mutations checked (STK11, PTEN, JAK1/2, B2M, KEAP1)
- [ ] Sensitivity mutations checked (POLE, PBRM1, DDR)
- [ ] FDA-approved ICIs identified for this cancer
- [ ] Clinical trial evidence retrieved
- [ ] ICI Response Score calculated with component breakdown
- [ ] Drug recommendation provided with evidence
- [ ] Monitoring plan included
- [ ] Alternative strategies for low responders
- [ ] Evidence grading applied to all findings
- [ ] Data completeness documented
- [ ] Missing data recommendations provided
- [ ] Report saved to file
