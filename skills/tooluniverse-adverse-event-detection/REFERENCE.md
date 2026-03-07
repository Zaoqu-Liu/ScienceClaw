# tooluniverse-adverse-event-detection — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 8: Risk Assessment & Safety Signal Score

### 8.1 Safety Signal Score Calculation (0-100)

The Safety Signal Score quantifies overall drug safety concern on a 0-100 scale (higher = more concern).

**Component 1: FAERS Signal Strength (0-35 points)**
```
If any signal has PRR >= 5 AND ROR lower CI >= 3: 35 points
If any signal has PRR 3-5 AND ROR lower CI 2-3: 20 points
If any signal has PRR 2-3 AND ROR lower CI 1-2: 10 points
If no signals detected: 0 points
```

**Component 2: Serious Adverse Events (0-30 points)**
```
Deaths reported with high count (>100): 30 points
Deaths reported with low count (1-100): 25 points
Life-threatening events: 20 points
Hospitalizations only: 15 points
Non-serious only: 0 points
```

**Component 3: FDA Label Warnings (0-25 points)**
```
Boxed warning present: 25 points
Drug withdrawn or restricted: 25 points
Contraindications present: 15 points
Warnings and precautions: 10 points
Adverse reactions only: 5 points
No label warnings: 0 points
```

**Component 4: Literature Evidence (0-10 points)**
```
Meta-analyses confirming safety signals: 10 points
Multiple RCTs with safety concerns: 7 points
Case reports/case series: 4 points
No published safety concerns: 0 points
```

**Total Score Interpretation:**
| Score Range | Interpretation | Action |
|-------------|---------------|--------|
| **75-100** | High concern | Serious safety signals; requires immediate regulatory attention |
| **50-74** | Moderate concern | Significant monitoring needed; consider risk mitigation |
| **25-49** | Low-moderate concern | Routine enhanced monitoring; standard risk management |
| **0-24** | Low concern | Standard safety profile; routine pharmacovigilance |

### 8.2 Evidence Grading

| Tier | Criteria | Example |
|------|----------|---------|
| **T1** | Boxed warning, confirmed by RCTs, PRR > 10 | Metformin: Lactic acidosis |
| **T2** | Label warning + FAERS signal (PRR 3-10) + published studies | Atorvastatin: Rhabdomyolysis |
| **T3** | FAERS signal (PRR 2-3) + case reports | Atorvastatin: Pancreatitis |
| **T4** | Computational prediction only (ADMET) or weak signal | ADMETAI hepatotoxicity prediction |

### 8.3 Output for Report

```markdown
## 9. Risk Assessment

### 9.1 Safety Signal Score: 62/100 (MODERATE CONCERN)

| Component | Score | Max | Rationale |
|-----------|-------|-----|-----------|
| FAERS Signal Strength | 35 | 35 | Strong signals (PRR >= 5 for rhabdomyolysis) |
| Serious Adverse Events | 15 | 30 | Hospitalizations; deaths uncommon for drug itself |
| FDA Label Warnings | 10 | 25 | Warnings/precautions but no boxed warning |
| Literature Evidence | 7 | 10 | Multiple RCTs confirm muscle-related risks |
| **TOTAL** | **62** | **100** | **MODERATE CONCERN** |

### 9.2 Evidence-Graded Signals

| Signal | Grade | PRR | Serious | Label | Literature | Overall |
|--------|-------|-----|---------|-------|------------|---------|
| Rhabdomyolysis | T2 | 4.79 | Yes | Warning | Confirmed | Moderate |
| Myopathy | T2 | 6.12 | Yes | Warning | Confirmed | Moderate |
| Hepatotoxicity | T3 | 3.45 | Rare | Warning | Case reports | Low-Moderate |
| Diabetes risk | T3 | 1.89 | No | Warning | RCT data | Low |
```

---

## Phase 9: Report Synthesis & Recommendations

### 9.1 Report Template

**File**: `[DRUG]_adverse_event_report.md`

```markdown
# Adverse Drug Event Signal Detection Report: [DRUG]

**Generated**: [Date] | **Drug**: [Generic Name] | **ChEMBL ID**: [ID]
**Safety Signal Score**: [XX/100] ([INTERPRETATION])

---

## Executive Summary

[2-3 paragraph summary of key findings]

**Key Safety Signals**:
1. [Strongest signal with PRR/ROR]
2. [Second signal]
3. [Third signal]

**Regulatory Status**: [Boxed warning Y/N] | [Withdrawn Y/N] | [Restrictions]

---

## 1. Drug Identification
[Phase 0 output]

## 2. FAERS Adverse Event Profile
[Phase 1 output]

## 3. Disproportionality Analysis
[Phase 2 output]

## 4. FDA Label Safety Information
[Phase 3 output]

## 5. Mechanism-Based Context
[Phase 4 output]

## 6. Comparative Safety Analysis
[Phase 5 output]

## 7. Drug-Drug Interactions & PGx Risk
[Phase 6 output]

## 8. Literature Evidence
[Phase 7 output]

## 9. Risk Assessment
[Phase 8 output]

## 10. Clinical Recommendations

### 10.1 Monitoring Recommendations
| Parameter | Frequency | Rationale |
|-----------|-----------|-----------|
| [Lab test] | [Frequency] | [Why] |

### 10.2 Risk Mitigation Strategies
| Risk | Mitigation | Evidence |
|------|-----------|----------|
| [Risk] | [Strategy] | [Source] |

### 10.3 Patient Counseling Points
- [Point 1]
- [Point 2]

### 10.4 Populations at Higher Risk
| Population | Risk Factor | Recommendation |
|-----------|-------------|----------------|
| [Group] | [Factor] | [Action] |

---

## 11. Completeness Checklist
[See below]

## 12. Data Sources
[All tools and databases used with timestamps]
```

---

## Completeness Checklist

### Phase 0: Drug Disambiguation
- [ ] Generic name resolved
- [ ] ChEMBL ID obtained
- [ ] DrugBank ID obtained
- [ ] Drug class identified
- [ ] Mechanism of action stated
- [ ] Primary target identified
- [ ] Blackbox/withdrawal status checked

### Phase 1: FAERS Profiling
- [ ] Top adverse events queried (>=15 events)
- [ ] Seriousness distribution obtained
- [ ] Outcome distribution obtained
- [ ] Age distribution obtained
- [ ] Death-related events counted
- [ ] Reporter country distribution obtained

### Phase 2: Disproportionality Analysis
- [ ] PRR calculated for >= 10 adverse events
- [ ] ROR with 95% CI for each event
- [ ] IC with 95% CI for each event
- [ ] Signal strength classified for each
- [ ] Demographics stratified for strong signals

### Phase 3: FDA Label
- [ ] Boxed warnings checked (or confirmed none)
- [ ] Contraindications extracted
- [ ] Warnings and precautions extracted
- [ ] Adverse reactions from label
- [ ] Drug interactions from label
- [ ] Special populations (pregnancy, geriatric, pediatric)

### Phase 4: Mechanism Context
- [ ] Target safety profile (OpenTargets)
- [ ] OpenTargets adverse events queried
- [ ] ADMET predictions (if SMILES available)

### Phase 5: Comparative Analysis
- [ ] At least 1 class comparison performed
- [ ] Class-wide vs drug-specific signals identified
- [ ] Aggregate class AEs computed (if applicable)

### Phase 6: DDIs & PGx
- [ ] DDIs from FDA label extracted
- [ ] PharmGKB queried
- [ ] Dosing guidelines checked
- [ ] FDA PGx biomarkers checked

### Phase 7: Literature
- [ ] PubMed searched (>=10 articles)
- [ ] OpenAlex citation analysis (if time permits)
- [ ] Key safety publications cited

### Phase 8: Risk Assessment
- [ ] Safety Signal Score calculated (0-100)
- [ ] Each signal evidence-graded (T1-T4)
- [ ] Score interpretation provided

### Phase 9: Report
- [ ] Report file created and saved
- [ ] Executive summary written
- [ ] Monitoring recommendations provided
- [ ] Risk mitigation strategies listed
- [ ] Patient counseling points included
- [ ] All sources cited

---

## Tool Parameter Reference (Verified)

### FAERS Tools (OpenFDA-based)

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `FAERS_count_reactions_by_drug_event` | `medicinalproduct` (REQUIRED), `patientsex`, `patientagegroup`, `occurcountry` | Returns [{term, count}] |
| `FAERS_count_seriousness_by_drug_event` | `medicinalproduct` (REQUIRED), `patientsex`, `patientagegroup`, `occurcountry` | Returns [{term: "Serious"/"Non-serious", count}] |
| `FAERS_count_outcomes_by_drug_event` | `medicinalproduct` (REQUIRED), `patientsex`, `patientagegroup`, `occurcountry` | Returns [{term: "Fatal"/"Recovered"/..., count}] |
| `FAERS_count_patient_age_distribution` | `medicinalproduct` (REQUIRED) | Returns [{term: "Elderly"/"Adult"/..., count}] |
| `FAERS_count_death_related_by_drug` | `medicinalproduct` (REQUIRED) | Returns [{term: "alive"/"death", count}] |
| `FAERS_count_reportercountry_by_drug_event` | `medicinalproduct` (REQUIRED), `patientsex`, `patientagegroup`, `serious` | Returns [{term: "US"/"GB"/..., count}] |
| `FAERS_search_adverse_event_reports` | `medicinalproduct`, `limit` (max 100), `skip` | Returns individual case reports with patient/drug/reaction data |
| `FAERS_search_reports_by_drug_and_reaction` | `medicinalproduct` (REQUIRED), `reactionmeddrapt` (REQUIRED), `limit`, `skip`, `patientsex`, `serious` | Returns individual reports filtered by specific reaction |
| `FAERS_search_serious_reports_by_drug` | `medicinalproduct` (REQUIRED), `seriousnessdeath`, `seriousnesshospitalization`, `seriousnesslifethreatening`, `seriousnessdisabling`, `limit` | Returns serious event reports |

### FAERS Analytics Tools (operation-based)

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `FAERS_calculate_disproportionality` | `operation`="calculate_disproportionality", `drug_name` (REQUIRED), `adverse_event` (REQUIRED) | Returns PRR, ROR, IC with 95% CI and signal detection |
| `FAERS_analyze_temporal_trends` | `operation`="analyze_temporal_trends", `drug_name` (REQUIRED), `adverse_event` (optional) | Returns yearly counts and trend direction |
| `FAERS_compare_drugs` | `operation`="compare_drugs", `drug1` (REQUIRED), `drug2` (REQUIRED), `adverse_event` (REQUIRED) | Returns PRR/ROR/IC for both drugs side-by-side |
| `FAERS_filter_serious_events` | `operation`="filter_serious_events", `drug_name` (REQUIRED), `seriousness_type` (death/hospitalization/disability/life_threatening/all) | Returns top serious reactions with counts |
| `FAERS_stratify_by_demographics` | `operation`="stratify_by_demographics", `drug_name` (REQUIRED), `adverse_event` (REQUIRED), `stratify_by` (sex/age/country) | Returns stratified counts and percentages. Sex codes: 0=Unknown, 1=Male, 2=Female |
| `FAERS_rollup_meddra_hierarchy` | `operation`="rollup_meddra_hierarchy", `drug_name` (REQUIRED) | Returns top 50 preferred terms with counts |

### FAERS Aggregate Tools (multi-drug)

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `FAERS_count_additive_adverse_reactions` | `medicinalproducts` (REQUIRED, array), `patientsex`, `patientagegroup`, `occurcountry`, `serious`, `seriousnessdeath` | Aggregates AE counts across multiple drugs |
| `FAERS_count_additive_seriousness_classification` | `medicinalproducts` (REQUIRED, array), `patientsex`, `patientagegroup`, `occurcountry` | Aggregates seriousness across multiple drugs |
| `FAERS_count_additive_reaction_outcomes` | `medicinalproducts` (REQUIRED, array) | Aggregates outcomes across multiple drugs |

### FDA Label Tools

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `FDA_get_boxed_warning_info_by_drug_name` | `drug_name` | Returns `{error: {code: "NOT_FOUND"}}` if no boxed warning |
| `FDA_get_contraindications_by_drug_name` | `drug_name` | Returns `{meta: {total: N}, results: [{contraindications: [...]}]}` |
| `FDA_get_adverse_reactions_by_drug_name` | `drug_name` | Returns `{meta: {total: N}, results: [{adverse_reactions: [...]}]}` |
| `FDA_get_warnings_by_drug_name` | `drug_name` | Returns `{meta: {total: N}, results: [{warnings: [...]}]}` |
| `FDA_get_drug_interactions_by_drug_name` | `drug_name` | Returns `{meta: {total: N}, results: [{drug_interactions: [...]}]}` |
| `FDA_get_pharmacogenomics_info_by_drug_name` | `drug_name` | Returns PGx info from label |
| `FDA_get_pregnancy_or_breastfeeding_info_by_drug_name` | `drug_name` | Returns pregnancy info |
| `FDA_get_geriatric_use_info_by_drug_name` | `drug_name` | Returns geriatric use info |
| `FDA_get_pediatric_use_info_by_drug_name` | `drug_name` | Returns pediatric info |

### OpenTargets Tools

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `OpenTargets_get_drug_chembId_by_generic_name` | `drugName` | Returns `{data: {search: {hits: [{id, name, description}]}}}` |
| `OpenTargets_get_drug_adverse_events_by_chemblId` | `chemblId` | Returns `{data: {drug: {adverseEvents: {count, rows: [{name, meddraCode, count, logLR}]}}}}` |
| `OpenTargets_get_drug_blackbox_status_by_chembl_ID` | `chemblId` | Returns `{data: {drug: {hasBeenWithdrawn, blackBoxWarning}}}` |
| `OpenTargets_get_drug_warnings_by_chemblId` | `chemblId` | Returns drug warnings (may be empty) |
| `OpenTargets_get_drug_mechanisms_of_action_by_chemblId` | `chemblId` | Returns `{data: {drug: {mechanismsOfAction: {rows: [{mechanismOfAction, actionType, targetName, targets}]}}}}` |
| `OpenTargets_get_drug_indications_by_chemblId` | `chemblId` | Returns approved and investigational indications |
| `OpenTargets_get_target_safety_profile_by_ensemblID` | `ensemblId` | Returns `{data: {target: {safetyLiabilities: [{event, effects, studies, datasource}]}}}` |

### DrugBank Tools

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `drugbank_get_safety_by_drug_name_or_drugbank_id` | `query`, `case_sensitive` (bool), `exact_match` (bool), `limit` | Returns toxicity, food interactions |
| `drugbank_get_targets_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Returns drug targets |
| `drugbank_get_drug_interactions_by_drug_name_or_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Returns DDIs |
| `drugbank_get_pharmacology_by_drug_name_or_drugbank_id` | `query`, `case_sensitive`, `exact_match`, `limit` | Returns pharmacology |

### PharmGKB Tools

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `PharmGKB_search_drugs` | `query` | Returns `{data: [{id, name, smiles}]}` |
| `PharmGKB_get_drug_details` | `drug_id` (e.g., "PA448500") | Returns detailed drug info |
| `PharmGKB_get_dosing_guidelines` | `guideline_id`, `gene` (both optional) | Returns dosing guidelines |
| `PharmGKB_get_clinical_annotations` | `annotation_id`, `gene_id` (both optional) | Returns clinical annotations |
| `fda_pharmacogenomic_biomarkers` | `drug_name`, `biomarker`, `limit` | Returns `{count, results: [...]}` |

### ADMETAI Tools

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `ADMETAI_predict_toxicity` | `smiles` (REQUIRED, array of strings) | Predicts hepatotoxicity, cardiotoxicity, etc. |
| `ADMETAI_predict_CYP_interactions` | `smiles` (REQUIRED, array) | Predicts CYP inhibition/substrate |

### Literature Tools

| Tool | Key Parameters | Notes |
|------|---------------|-------|
| `PubMed_search_articles` | `query`, `limit` | Returns list of article dicts |
| `openalex_search_works` | `query`, `limit` | Returns works with citation counts |
| `EuropePMC_search_articles` | `query`, `source` ("PPR" for preprints), `pageSize` | Returns articles including preprints |
| `search_clinical_trials` | `query_term` (REQUIRED), `condition`, `intervention`, `pageSize` | Returns clinical trials |

---

## Fallback Chains

| Primary Tool | Fallback 1 | Fallback 2 |
|--------------|------------|------------|
| `FAERS_calculate_disproportionality` | Manual calculation from `FAERS_count_*` data | Literature PRR values |
| `FAERS_count_reactions_by_drug_event` | `FAERS_rollup_meddra_hierarchy` | OpenTargets adverse events |
| `FDA_get_boxed_warning_info_by_drug_name` | `OpenTargets_get_drug_blackbox_status_by_chembl_ID` | DrugBank safety |
| `FDA_get_contraindications_by_drug_name` | `FDA_get_warnings_by_drug_name` | DrugBank safety |
| `OpenTargets_get_drug_chembId_by_generic_name` | `ChEMBL_search_drugs` | Manual search |
| `PharmGKB_search_drugs` | `fda_pharmacogenomic_biomarkers` | FDA label PGx section |
| `PubMed_search_articles` | `openalex_search_works` | `EuropePMC_search_articles` |

---

## Common Patterns

### Pattern 1: Full Safety Signal Profile for a Single Drug
Use all phases (0-9) for comprehensive report. Best for regulatory submissions, safety reviews.

### Pattern 2: Specific Adverse Event Investigation
Focus on Phases 0, 2, 3, 7. User asks "Does [drug] cause [event]?" - calculate disproportionality for that specific event, check label, search literature.

### Pattern 3: Drug Class Comparison
Focus on Phases 0, 2, 5. Compare 3-5 drugs in same class for a specific adverse event using `FAERS_compare_drugs`.

### Pattern 4: Emerging Signal Detection
Focus on Phases 1, 2, 7. Screen top 20+ FAERS events for signals, identify any not in FDA label (Phase 3), search recent literature for confirmation.

### Pattern 5: Pharmacogenomic Risk Assessment
Focus on Phases 0, 6. Identify genetic risk factors for adverse events using PharmGKB and FDA PGx biomarkers.

### Pattern 6: Pre-Approval Safety Assessment
Focus on Phases 4, 7. Use ADMET predictions and target safety profiles when FAERS data is limited (new drugs).

---

## Edge Cases

### Drug with No FAERS Reports
- Skip Phases 1-2
- Rely on FDA label (Phase 3), mechanism predictions (Phase 4), and literature (Phase 7)
- Safety Signal Score will be lower due to lack of signal detection data

### Generic vs Brand Name
- Always try both names in FAERS queries (FAERS uses brand names sometimes)
- Use `OpenTargets_get_drug_chembId_by_generic_name` to resolve to standard identifier
- Use `FDA_get_brand_name_generic_name` for name cross-reference

### Drug Combinations
- Use `FAERS_search_reports_by_drug_combination` for polypharmacy analysis
- Distinguish combination AEs from individual drug AEs
- Use `FAERS_count_additive_adverse_reactions` for aggregate class analysis

### Confounding by Indication
- Compare AE profile to the disease being treated
- Example: "Death" reports for chemotherapy drugs may reflect disease progression
- Always note this limitation in the report

### Drugs with Boxed Warnings
- Score component automatically 25/25 for label warnings
- Prioritize boxed warning events in disproportionality analysis
- Cross-reference boxed warning with FAERS signal strength
