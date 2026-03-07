---
name: tooluniverse-drug-research
description: Generates comprehensive drug research reports with compound disambiguation, evidence grading, and mandatory completeness sections. Covers identity, chemistry, pharmacology, targets, clinical trials, safety, pharmacogenomics, and ADMET properties. Use when users ask about drugs, medications, therapeutics, or need drug profiling, safety assessment, or clinical development research.
---

# Drug Research Strategy

Comprehensive drug investigation using 50+ ToolUniverse tools across chemical databases, clinical trials, adverse events, pharmacogenomics, and literature.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create report file FIRST, then populate progressively
2. **Compound disambiguation FIRST** - Resolve identifiers before research
3. **Citation requirements** - Every fact must have inline source attribution
4. **Evidence grading** - Grade claims by evidence strength
5. **Mandatory completeness** - All sections must exist, even if "data unavailable"
6. **English-first queries** - Always use English drug/compound names in tool calls, even if the user writes in another language. Only try original-language terms as a fallback. Respond in the user's language

---

## Critical Workflow Requirements

### 1. Report-First Approach (MANDATORY)

**DO NOT** show the search process or tool outputs to the user. Instead:

1. **Create the report file FIRST** - Before any data collection, create a markdown file:
   - File name: `[DRUG]_drug_report.md` (e.g., `metformin_drug_report.md`)
   - Initialize with all 11 section headers from the template
   - Add placeholder text: `[Researching...]` in each section

2. **Progressively update the report** - As you gather data:
   - Update each section with findings immediately after retrieving data
   - Replace `[Researching...]` with actual content
   - The user sees the report growing, not the search process

3. **Use ALL relevant tools** - For comprehensive coverage:
   - Query multiple databases for each data type
   - Cross-reference information across sources
   - Use fallback tools when primary tools return limited data

### 2. Citation Requirements (MANDATORY)

**Every piece of information MUST include its source.** Use inline citations:

```markdown
## 3. Mechanism & Targets

### 3.1 Primary Mechanism
Metformin activates AMP-activated protein kinase (AMPK), reducing hepatic glucose 
production and increasing insulin sensitivity in peripheral tissues.

*Source: PubChem via `PubChem_get_drug_label_info_by_CID` (CID: 4091)*

### 3.2 Primary Target(s)
| Target | UniProt | Activity | Potency | Source |
|--------|---------|----------|---------|--------|
| AMPK (PRKAA1) | Q13131 | Activator | EC50 ~10 µM | ChEMBL |
| Mitochondrial Complex I | - | Inhibitor | IC50 ~1 mM | Literature |

*Source: ChEMBL via `ChEMBL_get_target_by_chemblid` (CHEMBL1431)*
```

### Citation Format

For each data section, include at the end:

```markdown
---
**Data Sources for this section:**
- PubChem: `PubChem_get_compound_properties_by_CID` (CID: 4091)
- ChEMBL: `ChEMBL_get_bioactivity_by_chemblid` (CHEMBL1431)
- DGIdb: `DGIdb_get_drug_info` (metformin)
---
```

### 3. Progressive Writing Workflow

```
Step 1: Create report file with all section headers
        ↓
Step 2: Resolve compound identifiers → Update Section 1
        ↓
Step 3: Query PubChem/ADMET-AI/DailyMed SPL → Update Section 2 (Chemistry)
        ↓
Step 4: Query FDA Label MOA + ChEMBL activities + DGIdb → Update Section 3 (Mechanism & Targets)
        ↓
Step 5: Query ADMET-AI tools → Update Section 4 (ADMET)
        ↓
Step 6: Query ClinicalTrials.gov → Update Section 5 (Clinical Development)
        ↓
Step 7: Query FAERS/DailyMed → Update Section 6 (Safety)
        ↓
Step 8: Query PharmGKB → Update Section 7 (Pharmacogenomics)
        ↓
Step 9: Query DailyMed → Update Section 8 (Regulatory)
        ↓
Step 10: Query PubMed/literature → Update Section 9 (Literature)
        ↓
Step 11: Synthesize findings → Update Executive Summary & Section 10
        ↓
Step 12: Document all sources → Update Section 11 (Data Sources)
```

### 4. Report Detail Requirements

Each section must be **comprehensive and detailed**:

- **Tables**: Use tables for structured data (targets, trials, adverse events)
- **Lists**: Use bullet points for features, findings, key points
- **Paragraphs**: Include narrative summaries that synthesize findings
- **Numbers**: Include specific values, counts, percentages (not vague terms)
- **Context**: Explain what the data means, not just what it is

**BAD** (too brief):
```markdown
### Clinical Trials
Multiple trials completed. Approved for diabetes.
```

**GOOD** (detailed with sources):
```markdown
### 5.2 Clinical Trial Landscape

| Phase | Total | Completed | Recruiting | Status |
|-------|-------|-----------|------------|--------|
| Phase 4 | 89 | 72 | 12 | Post-marketing |
| Phase 3 | 156 | 134 | 15 | Pivotal |
| Phase 2 | 203 | 178 | 18 | Dose-finding |
| Phase 1 | 67 | 61 | 4 | Safety |

*Source: ClinicalTrials.gov via `search_clinical_trials` (intervention="metformin")*

**Total Registered Trials**: 515 (as of 2026-02-04)
**Primary Indications Under Investigation**: Type 2 diabetes (312), PCOS (87), Cancer (45), Obesity (38), NAFLD (33)

### Trial Outcomes Summary
- **Glycemic Control**: Mean HbA1c reduction of 1.0-1.5% in monotherapy [★★★: NCT00123456]
- **Cardiovascular**: UKPDS showed 39% reduction in MI risk [★★★: PMID:9742976]
- **Cancer Prevention**: Mixed results; ongoing investigation [★★☆: NCT02019979]

*Source: `extract_clinical_trial_outcomes` for NCT IDs listed*
```

---

## Initial Report Template (Create This First)

When starting research, **immediately create this file** before any tool calls:

**File**: `[DRUG]_drug_report.md`

```markdown
# Drug Research Report: [DRUG NAME]

**Generated**: [Date] | **Query**: [Original query] | **Status**: In Progress

---

## Executive Summary
[Researching...]

---

## 1. Compound Identity
### 1.1 Database Identifiers
[Researching...]
### 1.2 Structural Information
[Researching...]
### 1.3 Names & Synonyms
[Researching...]

---

## 2. Chemical Properties
### 2.1 Physicochemical Profile
[Researching...]
### 2.2 Drug-Likeness Assessment
[Researching...]
### 2.3 Solubility & Permeability
[Researching...]
### 2.4 Salt Forms & Polymorphs
[Researching...]
### 2.5 Structure Visualization
[Researching...]

---

## 3. Mechanism & Targets
### 3.1 Primary Mechanism of Action
[Researching...]
### 3.2 Primary Target(s)
[Researching...]
### 3.3 Target Selectivity & Off-Targets
[Researching...]
### 3.4 Bioactivity Profile (ChEMBL)
[Researching...]

---

## 4. ADMET Properties
### 4.1 Absorption
[Researching...]
### 4.2 Distribution
[Researching...]
### 4.3 Metabolism
[Researching...]
### 4.4 Excretion
[Researching...]
### 4.5 Toxicity Predictions
[Researching...]

---

## 5. Clinical Development
### 5.1 Development Status
[Researching...]
### 5.2 Clinical Trial Landscape
[Researching...]
### 5.3 Approved Indications
[Researching...]
### 5.4 Investigational Indications
[Researching...]
### 5.5 Key Efficacy Data
[Researching...]
### 5.6 Biomarkers & Companion Diagnostics
[Researching...]

---

## 6. Safety Profile
### 6.1 Clinical Adverse Events
[Researching...]
### 6.2 Post-Marketing Safety (FAERS)
[Researching...]
### 6.3 Black Box Warnings
[Researching...]
### 6.4 Contraindications
[Researching...]
### 6.5 Drug-Drug Interactions
[Researching...]
### 6.5.2 Drug-Food Interactions
[Researching...]
### 6.6 Dose Modification Guidance
[Researching...]
### 6.7 Drug Combinations & Regimens
[Researching...]

---

## 7. Pharmacogenomics
### 7.1 Relevant Pharmacogenes
[Researching...]
### 7.2 Clinical Annotations
[Researching...]
### 7.3 Dosing Guidelines (CPIC/DPWG)
[Researching...]
### 7.4 Actionable Variants
[Researching...]

---

## 8. Regulatory & Labeling
### 8.1 Approval Status
[Researching...]
### 8.2 Label Highlights
[Researching...]
### 8.3 Patents & Exclusivity
[Researching...]
### 8.4 Label Changes & Warnings
[Researching...]
### 8.5 Special Populations
[Researching...]
### 8.6 Regulatory Timeline & History
[Researching...]

---

## 9. Literature & Research Landscape
### 9.1 Publication Metrics
[Researching...]
### 9.2 Research Themes
[Researching...]
### 9.3 Recent Key Publications
[Researching...]
### 9.4 Real-World Evidence
[Researching...]

---

## 10. Conclusions & Assessment
### 10.1 Drug Profile Scorecard
[Researching...]
### 10.2 Key Strengths
[Researching...]
### 10.3 Key Concerns/Limitations
[Researching...]
### 10.4 Research Gaps
[Researching...]
### 10.5 Comparative Analysis
[Researching...]

---

## 11. Data Sources & Methodology
### 11.1 Primary Data Sources
[Researching...]
### 11.2 Tool Call Summary
[Researching...]
### 11.3 Quality Control Metrics
[Researching...]
```

Then progressively replace `[Researching...]` with actual findings as you query each tool.

---

## FDA Label Core Fields Bundle

**For approved drugs, ALWAYS retrieve these FDA label sections early** (after getting set_id from `DailyMed_search_spls`):

### Critical Label Sections

Call `DailyMed_get_spl_sections_by_setid(setid=set_id, sections=[...])` with these sections:

**Phase 1 (Mechanism & Chemistry)**:
- `mechanism_of_action` → Section 3.1
- `pharmacodynamics` → Section 3.1
- `chemistry` → Section 2.4

**Phase 2 (ADMET & PK)**:
- `clinical_pharmacology` → Section 4
- `pharmacokinetics` → Section 4.1-4.4
- `drug_interactions` → Section 4.3, 6.5

**Phase 3 (Safety & Dosing)**:
- `warnings_and_cautions` → Section 6.3
- `adverse_reactions` → Section 6.1
- `dosage_and_administration` → Section 6.6, 8.2

**Phase 4 (PGx & Clinical)**:
- `pharmacogenomics` → Section 7
- `clinical_studies` → Section 5.5
- `description` → Section 2.5 (formulation)
- `inactive_ingredients` → Section 2.5

### Label Extraction Strategy

```
1. Get set_id: DailyMed_search_spls(drug_name)
   
2. Batch call for all core sections (or 3-4 calls with 4-5 sections each):
   DailyMed_get_spl_sections_by_setid(setid=set_id, sections=["mechanism_of_action", "pharmacodynamics", ...])
   
3. Extract and populate report sections as you retrieve data
```

This ensures you have authoritative FDA-approved information even if prediction tools fail.

---

## Compound Disambiguation (Phase 1)

**CRITICAL**: Establish compound identity before any research.

### Identifier Resolution Chain

```
1. PubChem_get_CID_by_compound_name(compound_name)
   └─ Extract: CID, canonical SMILES, formula
   
2. ChEMBL_search_compounds(query=drug_name)
   └─ Extract: ChEMBL ID, pref_name
   
3. DailyMed_search_spls(drug_name)
   └─ Extract: Set ID, NDC codes (if approved)
   
4. PharmGKB_search_drugs(query=drug_name)
   └─ Extract: PharmGKB ID (PA...)
```

### Handle Naming Ambiguity

| Issue | Example | Resolution |
|-------|---------|------------|
| Salt forms | metformin vs metformin HCl | Note all CIDs; use parent compound |
| Isomers | omeprazole vs esomeprazole | Verify SMILES; separate entries if distinct |
| Prodrugs | enalapril vs enalaprilat | Document both; note conversion |
| Brand confusion | Different products same name | Clarify with user |

---

## Key Tools by Report Section

| Report Section | Primary Tools | Fallback |
|----------------|--------------|----------|
| 1. Identity | `PubChem_get_CID_by_compound_name`, `ChEMBL_search_compounds`, `DailyMed_search_spls` | `PharmGKB_search_drugs` |
| 2. Chemistry | `PubChem_get_compound_properties_by_CID`, `ADMETAI_predict_physicochemical_properties` | `DailyMed_get_spl_sections_by_setid` (sections=["chemistry"]) |
| 3. Mechanism | `DailyMed_get_spl_sections_by_setid` (sections=["mechanism_of_action"]), `OpenTargets_get_drug_mechanisms_of_action_by_chemblId` | `DGIdb_get_drug_gene_interactions`, `CTD_get_chemical_gene_interactions` |
| 4. ADMET | `ADMETAI_predict_absorption`, `ADMETAI_predict_distribution`, `ADMETAI_predict_metabolism`, `ADMETAI_predict_excretion`, `ADMETAI_predict_toxicity` | `DailyMed_get_spl_sections_by_setid` (sections=["pharmacokinetics"]) |
| 5. Clinical | `search_clinical_trials` (query_term REQUIRED), `extract_clinical_trial_outcomes` | `OpenTargets_get_drug_indications_by_chemblId` |
| 6. Safety | `FAERS_calculate_disproportionality`, `FAERS_count_reactions_by_drug`, `DailyMed_get_spl_sections_by_setid` (sections=["warnings_and_cautions", "adverse_reactions"]) | `OpenTargets_get_drug_adverse_events_by_chemblId` |
| 7. PGx | `PharmGKB_get_clinical_annotations`, `PharmGKB_get_drug_label_info` | `DailyMed_get_spl_sections_by_setid` (sections=["pharmacogenomics"]) |
| 8. Regulatory | `DailyMed_search_spls`, `FDA_get_warnings_and_cautions_by_drug_name` | `OpenTargets_get_drug_warnings_by_chemblId` |
| 9. Literature | `PubMed_search_articles` (returns plain list), `EuropePMC_search_articles` | `OpenTargets_get_publications_by_drug_chemblId` |

**Key API notes**:
- FAERS analytics: ALL require `operation` parameter
- FAERS count tools: use `medicinalproduct` NOT `drug_name`
- DrugBank tools: ALL require `query`, `case_sensitive`, `exact_match`, `limit` (4 params)
- ADMETAI tools: `smiles` must be a list `[smiles_string]`
- PubMed: returns plain list, NOT `{articles: [...]}`
- DailyMed: get set_id first via `DailyMed_search_spls`, then call section tools

---

## Common Use Cases

- **Approved drug profile**: Full 11-section report (emphasize clinical, FAERS, PGx)
- **Investigational compound**: Emphasize preclinical, mechanism, early trials; safety sparse
- **Safety review**: Deep dive FAERS + warnings + interactions + PGx
- **ADMET assessment**: Focus Sections 2 & 4; other sections brief
- **Clinical landscape**: Heavy Section 5; trial tables with phases/indications

---

> **Extended Reference**: Full tool chain examples with exact parameter types, response parsing, evidence grading system, and quality improvement tips from real-world testing are in `REFERENCE.md`.
