---
name: devtu-optimize-skills
description: Optimize ToolUniverse skills for better report quality, evidence handling, and user experience. Apply patterns like tool verification, foundation data layers, disambiguation-first, evidence grading, quantified completeness, and report-only output. Use when reviewing skills, improving existing skills, or creating new ToolUniverse research skills.
---

# Optimizing ToolUniverse Skills

Best practices for creating high-quality ToolUniverse research skills that produce detailed, evidence-graded reports with proper source attribution.

## When to Use This Skill

Apply when:
- Creating new ToolUniverse research skills
- Reviewing/improving existing skills
- User complains about missing details, noisy results, or unclear reports
- Skill produces process-heavy instead of content-heavy output
- Tools are failing silently or returning empty results

## Tool Quality Standards

These principles apply when evaluating or improving the underlying tool implementations (not just the skill layer):

1. **Error messages must be actionable** — tell the user *what* went wrong AND *what to do*. Not "Not found" but "Cancer type 'CLL' is not a TCGA type. Use one of: [BRCA, LUAD, ...]. For CLL data, try `CancerPrognosis_search_studies(keyword='CLL')`."

2. **Schema must match API reality** — `return_schema` field names must match actual API response fields. Run `python3 -m tooluniverse.cli run <Tool> '<json>'` and compare field names against the schema before publishing.

3. **Coverage transparency** — descriptions must state what data is NOT included, not just what is. If a tool only covers TCGA cancer types, say so explicitly in the description.

4. **Input validation before API calls** — validate cancer names, gene symbols, drug names at input. Don't silently send invalid values to the API and return empty results.

5. **Cross-tool routing** — when a query is out-of-scope, the error message should name the correct tool to use instead.

6. **No silent parameter dropping** — if a parameter is ignored or unsupported, the response must say so. Never silently discard a user-supplied filter.

## Core Optimization Principles

### 1. Tool Interface Verification (Pre-flight Check)

**Problem**: Tool APIs change parameter names over time, or skills are written with incorrect parameter assumptions. This causes silent failures - tools return empty results without errors.

**Solution**: Verify tool parameters before calling unfamiliar tools:

```python
# Always check tool params to prevent silent failures
tool_info = tu.tools.get_tool_info(tool_name="Reactome_map_uniprot_to_pathways")
# Reveals: takes `id` not `uniprot_id`
```

**Maintain a known corrections table** in skills that use many tools:

| Tool | WRONG Parameter | CORRECT Parameter |
|------|-----------------|-------------------|
| `Reactome_map_uniprot_to_pathways` | `uniprot_id` | `id` |
| `ensembl_get_xrefs` | `gene_id` | `id` |
| `GTEx_get_median_gene_expression` | `gencode_id` only | `gencode_id` + `operation="median"` |
| `OpenTargets_*` | `ensemblID` | `ensemblId` (camelCase) |

**Rule**: Before calling any tool for the first time in a skill, confirm params via `get_tool_info()` once per tool family, or maintain a vetted param map in the skill.

**Why this matters**: Retry logic won't help if you're calling a tool with wrong parameter names - it will consistently return empty. This is different from API flakiness.

### 2. Foundation Data Layer (Path 0)

**Problem**: Skills query specialized tools for each section independently, missing data that a comprehensive aggregator already has. Results are inconsistent when specialized tools fail.

**Solution**: Identify if your domain has a **comprehensive aggregator** and query it FIRST before specialized tools.

**Examples by domain**:

| Domain | Foundation Source | What It Provides |
|--------|-------------------|------------------|
| Drug targets | Open Targets | Diseases, tractability, safety, drugs, GO, publications, mouse models |
| Chemicals | PubChem | Properties, bioactivity, patents, literature |
| Diseases | Open Targets / OMIM | Genes, drugs, phenotypes, literature |
| Genes | MyGene / Ensembl | Annotations, cross-refs, GO, pathways |

**Pattern**:
```markdown
## Workflow
Phase 0: Foundation Data (aggregator query)
Phase 1: Disambiguation (ID resolution, collision detection)
Phase 2: Specialized Queries (fill gaps from Phase 0)
Phase 3: Report Synthesis
```

**Why this works**: The aggregator provides reliable baseline data across multiple sections. Specialized tools then add depth or fill gaps, rather than being the sole source.

### 3. Versioned Identifier Handling

**Problem**: Some APIs require versioned identifiers (e.g., GTEx needs `ENSG00000123456.12`), while others reject them. Skills fail silently when using the wrong format.

**Solution**: During ID resolution, capture BOTH versioned and unversioned forms:

```python
ids = {
    'ensembl': 'ENSG00000123456',           # Unversioned (most APIs)
    'ensembl_versioned': 'ENSG00000123456.12'  # Versioned (GTEx, some others)
}

# Get version from Ensembl lookup
gene_info = tu.tools.ensembl_lookup_gene(id=ensembl_id, species="human")
if gene_info and gene_info.get('version'):
    ids['ensembl_versioned'] = f"{ensembl_id}.{gene_info['version']}"
```

**Fallback strategy**:
1. Try unversioned first (more portable)
2. If empty, try versioned
3. Document which format worked

**Common versioned ID APIs**: GTEx, GENCODE, some Ensembl endpoints

### 4. Disambiguation Before Research

**Problem**: Skills that jump straight to literature search often miss target details or retrieve irrelevant papers due to naming collisions.

**Solution**: Add a disambiguation phase before any literature search:

```markdown
## Phase 1: Target Disambiguation (Default ON)

### 1.1 Resolve Official Identifiers
- UniProt accession (canonical protein)
- Ensembl gene ID + version (for expression data)
- NCBI Gene ID (for literature)
- ChEMBL target ID (for drug data)

### 1.2 Gather Synonyms and Aliases
- All known gene symbols
- Protein name variants
- Historical names

### 1.3 Detect Naming Collisions
- Search "[SYMBOL]"[Title] - review top 20 results
- If >20% off-topic → identify collision terms
- Build negative filter: NOT [collision1] NOT [collision2]

### 1.4 Get Baseline Profile (from annotation DBs, not literature)
- Protein domains (InterPro)
- Subcellular location (HPA)
- Tissue expression (GTEx)
- GO terms and pathways
```

**Why this works**: Annotation databases provide reliable baseline data even when literature is sparse or noisy.

### 5. Report-Only Output (Hide Search Process)

**Problem**: Users don't want to see "searched 8 databases, found 1,247 papers, deduplicated to 892..."

**Solution**: Output structure:

| File | Content | When |
|------|---------|------|
| `[topic]_report.md` | Narrative findings only | Always (default) |
| `[topic]_bibliography.json` | Full deduplicated papers | Always |
| `methods_appendix.md` | Search methodology | Only if requested |

**In the report**:
- ✅ DO: "The literature reveals three main therapeutic approaches..."
- ❌ DON'T: "I searched PubMed, OpenAlex, and EuropePMC, finding 342 papers..."

### 6. Evidence Grading

**Problem**: A review article mention is treated the same as a mechanistic study with direct evidence.

**Solution**: Apply evidence tiers to every claim:

| Tier | Symbol | Criteria |
|------|--------|----------|
| T1 | ★★★ | Mechanistic study with direct evidence |
| T2 | ★★☆ | Functional study (knockdown, overexpression) |
| T3 | ★☆☆ | Association (screen hit, GWAS, correlation) |
| T4 | ☆☆☆ | Mention (review, text-mined, peripheral) |

**In report**:
```markdown
ATP6V1A drives lysosomal acidification [★★★: PMID:12345678] and has been 
implicated in cancer progression [★☆☆: PMID:23456789, TCGA expression data].
```

**Required locations for evidence grades**:
1. Executive Summary - key disease claims
2. Disease Associations - every disease link
3. Key Papers table - evidence tier column
4. Recommendations - reference evidence quality

**Per-section summary**:
```markdown
### Theme: Lysosomal Function (47 papers)
**Evidence Quality**: Strong (32 mechanistic, 11 functional, 4 association)
```

### 7. Quantified Completeness (Not Just Categorical)

**Problem**: "Include PPIs" is aspirational; reports pass the checklist but are data-thin.

**Solution**: Define **numeric minimums** for each section:

| Section | Minimum Data | If Not Met |
|---------|--------------|------------|
| PPIs | ≥20 interactors | Explain why fewer + which tools failed |
| Expression | Top 10 tissues with values | Note "limited data" with specific gaps |
| Disease | Top 10 associations with scores | Note if fewer available |
| Variants | All 4 constraint scores (pLI, LOEUF, missense Z, pRec) | Note which unavailable |
| Druggability | All modalities assessed | "No drugs/probes" is valid data |
| Literature | Total + 5-year trend + 3-5 key papers | Note if sparse (<50 papers) |

**Why this matters**: Quantified minimums make completeness auditing objective and mechanical, not subjective.

### 8. Mandatory Completeness Checklist

**Problem**: Reports have inconsistent sections; some topics get skipped entirely.

**Solution**: Define mandatory sections that MUST exist, even if populated with "Limited evidence" or "Unknown":

```markdown
## Completeness Checklist (ALL Required)

### Identity & Context
- [ ] Official identifiers resolved (all 6 types)
- [ ] Synonyms/aliases documented
- [ ] Naming collisions handled (or "none detected")

### Biology
- [ ] Protein architecture (or "N/A for non-protein")
- [ ] Subcellular localization
- [ ] Expression profile (≥10 tissues with values)
- [ ] Pathway involvement (≥10 pathways)

### Mechanism
- [ ] Core function with evidence grades
- [ ] Model organism data (or "none found")
- [ ] Key assays described

### Disease & Clinical
- [ ] Genetic variants (SNVs and CNVs separated)
- [ ] Constraint scores (all 4, with interpretations)
- [ ] Disease links with evidence grades (≥10 or "limited")

### Druggability
- [ ] Tractability for all modalities
- [ ] Known drugs (or "none")
- [ ] Chemical probes (or "none available")
- [ ] Clinical pipeline (or "none")

### Synthesis (CRITICAL)
- [ ] Research themes (≥3 papers each, or "limited")
- [ ] Open questions/gaps
- [ ] Biological model synthesized
- [ ] Testable hypotheses (≥3)
```

### 9. Aggregated Data Gaps Section

**Problem**: "No data" notes scattered across 14 sections; users can't quickly see what's missing.

**Solution**: Add a dedicated **Data Gaps & Limitations** section that consolidates all gaps:

```markdown
## 15. Data Gaps & Limitations

| Section | Expected Data | Actual | Reason | Alternative Source |
|---------|---------------|--------|--------|-------------------|
| 6. PPIs | ≥20 interactors | 8 | Novel target, limited studies | Literature review needed |
| 7. Expression | GTEx TPM | None | Versioned ID not recognized | See HPA data |
| 9. Probes | Chemical probes | None | No validated probes exist | Consider tool compound dev |

**Recommendations for Data Gaps**:
1. For PPIs: Query BioGRID with broader parameters; check yeast-2-hybrid studies
2. For Expression: Query GEO directly for tissue-specific datasets
```

**Why this matters**: Users can quickly assess data quality and know where to look for more information.

### 10. Query Strategy Optimization

**Problem**: Simple keyword searches retrieve too much noise or miss relevant papers.

**Solution**: Three-step collision-aware query strategy:

```markdown
## Query Strategy

### Step 1: High-Precision Seeds
Build a mechanistic core set (15-30 papers):
- "[GENE_SYMBOL]"[Title] AND mechanism
- "[FULL_PROTEIN_NAME]"[Title]
- "UniProt:ACCESSION"

### Step 2: Citation Network Expansion
From seeds, expand via citations:
- Forward: PubMed_get_cited_by, EuropePMC_get_citations
- Related: PubMed_get_related
- Backward: EuropePMC_get_references

### Step 3: Collision-Filtered Broad
Apply negative filters for known collisions:
- "TRAG" AND immune NOT plasmid NOT conjugation
- "JAK" AND kinase NOT "just another"
```

**Citation-first for sparse targets**: When keyword search returns <30 papers, prioritize citation expansion from the few good seeds.

### 11. Tool Failure Handling

**Problem**: NCBI elink and other APIs can be flaky; skills fail silently.

**Solution**: Automatic retry with fallback chains:

```markdown
## Failure Handling

### Retry Protocol
Attempt 1 → fails → wait 2s → Attempt 2 → fails → wait 5s → Fallback

### Fallback Chains
| Primary | Fallback 1 | Fallback 2 |
|---------|------------|------------|
| PubMed_get_cited_by | EuropePMC_get_citations | OpenAlex citations |
| PubMed_get_related | SemanticScholar | Keyword search |
| GTEx_* | HPA_* | Note as unavailable |
| Unpaywall | EuropePMC OA flag | OpenAlex is_oa |
| ChEMBL_get_target_activities | GtoPdb_get_target_ligands | OpenTargets drugs |
| intact_get_interactions | STRING_get_protein_interactions | OpenTargets interactions |

### Document Failures
In report: "Expression data unavailable (GTEx API timeout after 3 attempts)"
```

**Rule**: NEVER silently skip failed tools. Always document in the Data Gaps section.

### 12. Scalable Output Structure

**Problem**: Reports with 500+ papers become unreadable; users can't find what they need.

**Solution**: Separate narrative from data:

**Narrative report** (~20-50 pages max):
- Executive summary
- Key findings by theme
- Top 20-50 papers highlighted
- Conclusions and hypotheses

**Bibliography files** (unlimited):
- `[topic]_bibliography.json` - Full structured data
- `[topic]_bibliography.csv` - Tabular for filtering

**JSON structure**:
```json
{
  "pmid": "12345678",
  "doi": "10.1038/xxx",
  "title": "...",
  "evidence_tier": "T1",
  "themes": ["lysosomal_function", "autophagy"],
  "is_core_seed": true,
  "oa_status": "gold"
}
```

### 13. Synthesis Sections

**Problem**: Reports describe what was found but don't synthesize into actionable insights.

**Solution**: Require synthesis sections:

```markdown
## Required Synthesis Sections

### Biological Model (3-5 paragraphs)
Integrate all evidence into a coherent model:
- What does the target do?
- How does it connect to disease?
- What's the key uncertainty?

### Testable Hypotheses (≥3)
| # | Hypothesis | Perturbation | Readout | Expected |
|---|------------|--------------|---------|----------|
| 1 | [Hypothesis] | [Experiment] | [Measure] | [Prediction] |

### Suggested Experiments
Brief description of how to test each hypothesis.
```

---

## Skill Review Checklist

When reviewing a ToolUniverse skill, check:

### Tool Contract
- [ ] Tool parameters verified via `get_tool_info()` or documented corrections
- [ ] Versioned vs unversioned ID handling specified
- [ ] Foundation data source identified (if available for domain)

### Report Quality
- [ ] Report focuses on content, not search process
- [ ] Methodology in separate appendix (optional)
- [ ] Evidence grades applied to claims (T1-T4)
- [ ] Source attribution on every fact
- [ ] Sections exist even if "limited evidence"

### Query Strategy
- [ ] Disambiguation phase before search
- [ ] Collision detection for ambiguous names
- [ ] High-precision seeds before broad search
- [ ] Citation expansion option for sparse topics
- [ ] Negative filters documented

### Tool Usage
- [ ] Annotation tools used (not just literature)
- [ ] Fallback chains defined
- [ ] Failure handling with retry
- [ ] OA handling (full or best-effort)

### Completeness
- [ ] Quantified minimums defined per section
- [ ] Completeness checklist with checkboxes
- [ ] Data Gaps section aggregates all missing data
- [ ] "Negative results" explicitly documented ("no probes" not blank)

### Output Structure
- [ ] Main report is narrative-focused
- [ ] Bibliography in separate JSON/CSV
- [ ] Synthesis sections required

### User Experience
- [ ] Progress updates are brief
- [ ] No raw tool outputs shown
- [ ] Final report is the deliverable

---

## Common Anti-Patterns to Fix

### 1. "Search Log" Reports
**Bad**: "Round 1: Searched PubMed (234 papers), OpenAlex (456 papers)..."
**Fix**: Keep methodology internal; report findings only

### 2. Missing Disambiguation
**Bad**: Search "JAK" and get kinase + "just another kinase" papers mixed
**Fix**: Add collision detection; build negative filters

### 3. No Evidence Grading
**Bad**: "Multiple studies show..." (which studies? what quality?)
**Fix**: Apply T1-T4 grades; label each claim

### 4. Empty Sections Omitted
**Bad**: Skip "Pathogen Involvement" because nothing found
**Fix**: Include section with "None identified in literature search"

### 5. No Synthesis
**Bad**: Long list of papers organized by theme
**Fix**: Add biological model + testable hypotheses

### 6. Monolithic Bibliography
**Bad**: 200 papers embedded in report narrative
**Fix**: Top 20-50 in report; full list in JSON/CSV

### 7. Silent Failures
**Bad**: "Expression data: [blank]" (tool failed, user doesn't know)
**Fix**: "Expression data unavailable (API timeout); see HPA directly"

### 8. Wrong Tool Parameters (NEW)
**Bad**: `Reactome_map_uniprot_to_pathways(uniprot_id=...)` returns empty
**Fix**: Verify params via `get_tool_info()`; use correct param `id`

### 9. Missing Versioned IDs (NEW)
**Bad**: GTEx returns empty for `ENSG00000123456`
**Fix**: Try versioned ID `ENSG00000123456.12`; document which worked

### 10. No Foundation Layer (NEW)
**Bad**: Query 15 specialized tools independently, miss data when some fail
**Fix**: Query comprehensive aggregator (e.g., Open Targets) first

### 11. Scattered "No Data" Notes (NEW)
**Bad**: "No data" in 5 different sections; user doesn't know overall gaps
**Fix**: Aggregate all gaps in dedicated Data Gaps section with recommendations

### 12. Aspirational Completeness (NEW)
**Bad**: "Include PPIs" ✓ (but only 3 interactors listed)
**Fix**: "≥20 PPIs OR explanation why fewer"

### 13. Untested Tool Calls (CRITICAL - NEW)
**Bad**: Skill created with excellent documentation but tools never actually called
**Example**: Documentation shows `drugbank_get_drug_basic_info(drug_name_or_drugbank_id="...")` but parameter doesn't exist
**Impact**: All 4 broken skills discovered in 2026-02 had this issue - 0% functionality despite 1,500+ line docs

**Fix**: Test-driven skill development:
1. Write test script FIRST: `test_[skill].py`
2. Call every tool with real ToolUniverse instance
3. Verify parameters work and results are correct
4. Create working pipeline from tested code
5. Write documentation from working examples

**Verification**:
```python
# Test every tool before documenting
def test_tools():
    tu = ToolUniverse()
    tu.load_tools()

    # Test Tool 1
    result = tu.tools.TOOL_NAME(param="value")
    assert result.get('status') == 'success', "Tool 1 failed"

    # Test Tool 2
    result = tu.tools.TOOL_NAME2(param="value")
    assert result.get('status') == 'success', "Tool 2 failed"
```

**Rule**: NEVER write skill documentation without first testing all tool calls.

---

## NEW: Implementation-Agnostic Skills (2026-02 Update)

### Critical Lesson from Real Fixes

**All 4 broken skills** (Drug-Drug Interaction, Clinical Trial Design, Antibody Engineering, CRISPR Screen Analysis) had excellent documentation but were never tested with real tool calls. This section documents critical lessons learned from fixing them.

### 14. Implementation-Agnostic Documentation

**Problem**: Skills written with implementation-specific code (Python SDK only) limit users to one interface. Users may access ToolUniverse via Python SDK, MCP (Model Context Protocol), or future APIs.

**Solution**: Separate general concepts from implementation details.

**File Structure**:
```
skills/[skill-name]/
├── SKILL.md                     # General workflow (NO Python/MCP code)
├── python_implementation.py     # Python SDK implementation
├── QUICK_START.md              # Multi-implementation examples
└── test_[skill].py             # Test script
```

**SKILL.md Format (General)**:
```markdown
## Phase 1: [Name]

**Objective**: What this phase achieves

**Tools needed**:
- Tool_A: Purpose and what it does
  - Input: parameter descriptions
  - Output: expected results

**Workflow**:
1. Query Tool_A with [inputs]
2. Extract [specific data]
3. If no results → try Tool_B
4. Continue with available data

**Decision logic**:
- When to use exact match vs fuzzy
- How to handle empty results
- When to trigger fallback
```

**Don't include in SKILL.md**:
- ❌ `from tooluniverse import ToolUniverse`
- ❌ `tu.tools.TOOL_NAME(...)`
- ❌ Python-specific code
- ❌ MCP-specific JSON

**QUICK_START.md Format (Multi-Implementation)**:
```markdown
## Choose Your Implementation

### Python SDK
[Python code examples]

### MCP (Model Context Protocol)
[Conversational prompts + JSON tool calls]

## Tool Parameters (All Implementations)
[Parameter table noting: applies to both Python SDK and MCP]
```

**Why this matters**: Users can choose Python SDK, MCP, or future interfaces without relearning the skill workflow.

### 15. SOAP Tools Special Handling

**Problem**: SOAP-based tools (IMGT, SAbDab, TheraSAbDab) require a special `operation` parameter that isn't obvious from function names. Missing this causes 100% tool failure.

**Detection**: If tool returns error "Parameter validation failed: 'operation' is a required property" → SOAP tool

**Add to Tool Interface Verification (Section 1)**:

| Tool Family | Parameter | CRITICAL Requirement |
|-------------|-----------|---------------------|
| IMGT_* | `operation` | MUST be first parameter (e.g., "search_genes") |
| SAbDab_* | `operation` | MUST be first parameter (e.g., "search_structures") |
| TheraSAbDab_* | `operation` | MUST be first parameter (e.g., "search_by_target") |

**Example**:
```markdown
### Tool: IMGT_search_genes

**Parameters** (implementation-agnostic):
- `operation` (string, required): SOAP method name = "search_genes"
- `gene_type` (string, required): "IGHV", "IGKV", "IGLV"
- `species` (string, required): "Homo sapiens" for human

**Python SDK**:
```python
result = tu.tools.IMGT_search_genes(
    operation="search_genes",  # Required!
    gene_type="IGHV",
    species="Homo sapiens"
)
```

**MCP**:
```json
{
  "operation": "search_genes",
  "gene_type": "IGHV",
  "species": "Homo sapiens"
}
```

**Critical**: SOAP tools will fail without `operation` parameter in both implementations.
```

### 16. Fallback Strategies for API Failures

**Problem**: Primary APIs can go down completely (e.g., DepMap 404 errors). Skills without fallbacks become 0% functional.

**Solution**: Implement tiered fallback strategies and document them clearly.

**Fallback Pattern**:
```markdown
## Fallback Strategy

**Primary**: [Best data source with detailed info]
**Fallback**: [Alternative source with partial data]
**Default**: [Continue with limited/unvalidated data]

**Python SDK**:
```python
try:
    result = tu.tools.PRIMARY_TOOL(param=value)
except:
    result = tu.tools.FALLBACK_TOOL(param=value)
```

**MCP**: Tell Claude to use Fallback if Primary unavailable
```

**Real Example from CRISPR Screen Analysis**:
- **Primary**: DepMap_search_genes (comprehensive essentiality data)
- **Fallback**: Pharos_get_target (TDL classification as essentiality proxy)
- **Default**: Continue with unvalidated genes

**Impact**: Skill went from 20% functional (total failure when DepMap down) to 60% functional (continues with Pharos data).

---

## Comprehensive Parameter Corrections (From Real Fixes)

**Add to Section 1 (Tool Interface Verification)**:

The following corrections were discovered while fixing 4 non-functional skills in February 2026:

| Tool | Common Mistake | Correct Parameter | Evidence |
|------|----------------|-------------------|----------|
| RxNorm_get_drug_names | `query` | `drug_name` | DDI skill fix |
| drugbank_get_drug_basic_info_by_drug_name_or_id | `drug_name_or_id` | `query` | DDI + Trial skill fixes |
| drugbank_get_pharmacology_by_drug_name_or_drugbank_id | `drug_name_or_drugbank_id` | `query` | Trial skill fix |
| drugbank_get_safety_by_drug_name_or_drugbank_id | `drug_name_or_drugbank_id` | `query` | Trial skill fix |
| FAERS_count_reactions_by_drug_event | `drug_name` | `medicinalproduct` | DDI skill fix |
| IMGT_search_genes | Missing parameter | `operation="search_genes"` | Antibody skill fix |
| IMGT_get_sequence | Missing parameter | `operation="get_sequence"` | Antibody skill fix |
| SAbDab_search_structures | Missing parameter | `operation="search_structures"` | Antibody skill fix |
| TheraSAbDab_search_by_target | Missing parameter | `operation="search_by_target"` | Antibody skill fix |

**Pattern**: Tool function names DO NOT predict parameter names - always test!

---

## Real-World Case Studies

### Case Study 1: Drug-Drug Interaction Skill

**Original State**: 0% functional
- Documentation showed `drugbank_get_drug_basic_info(drug_name_or_drugbank_id="...")`
- Tool actually requires `query` parameter
- Never tested with real ToolUniverse instance
- Beautiful 300+ line documentation, completely non-functional

**Fixed State**: 100% functional
- Created `test_ddi.py` - verified all tool parameters
- Created `python_implementation.py` - working 8-step pipeline
- Updated `QUICK_START.md` - both Python SDK and MCP examples
- Tool parameter table documents correct names

**Key Fixes**:
```markdown
| Tool | WRONG (in docs) | CORRECT (tested) |
|------|-----------------|------------------|
| RxNorm_get_drug_names | query | drug_name |
| drugbank_* | drug_name_or_id | query |
| FAERS_count_reactions | drug_name | medicinalproduct |
```

**Lesson**: Function names are misleading - `get_drug_basic_info_by_drug_name_or_id` actually takes `query`, not `drug_name_or_id`.

### Case Study 2: Antibody Engineering Skill

**Original State**: 0% functional
- All SOAP tool calls missing `operation` parameter
- Error: "Parameter validation failed: 'operation' is a required property"
- 5/8 tools completely broken
- Documentation looked professional but untested

**Fixed State**: 80% functional
- Identified SOAP tools (IMGT, SAbDab, TheraSAbDab)
- Added `operation` parameter to all SOAP calls
- Created side-by-side Python/MCP examples
- Documented SOAP requirement prominently in QUICK_START

**Key Fix**:
```markdown
## CRITICAL: SOAP Tools

**Python SDK**:
```python
tu.tools.IMGT_search_genes(
    operation="search_genes",  # Required!
    gene_type="IGHV"
)
```

**MCP**:
```json
{
  "operation": "search_genes",
  "gene_type": "IGHV"
}
```
```

**Lesson**: SOAP tools have special requirements not obvious from function signatures. Always test.

### Case Study 3: CRISPR Screen Analysis Skill

**Original State**: 20% functional
- Primary API (DepMap) completely down (404 errors from both Sanger and Broad)
- No fallback strategy
- Skill failed completely when DepMap unavailable
- Users got zero results despite many alternative tools available

**Fixed State**: 60% functional
- Implemented Pharos TDL fallback for gene validation
- Documented fallback strategy in both Python SDK and MCP
- TDL classification (Tclin/Tchem/Tbio/Tdark) as essentiality proxy
- Skill continues with alternative data source

**Key Fix**:
```markdown

---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/devtu-optimize-skills/REFERENCE.md`
