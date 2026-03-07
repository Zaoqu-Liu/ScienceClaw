# scientific-writing — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Integration with Other Scientific Skills

This skill works effectively with:
- **Data analysis skills**: For generating results to report
- **Statistical analysis**: For determining appropriate statistical presentations
- **Literature review skills**: For contextualizing research
- **Figure creation tools**: For developing publication-quality visualizations
- **Venue-templates skill**: For venue-specific writing styles and formatting (journal manuscripts)
- **scientific_report.sty**: For professional reports, white papers, and technical documents

### Professional Reports vs. Journal Manuscripts

**Choose the right formatting approach:**

| Document Type | Formatting Approach |
|---------------|---------------------|
| Journal manuscripts | Use `venue-templates` skill |
| Conference papers | Use `venue-templates` skill |
| Research reports | Use `scientific_report.sty` (this skill) |
| White papers | Use `scientific_report.sty` (this skill) |
| Technical reports | Use `scientific_report.sty` (this skill) |
| Grant reports | Use `scientific_report.sty` (this skill) |

### Venue-Specific Writing Styles

**Before writing for a specific venue, consult the venue-templates skill for writing style guides:**

Different venues have dramatically different writing expectations:
- **Nature/Science**: Accessible, story-driven, broad significance
- **Cell Press**: Mechanistic depth, graphical abstracts, Highlights
- **Medical journals (NEJM, Lancet)**: Structured abstracts, evidence language
- **ML conferences (NeurIPS, ICML)**: Contribution bullets, ablation studies
- **CS conferences (CHI, ACL)**: Field-specific conventions

The venue-templates skill provides:
- `venue_writing_styles.md`: Master style comparison
- Venue-specific guides: `nature_science_style.md`, `cell_press_style.md`, `medical_journal_styles.md`, `ml_conference_style.md`, `cs_conference_style.md`
- `reviewer_expectations.md`: What reviewers look for at each venue
- Writing examples in `assets/examples/`

**Workflow**: First use this skill for general scientific writing principles (IMRAD, clarity, citations), then consult venue-templates for venue-specific style adaptation.

## References

This skill includes comprehensive reference files covering specific aspects of scientific writing:

- `references/imrad_structure.md`: Detailed guide to IMRAD format and section-specific content
- `references/citation_styles.md`: Complete citation style guides (APA, AMA, Vancouver, Chicago, IEEE)
- `references/figures_tables.md`: Best practices for creating effective data visualizations
- `references/reporting_guidelines.md`: Study-specific reporting standards and checklists
- `references/writing_principles.md`: Core principles of effective scientific communication
- `references/professional_report_formatting.md`: Guide to professional report styling with `scientific_report.sty`

## Assets

This skill includes LaTeX style packages and templates for professional report formatting:

- `assets/scientific_report.sty`: Professional LaTeX style package with Helvetica fonts, colored boxes, and attractive tables
- `assets/scientific_report_template.tex`: Complete report template demonstrating all style features
- `assets/REPORT_FORMATTING_GUIDE.md`: Quick reference guide for the style package

**Key Features of `scientific_report.sty`:**
- Helvetica font family for modern, professional appearance
- Professional color scheme (blues, greens, oranges, purples)
- Box environments: `keyfindings`, `methodology`, `resultsbox`, `recommendations`, `limitations`, `criticalnotice`, `definition`, `executivesummary`, `hypothesis`
- Tables with alternating row colors and professional headers
- Scientific notation commands for p-values, effect sizes, confidence intervals
- Professional headers and footers

**For venue-specific writing styles** (tone, voice, abstract format, reviewer expectations), see the **venue-templates** skill which provides comprehensive style guides for Nature/Science, Cell Press, medical journals, ML conferences, and CS conferences.

Load these references as needed when working on specific aspects of scientific writing.
