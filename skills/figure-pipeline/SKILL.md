---
name: figure-pipeline
description: Five-step figure generation pipeline inspired by PaperVizAgent (Google Research, 2026). Orchestrates Retriever → Planner → Stylist → Visualizer → Critic stages for publication-quality scientific figures. Retrieves reference figures from literature, plans layout and composition, applies journal-specific styling, generates the figure, then critiques and refines. Use when the user needs high-quality figures for papers/presentations and wants a more deliberate, reference-driven approach than direct code generation. Especially useful for multi-panel figures and complex data visualizations.
---

# Five-Step Figure Generation Pipeline

Generate publication-quality scientific figures through a structured pipeline with reference retrieval, planning, styling, generation, and self-critique. Inspired by PaperVizAgent's five-agent architecture.

## When to Use

- Multi-panel composite figures (e.g., "Figure 1: A) boxplot, B) KM curve, C) heatmap, D) network")
- Figures that need to match a specific journal's style
- Complex visualizations where direct code generation often produces suboptimal layouts
- User explicitly asks for "publication-quality" or "journal-ready" figures
- Graphical abstracts

**When NOT to use** (overkill):
- Single simple plot → just write matplotlib/ggplot2 code directly
- Mechanism diagrams → use `svg-scientific-figures` skill
- Quick exploratory plots → direct code

---

## Pipeline Steps

### Step 1: RETRIEVE — Find Reference Figures

Search for published figures on the same topic to establish visual expectations:

```bash
bash: echo "=== PubMed figure captions ===" && \
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=10&sort=relevance&term=TOPIC+AND+(figure+OR+visualization)" && \
echo -e "\n=== bioRxiv recent figures ===" && \
curl -s "https://api.biorxiv.org/details/biorxiv/2025-01-01/2026-03-18?jou=biorxiv" 2>/dev/null | head -c 2000
```

Also search for figure captions in full-text papers via Asta or Europe PMC:

```bash
curl -s "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=TOPIC+AND+FIG_TYPE:figure&format=json&pageSize=5"
```

From reference figures, extract:
- **Figure types used** (violin plot vs boxplot, clustered vs simple heatmap)
- **Panel arrangement** (2x2 grid, horizontal strip, vertical stack)
- **Color schemes** (which journal palette)
- **Annotation patterns** (significance brackets, gene labels, axis formatting)

### Step 2: PLAN — Design Figure Composition

Create a structured figure plan:

```json
{
  "figure_id": "Figure 1",
  "title": "THBS2 Expression and Survival Analysis Across Cancer Types",
  "layout": {
    "type": "grid",
    "rows": 2,
    "cols": 2,
    "width_cm": 17.5,
    "height_cm": 15
  },
  "panels": [
    {
      "id": "A",
      "type": "boxplot",
      "data": "TCGA pan-cancer expression",
      "x": "cancer_type",
      "y": "THBS2_expression_TPM",
      "notes": "Sort by median expression, highlight significant (red asterisks)"
    },
    {
      "id": "B",
      "type": "kaplan_meier",
      "data": "PAAD survival",
      "groups": "THBS2_high vs THBS2_low",
      "notes": "Include risk table, log-rank p, HR with 95%CI"
    },
    {
      "id": "C",
      "type": "heatmap",
      "data": "Immune cell correlation matrix",
      "notes": "Cluster by correlation, annotate r values for significant pairs"
    },
    {
      "id": "D",
      "type": "dot_plot",
      "data": "GO enrichment top 15 terms",
      "notes": "Color by p-value, size by gene count, order by enrichment score"
    }
  ],
  "shared_style": {
    "palette": "NPG",
    "font": "Arial",
    "label_size": 8,
    "title_size": 10
  }
}
```

### Step 3: STYLE — Apply Journal-Specific Formatting

Select and apply styling rules based on target journal:

| Journal Category | Width | DPI | Font | Palette | Panel Labels |
|-----------------|-------|-----|------|---------|--------------|
| Nature/Science/Cell | 8.9cm (single) / 18.3cm (double) | 300 | Arial/Helvetica | NPG | Bold uppercase A, B, C |
| Lancet/NEJM/JAMA | 8.5cm / 17.5cm | 300 | Arial | Lancet/NEJM | Bold a, b, c |
| Cancer Research | 8.5cm / 17.5cm | 300 | Arial | AACR | Bold A, B, C |
| Default (no journal specified) | 17.5cm (double) | 300 | Arial | NPG | Bold A, B, C |

Styling rules:
- Axis labels: 8-9pt, sentence case
- Axis tick labels: 7-8pt
- Panel labels: 10-12pt, bold, top-left corner outside plot area
- Legend: 7-8pt, outside plot or in open space
- Significance annotations: `*` p<0.05, `**` p<0.01, `***` p<0.001, `ns` not significant
- Color: use colorblind-friendly palettes; never use red-green only
- Grid lines: minimal or none; let data speak

### Step 4: VISUALIZE — Generate the Figure

Write Python or R code implementing the planned figure. Use the styling rules from Step 3.

**Python approach** (for multi-panel):
```python
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(17.5/2.54, 15/2.54), dpi=300)
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.35)

ax_a = fig.add_subplot(gs[0, 0])
# Panel A code...
ax_a.text(-0.15, 1.05, 'A', transform=ax_a.transAxes, fontsize=12, fontweight='bold')

ax_b = fig.add_subplot(gs[0, 1])
# Panel B code...

# ... etc

plt.savefig(out_path, dpi=300, bbox_inches='tight', facecolor='white')
```

**R approach** (using patchwork):
```r
library(ggplot2); library(patchwork)
p_a <- ggplot(...) + labs(tag = "A")
p_b <- ggplot(...) + labs(tag = "B")
combined <- (p_a | p_b) / (p_c | p_d)
ggsave(out_path, combined, width=17.5, height=15, units="cm", dpi=300)
```

### Step 5: CRITIQUE — Review and Refine

After generating the figure, perform a quality review:

**Checklist**:
1. [ ] All panel labels (A, B, C, D) present and correctly positioned?
2. [ ] All axis labels present, readable, and correctly spelled?
3. [ ] Legend present where needed? Not obscuring data?
4. [ ] Font sizes consistent across all panels?
5. [ ] Color palette consistent across all panels?
6. [ ] Significance annotations correct and complete?
7. [ ] White space balanced? No cramped or empty areas?
8. [ ] Data accurately represented? (spot-check values against source data)
9. [ ] Figure would be understandable from caption alone?
10. [ ] Resolution sufficient for print (300 DPI at target size)?

If any check fails, go back to Step 4 and fix. Maximum 2 refinement rounds.

After passing critique:
```
✅ Figure review passed (10/10 checks)
Saved: figures/figure1_thbs2_landscape.png (17.5 x 15 cm, 300 DPI)
```

---

## Output

| File | Description |
|------|-------------|
| `figures/figure1_DESCRIPTION.png` | Final PNG at 300 DPI |
| `figures/figure1_DESCRIPTION.pdf` | Vector PDF (when using R/matplotlib PDF backend) |
| `figures/figure1_DESCRIPTION.svg` | SVG if generated via the SVG skill |

---

## Integration with Research Recipes

When a Recipe generates multiple figure outputs, offer to combine them into a composite figure using this pipeline:

"已生成 4 张独立图表。需要用 Figure Pipeline 组装为一张多面板组合图吗？"
