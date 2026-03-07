# Academic Presentation Generation

## Overview
Create publication-quality academic presentations (.pptx) for group meetings, thesis defenses, conference talks, and posters.

## Templates

### Group Meeting (10-15 slides)
1. Title slide (project name, date, presenter)
2. Background / Context (1-2 slides)
3. This Week's Progress (3-5 slides)
4. Results & Figures (2-3 slides)
5. Challenges / Questions (1 slide)
6. Next Steps (1 slide)

### Thesis Defense (30-50 slides)
1. Title (name, committee, date)
2. Outline
3. Background & Significance (5-8 slides, establishing expertise)
4. Specific Aims / Research Questions (1-2 slides)
5. Aim 1: Methods → Results → Summary (8-12 slides)
6. Aim 2: Methods → Results → Summary (8-12 slides)
7. Aim 3 (if applicable)
8. Integrated Discussion (2-3 slides)
9. Conclusions & Impact (1-2 slides)
10. Future Directions (1-2 slides)
11. Acknowledgments
12. Backup slides (for committee questions)

### Conference Talk (12-20 slides, 10-15 min)
1. Title (grab attention)
2. The Problem (why should the audience care?)
3. Key Question (one sentence)
4. Our Approach (why this method?)
5. Key Results (3-5 slides, one finding per slide)
6. So What? (implications, impact)
7. Acknowledgments

## Design Principles
- **One message per slide**: if you need two messages, use two slides
- **Visual hierarchy**: title → key message → supporting data → source
- **Minimal text**: bullet points, not paragraphs. The speaker IS the narrative.
- **Figure-first**: lead with the figure, explain verbally
- **Consistent styling**: same fonts, colors, and layout throughout

## Technical Implementation

### Dependencies

Install before use (include in the same bash call as the script):
```bash
pip install -q python-pptx Pillow
```

### Execution Pattern

Write the ENTIRE presentation as a single self-contained Python script, then run it in ONE bash call:

```bash
bash: pip install -q python-pptx Pillow && python3 << 'PPTXEOF'
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor
import os

OUTPUT_DIR = os.path.expanduser("~/.scienceclaw/workspace")
os.makedirs(OUTPUT_DIR, exist_ok=True)
OUTPUT_PATH = os.path.join(OUTPUT_DIR, "presentation.pptx")

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)

# ... build all slides here ...

prs.save(OUTPUT_PATH)
print(f"DONE: {OUTPUT_PATH} ({len(prs.slides)} slides)")
PPTXEOF
```

### Output Convention

- Save to `~/.scienceclaw/workspace/<descriptive-name>.pptx`
- Print the absolute path and slide count on success
- If the script fails, print the traceback — do NOT silently swallow errors

### Error Handling

- If `python-pptx` fails to install, tell the user: "python-pptx is not available. Please run `pip install python-pptx` on the host."
- If the script errors, read the traceback, fix the issue, and re-run (max 3 attempts).
- After success, verify the file exists and has non-zero size before telling the user it is ready.

### Color Themes

Use academic color palettes from SCIENCE.md (NPG, Lancet, JCO, NEJM) for consistent styling:
```python
THEME = {
    "primary": RGBColor(0x00, 0x46, 0x8B),    # Lancet blue
    "accent":  RGBColor(0xED, 0x00, 0x00),     # Lancet red
    "text":    RGBColor(0x33, 0x33, 0x33),
    "bg":      RGBColor(0xFF, 0xFF, 0xFF),
}
```
