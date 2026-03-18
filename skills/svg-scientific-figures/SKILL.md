---
name: svg-scientific-figures
description: Generate editable SVG scientific illustrations (mechanism diagrams, signaling pathways, workflow figures) directly from LLM text output. Uses a Review-Refine loop inspired by AutoFigure (ICLR 2026). Outputs editable SVG files compatible with draw.io, Illustrator, and PowerPoint, plus PNG renders. Use when the user needs mechanism diagrams, pathway illustrations, experimental workflow figures, or any schematic that should be editable. Complements the existing Gemini-based scientific-diagram-generation skill (which produces non-editable PNG).
---

# SVG Scientific Figure Generation

Generate publication-quality, **editable** SVG scientific illustrations through a Review-Refine loop. Unlike the Gemini image model approach (PNG, non-editable), this skill produces vector SVG code that users can modify in draw.io, Adobe Illustrator, Inkscape, or PowerPoint.

## When to Use

- User needs a **mechanism diagram** (signaling pathway, cellular process, drug mechanism)
- User needs an **experimental workflow** figure (study design, analysis pipeline)
- User needs a **conceptual figure** (graphical abstract, model summary)
- User explicitly asks for **editable** or **SVG** figures
- The existing Gemini diagram skill generated something that needs precise label/layout control

**When NOT to use** (use other approaches):
- Data-driven plots (boxplot, volcano, KM curve) → use Python/R code
- Microscopy/imaging results → use Gemini image generation
- Quick sketches → use Gemini image generation

## Review-Refine Architecture

```
Step 1: EXTRACT — Parse entities and relationships from research context
Step 2: GENERATE — LLM writes SVG code with precise layout
Step 3: CRITIQUE — LLM reviews SVG for errors (as a separate reasoning step)
Step 4: REFINE — Fix issues identified by critique (max 2 rounds)
Step 5: RENDER — Save SVG + convert to PNG via cairosvg or rsvg-convert
```

---

## Step 1: Extract Entities and Relationships

From the research context (report text, user description, or paper content), extract:

**BioNodes** (entities):
- `cell`: Tumor cell, Macrophage, T cell, Fibroblast, ...
- `protein`: PD-L1, VEGF, EGFR, TREM2, ...
- `receptor`: PD-1, VEGFR2, TLR4, ...
- `molecule`: ATP, cAMP, ROS, ...
- `gene`: TP53, KRAS, MYC, ...
- `drug`: Pembrolizumab, Sorafenib, ...
- `process`: Apoptosis, Autophagy, EMT, ...
- `compartment`: Nucleus, Cytoplasm, Membrane, Extracellular space, ...

**BioEdges** (relationships):
- `activate` (solid arrow →)
- `inhibit` (T-bar ⊣)
- `bind` (double line =)
- `phosphorylate` (arrow with P)
- `secrete` (dashed arrow -→)
- `translocate` (curved arrow)
- `upregulate` / `downregulate` (arrows with + / -)

Format as structured JSON before generating SVG:

```json
{
  "title": "PD-L1/PD-1 Immune Checkpoint Pathway",
  "nodes": [
    {"id": "tumor", "type": "cell", "label": "Tumor Cell", "x": 200, "y": 100},
    {"id": "pdl1", "type": "protein", "label": "PD-L1", "x": 200, "y": 200},
    {"id": "pd1", "type": "receptor", "label": "PD-1", "x": 400, "y": 200},
    {"id": "tcell", "type": "cell", "label": "CD8+ T Cell", "x": 400, "y": 100}
  ],
  "edges": [
    {"from": "tumor", "to": "pdl1", "action": "express"},
    {"from": "pdl1", "to": "pd1", "action": "bind"},
    {"from": "pd1", "to": "tcell", "action": "inhibit"}
  ]
}
```

---

## Step 2: Generate SVG Code

Write complete, valid SVG. Follow these rules strictly:

### SVG Template Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
     width="800" height="600" viewBox="0 0 800 600">

  <defs>
    <!-- Arrow markers -->
    <marker id="arrowhead" markerWidth="10" markerHeight="7"
            refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
    </marker>
    <marker id="tbar" markerWidth="10" markerHeight="10"
            refX="0" refY="5" orient="auto">
      <line x1="0" y1="0" x2="0" y2="10" stroke="#CC0000" stroke-width="2"/>
    </marker>
  </defs>

  <!-- Background -->
  <rect width="800" height="600" fill="#FFFFFF"/>

  <!-- Title -->
  <text x="400" y="30" text-anchor="middle" font-family="Arial, Helvetica, sans-serif"
        font-size="16" font-weight="bold" fill="#333">Figure Title Here</text>

  <!-- Compartments (draw first, behind everything) -->
  <rect x="50" y="50" width="700" height="250" rx="10" fill="#F0F8FF" stroke="#4A90D9"
        stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="60" y="70" font-family="Arial" font-size="11" fill="#4A90D9"
        font-style="italic">Extracellular Space</text>

  <!-- Nodes -->
  <!-- Cells: rounded rectangles -->
  <rect x="150" y="80" width="120" height="60" rx="8" fill="#E8F5E9" stroke="#4CAF50"
        stroke-width="1.5"/>
  <text x="210" y="115" text-anchor="middle" font-family="Arial" font-size="12"
        fill="#2E7D32">Tumor Cell</text>

  <!-- Proteins: ovals -->
  <ellipse cx="210" cy="200" rx="45" ry="20" fill="#FFF3E0" stroke="#FF9800"
           stroke-width="1.5"/>
  <text x="210" y="205" text-anchor="middle" font-family="Arial" font-size="11"
        fill="#E65100">PD-L1</text>

  <!-- Edges -->
  <!-- Activation arrow -->
  <line x1="210" y1="140" x2="210" y2="175" stroke="#333" stroke-width="1.5"
        marker-end="url(#arrowhead)"/>

  <!-- Inhibition T-bar -->
  <line x1="260" y1="200" x2="340" y2="200" stroke="#CC0000" stroke-width="1.5"
        marker-end="url(#tbar)"/>

</svg>
```

### Design Rules

1. **Font**: Always `Arial, Helvetica, sans-serif`. Never decorative fonts.
2. **Background**: Pure white `#FFFFFF`.
3. **Labels**: Title Case for cell types and processes. Gene/protein abbreviations as-is (PD-L1, IFN-γ).
4. **Font sizes**: Title 16px, node labels 11-12px, edge labels 9-10px.
5. **Colors by node type**:
   - Cells: green family (`#E8F5E9` fill, `#4CAF50` stroke)
   - Proteins/receptors: orange family (`#FFF3E0` fill, `#FF9800` stroke)
   - Drugs: blue family (`#E3F2FD` fill, `#2196F3` stroke)
   - DNA/genes: purple family (`#F3E5F5` fill, `#9C27B0` stroke)
   - Processes: grey family (`#F5F5F5` fill, `#9E9E9E` stroke)
6. **Edge colors**: Activation `#333333`, Inhibition `#CC0000`, Binding `#1565C0`, Secretion `#666666` (dashed).
7. **Spacing**: Minimum 30px between node edges. No overlapping elements.
8. **Canvas size**: Default 800x600. Scale up for complex diagrams (1200x800).
9. **No gradients or shadows** — keep it flat and clean for journal compatibility.

---

## Step 3: Critique

After generating SVG, perform a self-review checklist:

1. **Completeness**: Are all entities from the extract in the SVG? Missing labels?
2. **Overlap**: Do any nodes overlap? Do any labels overlap edges?
3. **Alignment**: Are horizontally-aligned elements at the same y? Vertically-aligned at same x?
4. **Edge clarity**: Can you trace every arrow from source to target without ambiguity?
5. **Text readability**: Are all labels large enough (≥10px)? High contrast against background?
6. **Scientific accuracy**: Do arrow directions match biological reality? (activation → not ⊣)
7. **Compartment logic**: Are intracellular proteins inside the cell? Extracellular factors outside?

Report issues as a numbered list. If no issues, proceed to Step 5.

---

## Step 4: Refine

Fix each issue identified in the critique. Common fixes:
- Adjust `x`/`y` coordinates to resolve overlaps
- Increase font size for readability
- Add missing nodes/edges
- Correct edge types (arrow vs T-bar)
- Re-route edges to avoid crossing nodes

Maximum 2 refinement rounds. If issues persist, output with a note about remaining imperfections.

---

## Step 5: Render

Save SVG and convert to PNG:

```bash
# Save SVG
cat > "$FIG_DIR/mechanism_diagram.svg" << 'SVGEOF'
... SVG content ...
SVGEOF

# Convert to PNG (try cairosvg first, fall back to rsvg-convert)
pip install -q cairosvg 2>/dev/null && \
python3 -c "
import cairosvg
cairosvg.svg2png(
    url='$FIG_DIR/mechanism_diagram.svg',
    write_to='$FIG_DIR/mechanism_diagram.png',
    output_width=2400, output_height=1800
)
print('PNG rendered at 300 DPI equivalent')
" || \
rsvg-convert -w 2400 -h 1800 "$FIG_DIR/mechanism_diagram.svg" > "$FIG_DIR/mechanism_diagram.png" 2>/dev/null || \
echo "SVG saved. Install cairosvg or rsvg-convert for PNG conversion."
```

### draw.io XML Export (optional)

For users who want to edit in draw.io, wrap the SVG in mxGraph XML:

```bash
python3 -c "
import base64, urllib.parse

with open('$FIG_DIR/mechanism_diagram.svg') as f:
    svg_content = f.read()

encoded = urllib.parse.quote(svg_content)
mxfile = f'''<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<mxfile>
  <diagram name=\"Page-1\">
    <mxGraphModel>
      <root>
        <mxCell id=\"0\"/>
        <mxCell id=\"1\" parent=\"0\"/>
        <mxCell id=\"2\" value=\"\" style=\"shape=image;image=data:image/svg+xml,{encoded};\" vertex=\"1\" parent=\"1\">
          <mxGeometry width=\"800\" height=\"600\" as=\"geometry\"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>'''

with open('$FIG_DIR/mechanism_diagram.drawio', 'w') as f:
    f.write(mxfile)
print('draw.io file saved')
"
```

---

## Output Files

| File | Format | Purpose |
|------|--------|---------|
| `mechanism_diagram.svg` | SVG | Editable vector source |
| `mechanism_diagram.png` | PNG | For reports and presentations (300 DPI) |
| `mechanism_diagram.drawio` | draw.io XML | For editing in draw.io (optional) |

---

## Relationship to Existing Diagram Skill

| Feature | scientific-diagram-generation (Gemini) | svg-scientific-figures (this) |
|---------|---------------------------------------|------------------------------|
| Output format | PNG (bitmap) | SVG (vector, editable) |
| Editability | Not editable | Fully editable in draw.io/Illustrator |
| Label precision | Approximate (Gemini may garble text) | Exact (text is SVG elements) |
| Visual quality | High (photorealistic style) | Clean (flat vector style) |
| API dependency | Requires Gemini image API | No external API (pure LLM text output) |
| Best for | Photorealistic cell illustrations | Pathway diagrams, workflow figures, schematics |

**Decision logic**: If the user wants a **photorealistic** biological illustration → use Gemini. If the user wants an **editable schematic** with precise labels → use this SVG skill.
