---
name: export-latex
description: Export research project findings to a LaTeX manuscript draft with figures, references, and methods. Supports Nature, Cell, Lancet, and generic article formats. Use when user says "导出 LaTeX", "/export latex", "写论文初稿", "export to LaTeX", "generate manuscript", or wants a paper draft from project results. Builds on venue-templates skill.
---

# Export Project to LaTeX Manuscript

Auto-generate a LaTeX paper draft from a ScienceClaw project's report, figures, and METHODS.md. Uses venue-templates skill for journal-specific formatting.

## When to Use

- User says "/export latex", "导出 LaTeX", "写论文初稿", "生成论文"
- User wants to draft a manuscript from analysis results
- User specifies a target journal (Nature, Cell, Lancet, etc.)

## Workflow

1. **Identify the project** and read report + METHODS.md + figures
2. **Ask for target journal** if not specified (default: generic article)
3. **Map report sections** to paper structure (Introduction, Methods, Results, Discussion)
4. **Generate .tex file** with proper formatting
5. **Copy figures** to a `latex/figures/` subdirectory
6. **Generate .bib file** from references
7. **Save** to `reports/<project_name>_manuscript.tex`

## Paper Structure Mapping

| Report Section | Paper Section |
|---------------|--------------|
| Background / Introduction | Introduction |
| METHODS.md | Methods / Materials and Methods |
| Results / Findings / Analysis | Results |
| Summary / Conclusions / Discussion | Discussion |
| References | Bibliography (.bib) |

## LaTeX Template (Generic Article)

```latex
\documentclass[11pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}
\usepackage[margin=2.5cm]{geometry}
\usepackage{natbib}
\bibliographystyle{unsrtnat}

\title{TITLE_PLACEHOLDER}
\author{ScienceClaw Analysis}
\date{\today}

\begin{document}
\maketitle

\begin{abstract}
ABSTRACT_PLACEHOLDER
\end{abstract}

\section{Introduction}
INTRO_PLACEHOLDER

\section{Methods}
METHODS_PLACEHOLDER

\section{Results}
RESULTS_PLACEHOLDER

\section{Discussion}
DISCUSSION_PLACEHOLDER

\section*{Acknowledgments}
This analysis was performed using ScienceClaw with data from [list databases].

\bibliography{references}

\end{document}
```

## BibTeX Generation

Convert GB/T 7714 references from the report to BibTeX entries:

```python
def gbt7714_to_bibtex(ref_line, key):
    """Convert a GB/T 7714 reference line to BibTeX @article entry."""
    # Parse: [N] Authors. Title[J]. Journal, Year, Vol(Issue): Pages. DOI: xxx.
    # Generate: @article{key, author={...}, title={...}, journal={...}, year={...}, ...}
    ...
```

## Journal-Specific Templates

For specific journals, refer to the `venue-templates` skill which provides full LaTeX class files and formatting requirements for:
- Nature / Nature Communications
- Cell / Cell Reports
- The Lancet
- PLOS ONE
- IEEE / ACM conferences

When the user specifies a journal, load the appropriate template from venue-templates and adapt the content accordingly.

## Output

- `reports/<project_name>_manuscript.tex`
- `reports/references.bib`
- `reports/latex/figures/` (copies of all PNG figures)

Report all file paths to the user.
