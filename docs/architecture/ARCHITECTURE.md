# Architecture

ScienceClaw is built on a radical design principle: **zero custom code**. The entire product is one markdown file ([`SCIENCE.md`](../../SCIENCE.md), ~600 lines) plus 266 domain skill files, running on the OpenClaw engine. There are no TypeScript services, no Python servers, no MCP plugins. The language model does 99% of the work.

---

## 4-Layer Design

```
┌─────────────────────────────────────────────────┐
│                    User                          │
│            (TUI / WebSocket client)              │
├─────────────────────────────────────────────────┤
│                  Gateway                         │
│         (OpenClaw WebSocket server)              │
│         Port 18789, token auth                   │
├─────────────────────────────────────────────────┤
│                   Agent                          │
│   SCIENCE.md (identity + instructions)           │
│   266 skills (domain knowledge)                  │
│   LLM (Claude / GPT / Gemini)                   │
├─────────────────────────────────────────────────┤
│              Infrastructure                      │
│   web_search  │  web_fetch  │  bash              │
│   (Google)    │  (REST APIs)│  (Python/R/Julia)  │
└─────────────────────────────────────────────────┘
```

### Layer 1: User

The user interacts through the **TUI** (terminal user interface), a built-in chat interface provided by OpenClaw. The TUI connects to the gateway via WebSocket.

Other clients can also connect -- any WebSocket client that speaks the OpenClaw protocol can talk to the gateway.

### Layer 2: Gateway

The **OpenClaw gateway** is a Node.js WebSocket server that:

- Accepts client connections with token authentication
- Routes messages between the client and the agent
- Manages agent lifecycle (start, stop, context compaction)
- Handles tool execution requests from the agent
- Serves on port **18789** by default

The gateway is entirely provided by OpenClaw. ScienceClaw adds zero code to it.

```
Client (TUI) <--WebSocket--> Gateway <--API--> LLM Provider
                                │
                                ├── web_search (via Google)
                                ├── web_fetch (HTTP requests)
                                └── bash (shell commands)
```

### Layer 3: Agent

The agent is the LLM (Claude, GPT, or Gemini) loaded with two types of context:

1. **SCIENCE.md** -- the agent's identity and core instructions (~600 lines)
2. **Skills** -- 266 domain-specific markdown files loaded on demand

The agent has no persistent state of its own. It operates purely through its context window, using the instructions in SCIENCE.md and loaded skills to decide what tools to call and how to interpret results.

### Layer 4: Infrastructure

Two primary tools provided by OpenClaw:

| Tool | What It Does | How the Agent Uses It |
|------|-------------|----------------------|
| `web_search` | Brave search | Broad discovery of papers, databases, documentation |
| `bash` | Shell command execution | Run Python/R/Julia code, query REST APIs via `curl` (PubMed, UniProt, ChEMBL, etc.) |

No additional tools, no MCP servers, no custom integrations. These two tools are sufficient because scientific databases expose REST APIs (queried via `bash` + `curl`), and analysis code can be written and executed on the fly.

---

## SCIENCE.md: The Agent's Brain

`SCIENCE.md` is the single most important file in the project. It defines:

### Identity

```markdown
You are ScienceClaw, a dedicated AI research colleague built for scientific
discovery. This is your ONLY identity.
```

The agent is told it is a science assistant and nothing else. It will refuse non-science tasks.

### Zero-Hallucination Rule

```markdown
When a search returns no results, say so. NEVER substitute citations from
training data. NEVER fabricate references.
```

This is the most critical instruction. Every citation must come from a tool result in the current conversation, never from the model's training data.

### Literature Search Strategy

SCIENCE.md includes exact API endpoints for:
- PubMed E-utilities
- OpenAlex API
- Semantic Scholar API
- Europe PMC API
- Jina Reader (for full-text extraction)

The agent constructs HTTP requests to these APIs using `web_fetch`.

### Database Query Patterns

Exact REST API URLs for:
- NCBI Gene, Ensembl, GTEx (genomics)
- UniProt, PDB, AlphaFold, STRING (proteomics)
- ChEMBL, PubChem, Open Targets (chemistry)
- ClinicalTrials.gov, ClinVar (clinical)
- Enrichr, Reactome (pathways)

### Code Execution Protocol

Instructions for running Python, R, and Julia code via `bash`, including:
- Self-verification (check exit codes, validate outputs)
- Scientific sense-checking (suspicious correlations, implausible p-values)
- Permutation-based null models for statistical results

### Visualization Standards

Journal-specification figure sizing and color palettes:
- NPG, Lancet, JCO, NEJM color palettes
- Single-column, double-column, presentation sizing presets
- 300 DPI minimum for publication quality

### ScholarEval Rubric

An 8-dimension research quality evaluation framework with weighted scoring for novelty, rigor, clarity, reproducibility, impact, coherence, limitations, and ethics.

---

## Skills System

Skills are markdown files in `skills/` that provide domain-specific knowledge. Each skill is a directory containing a `SKILL.md` file.

### How Skills Are Loaded

```
scienceclaw/
  skills/
    pubmed-search/
      SKILL.md          ← loaded by engine
    alphafold-database/
      SKILL.md          ← loaded by engine
    scanpy/
      SKILL.md          ← loaded by engine
    ... (266 total)
```

The OpenClaw engine:

1. Scans directories listed in `skills.load.extraDirs`
2. Indexes all `SKILL.md` files found
3. When a query arrives, matches it against skill descriptions
4. Loads relevant skills into the agent's context (up to `bootstrapTotalMaxChars`)

### Skill Categories

| Category | Count | Examples |
|----------|-------|---------|
| Literature & Search | 20+ | pubmed-search, openalex-database, arxiv-search |
| Genomics & Bioinformatics | 30+ | gene-database, ensembl-database, scanpy, bioinformatics |
| Proteomics & Structure | 15+ | uniprot-database, pdb-database, alphafold-database |
| Chemistry & Drugs | 20+ | chembl-database, rdkit, medchem, drug-discovery-search |
| Clinical & Medical | 15+ | clinicaltrials-database, clinical, treatment-plans |
| Data Analysis & Visualization | 30+ | statistics, matplotlib, scikit-learn, visualization |
| Scientific Writing | 15+ | scientific-writing, review-writing, peer-review |
| Materials & Earth Science | 10+ | materials, pymatgen, astropy, geopandas |
| ToolUniverse Integration | 50+ | Specialized bioinformatics workflow APIs |
| DevTools & Meta | 10+ | devtu-create-tool, setup-tooluniverse |

### Skill Size Limits

- **Per skill**: 30,000 characters max (`bootstrapMaxChars`)
- **Total budget**: 200,000 characters across all loaded skills (`bootstrapTotalMaxChars`)
- **Max skills per directory**: 300 (`maxSkillsLoadedPerSource`)

---

## Zero Custom Code Philosophy

ScienceClaw follows three design principles from [Agentic Product Design](https://docs.openclaw.ai):

### The Bitter Lesson

> The biggest lesson from 70 years of AI research is that general methods leveraging computation win in the long run.

No scaffolding. The model queries PubMed directly via `web_fetch`. There is no "PubMed integration" middleware, no query builder, no response parser. The model reads the API documentation (in SCIENCE.md and skills) and constructs requests itself.

When models get smarter, they automatically use these APIs better. No code needs updating.

### The Six Month Rule

> Any code you write today will be unnecessary in 6 months when models improve.

ScienceClaw has zero perishable code:
- No TypeScript services to maintain
- No Python backend to update
- No database schema to migrate
- No dependency chains to manage

The only things that change are the markdown instructions, which are trivial to update.

### The Thinnest Wrapper

> The thinnest possible layer between the model and the task.

```
Traditional approach:
  User → Frontend → Backend → Database → API Client → External API
  (hundreds of files, thousands of lines of code)

ScienceClaw approach:
  User → Gateway → Model → web_fetch → External API
  (0 lines of custom code, ~600 lines of markdown)
```

The `scienceclaw` bash wrapper manages the gateway lifecycle. `SCIENCE.md` (~600 lines) teaches the model how to be a scientist. Everything else is 266 skills (pure markdown), including 6 Research Recipes for end-to-end workflows, 3 export skills (Word/PPT/LaTeX), and a literature monitoring skill (`/watch`).

---

## Data Flow Example

Here's what happens when you ask: "Find recent papers on CRISPR base editing in sickle cell disease"

```
1. User types query in TUI
   │
2. TUI sends message via WebSocket to Gateway (port 18789)
   │
3. Gateway forwards to LLM with context:
   - SCIENCE.md (identity + instructions)
   - Relevant skills (pubmed-search, literature-search, etc.)
   - Previous conversation history
   │
4. LLM decides to call web_fetch with PubMed API:
   URL: https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi
        ?db=pubmed&retmode=json&retmax=20
        &term=CRISPR+base+editing+sickle+cell+disease
   │
5. Gateway executes web_fetch, returns JSON with PMIDs
   │
6. LLM calls web_fetch again to get abstracts:
   URL: https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi
        ?db=pubmed&retmode=xml&id=PMID1,PMID2,...
   │
7. LLM may also call web_fetch with OpenAlex for citation counts:
   URL: https://api.openalex.org/works?search=CRISPR+base+editing+sickle+cell
   │
8. LLM reads all results, synthesizes a response with:
   - Paper summaries with real citations
   - Key themes and trends
   - Proper author names, journals, years, DOIs
   │
9. Response sent back through Gateway → WebSocket → TUI
```

Total custom code involved: **0 lines**. The model did all the thinking.

---

## File Structure

```
scienceclaw/
├── scienceclaw              # Bash wrapper (gateway lifecycle)
├── SCIENCE.md               # Agent brain (identity + instructions, ~600 lines)
├── openclaw.config.json     # Configuration (models, agents, skills, gateway)
├── package.json             # Node.js package (depends on openclaw engine)
├── .env                     # API keys and tokens (not committed)
├── .env.example             # Environment variable template
├── scripts/
│   ├── setup.sh             # Interactive setup wizard
│   ├── i18n.sh              # Bilingual message system (zh/en)
│   └── channel.mjs          # Channel management helper
├── skills/                  # 266 domain skills
│   ├── CATALOG.json         # Skill index (name, title, description)
│   ├── research-recipes/    # 6 pre-built research workflows
│   ├── export-docx/         # Export to Word
│   ├── export-pptx/         # Export to PowerPoint
│   ├── export-latex/        # Export to LaTeX
│   ├── research-alerts/     # /watch literature monitoring
│   ├── scanpy/              # Single-cell analysis
│   ├── alphafold-database/  # Protein structure predictions
│   └── ... (266 total)
├── docs/                    # Documentation (you are here)
├── docker/                  # Docker sandbox configuration
├── assets/                  # Images and logos
└── tests/                   # Tests
```

---

## See Also

- [SCIENCE.md](../../SCIENCE.md) -- the agent's core instructions (read this to understand everything)
- [Skills Guide](../guides/skills.md) -- how skills work and how to create them
- [Database Reference](../guides/databases.md) -- all 77+ queryable databases
- [Configuration](../getting-started/configuration.md) -- all configuration options
