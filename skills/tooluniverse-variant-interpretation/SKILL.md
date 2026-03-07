---
name: tooluniverse-variant-interpretation
description: Systematic clinical variant interpretation from raw variant calls to ACMG-classified recommendations with structural impact analysis. Aggregates evidence from ClinVar, gnomAD, CIViC, UniProt, and PDB across ACMG criteria. Produces pathogenicity scores (0-100), clinical recommendations, and treatment implications. Use when interpreting genetic variants, classifying variants of uncertain significance (VUS), performing ACMG variant classification, or translating variant calls to clinical actionability.
---

# Clinical Variant Interpreter

Systematic variant interpretation using ToolUniverse — from raw variant calls to ACMG-classified clinical recommendations with structural impact analysis.

## Key Principles

1. **ACMG-Guided Classification** - Follow ACMG/AMP 2015 guidelines with explicit evidence codes
2. **Structural Evidence Integration** - Use AlphaFold2 for novel structural impact analysis
3. **Population Context** - gnomAD frequencies with ancestry-specific data
4. **Gene-Disease Validity** - ClinGen curation status for clinical relevance
5. **Actionable Output** - Clear recommendations, not just classifications
6. **English-first queries** - Always use English terms in tool calls

---

## Triggers

Use when users:
- Ask about variant interpretation, classification, or pathogenicity
- Have VCF data needing clinical annotation
- Need ACMG classification for variants (especially VUS)
- Want structural impact analysis for missense variants

**NOT for**: Structural variants/CNVs → `tooluniverse-structural-variant-analysis`; Variant calling from BAM → `tooluniverse-variant-analysis`

---

## Workflow (6 Phases)

### Phase 1: Variant Identity & Normalization

Standardize notation (HGVS), map to gene/transcript/protein, determine consequence type.

| Tool | Purpose |
|------|---------|
| `myvariant_query` | Variant annotations from MyVariant.info (dbSNP, ClinVar, gnomAD) |
| `Ensembl_get_variant_info` | Variant effect predictor data |
| `NCBI_gene_search` | Gene information, RefSeq transcripts |

**Capture**: HGVS (c. and p.), gene symbol, Ensembl ID, transcript (MANE Select), consequence, amino acid change, exon/intron location.

### Phase 2: Clinical Database Queries

| Tool | Purpose | Key Data |
|------|---------|----------|
| `clinvar_search` | Existing classifications | Classification, review status, conditions |
| `gnomad_search` | Population frequency | Overall AF, ancestry-specific AFs, homozygotes |
| `OMIM_search` + `OMIM_get_entry` | Gene-disease | Inheritance pattern, phenotypes |
| `ClinGen_search_gene_validity` | Gene curation | Gene-disease validity level |
| `ClinGen_search_dosage_sensitivity` | Dosage sensitivity | HI/TS scores |
| `COSMIC_search_mutations` | Somatic context | Cancer frequency, hotspot status |
| `DisGeNET_search_gene` | Gene-disease associations | Evidence scores |

**gnomAD frequency interpretation**:
- Absent (0) → PM2 (Supporting Pathogenic)
- <0.01% → Rare, consistent with pathogenicity
- 0.01-0.1% → Check gene/disease prevalence
- \>1% → BA1 (Stand-alone Benign)

### Phase 3: Computational Predictions

| Tool | Purpose | Threshold |
|------|---------|-----------|
| `myvariant_query` (contains SIFT/PolyPhen/CADD) | Damaging predictions | CADD ≥25 = likely deleterious |
| SpliceAI (via myvariant or Ensembl) | Splice impact | Score ≥0.5 = high splice impact |
| Conservation (via Ensembl) | Cross-species alignment | PhyloP, GERP scores |

**PP3 (Supporting Pathogenic)**: ≥3 concordant computational predictors agree "damaging"
**BP4 (Supporting Benign)**: ≥3 concordant predictors agree "tolerated"

### Phase 4: Structural Analysis (for VUS/novel missense)

| Tool | Purpose |
|------|---------|
| `AlphaFold_get_prediction` | Predicted protein structure |
| `PDB_search` | Experimental crystal structures |
| `UniProt_search` | Domain/feature annotations, active sites |
| `InterPro_search` | Protein family/domain classification |

**Assess**: Is residue buried/surface? Domain/active site? Secondary structure? pLDDT confidence (>90 = very high, 70-90 = high, 50-70 = moderate, <50 = disordered)?

**PM1**: Apply if variant in established functional domain without benign variation.

### Phase 5: Literature Evidence

| Tool | Purpose |
|------|---------|
| `PubMed_search_articles` | Functional studies, case reports (returns plain list) |
| `EuropePMC_search_articles` | Broader literature |
| `CIViC_search` | Cancer clinical evidence (if oncology) |

**PS3 (Strong)**: Well-established functional study shows damaging effect
**BS3 (Strong)**: Well-established functional study shows no effect

### Phase 6: ACMG Classification

**Key pathogenic evidence codes**:

| Code | Strength | Criteria |
|------|----------|----------|
| PVS1 | Very Strong | LOF in gene where LOF is disease mechanism |
| PS1 | Strong | Same amino acid change as established pathogenic |
| PS3 | Strong | Functional studies confirm damaging |
| PM1 | Moderate | In critical functional domain |
| PM2 | Moderate | Absent from gnomAD |
| PP3 | Supporting | Computational predictions concordant "damaging" |

**Key benign evidence codes**:

| Code | Strength | Criteria |
|------|----------|----------|
| BA1 | Stand-alone | gnomAD AF >1% |
| BS1 | Strong | gnomAD AF higher than expected for disease |
| BS3 | Strong | Functional study shows no effect |
| BP4 | Supporting | Computational predictions concordant "tolerated" |

**Classification rules**:
- Pathogenic: 1 Very Strong + 1 Strong, OR 2 Strong + ≥1 Moderate
- Likely Pathogenic: 1 Very Strong + 1 Moderate, OR 1 Strong + 2 Moderate
- VUS: Criteria insufficient for either direction
- Likely Benign: 1 Strong + 1 Supporting benign
- Benign: 1 Stand-alone benign, OR ≥2 Strong benign

---

## Special Scenarios

**Novel Missense VUS**: Phase 4 structural analysis critical → check if other pathogenic variants at same residue → AlphaFold2 → buried/surface? active site? conservation?

**Truncating Variant**: Check LOF mechanism → NMD escape (last exon)? → ClinGen LOF curation → PVS1 strength depends on LOF mechanism

**Splice Variant**: SpliceAI scores → canonical splice distance → in-frame skipping? → cryptic splice activation?

---

## Report Template (9 sections)

1. Variant Identity (HGVS, gene, transcript, consequence)
2. Population Data (gnomAD frequencies, ancestry breakdown)
3. Clinical Database Evidence (ClinVar, OMIM, ClinGen)
4. Computational Predictions (SIFT, PolyPhen, CADD, SpliceAI)
5. Structural Analysis (AlphaFold2/PDB, domain impact, confidence)
6. Literature Evidence (functional studies, case reports)
7. ACMG Classification (evidence codes, final classification + rationale)
8. Clinical Recommendations (actionable: diagnostic, therapeutic, family screening)
9. Limitations & Uncertainties

**Minimum requirements**: gnomAD overall + ≥3 ancestry groups, ≥3 computational predictors, ≥2 literature search strategies, all applicable ACMG codes listed.

---

> **Extended Reference**: Full Python implementations, detailed tool parameter tables, NVIDIA NIM integration, example reports, and special scenario workflows are in `REFERENCE.md`.
