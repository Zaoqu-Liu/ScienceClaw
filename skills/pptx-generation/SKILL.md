---
name: pptx-generation
description: Generate academic PowerPoint presentations (.pptx) using python-pptx. Use this skill for making PPT, slides, presentations, 生成PPT, 做PPT, 写PPT, 幻灯片. Provides complete helper functions and templates. Preferred over scientific-slides and frontend-slides for all PPTX generation.
---

# Academic Presentation Generation

## Overview
Create publication-quality academic presentations (.pptx) for group meetings, thesis defenses, conference talks, and product introductions.

## Templates

### Group Meeting (10-15 slides)
1. Title slide (project name, date, presenter)
2. Background / Context (1-2 slides)
3. This Week's Progress (3-5 slides)
4. Results & Figures (2-3 slides)
5. Challenges / Questions (1 slide)
6. Next Steps (1 slide)

### Thesis Defense (30-50 slides)
1. Title → 2. Outline → 3. Background (5-8) → 4. Aims (1-2) → 5-7. Aim chapters (8-12 each) → 8. Discussion (2-3) → 9. Conclusions (1-2) → 10. Future → 11. Acknowledgments → 12. Backup

### Conference Talk (12-20 slides, 10-15 min)
1. Title → 2. Problem → 3. Key Question → 4. Approach → 5-9. Results → 10. Implications → 11. Acknowledgments

### Product / Project Introduction (10-15 slides)
1. Title → 2. Problem → 3. Solution → 4. Architecture → 5-8. Core features → 9-10. Case studies → 11. Comparison → 12. Quick start → 13. Roadmap → 14. Summary

## Design Principles
- **One message per slide**: two messages → two slides
- **Visual hierarchy**: title → key message → supporting data → source
- **Minimal text**: bullet points, not paragraphs
- **Figure-first**: lead with figures, explain verbally
- **Consistent styling**: same fonts, colors, layout throughout

## Technical Implementation

### Dependencies

```bash
pip install -q python-pptx Pillow
```

### CRITICAL: Execution Pattern

**ALWAYS write the ENTIRE script FIRST, then run it. NEVER send text before running the script.**

The script MUST be self-contained. Install deps, define helpers, build slides, save — all in ONE bash call:

```bash
pip install -q python-pptx Pillow 2>/dev/null && python3 << 'PPTXEOF'
# === FULL SCRIPT HERE (see template below) ===
PPTXEOF
```

### Color Themes

Academic palettes — pick ONE and use consistently:

```python
THEMES = {
    "lancet": {
        "primary": (0x00, 0x46, 0x8B),
        "accent": (0xED, 0x00, 0x00),
        "accent2": (0x42, 0xB5, 0x40),
        "light": (0xE8, 0xEE, 0xF4),
        "text": (0x33, 0x33, 0x33),
        "muted": (0x88, 0x88, 0x88),
    },
    "npg": {
        "primary": (0x3C, 0x54, 0x88),
        "accent": (0xE6, 0x4B, 0x35),
        "accent2": (0x00, 0xA0, 0x87),
        "light": (0xEE, 0xF0, 0xF5),
        "text": (0x33, 0x33, 0x33),
        "muted": (0x84, 0x91, 0xB4),
    },
    "nejm": {
        "primary": (0x00, 0x72, 0xB5),
        "accent": (0xBC, 0x3C, 0x29),
        "accent2": (0x20, 0x85, 0x4E),
        "light": (0xE6, 0xF0, 0xF8),
        "text": (0x33, 0x33, 0x33),
        "muted": (0x6F, 0x99, 0xAD),
    },
}
```

### Complete Template Script

Copy this entire template. Fill in the `SLIDES` list with actual content. **Do not restructure the helpers — just fill in content.**

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.dml.color import RGBColor
import os

# --- CONFIG ---
OUTPUT_DIR = os.path.expanduser("~/.scienceclaw/workspace")
os.makedirs(OUTPUT_DIR, exist_ok=True)
FILENAME = "presentation.pptx"  # <-- change this
OUTPUT_PATH = os.path.join(OUTPUT_DIR, FILENAME)

THEME = "lancet"  # lancet | npg | nejm
T = {
    "lancet": {"p":(0,70,139),"a":(237,0,0),"a2":(66,181,64),"l":(232,238,244),"t":(51,51,51),"m":(136,136,136)},
    "npg":    {"p":(60,84,136),"a":(230,75,53),"a2":(0,160,135),"l":(238,240,245),"t":(51,51,51),"m":(132,145,180)},
    "nejm":   {"p":(0,114,181),"a":(188,60,41),"a2":(32,133,78),"l":(230,240,248),"t":(51,51,51),"m":(111,153,173)},
}[THEME]

def rgb(key): return RGBColor(*T[key])

prs = Presentation()
prs.slide_width  = Inches(13.333)
prs.slide_height = Inches(7.5)
W, H = prs.slide_width, prs.slide_height

def add_shape(slide, left, top, w, h, fill=None):
    s = slide.shapes.add_shape(1, left, top, w, h)
    s.line.fill.background()
    if fill: s.fill.solid(); s.fill.fore_color.rgb = RGBColor(*fill)
    else: s.fill.background()
    return s

def add_text(slide, left, top, w, h, text, size=18, bold=False, color="t", align=PP_ALIGN.LEFT, anchor=MSO_ANCHOR.TOP):
    box = slide.shapes.add_textbox(left, top, w, h)
    box.text_frame.word_wrap = True
    p = box.text_frame.paragraphs[0]
    p.text = text
    p.font.size = Pt(size)
    p.font.bold = bold
    p.font.color.rgb = rgb(color)
    p.alignment = align
    box.text_frame.paragraphs[0].space_after = Pt(4)
    return box

def add_bullets(slide, left, top, w, h, items, size=16, color="t"):
    box = slide.shapes.add_textbox(left, top, w, h)
    tf = box.text_frame
    tf.word_wrap = True
    for i, item in enumerate(items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = item
        p.font.size = Pt(size)
        p.font.color.rgb = rgb(color)
        p.space_after = Pt(8)
        p.level = 0
    return box

def title_slide(title, subtitle="", presenter=""):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    add_shape(s, 0, 0, W, H, fill=T["p"])
    add_shape(s, 0, Inches(5.2), W, Inches(2.3), fill=(max(0,T["p"][0]-20), max(0,T["p"][1]-20), max(0,T["p"][2]-20)))
    add_text(s, Inches(1), Inches(1.8), Inches(11), Inches(2), title, size=40, bold=True, color="l", align=PP_ALIGN.LEFT)
    if subtitle:
        add_text(s, Inches(1), Inches(3.8), Inches(11), Inches(1), subtitle, size=22, color="l")
    if presenter:
        add_text(s, Inches(1), Inches(5.6), Inches(11), Inches(0.8), presenter, size=16, color="l")
    return s

def section_slide(title):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    add_shape(s, 0, 0, W, H, fill=T["l"])
    add_shape(s, Inches(0.8), Inches(3.2), Inches(2), Pt(4), fill=T["p"])
    add_text(s, Inches(0.8), Inches(1.8), Inches(11), Inches(1.5), title, size=36, bold=True, color="p")
    return s

def content_slide(title, bullets, note=""):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    add_shape(s, 0, 0, W, Inches(0.06), fill=T["p"])
    add_text(s, Inches(0.8), Inches(0.4), Inches(11), Inches(1), title, size=28, bold=True, color="p")
    add_shape(s, Inches(0.8), Inches(1.3), Inches(2), Pt(3), fill=T["a"])
    add_bullets(s, Inches(0.8), Inches(1.6), Inches(11), Inches(4.8), bullets, size=18)
    if note:
        add_text(s, Inches(0.8), Inches(6.5), Inches(11), Inches(0.6), note, size=12, color="m")
    return s

def two_col_slide(title, left_items, right_items, left_title="", right_title=""):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    add_shape(s, 0, 0, W, Inches(0.06), fill=T["p"])
    add_text(s, Inches(0.8), Inches(0.4), Inches(11), Inches(1), title, size=28, bold=True, color="p")
    add_shape(s, Inches(0.8), Inches(1.3), Inches(2), Pt(3), fill=T["a"])
    if left_title:
        add_text(s, Inches(0.8), Inches(1.6), Inches(5.2), Inches(0.5), left_title, size=20, bold=True, color="p")
    add_bullets(s, Inches(0.8), Inches(2.2), Inches(5.2), Inches(4.2), left_items, size=16)
    if right_title:
        add_text(s, Inches(7), Inches(1.6), Inches(5.2), Inches(0.5), right_title, size=20, bold=True, color="p")
    add_bullets(s, Inches(7), Inches(2.2), Inches(5.2), Inches(4.2), right_items, size=16)
    return s

def table_slide(title, headers, rows):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    add_shape(s, 0, 0, W, Inches(0.06), fill=T["p"])
    add_text(s, Inches(0.8), Inches(0.4), Inches(11), Inches(1), title, size=28, bold=True, color="p")
    add_shape(s, Inches(0.8), Inches(1.3), Inches(2), Pt(3), fill=T["a"])
    cols = len(headers)
    tbl = s.shapes.add_table(len(rows)+1, cols, Inches(0.8), Inches(1.8), Inches(11.5), Inches(4.5)).table
    for j, h in enumerate(headers):
        c = tbl.cell(0, j); c.text = h
        for p in c.text_frame.paragraphs:
            p.font.size = Pt(14); p.font.bold = True; p.font.color.rgb = RGBColor(255,255,255)
        c.fill.solid(); c.fill.fore_color.rgb = rgb("p")
    for i, row in enumerate(rows):
        for j, val in enumerate(row):
            c = tbl.cell(i+1, j); c.text = str(val)
            for p in c.text_frame.paragraphs:
                p.font.size = Pt(13); p.font.color.rgb = rgb("t")
            c.fill.solid(); c.fill.fore_color.rgb = RGBColor(*(T["l"] if i%2==0 else (255,255,255)))
    return s

def end_slide(title, items=None):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    add_shape(s, 0, 0, W, H, fill=T["p"])
    add_text(s, Inches(1), Inches(2.5), Inches(11), Inches(2), title, size=36, bold=True, color="l", align=PP_ALIGN.CENTER)
    if items:
        add_bullets(s, Inches(2), Inches(4.2), Inches(9), Inches(2), items, size=18, color="l")
    return s


# ============================================================
# FILL IN SLIDES BELOW — use the helpers above
# ============================================================

title_slide(
    "Your Title Here",
    subtitle="Subtitle line",
    presenter="Author · Institution · Date",
)

content_slide("Slide Title", [
    "• Bullet point one",
    "• Bullet point two",
    "• Bullet point three",
])

# ... add more slides using the helpers ...

end_slide("Thank You", ["contact@example.com"])


# ============================================================
# SAVE
# ============================================================
prs.save(OUTPUT_PATH)
print(f"DONE: {OUTPUT_PATH} ({len(prs.slides)} slides)")
```

### Output Convention

- Save to `~/.scienceclaw/workspace/<descriptive-name>.pptx`
- Print the absolute path and slide count on success
- If the script fails, print the traceback — do NOT silently swallow errors

### Error Handling

- If `python-pptx` fails to install: tell the user to run `pip install python-pptx` on the host
- If script errors: read traceback, fix, re-run (max 3 attempts)
- After success: verify the file exists and has non-zero size before telling the user

### Language & Content Rules

- Match the user's language. If user writes in Chinese, all slide content must be Chinese.
- Keep bullet points to 3-5 per slide, 6-10 words per bullet.
- Use the academic palette consistently.
- The model decides which helper to use for each slide (title_slide, content_slide, two_col_slide, table_slide, section_slide, end_slide).
