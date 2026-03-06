# Database Reference

ScienceClaw can query **77+ scientific databases** directly through their REST APIs using `web_fetch`. No API keys are required for most databases -- the agent constructs HTTP requests and parses the JSON/XML responses.

---

## How the Agent Queries Databases

The agent uses the `web_fetch` tool to call database REST APIs. The pattern is:

1. **Construct the URL** with appropriate query parameters
2. **Fetch the response** (JSON or XML)
3. **Parse and interpret** the results
4. **Cross-reference** across multiple databases for validation

Most databases listed below have corresponding skills in `skills/` that provide detailed API patterns, parameter formats, and example queries.

---

## Genomics & Transcriptomics

Databases for genes, genomes, variants, and gene expression.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **NCBI Gene** | [ncbi.nlm.nih.gov/gene](https://www.ncbi.nlm.nih.gov/gene/) | Gene records, nomenclature, RefSeq, orthologs for all organisms |
| **Ensembl** | [ensembl.org](https://www.ensembl.org/) | Genome annotation, variants, comparative genomics, regulatory features |
| **GTEx** | [gtexportal.org](https://gtexportal.org/) | Gene expression across 54 human tissues from 948 donors |
| **GEO** | [ncbi.nlm.nih.gov/geo](https://www.ncbi.nlm.nih.gov/geo/) | Gene expression datasets, microarray and RNA-seq experiments |
| **ClinVar** | [ncbi.nlm.nih.gov/clinvar](https://www.ncbi.nlm.nih.gov/clinvar/) | Clinical significance of genetic variants |
| **GWAS Catalog** | [ebi.ac.uk/gwas](https://www.ebi.ac.uk/gwas/) | Published genome-wide association studies and SNP-trait associations |
| **ClinPGx** | [clinpgx.org](https://www.clinpgx.org/) | Pharmacogenomics clinical annotations |
| **COSMIC** | [cancer.sanger.ac.uk](https://cancer.sanger.ac.uk/cosmic) | Somatic mutations in cancer |
| **ENA** | [ebi.ac.uk/ena](https://www.ebi.ac.uk/ena/) | European Nucleotide Archive -- raw sequence reads and assemblies |
| **CellxGene** | [cellxgene.cziscience.com](https://cellxgene.cziscience.com/) | Single-cell gene expression datasets (Chan Zuckerberg Initiative) |

### Example: NCBI Gene Query

```
https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gene&retmode=json&term=TP53+AND+human[orgn]
```

### Example: Ensembl Lookup

```
https://rest.ensembl.org/lookup/symbol/homo_sapiens/BRCA1?content-type=application/json;expand=1
```

### Example: GTEx Expression

```
https://gtexportal.org/api/v2/expression/medianGeneExpression?gencodeId=ENSG00000141510&datasetId=gtex_v8
```

---

## Proteomics & Structural Biology

Databases for proteins, structures, interactions, and functional annotations.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **UniProt** | [uniprot.org](https://www.uniprot.org/) | Protein sequences, function, domains, PTMs, disease associations |
| **PDB** | [rcsb.org](https://www.rcsb.org/) | 3D structures of proteins, nucleic acids, and complexes |
| **AlphaFold DB** | [alphafold.ebi.ac.uk](https://alphafold.ebi.ac.uk/) | AI-predicted protein structures for 200M+ proteins |
| **STRING** | [string-db.org](https://string-db.org/) | Protein-protein interaction networks |
| **InterPro** | [ebi.ac.uk/interpro](https://www.ebi.ac.uk/interpro/) | Protein families, domains, and functional sites |
| **BRENDA** | [brenda-enzymes.org](https://www.brenda-enzymes.org/) | Enzyme functional data and kinetic parameters |

### Example: UniProt Search

```
https://rest.uniprot.org/uniprotkb/search?query=gene_exact:TP53+AND+organism_id:9606&format=json&size=5
```

### Example: PDB Search

```
https://search.rcsb.org/rcsbsearch/v2/query?json={"query":{"type":"terminal","service":"full_text","parameters":{"value":"hemoglobin"}},"return_type":"entry"}
```

### Example: AlphaFold Prediction

```
https://alphafold.ebi.ac.uk/api/prediction/P04637
```

### Example: STRING Interactions

```
https://string-db.org/api/json/network?identifiers=TP53&species=9606
```

---

## Chemistry & Drug Discovery

Databases for compounds, drugs, bioactivity, and chemical properties.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **ChEMBL** | [ebi.ac.uk/chembl](https://www.ebi.ac.uk/chembl/) | Bioactivity data for drug-like compounds (2M+ compounds, 20M+ activities) |
| **PubChem** | [pubchem.ncbi.nlm.nih.gov](https://pubchem.ncbi.nlm.nih.gov/) | Chemical structures, properties, bioassays (110M+ compounds) |
| **DrugBank** | [drugbank.com](https://go.drugbank.com/) | Drug data, targets, pharmacology, interactions |
| **ZINC** | [zinc.docking.org](https://zinc.docking.org/) | Commercially available compounds for virtual screening |
| **Open Targets** | [platform.opentargets.org](https://platform.opentargets.org/) | Drug target evidence from genetics, genomics, and literature |
| **HMDB** | [hmdb.ca](https://hmdb.ca/) | Human Metabolome Database -- metabolites and their biological roles |
| **Metabolomics Workbench** | [metabolomicsworkbench.org](https://www.metabolomicsworkbench.org/) | Metabolomics data repository |

### Example: ChEMBL Search

```
https://www.ebi.ac.uk/chembl/api/data/molecule/search.json?q=aspirin&limit=5
```

### Example: PubChem Compound

```
https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/ibuprofen/JSON
```

### Example: Open Targets (GraphQL)

```bash
curl -X POST https://api.platform.opentargets.org/api/v4/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ target(ensemblId: \"ENSG00000141510\") { id approvedSymbol approvedName } }"}'
```

---

## Clinical & Regulatory

Databases for clinical trials, drug safety, and regulatory information.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **ClinicalTrials.gov** | [clinicaltrials.gov](https://clinicaltrials.gov/) | Registry of 450K+ clinical studies worldwide |
| **FDA (openFDA)** | [open.fda.gov](https://open.fda.gov/) | Drug adverse events, product recalls, labeling |
| **DailyMed** | [dailymed.nlm.nih.gov](https://dailymed.nlm.nih.gov/) | Drug labeling information (FDA-approved package inserts) |
| **USPTO** | [developer.uspto.gov](https://developer.uspto.gov/) | US patent data |

### Example: ClinicalTrials.gov Search

```
https://clinicaltrials.gov/api/v2/studies?query.term=CRISPR+sickle+cell&pageSize=10
```

### Example: openFDA Drug Events

```
https://api.fda.gov/drug/event.json?search=patient.drug.medicinalproduct:"aspirin"&limit=5
```

---

## Pathways & Functional Annotation

Databases for biological pathways, gene ontology, and enrichment analysis.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **KEGG** | [genome.jp/kegg](https://www.genome.jp/kegg/) | Metabolic and signaling pathway maps |
| **Reactome** | [reactome.org](https://reactome.org/) | Curated biological pathways (human and other species) |
| **Enrichr** | [maayanlab.cloud/Enrichr](https://maayanlab.cloud/Enrichr/) | Gene set enrichment analysis (170+ libraries) |
| **Gene Ontology** | [geneontology.org](http://geneontology.org/) | Functional annotation of genes (biological process, molecular function, cellular component) |

### Example: Reactome Pathway Search

```
https://reactome.org/ContentService/search/query?query=TP53&types=Pathway&species=Homo+sapiens
```

### Example: Enrichr (Two-Step)

```bash
# Step 1: Submit gene list
curl -X POST https://maayanlab.cloud/Enrichr/addList \
  -F "list=TP53\nBRCA1\nEGFR\nMYC\nRB1" \
  -F "description=tumor suppressors"

# Step 2: Get enrichment results
curl "https://maayanlab.cloud/Enrichr/enrich?userListId=ID&backgroundType=KEGG_2021_Human"
```

---

## Multi-Omics & Integrative

Databases spanning multiple data types.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **TCGA** (via GDC) | [portal.gdc.cancer.gov](https://portal.gdc.cancer.gov/) | The Cancer Genome Atlas -- multi-omics cancer data |
| **ENCODE** | [encodeproject.org](https://www.encodeproject.org/) | Encyclopedia of DNA Elements -- functional genomics |
| **Human Cell Atlas** | [humancellatlas.org](https://www.humancellatlas.org/) | Single-cell reference maps of human cells |
| **Expression Atlas** | [ebi.ac.uk/gxa](https://www.ebi.ac.uk/gxa/) | Gene expression across species and conditions |
| **BioGRID** | [thebiogrid.org](https://thebiogrid.org/) | Protein and genetic interactions |
| **Data Commons** | [datacommons.org](https://datacommons.org/) | Aggregated statistical data from multiple sources |

---

## Literature & Preprints

Databases for scientific publications and preprints.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **PubMed** | [pubmed.ncbi.nlm.nih.gov](https://pubmed.ncbi.nlm.nih.gov/) | 36M+ biomedical citations and abstracts |
| **OpenAlex** | [openalex.org](https://openalex.org/) | 250M+ scholarly works with metadata, citations, open access links |
| **Semantic Scholar** | [semanticscholar.org](https://www.semanticscholar.org/) | AI-powered academic search with citation context |
| **Europe PMC** | [europepmc.org](https://europepmc.org/) | Full-text biomedical literature (includes PMC + preprints) |
| **bioRxiv** | [biorxiv.org](https://www.biorxiv.org/) | Biology preprints |
| **medRxiv** | [medrxiv.org](https://www.medrxiv.org/) | Health sciences preprints |
| **arXiv** | [arxiv.org](https://arxiv.org/) | Physics, math, CS, quantitative biology preprints |

### Example: PubMed Search

```
https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json&retmax=10&term=CRISPR+base+editing
```

### Example: OpenAlex Search

```
https://api.openalex.org/works?search=CRISPR+base+editing&per_page=10&select=id,title,authorships,publication_year,cited_by_count,doi
```

### Example: Semantic Scholar

```
https://api.semanticscholar.org/graph/v1/paper/search?query=CRISPR+base+editing&limit=10&fields=title,authors,year,abstract,citationCount
```

---

## Materials Science & Earth Science

Databases for materials, minerals, geospatial, and astronomical data.

| Database | URL | What It Contains |
|----------|-----|-----------------|
| **Materials Project** | [materialsproject.org](https://materialsproject.org/) | Computed properties of 150K+ inorganic materials |
| **AFLOW** | [aflowlib.org](http://aflowlib.org/) | Automatic flow for materials discovery |
| **Crystallography Open Database** | [crystallography.net](https://www.crystallography.net/) | Crystal structures of organic and inorganic compounds |
| **USGS** | [usgs.gov](https://www.usgs.gov/) | Geological data, earthquake catalogs, mineral resources |
| **NASA Earthdata** | [earthdata.nasa.gov](https://earthdata.nasa.gov/) | Earth science observation data |

---

## Database Count by Category

| Category | Count | Key Databases |
|----------|-------|---------------|
| Genomics & Transcriptomics | 10 | NCBI Gene, Ensembl, GTEx, GEO, ClinVar, GWAS Catalog |
| Proteomics & Structural Biology | 6 | UniProt, PDB, AlphaFold, STRING, InterPro, BRENDA |
| Chemistry & Drug Discovery | 7 | ChEMBL, PubChem, DrugBank, ZINC, Open Targets, HMDB |
| Clinical & Regulatory | 4 | ClinicalTrials.gov, FDA, DailyMed, USPTO |
| Pathways & Functional Annotation | 4 | KEGG, Reactome, Enrichr, Gene Ontology |
| Multi-Omics & Integrative | 6 | TCGA, ENCODE, Human Cell Atlas, Expression Atlas, BioGRID |
| Literature & Preprints | 7 | PubMed, OpenAlex, Semantic Scholar, Europe PMC, bioRxiv, arXiv |
| Materials & Earth Science | 5 | Materials Project, AFLOW, COD, USGS, NASA Earthdata |
| **Total** | **49 listed** | **77+ including sub-databases and specialized endpoints** |

The remaining databases are accessed through specialized skills (ToolUniverse integration, LIMS platforms, etc.) and via general `web_search` discovery.

---

## Adding a New Database

To teach ScienceClaw about a new database:

1. Find the database's REST API documentation
2. Create a new skill in `skills/my-database/SKILL.md`
3. Include: API endpoint, query parameters, example requests, response format
4. Add verification steps (how to check if results are valid)

See the [Skills Guide](skills.md) for the full skill creation process.

---

## See Also

- [Skills Guide](skills.md) -- how skills provide database query patterns
- [Architecture](../architecture/ARCHITECTURE.md) -- how `web_fetch` connects to databases
- [SCIENCE.md](../../SCIENCE.md) -- the agent's core instructions including database endpoints
