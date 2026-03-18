---
name: export-pptx
description: Export research project findings to a presentation (.pptx) with key findings, figures, and conclusions. Use when user says "导出 PPT", "/export pptx", "做个汇报", "生成 PPT", "export to PowerPoint", "make a presentation from results", or wants slides from project results. Builds on pptx-generation skill.
---

# Export Project to Presentation (.pptx)

Auto-generate a presentation from a ScienceClaw project's reports and figures. Uses the pptx-generation skill's code templates and themes.

## When to Use

- User says "/export pptx", "导出 PPT", "做个汇报", "生成 PPT"
- User completed a research analysis and wants slides for group meeting or conference
- User wants to present findings to collaborators

## Workflow

1. **Identify the project directory** from ACTIVE_PROJECT.md or most recent project
2. **Read the main report** from `reports/` — extract key findings, section headers, conclusions
3. **Collect figures** from `figures/` — each significant figure gets its own slide
4. **Read METHODS.md** if present — create a methods slide
5. **Generate .pptx** using the pptx-generation skill's helper functions
6. **Save** to `reports/<project_name>_presentation.pptx`

## Slide Structure (auto-generated)

| Slide | Content |
|-------|---------|
| 1 | Title slide (project name, date, "ScienceClaw Analysis") |
| 2 | Background / Research Question (from report intro) |
| 3-N | Key Findings (one per slide, with figure if available) |
| N+1 | Methods Summary (from METHODS.md) |
| N+2 | Conclusions (from report summary/conclusion section) |
| N+3 | References (top 10 cited papers) |

## Key Extraction Logic

From the report markdown, extract:
- **Title**: First `# ` heading
- **Background**: First section text (before second `## `)
- **Key findings**: Lines containing statistical results (p-values, HR, AUC, fold change, correlation coefficients)
- **Conclusions**: Section titled "Summary", "Conclusion", "总结", or "结论"
- **References**: Lines matching `[N] Author...` or numbered reference patterns

## Theme

Use the NPG theme from pptx-generation skill by default:
- Primary: `(0x3C, 0x54, 0x88)` — dark blue
- Accent: `(0xE6, 0x4B, 0x35)` — red
- Light background: `(0xEE, 0xF0, 0xF5)`

## Execution

Combine ALL steps into a single `bash` call:

```bash
pip install -q python-pptx Pillow 2>/dev/null && python3 << 'PPTXEOF'
# Use helpers from pptx-generation skill
# Read project directory
# Extract key findings from report
# Build slides
# Save to reports/
PPTXEOF
```

Refer to the `pptx-generation` skill for the full helper function library (title_slide, content_slide, figure_slide, table_slide, etc.).

## Output

- `reports/<project_name>_presentation.pptx`
- Report the slide count and file path to the user
