# Research Recipes — API Reference

Detailed API call patterns for each Recipe step. Use these as templates, replacing GENE/DISEASE/QUERY with actual values.

---

## Common API Patterns

### PubMed E-utilities

```bash
# Search
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=30&sort=relevance&term=QUERY"

# Fetch abstracts (XML)
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=PMID1,PMID2,PMID3"

# Author search
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=50&term=AUTHOR_NAME[author]"
```

### OpenAlex

```bash
# Works search
curl -s "https://api.openalex.org/works?search=QUERY&per_page=15&sort=relevance_score:desc&select=id,title,authorships,publication_year,cited_by_count,doi,primary_location"

# Author search
curl -s "https://api.openalex.org/authors?search=AUTHOR_NAME&select=id,display_name,works_count,cited_by_count,summary_stats,affiliations,x_concepts"

# Author's works
curl -s "https://api.openalex.org/works?filter=author.id:AUTHOR_OPENALEX_ID&sort=cited_by_count:desc&per_page=10&select=id,title,publication_year,cited_by_count,doi"
```

### Semantic Scholar

```bash
# Paper search
curl -s "https://api.semanticscholar.org/graph/v1/paper/search?query=QUERY&limit=15&fields=title,authors,year,abstract,citationCount,externalIds,url"

# Forward citations
curl -s "https://api.semanticscholar.org/graph/v1/paper/PMID:12345678/citations?fields=title,authors,year,citationCount&limit=10"

# References
curl -s "https://api.semanticscholar.org/graph/v1/paper/PMID:12345678/references?fields=title,authors,year,citationCount&limit=10"
```

---

## gene-landscape API Calls

### cBioPortal (TCGA Expression)

```bash
# Get cancer studies
curl -s "https://www.cbioportal.org/api/studies?projection=SUMMARY" | python3 -c "
import json, sys
studies = json.load(sys.stdin)
tcga = [s for s in studies if 'tcga' in s['studyId'].lower() and '_pan_can' not in s['studyId']]
for s in tcga[:5]:
    print(f\"{s['studyId']}: {s['name']} ({s['allSampleCount']} samples)\")
"

# Get gene expression for a study
curl -s "https://www.cbioportal.org/api/molecular-profiles/STUDY_ID_rna_seq_v2_mrna/molecular-data?entrezGeneId=ENTREZ_ID&sampleListId=STUDY_ID_all"
```

### TIMER2.0 (Immune Infiltration)

```bash
curl -s "http://timer.cistrome.org/infiltration_estimation_for_tcga.csv.gz" -o /tmp/timer_data.csv.gz
# Parse for specific gene correlation
```

### Enrichr (Pathway Enrichment)

```bash
# Step 1: Submit gene list
curl -s -X POST "https://maayanlab.cloud/Enrichr/addList" \
  -F "list=GENE1\nGENE2\nGENE3" \
  -F "description=coexpressed_genes"

# Step 2: Get enrichment results
curl -s "https://maayanlab.cloud/Enrichr/enrich?userListId=USER_LIST_ID&backgroundType=KEGG_2021_Human"
```

---

## target-validation API Calls

### UniProt

```bash
curl -s "https://rest.uniprot.org/uniprotkb/search?query=gene_exact:GENE+AND+organism_id:9606&format=json&size=1&fields=accession,protein_name,gene_names,organism_name,cc_function,cc_subcellular_location,ft_domain,sequence"
```

### AlphaFold

```bash
curl -s "https://alphafold.ebi.ac.uk/api/prediction/UNIPROT_ID"
```

### STRING

```bash
curl -s "https://string-db.org/api/json/network?identifiers=GENE&species=9606&required_score=700"
```

### ChEMBL

```bash
# Search for target
curl -s "https://www.ebi.ac.uk/chembl/api/data/target/search.json?q=GENE&limit=5"

# Get bioactivity data
curl -s "https://www.ebi.ac.uk/chembl/api/data/activity.json?target_chembl_id=CHEMBL_TARGET_ID&limit=20"
```

### DrugBank (via web search)

```bash
# DrugBank doesn't have a free REST API; use web_search
web_search: "GENE drug target DrugBank"
```

### ClinicalTrials.gov

```bash
curl -s "https://clinicaltrials.gov/api/v2/studies?query.term=GENE+AND+interventional&filter.overallStatus=RECRUITING,COMPLETED&pageSize=10"
```

---

## literature-review Publication Trend

```python
import matplotlib.pyplot as plt
import json

# year_counts = {2020: 15, 2021: 23, 2022: 45, ...} from search results
years = sorted(year_counts.keys())
counts = [year_counts[y] for y in years]

plt.figure(figsize=(12/2.54, 7/2.54), dpi=300)
colors = ['#3C5488' if y < max(years) else '#E64B35' for y in years]
plt.bar(years, counts, color=colors, edgecolor='white', linewidth=0.5)
plt.xlabel('Year', fontsize=9)
plt.ylabel('Publications', fontsize=9)
plt.title(f'Publication Trend: {TOPIC}', fontsize=10, fontweight='bold')
plt.xticks(years, rotation=45, fontsize=7)
plt.yticks(fontsize=7)
plt.tight_layout()
plt.savefig(f'{fig_dir}/publication_trend_{slug}.png', dpi=300, bbox_inches='tight')
```

---

## person-research API Calls

### OpenAlex Author Profile

```bash
# Search author
curl -s "https://api.openalex.org/authors?search=FULL_NAME&select=id,display_name,works_count,cited_by_count,summary_stats,affiliations,x_concepts"

# Get h-index from summary_stats.h_index
# Get top works
curl -s "https://api.openalex.org/works?filter=author.id:AUTHOR_ID&sort=cited_by_count:desc&per_page=10&select=id,title,publication_year,cited_by_count,doi,primary_location"
```

### Profile Report Template

```markdown
# Researcher Profile: [NAME]

## Affiliation
[Current institution and department]

## Metrics
| Metric | Value |
|--------|-------|
| Publications | N |
| Total citations | N |
| h-index | N |
| i10-index | N |

## Top Publications
1. [Title]. [Journal], [Year]. (Cited: N)
2. ...

## Research Focus
- [Concept 1] (N works)
- [Concept 2] (N works)
- ...
```
