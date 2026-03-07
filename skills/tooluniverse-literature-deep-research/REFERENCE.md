# tooluniverse-literature-deep-research — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Bibliography File Format

**File**: `[topic]_bibliography.json`

```json
{
  "metadata": {
    "generated": "2026-02-04",
    "query": "ATP6V1A",
    "total_papers": 342,
    "unique_after_dedup": 287
  },
  "papers": [
    {
      "pmid": "12345678",
      "doi": "10.1038/xxx",
      "title": "Paper Title",
      "authors": ["Smith A", "Jones B"],
      "year": 2024,
      "journal": "Nature",
      "source_databases": ["PubMed", "OpenAlex"],
      "evidence_tier": "T1",
      "themes": ["lysosomal_acidification", "autophagy"],
      "oa_status": "gold",
      "oa_url": "https://...",
      "citation_count": 45,
      "in_core_set": true
    }
  ]
}
```

Also generate `[topic]_bibliography.csv` with same data in tabular format.

---

## Theme Extraction Protocol

### Standardized Theme Clustering

1. **Extract keywords** from titles and abstracts
2. **Cluster into themes** using semantic similarity
3. **Require minimum N papers** per theme (default N=3)
4. **Label themes** with standardized names

### Standard Theme Categories (adapt to target)

For V-ATPase target example:
- `lysosomal_acidification` - Core function
- `autophagy_regulation` - mTORC1 signaling
- `bone_resorption` - Osteoclast function
- `cancer_metabolism` - Tumor acidification
- `viral_infection` - Viral entry mechanism
- `neurodegenerative` - Neuronal dysfunction
- `kidney_function` - Renal acid-base
- `methodology` - Assays/tools papers

### Theme Quality Requirements

| Papers | Theme Status |
|--------|--------------|
| ≥10 | Major theme (full section) |
| 3-9 | Minor theme (subsection) |
| <3 | Insufficient (note in "limited evidence" or merge) |

---

## Completeness Checklist (Verify Before Delivery)

**ALL boxes must be checked or explicitly marked "N/A" or "Limited evidence"**

### Identity & Context
- [ ] Official identifiers resolved (UniProt, Ensembl, NCBI, ChEMBL)
- [ ] All synonyms/aliases documented
- [ ] Naming collisions identified and handled
- [ ] Protein architecture described (or N/A stated)
- [ ] Subcellular localization documented
- [ ] Baseline expression profile included

### Mechanism & Function
- [ ] Core mechanism section with evidence grades
- [ ] Pathway involvement documented
- [ ] Model organism evidence (or "none found")
- [ ] Complexes/interaction partners listed
- [ ] Key assays/readouts described

### Disease & Clinical
- [ ] Human genetic variants documented
- [ ] Constraint scores with interpretation
- [ ] Disease links with evidence strength grades
- [ ] Pathogen involvement (or "none identified")

### Synthesis
- [ ] Research themes clustered with ≥3 papers each (or noted as limited)
- [ ] Open questions/gaps articulated
- [ ] Biological model synthesized
- [ ] ≥3 testable hypotheses with experiments
- [ ] Conclusions with confidence assessment

### Technical
- [ ] All claims have source attribution
- [ ] Evidence grades applied throughout
- [ ] Bibliography file generated
- [ ] Data limitations documented

---

## Quick Reference: Tool Categories

### Literature Tools
`PubMed_search_articles`, `PMC_search_papers`, `EuropePMC_search_articles`, `openalex_literature_search`, `Crossref_search_works`, `SemanticScholar_search_papers`, `BioRxiv_search_preprints`, `MedRxiv_search_preprints`

### Citation Tools
`PubMed_get_cited_by`, `PubMed_get_related`, `EuropePMC_get_citations`, `EuropePMC_get_references`

### Protein/Gene Annotation Tools
`UniProt_get_entry_by_accession`, `UniProt_search`, `UniProt_id_mapping`, `InterPro_get_protein_domains`, `proteins_api_get_protein`

### Expression Tools
`GTEx_get_median_gene_expression`, `GTEx_get_gene_expression`, `HPA_get_rna_expression_by_source`, `HPA_get_comprehensive_gene_details_by_ensembl_id`, `HPA_get_subcellular_location`

### Variant/Disease Tools
`gnomad_get_gene_constraints`, `gnomad_get_gene`, `clinvar_search_variants`, `OpenTargets_get_diseases_phenotypes_by_target_ensembl`

### Pathway Tools
`GO_get_annotations_for_gene`, `Reactome_map_uniprot_to_pathways`, `kegg_get_gene_info`, `OpenTargets_get_target_gene_ontology_by_ensemblID`

### Interaction Tools
`STRING_get_protein_interactions`, `intact_get_interactions`, `OpenTargets_get_target_interactions_by_ensemblID`

### OA Tools
`Unpaywall_check_oa_status` (if email provided), or use OA flags from Europe PMC/OpenAlex

---

## Communication with User

**During research** (brief updates):
- "Resolving target identifiers and gathering baseline profile..."
- "Building core paper set with high-precision queries..."
- "Expanding via citation network..."
- "Clustering into themes and grading evidence..."

**When the question looks like a factoid**:
- Ask (once) if the user wants *just the verified answer* or a *full deep-research report*.
- If the user doesn’t specify, default to **Factoid / Verification Mode** and keep it short + source-backed.

**DO NOT** expose:
- Raw tool outputs
- Deduplication counts
- Search round details
- Database-by-database results

**The report is the deliverable. Methodology stays internal.**

---

## Summary

This skill produces comprehensive, evidence-graded research reports that:

1. **Start with disambiguation** to prevent naming collisions and missing details
2. **Use annotation tools** to fill gaps when literature is sparse
3. **Grade all evidence** to separate signal from noise
4. **Require completeness** even if stating "limited evidence"
5. **Synthesize into biological models** with testable hypotheses
6. **Separate narrative from bibliography** for scalability
7. **Keep methodology internal** unless explicitly requested

The result is a detailed, actionable research report that reads like an expert synthesis, not a search log.
