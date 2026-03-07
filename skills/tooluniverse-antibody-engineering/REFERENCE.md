# tooluniverse-antibody-engineering — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## Phase 5: Developability Assessment

### 5.1 Aggregation Propensity

```python
def assess_aggregation(sequence):
    """Comprehensive aggregation risk assessment."""

    # Identify aggregation-prone regions (APR)
    aprs = find_aggregation_motifs(sequence)

    # Hydrophobic patches on surface
    hydrophobic_patches = identify_surface_hydrophobic(sequence)

    # Charge patches (extreme pI regions)
    charge_patches = identify_charge_clusters(sequence)

    # Sequence-based prediction scores
    tango_score = predict_tango_score(sequence)  # Beta-aggregation
    aggrescan_score = predict_aggrescan(sequence)  # General aggregation

    # Isoelectric point
    pi = calculate_isoelectric_point(sequence)

    return {
        'apr_count': len(aprs),
        'apr_regions': aprs,
        'hydrophobic_patches': hydrophobic_patches,
        'charge_patches': charge_patches,
        'tango_score': tango_score,
        'aggrescan_score': aggrescan_score,
        'pi': pi,
        'overall_risk': categorize_risk(tango_score, aggrescan_score, len(aprs))
    }
```

### 5.2 PTM Site Identification

```python
def identify_ptm_sites(sequence):
    """Identify post-translational modification liability sites."""

    ptm_sites = {
        'deamidation': [],
        'isomerization': [],
        'oxidation': [],
        'glycosylation': []
    }

    # Deamidation: Asn followed by Gly or Ser (NG, NS motifs)
    for i, aa in enumerate(sequence[:-1]):
        if aa == 'N' and sequence[i+1] in ['G', 'S']:
            ptm_sites['deamidation'].append({
                'position': i,
                'motif': sequence[i:i+2],
                'risk': 'High' if sequence[i+1] == 'G' else 'Medium',
                'region': identify_region(i)
            })

    # Isomerization: Asp followed by Gly or Ser (DG, DS motifs)
    for i, aa in enumerate(sequence[:-1]):
        if aa == 'D' and sequence[i+1] in ['G', 'S']:
            ptm_sites['isomerization'].append({
                'position': i,
                'motif': sequence[i:i+2],
                'risk': 'High',
                'region': identify_region(i)
            })

    # Oxidation: Met and Trp residues
    for i, aa in enumerate(sequence):
        if aa in ['M', 'W']:
            ptm_sites['oxidation'].append({
                'position': i,
                'residue': aa,
                'risk': 'Medium',
                'region': identify_region(i)
            })

    # N-glycosylation: N-X-S/T motif (X != P)
    for i in range(len(sequence)-2):
        if sequence[i] == 'N' and sequence[i+1] != 'P' and sequence[i+2] in ['S', 'T']:
            ptm_sites['glycosylation'].append({
                'position': i,
                'motif': sequence[i:i+3],
                'region': identify_region(i)
            })

    return ptm_sites
```

### 5.3 Developability Scoring

```python
def calculate_developability_score(sequence, structure):
    """Calculate comprehensive developability score (0-100)."""

    # Component scores
    aggregation = assess_aggregation(sequence)
    ptm = identify_ptm_sites(sequence)
    stability = predict_thermal_stability(structure)
    expression = predict_expression_level(sequence)
    solubility = predict_solubility(sequence)

    # Scoring rubric (0-100 for each)
    scores = {
        'aggregation': score_aggregation(aggregation),  # 100 = low risk
        'ptm_liability': score_ptm_risk(ptm),  # 100 = no PTM sites
        'stability': score_stability(stability),  # 100 = Tm > 70°C
        'expression': score_expression(expression),  # 100 = >1 g/L
        'solubility': score_solubility(solubility)  # 100 = >100 mg/mL
    }

    # Weighted average
    weights = {
        'aggregation': 0.30,  # Most critical
        'ptm_liability': 0.25,
        'stability': 0.20,
        'expression': 0.15,
        'solubility': 0.10
    }

    overall = sum(scores[k] * weights[k] for k in scores.keys())

    return {
        'component_scores': scores,
        'overall_score': overall,
        'tier': categorize_developability(overall)
    }
```

### 5.4 Output for Report

```markdown
## 5. Developability Assessment

### 5.1 Overall Developability Score

| Variant | Aggregation | PTM Liability | Stability | Expression | Solubility | **Overall** | Tier |
|---------|-------------|---------------|-----------|------------|------------|-------------|------|
| Original (Mouse) | 58 | 45 | 72 | 65 | 70 | **62** | T3 |
| VH_Humanized_v1 | 72 | 55 | 75 | 78 | 75 | **71** | T2 |
| VH_Humanized_v2 | 68 | 58 | 74 | 75 | 73 | **69** | T2 |
| Affinity_opt | 85 | 72 | 78 | 80 | 82 | **79** | T1 |

**Scoring**: 0-100 scale (higher is better), Tiers: T1 (>75), T2 (60-75), T3 (<60)

### 5.2 Aggregation Analysis

**Aggregation-Prone Regions** (APR) in VH:

| Position | Sequence | Region | TANGO Score | Risk | Recommendation |
|----------|----------|--------|-------------|------|----------------|
| 85-92 | STSTAYMEL | FR3 | 42 | Medium | Consider T86S mutation |
| 108-112 | DDGSY | CDR-H3 | 28 | Low | Monitor in formulation |

**Overall Aggregation Risk**:
- VH: Low (TANGO: 15, AGGRESCAN: -12)
- VL: Very Low (TANGO: 8, AGGRESCAN: -18)
- pI: VH 7.2, VL 5.8 (favorable for purification)

**Recommendations**:
- Formulate at pH 6.0-6.5 (below pI of VH)
- Add arginine-glutamate (20-50 mM) to reduce aggregation
- Target concentration: >100 mg/mL achievable

### 5.3 PTM Liability Sites

**High-Risk PTM Sites** (require mitigation):

| Position | Motif | PTM Type | Risk | Region | Mitigation Strategy |
|----------|-------|----------|------|--------|---------------------|
| H54-55 | NG | Deamidation | High | CDR-H2 | Mutate to NQ or QG |
| H84-85 | DS | Isomerization | High | FR3 | Mutate to ES or DA |
| L28 | M | Oxidation | Medium | CDR-L1 | Mutate to Leu or Ile |

**Medium-Risk Sites**:
- H89: Trp (oxidation) - Monitor but likely stable in framework
- L97: Asn (deamidation, NS motif) - Low risk in CDR-L3

**Mitigation Priority**:
1. H54-55 (NG → NQ): Removes high-risk deamidation, retains H-bond capability
2. H84-85 (DS → ES): Removes isomerization, maintains charge
3. L28 (M → L): Reduces oxidation risk, maintains hydrophobicity

**Expected Impact**: Mitigation improves PTM score from 72 → 92

### 5.4 Stability Predictions

**Thermal Stability**:

| Variant | Predicted Tm (°C) | ΔTm vs Original | Aggregation Tonset | Stability Tier |
|---------|-------------------|-----------------|-------------------|----------------|
| Original | 68 | - | 62°C | T3 (Marginal) |
| Humanized_v2 | 71 | +3°C | 64°C | T2 (Good) |
| Affinity_opt | 73 | +5°C | 67°C | T2 (Good) |
| PTM_mitigated | 74 | +6°C | 69°C | T1 (Excellent) |

**Target**: Tm >70°C, Tonset >65°C for long-term stability

**Stability Optimization**:
- Framework humanization improved Tm by +3°C
- Removal of destabilizing motifs: +2°C
- Further optimization possible: Proline introduction in loops

### 5.5 Expression & Manufacturing

**Expression Prediction** (CHO cells):

| Variant | Predicted Titer (g/L) | Soluble Fraction | His-tag Purification | Overall |
|---------|----------------------|------------------|---------------------|---------|
| Original | 1.2 | 75% | Good | T2 |
| Humanized_v2 | 1.8 | 85% | Excellent | T1 |
| Affinity_opt | 2.1 | 88% | Excellent | T1 |

**Manufacturing Considerations**:
- No unusual codons → Good for CHO expression
- No free cysteines → No misfolding risk
- Neutral pI → Easy purification by ion exchange
- Low aggregation → High formulation concentration possible

**Predicted Manufacturing Profile**:
- Expression: 2.0 g/L (CHO fed-batch)
- Purification yield: 75-80%
- Final formulation: >150 mg/mL achievable
- Shelf life: >2 years at 4°C (estimated)

*Source: In silico predictions, sequence analysis*
```

---

## Phase 6: Immunogenicity Prediction

### 6.1 T-Cell Epitope Prediction

```python
def predict_tcell_epitopes(tu, sequence):
    """Predict T-cell epitopes using IEDB tools."""

    # MHC-II binding prediction (immunogenicity risk)
    # Query IEDB for predicted epitopes
    predicted_epitopes = []

    # Scan sequence with 9-mer sliding window
    for i in range(len(sequence) - 8):
        peptide = sequence[i:i+9]

        # Search IEDB for similar epitopes
        iedb_results = tu.tools.iedb_search_epitopes(
            sequence_contains=peptide[:5],  # Core sequence
            limit=10
        )

        # If found in IEDB → higher risk
        if len(iedb_results) > 0:
            predicted_epitopes.append({
                'position': i,
                'peptide': peptide,
                'risk': 'High',
                'evidence': f"{len(iedb_results)} similar epitopes in IEDB"
            })

    # Score overall immunogenicity risk
    risk_score = calculate_immunogenicity_risk(predicted_epitopes, sequence)

    return {
        'epitope_count': len(predicted_epitopes),
        'high_risk_epitopes': [e for e in predicted_epitopes if e['risk'] == 'High'],
        'risk_score': risk_score,
        'recommendation': recommend_deimmunization(predicted_epitopes)
    }
```

### 6.2 Immunogenicity Risk Scoring

```python
def calculate_immunogenicity_risk(epitopes, sequence):
    """Calculate comprehensive immunogenicity risk score."""

    # Component 1: T-cell epitope count (IEDB-based)
    tcell_score = len(epitopes) * 10  # Each epitope adds 10 points

    # Component 2: Non-human residues in framework
    non_human_residues = count_non_human_residues(sequence)
    non_human_score = non_human_residues * 5

    # Component 3: Aggregation-related immunogenicity
    aggregation_score = assess_aggregation(sequence)['overall_risk'] * 20

    # Total risk (0-100, lower is better)
    total_risk = min(100, tcell_score + non_human_score + aggregation_score)

    return {
        'tcell_risk': tcell_score,
        'non_human_risk': non_human_score,
        'aggregation_risk': aggregation_score,
        'total_risk': total_risk,
        'category': 'Low' if total_risk < 30 else 'Medium' if total_risk < 60 else 'High'
    }
```

### 6.3 Output for Report

```markdown
## 6. Immunogenicity Prediction

### 6.1 T-Cell Epitope Analysis

**Predicted MHC-II Binding Epitopes** (IEDB):

| Position | Peptide | MHC Alleles | IEDB Matches | Risk Level | Region |
|----------|---------|-------------|--------------|------------|--------|
| VH 48-56 | QGLEWMGGI | HLA-DR1, DR4 | 3 | Medium | FR2 |
| VH 78-86 | TDTSTSTA | HLA-DR1 | 5 | High | FR3 (mouse residues) |
| VL 52-60 | LLIYSASSL | HLA-DR1, DR15 | 2 | Medium | FR2 |

**High-Risk Epitope Details**:
- **VH 78-86 (TDTSTSTA)**: Contains mouse-derived residues T84, S85
  - Found in 5 immunogenic peptides in IEDB
  - Recommendation: Backmutate to human consensus (TSTSSAYL)

### 6.2 Immunogenicity Risk Score

| Variant | T-Cell Epitopes | Non-Human Residues | Aggregation Risk | **Total Risk** | Category |
|---------|-----------------|-------------------|------------------|----------------|----------|
| Original (Mouse) | 12 | 38 | High (40) | **118** | High |
| VH_Humanized_v1 | 5 | 13 | Medium (20) | **60** | Medium |
| VH_Humanized_v2 | 4 | 15 | Medium (18) | **53** | Medium |
| Deimmunized | 2 | 10 | Low (12) | **32** | **Low** |

**Risk Scoring**: 0-100 (lower is better)
- Low risk: <30 (clinical candidate ready)
- Medium risk: 30-60 (acceptable with monitoring)
- High risk: >60 (requires optimization)

### 6.3 Deimmunization Strategy

**Recommended Mutations** (to achieve low risk):

| Position | Original | Mutant | Region | Rationale | Impact |
|----------|----------|--------|--------|-----------|--------|
| VH 78 | T | A | FR3 | Human consensus, removes epitope | -15 risk |
| VH 84 | T | S | FR3 | Human consensus, removes epitope | -12 risk |
| VL 55 | S | A | FR2 | Removes MHC-II binding | -8 risk |

**Expected Outcome**:
- Deimmunization reduces risk score: 53 → 32 (Low)
- T-cell epitopes reduced: 4 → 2
- Maintains CDR sequences (no affinity impact)

### 6.4 Clinical Precedent Comparison

**Approved Antibodies - Immunogenicity Rates**:

| Antibody | Target | % ADA (Anti-Drug Antibodies) | Humanization |
|----------|--------|------------------------------|--------------|
| Atezolizumab | PD-L1 | 30% | Fully human |
| Durvalumab | PD-L1 | 6% | Fully human |
| Trastuzumab | HER2 | 13% | Humanized (93%) |
| Rituximab | CD20 | 11% | Chimeric (66%) |

**Our Candidate**:
- Humanization: 85-87% (similar to trastuzumab)
- Predicted ADA risk: 10-15% (after deimmunization)
- Acceptable for clinical development

*Source: IEDB, TheraSAbDab, clinical trial data*
```

---

## Phase 7: Manufacturing Feasibility

### 7.1 Expression Optimization

```python
def assess_manufacturing_feasibility(sequence):
    """Assess manufacturing and CMC feasibility."""

    # Codon optimization for CHO
    cho_optimized = optimize_codons(sequence, host='CHO')
    rare_codons = count_rare_codons(sequence, host='CHO')

    # Signal peptide design
    signal_peptide = design_signal_peptide(sequence)

    # Purification considerations
    purification = {
        'protein_a_binding': check_protein_a_binding(sequence),
        'ion_exchange': suggest_ion_exchange_conditions(sequence),
        'hydrophobic': suggest_hic_conditions(sequence)
    }

    # Formulation
    formulation = {
        'target_concentration': predict_max_concentration(sequence),
        'buffer': suggest_buffer_conditions(sequence),
        'stabilizers': suggest_stabilizers(sequence),
        'shelf_life': predict_shelf_life(sequence)
    }

    return {
        'expression': {'cho_optimized': cho_optimized, 'rare_codons': rare_codons},
        'purification': purification,
        'formulation': formulation
    }
```

### 7.2 Output for Report

```markdown
## 7. Manufacturing Feasibility

### 7.1 Expression Assessment

**Expression System**: CHO (Chinese Hamster Ovary) cells

| Parameter | Assessment | Details |
|-----------|------------|---------|
| **Codon optimization** | Good | 5% rare codons (CHO) |
| **Signal peptide** | Native IgG leader | METDTLLLWVLLLWVPGSTG |
| **Predicted titer** | 2.0 g/L | Fed-batch, 14-day culture |
| **Soluble fraction** | 88% | High solubility predicted |

**Recommendations**:
- Use standard CHO expression system (CHO-K1 or CHO-S)
- Express as full IgG1 (not Fab) for Protein A purification
- Standard fed-batch process (no special requirements)

### 7.2 Purification Strategy

**Recommended 3-Step Purification**:

| Step | Method | Purpose | Expected Yield | Purity |
|------|--------|---------|----------------|--------|
| 1. Capture | Protein A affinity | IgG capture | >95% | >90% |
| 2. Polishing | Cation exchange (SP) | Aggregate/variant removal | >90% | >98% |
| 3. Viral | Nanofiltration (20 nm) | Viral clearance | >95% | >99% |

**Overall Process Yield**: 75-80% (from clarified harvest to final product)

**Purification Conditions**:
- Protein A: Standard pH 3.5 elution
- Cation exchange: pH 5.0-5.5 binding, salt gradient elution
- No special requirements (standard IgG process)

### 7.3 Formulation Development

**Recommended Formulation**:

| Component | Concentration | Purpose |
|-----------|---------------|---------|
| **Antibody** | 150 mg/mL | High concentration for SC delivery |
| **Buffer** | 20 mM Histidine-HCl | pH buffering, stability |
| **pH** | 6.0 | Minimizes aggregation (below pI) |
| **Stabilizer** | 0.02% Polysorbate 80 | Reduces surface adsorption |
| **Tonicity** | 240 mM Sucrose | Isotonic, cryoprotectant |

**Formulation Characteristics**:
- Viscosity: <15 cP (suitable for SC injection)
- Osmolality: 300 mOsm/kg (isotonic)
- Stability: >2 years at 2-8°C (predicted)
- Freeze/thaw: Stable for 5 cycles

**Alternative Formulations** (if needed):
- Lower concentration (100 mg/mL) for IV delivery
- Add arginine-glutamate (50 mM) if aggregation observed
- Trehalose (5%) as alternative stabilizer

### 7.4 Analytical Characterization

**Required Assays** (ICH guidelines):

| Assay | Purpose | Specification |
|-------|---------|---------------|
| **SEC-MALS** | Monomer content | >95% monomer |
| **CEX** | Charge variants | Main peak >70% |
| **CE-SDS** | Purity (reduced/non-reduced) | >95% main peak |
| **IEF/cIEF** | Isoelectric point | pI 7.0-7.5 |
| **SPR/ELISA** | Binding affinity | KD <5 nM |
| **DSF** | Thermal stability | Tm >65°C |
| **Cell-based** | Bioactivity | EC50 <10 nM |

### 7.5 CMC Timeline & Costs

**Estimated Development Timeline**:

| Phase | Duration | Activities | Cost Estimate |
|-------|----------|------------|---------------|
| **Cell line development** | 4-6 months | Transfection, selection, cloning | $150K |
| **Process development** | 6-9 months | Optimization, scale-up | $300K |
| **Analytical development** | 3-6 months | Method development, validation | $200K |
| **GMP manufacturing** | 9-12 months | Tech transfer, clinical batches | $1-2M |
| **Total to IND** | 18-24 months | - | **$1.65-2.65M** |

**Manufacturing Scale**:
- Phase 1: 5-10g (small scale, 50L bioreactor)
- Phase 2: 50-100g (pilot scale, 200L)
- Phase 3: 500g-1kg (commercial scale, 2000L)

### 7.6 Risk Assessment

**Manufacturing Risks**:

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Low expression | Low | Medium | Codon optimization, promoter engineering |
| Aggregation | Low | High | Optimized formulation, process controls |
| Glycosylation heterogeneity | Medium | Low | CHO cell line selection, process optimization |
| Charge variants | Medium | Low | Process pH control, storage conditions |

**Overall Manufacturing Risk**: Low (standard IgG process)

*Source: CMC assessment, manufacturing predictions*
```

---

## Phase 8: Final Report & Recommendations

### Report Template

```markdown
# Antibody Optimization Report: [ANTIBODY_NAME]

**Generated**: [Date] | **Target**: [Target Antigen] | **Status**: Complete

---

## Executive Summary

[Summary of optimization strategy, key improvements, and recommendations...]

**Top Candidate**: [Variant name]
- Humanization: 87% (from 62%)
- Affinity: 1.2 nM (7x improvement)
- Developability score: 82/100 (Tier 1)
- Immunogenicity: Low risk
- Manufacturing: Standard process

**Recommendation**: Advance to preclinical development

---

## 1. Input Characterization
[Section from Phase 1...]

## 2. Humanization Strategy
[Section from Phase 2...]

## 3. Structure Modeling & Analysis
[Section from Phase 3...]

## 4. Affinity Optimization
[Section from Phase 4...]

## 5. Developability Assessment
[Section from Phase 5...]

## 6. Immunogenicity Prediction
[Section from Phase 6...]

## 7. Manufacturing Feasibility
[Section from Phase 7...]

---

## 8. Final Recommendations

### 8.1 Recommended Candidate

**Variant**: VH_Humanized_Affinity_Optimized_v3

**Sequence**:
```
>VH_v3 | Humanized 87%, Affinity optimized, Deimmunized
EVQLVQSGAEVKKPGASVKVSCKASGYTFTSYYMHWVRQAPGQGLEWMWGIIPIFGTANY
AQKFQGRVTMTTDTSTSSAYMELRSLRSDDTAVYYCARARDDGSYSPFDYWGQGTLVTVSS

>VL_v3 | Humanized 90%
DIQMTQSPSSLSASVGDRVTITCRASQSISSYLNWYQQKPGKAPKLLIYAASSLQSGVPS
RFSGSGSGTDFTLTISSLQPEDFATYYCQQSYSTPLTFGQGTKVEIK
```

### 8.2 Key Improvements

| Metric | Original | Optimized | Improvement |
|--------|----------|-----------|-------------|
| **Humanness** | 62% | 87% | +40% |
| **Affinity (KD)** | 5.2 nM | 0.8 nM | 6.5x |
| **Developability** | 62/100 | 82/100 | +32% |
| **Immunogenicity risk** | High | Low | -70% |
| **Stability (Tm)** | 68°C | 74°C | +6°C |
| **Expression** | 1.2 g/L | 2.0 g/L | +67% |

### 8.3 Experimental Validation Plan

**Phase 1: In Vitro Characterization** (3-4 months)

| Assay | Purpose | Timeline |
|-------|---------|----------|
| Affinity (SPR/BLI) | Confirm KD | Week 1-2 |
| Cell-based binding | Target engagement | Week 2-3 |
| Thermal stability (DSF) | Tm measurement | Week 3 |
| Aggregation (SEC) | Monomer content | Week 3-4 |
| Expression (CHO) | Titer confirmation | Week 4-8 |
| Immunogenicity (in silico + PBMC) | ADA prediction | Week 8-12 |

**Phase 2: Lead Optimization** (2-3 months)
- Test backup variants if needed
- Formulation development
- Scale-up to 100mg

**Phase 3: Preclinical Studies** (6-12 months)
- In vivo efficacy (tumor models)
- PK/PD studies
- Toxicology (GLP)

### 8.4 Alternative Variants (Backup)

| Variant | Profile | Recommendation |
|---------|---------|----------------|
| VH_v2 | Higher humanness (90%) but lower affinity (1.8 nM) | Backup if immunogenicity issues |
| VH_v4 | Highest affinity (0.5 nM) but lower developability (72/100) | Research tool only |
| VH_v1 | Balanced (affinity 2.1 nM, dev 78/100) | Second backup |

### 8.5 Intellectual Property Considerations

**FTO Analysis Required**:
- Check existing patents on anti-[target] antibodies
- CDR sequence novelty assessment
- Humanization method IP landscape

**Patentability**:
- Novel CDR-H3 sequence (14 aa, unique)
- Specific humanization with affinity improvement
- Combination of mutations (H100aY+H52W+L91E)

### 8.6 Next Steps

**Immediate (Month 1-3)**:
1. Synthesize genes for VH_v3, VL_v3, and 2 backups
2. Express in CHO cells (transient and stable)
3. Purify and characterize (affinity, stability, aggregation)
4. Confirm developability predictions

**Short-term (Month 4-6)**:
1. Develop stable CHO cell line (top candidate)
2. Scale up to 500mg for in vivo studies
3. Formulation development and stability studies
4. Initiate in vivo efficacy studies

**Long-term (Month 7-24)**:
1. GMP manufacturing readiness
2. IND-enabling studies (tox, CMC)
3. File IND
4. Phase 1 clinical trial

---

## 9. Data Sources & Tools Used

| Tool | Purpose | Queries |
|------|---------|---------|
| IMGT | Germline identification | IGHV, IGKV genes |
| TheraSAbDab | Clinical precedents | Anti-[target] antibodies |
| AlphaFold | Structure prediction | VH-VL complex |
| IEDB | Immunogenicity | Epitope prediction |
| SAbDab | Structural analysis | PDB structures |
| UniProt | Target information | [Target accession] |
```

---

## Evidence Grading System

| Tier | Symbol | Criteria |
|------|--------|----------|
| **T1** | ★★★ | Humanness >85%, KD <2 nM, Developability >75, Low immunogenicity |
| **T2** | ★★☆ | Humanness 70-85%, KD 2-10 nM, Developability 60-75, Medium immunogenicity |
| **T3** | ★☆☆ | Humanness <70%, KD >10 nM, Developability <60, or High immunogenicity |
| **T4** | ☆☆☆ | Failed validation or major liabilities |

---

## Completeness Checklist

### Phase 1: Input Analysis
- [ ] Sequence annotated (CDRs, frameworks)
- [ ] Species identified
- [ ] Target antigen characterized
- [ ] Clinical precedents identified

### Phase 2: Humanization
- [ ] Germline genes identified (IMGT)
- [ ] Framework selected
- [ ] CDR grafting designed
- [ ] Backmutations analyzed
- [ ] ≥2 humanized variants designed

### Phase 3: Structure
- [ ] AlphaFold structure predicted
- [ ] CDR conformations analyzed
- [ ] Epitope mapped
- [ ] Structural quality assessed

### Phase 4: Affinity
- [ ] Current affinity estimated
- [ ] Affinity mutations proposed
- [ ] CDR optimization strategies identified
- [ ] Testing plan outlined

### Phase 5: Developability
- [ ] Aggregation assessed
- [ ] PTM sites identified
- [ ] Stability predicted
- [ ] Expression predicted
- [ ] Overall score calculated (0-100)

### Phase 6: Immunogenicity
- [ ] T-cell epitopes predicted (IEDB)
- [ ] Immunogenicity score calculated
- [ ] Deimmunization strategy proposed
- [ ] Clinical precedent comparison

### Phase 7: Manufacturing
- [ ] Expression system assessed
- [ ] Purification strategy outlined
- [ ] Formulation recommended
- [ ] CMC timeline estimated

### Phase 8: Final Report
- [ ] Ranked variant list
- [ ] Top candidate recommended
- [ ] Experimental validation plan
- [ ] Backup variants identified
- [ ] Next steps outlined

---

## Tool Reference

### IMGT Tools
- `IMGT_search_genes`: Search germline genes (IGHV, IGKV, etc.)
- `IMGT_get_sequence`: Get germline sequences
- `IMGT_get_gene_info`: Database information

### Antibody Databases
- `SAbDab_search_structures`: Search antibody structures
- `SAbDab_get_structure`: Get structure details
- `TheraSAbDab_search_therapeutics`: Search by name
- `TheraSAbDab_search_by_target`: Search by target antigen

### Immunogenicity
- `iedb_search_epitopes`: Search epitopes
- `iedb_search_bcell`: B-cell epitopes
- `iedb_search_mhc`: MHC-II epitopes
- `iedb_get_epitope_references`: Citations

### Structure & Target
- `AlphaFold_get_prediction`: Structure prediction
- `UniProt_get_protein_by_accession`: Target info
- `PDB_get_structure`: Experimental structures

### Systems Biology (for Bispecifics)
- `STRING_get_interactions`: Protein interactions
- `STRING_get_enrichment`: Pathway analysis

---

## Special Considerations

### Bispecific Antibody Engineering
- Use STRING tools to identify co-expressed targets
- Design separate binding arms for each target
- Consider asymmetric formats (e.g., CrossMAb, DuoBody)
- Assess aggregation risk (higher for bispecifics)

### pH-Dependent Binding
- Add His residues at interface (pKa ~6.0)
- Target: Bind at pH 7.4, release at pH 6.0
- Improves PK via FcRn recycling
- Useful for tumor targeting (acidic microenvironment)

### Affinity Ceiling
- Most therapeutic antibodies: KD 0.1-10 nM
- <0.1 nM: May cause target-mediated clearance
- 1-5 nM: Sweet spot for most targets
- Balance affinity vs. developability
