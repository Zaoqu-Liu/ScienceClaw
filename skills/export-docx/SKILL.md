---
name: export-docx
description: Export research project reports to Word (.docx) format with embedded figures and formatted references. Use when user says "导出 Word", "/export word", "转 docx", "生成 Word 报告", "export to Word", or wants a Word document from project results.
---

# Export to Word (.docx)

Convert a ScienceClaw project's report and figures into a formatted Word document using python-docx.

## When to Use

- User says "/export word", "导出 Word", "转 docx", "生成 Word 报告"
- User wants to share findings with collaborators who use Word
- User needs a formatted document for submission or review

## Workflow

1. **Identify the project directory** from ACTIVE_PROJECT.md or the most recent project
2. **Read the main report** from `reports/` directory (markdown)
3. **Collect figures** from `figures/` directory
4. **Read METHODS.md** if present
5. **Generate .docx** using python-docx with proper formatting
6. **Save** to `reports/<project_name>_report.docx`

## Code Template

```python
pip install -q python-docx Pillow 2>/dev/null && python3 << 'DOCXEOF'
import os, re, glob
from docx import Document
from docx.shared import Inches, Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.style import WD_STYLE_TYPE

PROJECT_DIR = os.path.expanduser("PROJECT_DIR_PLACEHOLDER")
REPORT_FILE = "REPORT_FILE_PLACEHOLDER"
OUTPUT_FILE = os.path.join(PROJECT_DIR, "reports", "OUTPUT_NAME_PLACEHOLDER.docx")

doc = Document()

# --- Page setup ---
section = doc.sections[0]
section.top_margin = Cm(2.54)
section.bottom_margin = Cm(2.54)
section.left_margin = Cm(3.18)
section.right_margin = Cm(3.18)

# --- Styles ---
style = doc.styles['Normal']
font = style.font
font.name = 'Times New Roman'
font.size = Pt(11)
font.color.rgb = RGBColor(0x33, 0x33, 0x33)
style.paragraph_format.line_spacing = 1.5
style.paragraph_format.space_after = Pt(6)

for level in range(1, 4):
    hs = doc.styles[f'Heading {level}']
    hs.font.name = 'Arial'
    hs.font.color.rgb = RGBColor(0x3C, 0x54, 0x88)
    hs.font.size = Pt(16 - level * 2)
    hs.font.bold = True

# --- Read report markdown ---
report_path = os.path.join(PROJECT_DIR, "reports", REPORT_FILE)
with open(report_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

fig_dir = os.path.join(PROJECT_DIR, "figures")

# --- Parse and convert ---
for line in lines:
    line = line.rstrip('\n')

    # Headings
    if line.startswith('### '):
        doc.add_heading(line[4:], level=3)
    elif line.startswith('## '):
        doc.add_heading(line[3:], level=2)
    elif line.startswith('# '):
        doc.add_heading(line[2:], level=1)
    # Figure references
    elif '![' in line:
        m = re.search(r'!\[.*?\]\((.*?)\)', line)
        if m:
            img_path = m.group(1)
            if not os.path.isabs(img_path):
                img_path = os.path.join(PROJECT_DIR, img_path)
            if os.path.exists(img_path):
                doc.add_picture(img_path, width=Inches(5.5))
                last_p = doc.paragraphs[-1]
                last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    # Table rows (simple pipe tables)
    elif line.startswith('|') and '---' not in line:
        cells = [c.strip() for c in line.split('|')[1:-1]]
        if cells:
            # Check if this is first row of a table
            if not hasattr(doc, '_current_table') or doc._current_table is None:
                doc._current_table = doc.add_table(rows=0, cols=len(cells))
                doc._current_table.style = 'Table Grid'
            row = doc._current_table.add_row()
            for i, cell_text in enumerate(cells):
                if i < len(row.cells):
                    row.cells[i].text = cell_text
    elif line.startswith('|') and '---' in line:
        pass  # skip separator rows
    else:
        # End current table if any
        if hasattr(doc, '_current_table'):
            doc._current_table = None
        # Regular paragraph
        if line.strip():
            p = doc.add_paragraph()
            parts = re.split(r'(\*\*.*?\*\*)', line)
            for part in parts:
                if part.startswith('**') and part.endswith('**'):
                    run = p.add_run(part[2:-2])
                    run.bold = True
                else:
                    p.add_run(part)

# --- Embed remaining figures at the end ---
if os.path.isdir(fig_dir):
    pngs = sorted(glob.glob(os.path.join(fig_dir, '*.png')))
    if pngs:
        doc.add_heading('Figures', level=1)
        for png in pngs:
            fname = os.path.basename(png)
            doc.add_heading(fname.replace('.png', '').replace('_', ' ').title(), level=3)
            doc.add_picture(png, width=Inches(5.5))
            last_p = doc.paragraphs[-1]
            last_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            doc.add_paragraph('')

# --- Append METHODS if present ---
methods_path = os.path.join(PROJECT_DIR, "METHODS.md")
if os.path.exists(methods_path):
    doc.add_page_break()
    doc.add_heading('Methods', level=1)
    with open(methods_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                doc.add_paragraph(line)

os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
doc.save(OUTPUT_FILE)
print(f"Saved: {OUTPUT_FILE}")
DOCXEOF
```

## Customization

- Replace `PROJECT_DIR_PLACEHOLDER` with the actual project directory
- Replace `REPORT_FILE_PLACEHOLDER` with the main report filename
- Replace `OUTPUT_NAME_PLACEHOLDER` with the desired output name
- Adjust page margins, fonts, and heading styles as needed
