---
name: tooluniverse-epigenomics
description: Production-ready genomics and epigenomics data processing for BixBench questions. Handles methylation array analysis (CpG filtering, differential methylation, age-related CpG detection, chromosome-level density), ChIP-seq peak analysis (peak calling, motif enrichment, coverage stats), ATAC-seq chromatin accessibility, multi-omics integration (expression + methylation correlation), and genome-wide statistics. Pure Python computation (pandas, scipy, numpy, pysam, statsmodels) plus ToolUniverse annotation tools (Ensembl, ENCODE, SCREEN, JASPAR, ReMap, RegulomeDB, ChIPAtlas). Supports BED, BigWig, methylation beta-value matrices, Illumina manifest files, and multi-sample clinical data. Use when processing methylation data, ChIP-seq peaks, ATAC-seq signals, or answering questions about CpG sites, differential methylation, chromatin accessibility, histone marks, or epigenomic statistics.
---

# Genomics and Epigenomics Data Processing

Production-ready computational skill for processing and analyzing epigenomics data. Combines local Python computation (pandas, scipy, numpy, pysam, statsmodels) with ToolUniverse annotation tools for regulatory context. Designed to solve BixBench-style questions about methylation, ChIP-seq, ATAC-seq, and multi-omics integration.

## When to Use This Skill

**Triggers**:
- User provides methylation data (beta-value matrices, Illumina arrays) and asks about CpG sites
- Questions about differential methylation analysis
- Age-related CpG detection or epigenetic clock questions
- Chromosome-level methylation density or statistics
- ChIP-seq peak files (BED format) with analysis questions
- ATAC-seq chromatin accessibility questions
- Multi-omics integration (expression + methylation, expression + ChIP-seq)
- Genome-wide epigenomic statistics
- Questions mentioning "methylation", "CpG", "ChIP-seq", "ATAC-seq", "histone", "chromatin", "epigenetic"
- Questions about missing data across clinical/genomic/epigenomic modalities
- Regulatory element annotation for processed epigenomic data

**NOT for** (use other skills instead):
- Gene regulation lookup without data files -> Use existing epigenomics annotation pattern
- RNA-seq differential expression -> Use `tooluniverse-rnaseq-deseq2`
- Variant calling/annotation from VCF -> Use `tooluniverse-variant-analysis`
- Gene enrichment analysis -> Use `tooluniverse-gene-enrichment`

---

## Required Python Packages

```python
import pandas as pd
import numpy as np
from scipy import stats
import statsmodels.stats.multitest as mt
# Optional: pysam (BAM/CRAM), gseapy (enrichment)
from tooluniverse import ToolUniverse
```

---

## KEY PRINCIPLES

1. **Data-first approach** - Load and inspect data files BEFORE any analysis
2. **Question-driven** - Parse what the user is actually asking and extract the specific numeric answer
3. **File format detection** - Automatically detect methylation arrays, BED files, BigWig, clinical data
4. **Coordinate system awareness** - Track genome build (hg19, hg38, mm10), handle chr prefix differences
5. **Statistical rigor** - Proper multiple testing correction, effect size filtering, sample size awareness
6. **Missing data handling** - Explicitly report and handle NaN/missing values
7. **Chromosome normalization** - Always normalize chromosome names (chr1 vs 1, chrX vs X)
8. **Report-first** - Create output file first, populate progressively
9. **English-first queries** - Use English in all tool calls

---

## Complete Workflow

### Phase 0: Question Parsing and Data Discovery

**CRITICAL FIRST STEP**: Before writing ANY code, parse the question to identify what is being asked and what data files are available.

```python
import os, glob
data_dir = "."
all_files = glob.glob(os.path.join(data_dir, "**/*"), recursive=True)

methylation_files = [f for f in all_files if any(x in f.lower() for x in
    ['methyl', 'beta', 'cpg', 'illumina', '450k', '850k', 'epic', 'mval'])]
chipseq_files = [f for f in all_files if any(x in f.lower() for x in
    ['chip', 'peak', 'narrowpeak', 'broadpeak', 'histone'])]
atacseq_files = [f for f in all_files if any(x in f.lower() for x in
    ['atac', 'accessibility', 'openChromatin', 'dnase'])]
bed_files = [f for f in all_files if f.endswith(('.bed', '.bed.gz', '.narrowPeak', '.broadPeak'))]
clinical_files = [f for f in all_files if any(x in f.lower() for x in
    ['clinical', 'patient', 'sample', 'metadata', 'phenotype', 'survival'])]
expression_files = [f for f in all_files if any(x in f.lower() for x in
    ['express', 'rnaseq', 'fpkm', 'tpm', 'counts', 'transcriptom'])]
manifest_files = [f for f in all_files if any(x in f.lower() for x in
    ['manifest', 'annotation', 'probe', 'platform'])]
```

**Extract parameters from question**:

| Parameter | Default | Example |
|-----------|---------|---------|
| Significance threshold | 0.05 | "padj < 0.05", "FDR < 0.01" |
| Beta difference threshold | 0 | "|delta_beta| > 0.2" |
| Variance filter | None | "variance > 0.01", "top 5000 most variable" |
| Chromosome filter | All | "chromosome 17", "autosomes only" |
| Genome build | hg38 | "hg19", "GRCh37", "mm10" |

**Decision Tree**:
```
METHYLATION data? -> Phase 1 (load, filter, differential methylation, age CpG, density)
CHIP-SEQ data?    -> Phase 2 (load BED, peak stats, annotation, overlap)
ATAC-SEQ data?    -> Phase 3 (open chromatin, NFR analysis)
MULTI-OMICS?      -> Phase 4 (expression-methylation correlation)
CLINICAL?         -> Phase 5 (missing data, complete cases)
ANNOTATION?       -> Phase 6 (ToolUniverse regulatory annotation)
GENOME-WIDE?      -> Phase 7 (chromosome density, ratios)
```

---

### Phase 1: Methylation Data Processing

**Core functions** (copy-paste ready):

```python
def load_methylation_data(file_path):
    """Load methylation beta/M-value matrix. Rows=probes, Cols=samples."""
    ext = os.path.splitext(file_path)[1].lower()
    if ext in ['.csv']: return pd.read_csv(file_path, index_col=0)
    elif ext in ['.tsv', '.txt']: return pd.read_csv(file_path, sep='\t', index_col=0)
    elif ext in ['.parquet']: return pd.read_parquet(file_path)
    else:
        try: return pd.read_csv(file_path, sep='\t', index_col=0)
        except: return pd.read_csv(file_path, index_col=0)

def normalize_chromosome(chrom):
    if chrom is None or pd.isna(chrom): return None
    chrom = str(chrom).strip()
    return chrom if chrom.startswith('chr') else 'chr' + chrom

def differential_methylation(beta_df, group1_samples, group2_samples,
                              test='ttest', correction='fdr_bh', alpha=0.05):
    """DMP analysis between two groups. Returns DataFrame with padj, delta_beta."""
    g1, g2 = beta_df[group1_samples], beta_df[group2_samples]
    results = []
    for probe in beta_df.index:
        vals1, vals2 = g1.loc[probe].dropna().values, g2.loc[probe].dropna().values
        if len(vals1) < 2 or len(vals2) < 2:
            results.append({'probe': probe, 'mean_g1': np.nan, 'mean_g2': np.nan,
                'delta_beta': np.nan, 'pvalue': np.nan}); continue
        mean1, mean2 = np.nanmean(vals1), np.nanmean(vals2)
        if test == 'ttest': _, pval = stats.ttest_ind(vals1, vals2, equal_var=False)
        elif test == 'wilcoxon': _, pval = stats.mannwhitneyu(vals1, vals2, alternative='two-sided')
        else: _, pval = stats.ttest_ind(vals1, vals2, equal_var=False)
        results.append({'probe': probe, 'mean_g1': mean1, 'mean_g2': mean2,
            'delta_beta': mean2 - mean1, 'pvalue': pval})
    result_df = pd.DataFrame(results).set_index('probe')
    valid = result_df['pvalue'].dropna()
    if len(valid) > 0:
        _, padj, _, _ = mt.multipletests(valid.values, alpha=alpha, method=correction)
        result_df.loc[valid.index, 'padj'] = padj
    else: result_df['padj'] = np.nan
    return result_df

def chromosome_cpg_density(cpg_probes, manifest, genome='hg38'):
    """CpG density per chromosome. Returns DataFrame with chr, n_cpgs, density_per_bp."""
    chr_lengths = get_chromosome_lengths(genome)
    probe_id_col = 'probe_id' if 'probe_id' in manifest.columns else manifest.columns[0]
    probe_chr = manifest.set_index(probe_id_col) if probe_id_col in manifest.columns else manifest
    chr_col = 'chr' if 'chr' in probe_chr.columns else 'CHR'
    probe_chrs = probe_chr.loc[probe_chr.index.isin(cpg_probes), chr_col].apply(normalize_chromosome)
    chr_counts = probe_chrs.value_counts()
    results = []
    for chrom, count in chr_counts.items():
        if chrom in chr_lengths:
            length = chr_lengths[chrom]
            results.append({'chr': chrom, 'n_cpgs': count, 'chr_length': length,
                'density_per_bp': count / length, 'density_per_mb': count / length * 1e6})
    return pd.DataFrame(results).sort_values('chr',
        key=lambda x: x.str.replace('chr','').replace({'X':'23','Y':'24'}).astype(int))
```

**Genome chromosome lengths** (hg38/hg19/mm10): see `get_chromosome_lengths()` in REFERENCE.md.

---

### Phase 2-3: ChIP-seq / ATAC-seq (summary)

```python
def load_bed_file(file_path, format='auto'):
    """Load BED/narrowPeak/broadPeak. Returns DataFrame with chrom, start, end, ..."""
    # Auto-detect format from extension, read TSV, normalize chromosomes
    # Full implementation in REFERENCE.md

def peak_statistics(peaks_df):
    """Return dict: total_peaks, mean/median_peak_length, total_coverage_bp, per-chromosome counts."""

def find_overlaps(peaks_a, peaks_b, min_overlap=1):
    """Pure-Python interval overlap between two BED DataFrames."""

def annotate_peaks_to_genes(peaks_df, gene_annotation, tss_upstream=2000):
    """Annotate peaks to nearest gene: promoter/gene_body/proximal/distal."""
```

Full implementations with all edge cases are in REFERENCE.md.

---

### Phase 4-5: Multi-Omics & Clinical Integration (summary)

```python
def correlate_methylation_expression(beta_df, expression_df, probe_gene_map, method='pearson'):
    """Correlate methylation with expression per probe-gene pair. Returns corr + padj."""

def missing_data_analysis(clinical_df=None, expression_df=None, methylation_df=None):
    """Count patients with complete data across modalities."""

def find_complete_cases(data_frames, variables=None):
    """Find sample IDs present in ALL provided DataFrames with no missing values."""
```

Full implementations in REFERENCE.md.

---

### Phase 6: ToolUniverse Annotation Tools

| Tool | Key Parameters | Returns |
|------|---------------|---------|
| `ensembl_lookup_gene` | `id`, `species='homo_sapiens'` (REQUIRED) | gene coords, biotype |
| `ensembl_get_regulatory_features` | `region` (NO "chr" prefix!), `feature`, `species` | regulatory features |
| `SCREEN_get_regulatory_elements` | `gene_name`, `element_type`, `limit` | cCREs (enhancers, promoters) |
| `ChIPAtlas_get_experiments` | `operation='get_experiment_list'` (REQUIRED), `genome`, `antigen` | experiment list |
| `ReMap_get_transcription_factor_binding` | `gene_name`, `cell_type`, `limit` | TF binding sites |
| `RegulomeDB_query_variant` | `rsid` | regulatory score |
| `jaspar_search_matrices` | `search`, `collection`, `species` | TF matrices |
| `ENCODE_search_experiments` | `assay_title`, `target`, `organism`, `limit` | experiment metadata |

**CRITICAL**: Ensembl region format is `"17:start-end"` (NO "chr" prefix). ChIPAtlas/FourDN ALL require `operation` parameter.

---

## Common Use Patterns

**Methylation array**: Load beta matrix + manifest → filter CpGs → define groups → `differential_methylation()` → apply thresholds → report DMPs

**Age-related CpG density**: Load beta + ages → correlate per probe → filter significant → map to chromosomes → `chromosome_cpg_density()` → compute ratios

**Multi-omics missing data**: Load clinical + expression + methylation → extract sample IDs → find intersection → check NaN in clinical vars → report complete cases

**ChIP-seq annotation**: Load BED → load gene annotation → `annotate_peaks_to_genes()` → `classify_peak_regions()` → report fractions

**Methylation-expression**: Load both matrices → build probe-gene map → align samples → `correlate_methylation_expression()` → report anti-correlations

---

## Fallback Strategies

| Scenario | Fallback |
|----------|----------|
| No manifest file | Build minimal from Ensembl lookup |
| No pybedtools | Pure Python overlap (pandas intervals) |
| Low sample count | Non-parametric test (Wilcoxon) |
| Large dataset (>500K probes) | Pre-filter by variance, chunk processing |
| Sample ID mismatches | Try truncating TCGA barcodes, partial matching |

---

> **Extended Reference**: Full code implementations for all phases (including `get_chromosome_lengths()`, `load_bed_file()`, peak overlap, multi-omics integration, edge cases, and limitations) are in `REFERENCE.md`.
