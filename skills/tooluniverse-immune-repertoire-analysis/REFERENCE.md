# tooluniverse-immune-repertoire-analysis — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Advanced Use Cases

### Use Case 1: Cancer Immunotherapy Response Analysis

```python
# Compare TCR repertoires before and after immunotherapy

# Load baseline and post-treatment samples
tcr_baseline = load_airr_data("patient_baseline.txt", format='mixcr')
tcr_post = load_airr_data("patient_post_treatment.txt", format='mixcr')

# Define clonotypes
clones_baseline = define_clonotypes(tcr_baseline, method='vj_cdr3')
clones_post = define_clonotypes(tcr_post, method='vj_cdr3')

# Calculate diversity changes
div_baseline = calculate_diversity(clones_baseline['count'])
div_post = calculate_diversity(clones_post['count'])

print(f"Baseline diversity: {div_baseline['shannon_entropy']:.2f}")
print(f"Post-treatment diversity: {div_post['shannon_entropy']:.2f}")
print(f"Change: {div_post['shannon_entropy'] - div_baseline['shannon_entropy']:.2f}")

# Track clonal expansion
expanded_baseline = detect_expanded_clones(clones_baseline)
expanded_post = detect_expanded_clones(clones_post)

# Identify newly expanded clonotypes
new_clones = set(expanded_post['expanded_clonotypes']['clonotype']) - \
             set(expanded_baseline['expanded_clonotypes']['clonotype'])

print(f"Newly expanded clonotypes: {len(new_clones)}")

# Query epitope specificity for newly expanded clones
epitope_matches = query_epitope_database(list(new_clones)[:10])
```

### Use Case 2: Vaccine Response Tracking

```python
# Track TCR repertoire changes after vaccination

timepoints = [
    load_airr_data("pre_vaccine.txt", format='mixcr'),
    load_airr_data("week1_post.txt", format='mixcr'),
    load_airr_data("week4_post.txt", format='mixcr'),
    load_airr_data("week12_post.txt", format='mixcr')
]

# Process each timepoint
clonotype_dfs = [define_clonotypes(df, method='vj_cdr3') for df in timepoints]

# Track longitudinal dynamics
tracking = track_clonotypes_longitudinal(clonotype_dfs)

# Identify persistent vaccine-responding clones
persistent_clones = tracking[tracking['persistence'] == 4]  # Present at all timepoints
print(f"Persistent clonotypes: {len(persistent_clones)}")

# Identify clonotypes that expanded after vaccination
tracking['fold_change'] = tracking.iloc[:, 3] / (tracking.iloc[:, 0] + 1e-6)
vaccine_responders = tracking[tracking['fold_change'] > 10]
print(f"Vaccine-responding clonotypes (>10-fold expansion): {len(vaccine_responders)}")
```

### Use Case 3: Autoimmune Disease Repertoire Analysis

```python
# Compare TCR repertoires between autoimmune patients and healthy controls

# Load data
patient_tcr = load_airr_data("autoimmune_patient.txt", format='mixcr')
control_tcr = load_airr_data("healthy_control.txt", format='mixcr')

# Define clonotypes
patient_clones = define_clonotypes(patient_tcr, method='vj_cdr3')
control_clones = define_clonotypes(control_tcr, method='vj_cdr3')

# Compare diversity
div_patient = calculate_diversity(patient_clones['count'])
div_control = calculate_diversity(control_clones['count'])

print(f"Patient clonality: {div_patient['clonality']:.3f}")
print(f"Control clonality: {div_control['clonality']:.3f}")

# Identify disease-specific clonotypes
patient_specific = set(patient_clones['clonotype']) - set(control_clones['clonotype'])
print(f"Patient-specific clonotypes: {len(patient_specific)}")

# Analyze V(D)J usage bias
vdj_patient = analyze_vdj_usage(patient_tcr)
vdj_control = analyze_vdj_usage(control_tcr)

# Compare V gene usage
v_comparison = pd.DataFrame({
    'patient': vdj_patient['v_usage'],
    'control': vdj_control['v_usage']
}).fillna(0)

v_comparison['fold_change'] = (v_comparison['patient'] + 1e-6) / (v_comparison['control'] + 1e-6)
biased_v_genes = v_comparison[v_comparison['fold_change'] > 2]
print(f"V genes overrepresented in patient: {len(biased_v_genes)}")
```

### Use Case 4: Single-Cell TCR-seq + RNA-seq Integration

```python
# Integrate TCR clonotypes with T-cell phenotypes

import scanpy as sc

# Load 10x data
tcr_10x = load_airr_data("filtered_contig_annotations.csv", format='10x')
gex_adata = sc.read_10x_h5("filtered_feature_bc_matrix.h5")

# Standard single-cell processing
sc.pp.filter_cells(gex_adata, min_genes=200)
sc.pp.normalize_total(gex_adata, target_sum=1e4)
sc.pp.log1p(gex_adata)
sc.pp.highly_variable_genes(gex_adata, n_top_genes=2000)
sc.pp.pca(gex_adata)
sc.pp.neighbors(gex_adata)
sc.tl.umap(gex_adata)
sc.tl.leiden(gex_adata)

# Integrate TCR data
integrated = integrate_with_single_cell(tcr_10x, gex_adata)

# Analyze clonotype-phenotype associations
associations = analyze_clonotype_phenotype(integrated)

# Identify phenotype of expanded clones
expanded_cells = integrated[integrated.obs['is_expanded']].copy()
sc.pl.umap(expanded_cells, color='leiden', title='Phenotype of Expanded Clones')

# Find marker genes for expanded vs non-expanded
sc.tl.rank_genes_groups(integrated, 'is_expanded', method='wilcoxon')
sc.pl.rank_genes_groups(integrated, n_genes=20)
```

## ToolUniverse Tool Integration

**Key Tools Used**:
- `IEDB_search_tcells` - Known T-cell epitopes
- `IEDB_search_bcells` - Known B-cell epitopes
- `PubMed_search` - Literature on TCR/BCR specificity
- `UniProt_get_protein` - Antigen protein information

**Integration with Other Skills**:
- `tooluniverse-single-cell` - Single-cell transcriptomics
- `tooluniverse-rnaseq-deseq2` - Bulk RNA-seq analysis
- `tooluniverse-variant-analysis` - Somatic hypermutation analysis (BCR)

## Best Practices

1. **Sequencing Depth**: Aim for 10,000+ unique UMIs per sample for bulk TCR-seq; 500+ for single-cell

2. **Technical Replicates**: Use biological replicates (n≥3) for statistical comparisons

3. **Clonotype Definition**: Use V+J+CDR3aa for most analyses (balances specificity and sensitivity)

4. **Diversity Metrics**: Report multiple metrics (Shannon, Simpson, clonality) for comprehensive assessment

5. **Rare Clonotypes**: Filter clonotypes with very low frequency (<0.001%) to remove sequencing errors

6. **Public Clonotypes**: Check VDJdb, McPAS-TCR databases for known antigen specificities

7. **CDR3 Length**: Flag unusual length distributions (may indicate PCR bias or sequencing issues)

8. **V(D)J Annotation**: Use high-quality reference databases (IMGT, TRAPeS)

9. **Batch Effects**: Correct for batch effects when comparing samples from different runs

10. **Functional Validation**: Validate predicted specificities with tetramer staining or functional assays

## Troubleshooting

**Problem**: Very low diversity (few dominant clonotypes)
- **Solution**: May indicate clonal expansion (biological) or PCR bias (technical); check sequencing QC

**Problem**: Unusual CDR3 length distribution
- **Solution**: Check for PCR amplification bias; verify primer design

**Problem**: Many non-productive sequences
- **Solution**: May indicate B-cell repertoire or contamination; filter for productive sequences only

**Problem**: No matches in epitope databases
- **Solution**: Most TCR/BCR specificities are unknown; use convergence and public clonotype analysis

**Problem**: Low integration rate with single-cell GEX
- **Solution**: Check cell barcodes match; ensure VDJ and GEX libraries from same cells

## References

- Dash P, et al. (2017) Quantifiable predictive features define epitope-specific T cell receptor repertoires. Nature
- Glanville J, et al. (2017) Identifying specificity groups in the T cell receptor repertoire. Nature
- Stubbington MJT, et al. (2016) T cell fate and clonality inference from single-cell transcriptomes. Nature Methods
- Vander Heiden JA, et al. (2014) pRESTO: a toolkit for processing high-throughput sequencing raw reads of lymphocyte receptor repertoires. Bioinformatics

## Quick Start

```python
# Minimal workflow
from tooluniverse import ToolUniverse

# 1. Load data
tcr_data = load_airr_data("clonotypes.txt", format='mixcr')

# 2. Define clonotypes
clonotypes = define_clonotypes(tcr_data, method='vj_cdr3')

# 3. Calculate diversity
diversity = calculate_diversity(clonotypes['count'])
print(f"Shannon entropy: {diversity['shannon_entropy']:.2f}")

# 4. Detect expanded clones
expansion = detect_expanded_clones(clonotypes)
print(f"Expanded clonotypes: {expansion['n_expanded']}")

# 5. Analyze V(D)J usage
vdj_usage = analyze_vdj_usage(tcr_data)

# 6. Query epitope databases
top_clones = expansion['expanded_clonotypes']['clonotype'].head(10)
epitopes = query_epitope_database(top_clones)
```
