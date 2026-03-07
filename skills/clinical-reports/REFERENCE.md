# clinical-reports — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Medical Terminology and Standards

### Standardized Nomenclature

**SNOMED CT (Systematized Nomenclature of Medicine - Clinical Terms)**
- Comprehensive clinical terminology
- Used for electronic health records
- Enables semantic interoperability

**LOINC (Logical Observation Identifiers Names and Codes)**
- Standard for laboratory and clinical observations
- Facilitates data exchange and reporting

**ICD-10-CM (International Classification of Diseases, 10th Revision, Clinical Modification)**
- Diagnosis coding for billing and epidemiology
- Required for reimbursement

**CPT (Current Procedural Terminology)**
- Procedure coding for billing
- Maintained by AMA

### Abbreviation Standards

**Acceptable Abbreviations:**
Use standard abbreviations to improve efficiency while maintaining clarity.

**Do Not Use List (Joint Commission):**
- U (unit) - write "unit"
- IU (international unit) - write "international unit"
- QD, QOD (daily, every other day) - write "daily" or "every other day"
- Trailing zero (X.0 mg) - never use after decimal
- Lack of leading zero (.X mg) - always use before decimal (0.X mg)
- MS, MSO4, MgSO4 - write "morphine sulfate" or "magnesium sulfate"

For comprehensive terminology standards, see `references/medical_terminology.md`.

## Quality Assurance and Validation

### Documentation Quality Principles

**Completeness:**
- All required elements present
- No missing data fields
- Comprehensive patient information

**Accuracy:**
- Factually correct information
- Verified data sources
- Appropriate clinical reasoning

**Timeliness:**
- Documented contemporaneously or shortly after encounter
- Time-sensitive reports prioritized
- Regulatory deadlines met

**Clarity:**
- Clear and unambiguous language
- Organized logical structure
- Appropriate use of medical terminology

**Compliance:**
- Regulatory requirements met
- Privacy protections in place
- Institutional policies followed

### Validation Checklists

For each report type, use validation checklists to ensure quality:
- Case report CARE checklist
- Diagnostic report completeness
- SAE report regulatory compliance
- Clinical documentation billing requirements

Validation scripts are available in the `scripts/` directory.

## Data Presentation in Clinical Reports

### Tables and Figures

**Tables for Clinical Data:**
- Demographic and baseline characteristics
- Adverse events summary
- Laboratory values over time
- Efficacy outcomes

**Table Design Principles:**
- Clear column headers with units
- Footnotes for abbreviations and statistical notes
- Consistent formatting
- Appropriate precision (significant figures)

**Figures for Clinical Data:**
- Kaplan-Meier survival curves
- Forest plots for subgroup analyses
- Patient flow diagrams (CONSORT)
- Timeline figures for case reports
- Before-and-after images

**Image Guidelines:**
- High resolution (300 dpi minimum)
- Appropriate scale bars
- Annotations for key features
- De-identified (no patient identifiers visible)
- Informed consent for recognizable images

For data presentation standards, see `references/data_presentation.md`.

## Integration with Other Skills

This clinical reports skill integrates with:
- **Scientific Writing**: For clear, professional medical writing
- **Peer Review**: For quality assessment of case reports
- **Citation Management**: For literature references in case reports
- **Research Grants**: For clinical trial protocol development
- **Literature Review**: For background sections in case reports

## Workflow for Clinical Report Writing

### Case Report Workflow

**Phase 1: Case Identification and Consent (Week 1)**
- Identify novel or educational case
- Obtain patient informed consent
- De-identify patient information
- Collect clinical data and images

**Phase 2: Literature Review (Week 1-2)**
- Search for similar cases
- Review relevant pathophysiology
- Identify knowledge gaps
- Determine novelty and significance

**Phase 3: Drafting (Week 2-3)**
- Write structured outline following CARE guidelines
- Draft all sections (abstract through discussion)
- Create timeline and figures
- Format references

**Phase 4: Internal Review (Week 3-4)**
- Co-author review
- Attending physician review
- Institutional review if required
- Patient review of de-identified draft

**Phase 5: Journal Selection and Submission (Week 4-5)**
- Select appropriate journal
- Format per journal guidelines
- Prepare cover letter
- Submit manuscript

**Phase 6: Revision (Variable)**
- Respond to peer reviewer comments
- Revise manuscript
- Resubmit

### Diagnostic Report Workflow

**Real-time Workflow:**
- Review clinical indication and prior studies
- Interpret imaging, pathology, or laboratory findings
- Dictate or type report using structured format
- Peer review for complex cases
- Final sign-out and distribution
- Critical value notification if applicable

**Turnaround Time Benchmarks:**
- STAT reports: <1 hour
- Routine reports: 24-48 hours
- Complex cases: 2-5 days
- Pending additional studies: documented delay

### Clinical Trial Report Workflow

**SAE Report: 24 hours to 15 days**
- Event identified by site
- Initial assessment and documentation
- Causality and expectedness determination
- Report completion and review
- Submission to sponsor, IRB, FDA (as required)
- Follow-up reporting until resolution

**CSR: 6-12 months post-study completion**
- Database lock and data cleaning
- Statistical analysis per SAP
- Drafting by medical writer
- Review by biostatistician and clinical team
- Quality control review
- Final approval and regulatory submission

## Resources

This skill includes comprehensive reference files and templates:

### Reference Files

- `references/case_report_guidelines.md` - CARE guidelines, journal requirements, writing tips
- `references/diagnostic_reports_standards.md` - ACR, CAP, laboratory reporting standards
- `references/clinical_trial_reporting.md` - ICH-E3, CONSORT, SAE reporting, CSR structure
- `references/patient_documentation.md` - SOAP notes, H&P, discharge summaries, coding
- `references/regulatory_compliance.md` - HIPAA, 21 CFR Part 11, ICH-GCP, FDA requirements
- `references/medical_terminology.md` - SNOMED, LOINC, ICD-10, abbreviations, nomenclature
- `references/data_presentation.md` - Tables, figures, safety data, CONSORT diagrams
- `references/peer_review_standards.md` - Review criteria for clinical manuscripts

### Template Assets

- `assets/case_report_template.md` - Structured case report following CARE guidelines
- `assets/radiology_report_template.md` - Standard radiology report format
- `assets/pathology_report_template.md` - Surgical pathology report with synoptic elements
- `assets/lab_report_template.md` - Clinical laboratory report format
- `assets/clinical_trial_sae_template.md` - Serious adverse event report form
- `assets/clinical_trial_csr_template.md` - Clinical study report outline per ICH-E3
- `assets/soap_note_template.md` - SOAP progress note format
- `assets/history_physical_template.md` - Comprehensive H&P template
- `assets/discharge_summary_template.md` - Hospital discharge summary
- `assets/consult_note_template.md` - Consultation note format
- `assets/quality_checklist.md` - Quality assurance checklist for all report types
- `assets/hipaa_compliance_checklist.md` - Privacy and de-identification checklist

### Automation Scripts

- `scripts/validate_case_report.py` - Check CARE guideline compliance and completeness
- `scripts/validate_trial_report.py` - Verify ICH-E3 structure and required elements
- `scripts/check_deidentification.py` - Scan for 18 HIPAA identifiers in text
- `scripts/format_adverse_events.py` - Generate AE summary tables from data
- `scripts/generate_report_template.py` - Interactive template selection and generation
- `scripts/extract_clinical_data.py` - Parse structured data from clinical reports
- `scripts/compliance_checker.py` - Verify regulatory compliance requirements
- `scripts/terminology_validator.py` - Validate medical terminology and coding

Load these resources as needed when working on specific clinical reports.

## Common Pitfalls to Avoid

### Case Reports
- **Privacy violations**: Inadequate de-identification or missing consent
- **Lack of novelty**: Reporting common or well-documented cases
- **Insufficient detail**: Missing key clinical information
- **Poor literature review**: Failure to contextualize within existing knowledge
- **Overgeneralization**: Drawing broad conclusions from single case

### Diagnostic Reports
- **Vague language**: Using ambiguous terms like "unremarkable" without specifics
- **Incomplete comparison**: Not reviewing prior imaging
- **Missing clinical correlation**: Failing to answer clinical question
- **Technical jargon**: Overuse of terminology without explanation
- **Delayed critical value notification**: Not communicating urgent findings

### Clinical Trial Reports
- **Late reporting**: Missing regulatory deadlines for SAE reporting
- **Incomplete causality**: Inadequate causality assessment
- **Data inconsistencies**: Discrepancies between data sources
- **Protocol deviations**: Unreported or inadequately documented deviations
- **Selective reporting**: Omitting negative or unfavorable results

### Patient Documentation
- **Illegibility**: Poor handwriting in paper records
- **Copy-forward errors**: Propagating outdated information
- **Insufficient detail**: Vague or incomplete documentation affecting billing
- **Lack of medical necessity**: Not documenting indication for services
- **Missing signatures**: Unsigned or undated notes

## Final Checklist

Before finalizing any clinical report, verify:

- [ ] All required sections complete
- [ ] Patient privacy protected (HIPAA compliance)
- [ ] Informed consent obtained (if applicable)
- [ ] Accurate and verified clinical data
- [ ] Appropriate medical terminology and coding
- [ ] Clear, professional language
- [ ] Proper formatting per guidelines
- [ ] References cited appropriately
- [ ] Figures and tables labeled correctly
- [ ] Spell-checked and proofread
- [ ] Regulatory requirements met
- [ ] Institutional policies followed
- [ ] Signatures and dates present
- [ ] Quality assurance review completed

---

**Final Note**: Clinical report writing requires attention to detail, medical accuracy, regulatory compliance, and clear communication. Whether documenting patient care, reporting research findings, or communicating diagnostic results, the quality of clinical reports directly impacts patient safety, healthcare delivery, and medical knowledge advancement. Always prioritize accuracy, privacy, and professionalism in all clinical documentation.

