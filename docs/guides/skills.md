# Skills Guide

Skills are the domain knowledge layer of ScienceClaw. They are markdown files that teach the agent how to perform specific scientific tasks -- from querying protein databases to running survival analysis to writing LaTeX papers.

---

## What Are Skills?

A skill is a directory containing a `SKILL.md` file. Each file provides:

- **When to activate** -- trigger conditions (e.g., "when the user asks about protein structure")
- **Domain knowledge** -- API endpoints, parameter formats, common workflows
- **Code templates** -- ready-to-use Python/R code for specific analyses
- **Best practices** -- quality standards, common pitfalls, verification steps

Skills are NOT code plugins. They are pure markdown instructions that the agent reads and follows. The agent decides which skills are relevant based on your query and loads them into context.

### Example: The `pubmed-search` Skill

```markdown
# PubMed Search

Use when the user wants to search PubMed for biomedical literature.

## API Endpoint
https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi

## Parameters
- db=pubmed
- retmode=json
- retmax=20
- term=YOUR+SEARCH+TERMS

## Strategy
1. Start with a broad search to estimate result count
2. Refine with MeSH terms for precision
3. Fetch abstracts for the top hits
4. Cross-reference with OpenAlex for citation counts
...
```

---

## How the Agent Uses Skills

1. **At startup**, the engine scans the `skills/` directory and creates an index of all available skills
2. **When you ask a question**, the engine matches your query against skill descriptions
3. **Relevant skills are loaded** into the agent's context (subject to character limits)
4. **The agent follows the instructions** in the skill to perform the task

The loading is governed by these settings in `openclaw.config.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": ["/path/to/scienceclaw/skills"]
    },
    "limits": {
      "maxSkillsLoadedPerSource": 300,
      "maxCandidatesPerRoot": 300
    }
  },
  "agents": {
    "defaults": {
      "bootstrapMaxChars": 30000,
      "bootstrapTotalMaxChars": 200000
    }
  }
}
```

- `extraDirs` -- directories to scan for skills
- `maxSkillsLoadedPerSource` -- max skills loaded from one directory
- `bootstrapMaxChars` -- max characters per individual skill
- `bootstrapTotalMaxChars` -- total character budget across all loaded skills

---

## Browsing Skills

### CLI (recommended)

```bash
./scienceclaw skills                    # list all 266 skills grouped by domain
./scienceclaw skills search "protein"   # search by keyword
./scienceclaw skills search "survival"  # find survival-related skills
./scienceclaw skills search "database"  # find all database skills
```

### Direct File Access

```bash
ls skills/                              # list all skill directories
cat skills/pubmed-search/SKILL.md       # read a specific skill
cat skills/CATALOG.json | head -50      # browse the skill index
```

---

## Skill Categories

ScienceClaw ships with **266 skills** organized across these domains.

**New skills** added in the latest release:

| Skill | Description |
|-------|-------------|
| `research-recipes` | 6 pre-built research workflows (gene-landscape, target-validation, literature-review, diff-expression, clinical-query, person-research) |
| `export-docx` | Export project reports to Word (.docx) with embedded figures and references |
| `export-pptx` | Export findings to PowerPoint (.pptx) with key findings, figures, and conclusions |
| `export-latex` | Export findings to LaTeX manuscript draft (Nature, Cell, Lancet formats) |
| `research-alerts` | `/watch` command for monitoring new publications on PubMed |

### Literature & Search (20+ skills)

Skills for searching and analyzing academic literature.

| Skill | Description |
|-------|-------------|
| `academic-literature-search` | Multi-source academic search strategy |
| `pubmed-search` | PubMed E-utilities query patterns |
| `pubmed-database` | PubMed database reference |
| `openalex-database` | OpenAlex API for citation data |
| `arxiv-search` | arXiv preprint search |
| `biorxiv-search` | bioRxiv preprint search |
| `medrxiv-search` | medRxiv preprint search |
| `literature-search` | General literature search workflow |
| `literature-review` | Systematic literature review methodology |
| `perplexity-search` | Perplexity AI search integration |
| `citation-management` | Citation formatting and management |

### Genomics & Bioinformatics (30+ skills)

| Skill | Description |
|-------|-------------|
| `gene-database` | NCBI Gene, Ensembl queries |
| `ensembl-database` | Ensembl REST API patterns |
| `clinvar-database` | ClinVar variant database |
| `gwas-database` | GWAS Catalog queries |
| `geo-database` | GEO expression datasets |
| `ena-database` | European Nucleotide Archive |
| `bioinformatics` | General bioinformatics workflows |
| `biopython` | BioPython library usage |
| `pysam` | SAM/BAM file processing |
| `scanpy` | Single-cell analysis with Scanpy |
| `scvi-tools` | Deep learning for single-cell |
| `pydeseq2` | Differential expression analysis |
| `deeptools` | Sequencing data analysis tools |

### Proteomics & Structural Biology (15+ skills)

| Skill | Description |
|-------|-------------|
| `uniprot-database` | UniProt protein database |
| `pdb-database` | Protein Data Bank queries |
| `alphafold-database` | AlphaFold structure predictions |
| `string-database` | STRING protein interactions |
| `esm` | ESM protein language models |
| `diffdock` | Molecular docking predictions |

### Chemistry & Drug Discovery (20+ skills)

| Skill | Description |
|-------|-------------|
| `chembl-database` | ChEMBL bioactivity database |
| `chembl-search` | ChEMBL search patterns |
| `pubchem-database` | PubChem compound database |
| `drugbank-database` | DrugBank drug information |
| `zinc-database` | ZINC compound library |
| `rdkit` | RDKit cheminformatics |
| `medchem` | Medicinal chemistry workflows |
| `datamol` | Molecular data processing |
| `deepchem` | Deep learning for chemistry |

### Clinical & Medical (15+ skills)

| Skill | Description |
|-------|-------------|
| `clinicaltrials-database` | ClinicalTrials.gov queries |
| `clinical-trials-search` | Trial search strategies |
| `clinical` | Clinical data analysis |
| `clinical-decision-support` | Clinical decision frameworks |
| `fda-database` | FDA drug approvals and labels |
| `drug-labels-search` | Drug label search |
| `treatment-plans` | Treatment planning support |

### Pathways & Systems Biology (10+ skills)

| Skill | Description |
|-------|-------------|
| `kegg-database` | KEGG pathway database |
| `reactome-database` | Reactome pathway database |
| `opentargets-database` | Open Targets platform |

### Data Analysis & Visualization (30+ skills)

| Skill | Description |
|-------|-------------|
| `statistics` | Statistical analysis methods |
| `statistical-analysis` | Advanced statistical workflows |
| `visualization` | General visualization guidance |
| `matplotlib` | Matplotlib plotting |
| `seaborn` | Seaborn statistical plots |
| `plotly` | Interactive Plotly charts |
| `scikit-learn` | Machine learning with sklearn |
| `shap` | SHAP explainability |
| `networkx` | Network analysis |
| `exploratory-data-analysis` | EDA workflows |

### Scientific Writing & Communication (15+ skills)

| Skill | Description |
|-------|-------------|
| `scientific-writing` | Academic writing standards |
| `review-writing` | Review article methodology |
| `peer-review` | Peer review evaluation |
| `science-communication` | Science communication |
| `scientific-slides` | Presentation creation |
| `latex-posters` | LaTeX poster generation |
| `patent-drafting` | Patent writing |

### Materials & Earth Science (10+ skills)

| Skill | Description |
|-------|-------------|
| `materials` | Materials science workflows |
| `pymatgen` | Materials analysis with pymatgen |
| `astropy` | Astronomy with AstroPy |
| `geopandas` | Geospatial data analysis |
| `fluidsim` | Fluid dynamics simulation |

### ToolUniverse Integration (50+ skills)

Skills for ToolUniverse API endpoints covering specialized bioinformatics workflows.

| Skill | Description |
|-------|-------------|
| `tooluniverse-single-cell` | Single-cell analysis pipelines |
| `tooluniverse-protein-structure-retrieval` | Protein structure retrieval |
| `tooluniverse-drug-target-validation` | Drug target validation |
| `tooluniverse-gwas-study-explorer` | GWAS study exploration |
| `tooluniverse-precision-oncology` | Precision oncology workflows |
| `tooluniverse-variant-interpretation` | Genetic variant interpretation |
| `tooluniverse-spatial-transcriptomics` | Spatial transcriptomics |
| `tooluniverse-metabolomics-analysis` | Metabolomics analysis |
| `tooluniverse-antibody-engineering` | Antibody engineering |
| ... | 40+ more specialized workflows |

---

## Creating a New Skill

### 1. Create the Directory

```bash
mkdir skills/my-new-skill
```

### 2. Write the SKILL.md

Create `skills/my-new-skill/SKILL.md` with this structure:

```markdown
# Skill Name

Brief description of what this skill does. Use when [trigger conditions].

## When to Use

- When the user asks about [topic]
- When the task involves [specific technique]

## Key Resources

- **API Endpoint**: https://example.com/api/v1/...
- **Documentation**: https://docs.example.com

## Workflow

1. First, do X
2. Then, query Y with parameters Z
3. Verify results by checking W

## Code Templates

### Python Example

\`\`\`python
import requests

response = requests.get("https://api.example.com/query", params={
    "term": "QUERY",
    "format": "json"
})
data = response.json()
\`\`\`

## Common Pitfalls

- Pitfall 1: description and how to avoid
- Pitfall 2: description and how to avoid

## Quality Checks

- Verify: condition 1
- Verify: condition 2
```

### 3. Register the Skill

Skills in the `skills/` directory are auto-discovered. If your skill is in a different directory, add it to `openclaw.config.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "/path/to/scienceclaw/skills",
        "/path/to/my-custom-skills"
      ]
    }
  }
}
```

### 4. Test It

Restart the gateway and ask the agent a question that should trigger your skill:

```bash
./scienceclaw stop && ./scienceclaw run
```

Then ask a relevant question in the TUI. The agent should use your skill's instructions to handle the query.

---

## Skill Writing Best Practices

1. **Be specific about trigger conditions** -- the agent needs to know when to apply this skill
2. **Include real API endpoints** with example parameters -- the agent calls these directly
3. **Provide code templates** -- reduces errors and speeds up execution
4. **Add verification steps** -- teaches the agent to check its own work
5. **Document common pitfalls** -- prevents known failure modes
6. **Keep it concise** -- skills compete for context space (30K char limit per skill)

---

## See Also

- [Database Reference](databases.md) -- all 77+ databases the agent can query
- [Architecture](../architecture/ARCHITECTURE.md) -- how skills fit into the system
- [Configuration](../getting-started/configuration.md) -- skills loading settings
