# Quickstart

Get from zero to your first research query in under 5 minutes.

**Prerequisites:** You've completed the [Installation](installation.md) steps (clone, `.env`, `setup.sh`).

---

## 1. Start ScienceClaw

One command does everything -- starts the gateway in the background and opens the terminal UI:

```bash
./scienceclaw run
```

You'll see:

```
  🚀 Starting Gateway on port 18789 ...
  ✅ Gateway ready (PID 12345)
```

Then the TUI opens, showing the ScienceClaw agent ready for input.

---

## 2. Ask Your First Research Question

Type a research question in the TUI. For example:

```
Search for recent papers on CRISPR base editing in sickle cell disease
```

### What Happens Behind the Scenes

1. **The agent reads your query** and decides which databases to search
2. **PubMed search** -- queries `eutils.ncbi.nlm.nih.gov` for matching articles with structured metadata (PMIDs, titles, authors, journals)
3. **OpenAlex search** -- queries `api.openalex.org` for broader coverage and citation counts
4. **Abstract retrieval** -- fetches full abstracts for the most relevant hits
5. **Synthesis** -- the agent reads the results, identifies themes, and writes a coherent summary with proper citations

The entire process takes 15-60 seconds depending on query complexity and model speed.

### Example Output

The agent might respond with something like:

> I found 47 results on PubMed for CRISPR base editing in sickle cell disease. Here are the key findings from the most relevant papers:
>
> **1.** Zhang et al. (2024) demonstrated adenine base editing of the HBB promoter in patient-derived CD34+ cells, achieving >90% editing efficiency with sustained fetal hemoglobin induction. *Nature Medicine*, 30(3):820-831. DOI: 10.1038/...
>
> **2.** ...
>
> **Key themes:**
> - Base editing (ABE8e variants) shows higher precision than traditional CRISPR-Cas9 for sickle cell correction
> - Clinical trials (NCT05456880) are in Phase I/II with promising early safety data
> - ...

Every citation comes from the actual search results -- never fabricated.

---

## 3. Try More Queries

ScienceClaw handles a wide range of research tasks. Try these:

### Literature Search

```
Find the top-cited papers on transformer architectures in drug discovery published since 2023
```

### Database Query

```
Look up the protein structure of human hemoglobin beta subunit in UniProt and PDB
```

### Gene Analysis

```
What is known about TP53 mutations in hepatocellular carcinoma? Check ClinVar and COSMIC.
```

### Data Analysis

```
I have gene expression data. Write Python code to perform differential expression
analysis using DESeq2-style negative binomial regression.
```

### Figure Generation

```
Create a volcano plot from this differential expression data using the NPG color palette
with journal-specification sizing.
```

### Research Review

```
Review this research abstract using the ScholarEval rubric and provide scores
for novelty, rigor, clarity, reproducibility, and impact.
```

---

## 4. Useful Commands

### Gateway Management

```bash
./scienceclaw run       # Start gateway + open TUI (most common)
./scienceclaw status    # Check if gateway is running
./scienceclaw stop      # Stop the gateway
./scienceclaw start     # Start gateway in foreground (for debugging)
```

### Two-Terminal Mode

If you prefer separate control:

```bash
# Terminal 1: Start the gateway
./scienceclaw start

# Terminal 2: Open the TUI
./scienceclaw tui
```

---

## 5. Next Steps

Now that you're up and running:

- **[Configuration](configuration.md)** -- switch between Claude, GPT, and Gemini models
- **[Skills Guide](../guides/skills.md)** -- explore 266 domain skills (single-cell, drug discovery, survival analysis, etc.)
- **[Database Reference](../guides/databases.md)** -- see all 77+ databases the agent can query
- **[Architecture](../architecture/ARCHITECTURE.md)** -- understand how ScienceClaw works under the hood
- **[Deployment](../guides/deployment.md)** -- run ScienceClaw in Docker or deploy to production
