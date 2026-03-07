---
name: tooluniverse-antibody-engineering
description: Comprehensive antibody engineering and optimization for therapeutic development. Covers humanization, affinity maturation, developability assessment, and immunogenicity prediction. Use when asked to optimize antibodies, humanize sequences, or engineer therapeutic antibodies from lead to clinical candidate.
---

# Antibody Engineering & Optimization

AI-guided antibody optimization pipeline from preclinical lead to clinical candidate. Covers sequence humanization, structure modeling, affinity optimization, developability assessment, immunogenicity prediction, and manufacturing feasibility.

**KEY PRINCIPLES**:
1. **Report-first approach** - Create optimization report before analysis
2. **Evidence-graded humanization** - Score based on germline alignment and framework retention
3. **Developability-focused** - Assess aggregation, stability, PTMs, immunogenicity
4. **Structure-guided** - Use AlphaFold/PDB structures for CDR analysis
5. **Clinical precedent** - Reference approved antibodies for validation
6. **Quantitative scoring** - Developability score (0-100) combining multiple factors
7. **English-first queries** - Always use English terms in tool calls, even if user writes in another language. Respond in user's language

---

## When to Use

Apply when user asks:
- "Humanize this mouse antibody sequence"
- "Optimize antibody affinity for [target]"
- "Assess developability of this antibody"
- "Predict immunogenicity risk for [sequence]"
- "Engineer bispecific antibody against [targets]"
- "Reduce aggregation in antibody formulation"
- "Design pH-dependent binding antibody"
- "Analyze CDR sequences and suggest mutations"

---

## Critical Workflow Requirements

### 1. Report-First Approach (MANDATORY)

1. **Create the report file FIRST**:
   - File name: `antibody_optimization_report.md`
   - Initialize with section headers
   - Add placeholder: `[Analyzing...]`

2. **Progressively update** as analysis completes

3. **Output separate files**:
   - `optimized_sequences.fasta` - All optimized variants
   - `humanization_comparison.csv` - Before/after comparison
   - `developability_assessment.csv` - Detailed scores

### 2. Documentation Standards (MANDATORY)

Every optimization MUST include:

```markdown
### Optimized Variant: VH_Humanized_v1

**Original Sequence**: EVQLVESGGGLVQPGG... (mouse)
**Humanized Sequence**: EVQLVQSGAEVKKPGA... (human framework)
**Humanization Score**: 87% human framework
**CDR Preservation**: 100% (all CDR residues retained)

**Metrics**:
| Metric | Original | Optimized | Change |
|--------|----------|-----------|--------|
| Humanness | 62% | 87% | +25% |
| Aggregation risk | 0.58 | 0.32 | -45% |
| Predicted KD | 5.2 nM | 3.8 nM | +27% affinity |
| Immunogenicity | High | Low | -65% |

*Source: IMGT germline analysis, IEDB predictions*
```

---

## Phase 0: Tool Verification

### Required Tools

| Tool | Purpose | Category |
|------|---------|----------|
| `IMGT_search_genes` | Germline gene identification | Humanization |
| `IMGT_get_sequence` | Human framework sequences | Humanization |
| `SAbDab_search_structures` | Antibody structure precedents | Structure |
| `TheraSAbDab_search_by_target` | Clinical antibody benchmarks | Validation |
| `AlphaFold_get_prediction` | Structure modeling | Structure |
| `iedb_search_epitopes` | Epitope identification | Immunogenicity |
| `iedb_search_bcell` | B-cell epitope prediction | Immunogenicity |
| `UniProt_get_protein_by_accession` | Target antigen information | Target |
| `STRING_get_interactions` | Protein interaction network | Bispecifics |
| `PubMed_search` | Literature precedents | Validation |

---

## Workflow Overview

```
Phase 1: Input Analysis & Characterization
├── Sequence annotation (CDRs, framework)
├── Species identification
├── Target antigen identification
├── Clinical precedent search
└── OUTPUT: Input characterization
    ↓
Phase 2: Humanization Strategy
├── Germline gene alignment (IMGT)
├── Framework selection
├── CDR grafting design
├── Backmutation identification
└── OUTPUT: Humanization plan
    ↓
Phase 3: Structure Modeling & Analysis
├── AlphaFold prediction
├── CDR conformation analysis
├── Epitope mapping
├── Interface analysis
└── OUTPUT: Structural assessment
    ↓
Phase 4: Affinity Optimization
├── In silico mutation screening
├── CDR optimization strategies
├── Interface improvement
└── OUTPUT: Affinity variants
    ↓
Phase 5: Developability Assessment
├── Aggregation propensity
├── PTM site identification
├── Stability prediction
├── Expression prediction
└── OUTPUT: Developability score
    ↓
Phase 6: Immunogenicity Prediction
├── MHC-II epitope prediction (IEDB)
├── T-cell epitope risk
├── Aggregation-related immunogenicity
└── OUTPUT: Immunogenicity risk score
    ↓
Phase 7: Manufacturing Feasibility
├── Expression level prediction
├── Purification considerations
├── Formulation stability
└── OUTPUT: Manufacturing assessment
    ↓
Phase 8: Final Report & Recommendations
├── Ranked variant list
├── Experimental validation plan
├── Next steps
└── OUTPUT: Comprehensive report
```

---

## Phase 1: Input Analysis & Characterization

### 1.1 Sequence Annotation

```python
def annotate_antibody_sequence(sequence):
    """Annotate antibody sequence with CDRs and framework regions."""

    # Use IMGT numbering scheme (standard for antibodies)
    # CDR definitions (IMGT):
    # CDR-H1: 27-38, CDR-H2: 56-65, CDR-H3: 105-117
    # CDR-L1: 27-38, CDR-L2: 56-65, CDR-L3: 105-117

    annotation = {
        'sequence': sequence,
        'length': len(sequence),
        'regions': {
            'FR1': sequence[0:26],
            'CDR1': sequence[26:38],
            'FR2': sequence[38:55],
            'CDR2': sequence[55:65],
            'FR3': sequence[65:104],
            'CDR3': sequence[104:117],
            'FR4': sequence[117:]
        }
    }

    return annotation
```

### 1.2 Species & Germline Identification

```python
def identify_germline(tu, vh_sequence, vl_sequence):
    """Identify germline genes for VH and VL chains using IMGT."""

    # Search for human germline genes
    vh_germlines = tu.tools.IMGT_search_genes(
        gene_type="IGHV",
        species="Homo sapiens"
    )

    vl_germlines = tu.tools.IMGT_search_genes(
        gene_type="IGKV",  # or IGLV for lambda
        species="Homo sapiens"
    )

    # Get sequences for top matches
    # Calculate identity % for each germline
    # Return closest matches

    return {
        'vh_germline': 'IGHV1-69*01',
        'vh_identity': 87.2,
        'vl_germline': 'IGKV1-39*01',
        'vl_identity': 89.5
    }
```

### 1.3 Clinical Precedent Search

```python
def search_clinical_precedents(tu, target_antigen):
    """Find approved/clinical antibodies against same target."""

    # Search Thera-SAbDab for clinical antibodies
    therapeutics = tu.tools.TheraSAbDab_search_by_target(
        target=target_antigen
    )

    approved = [ab for ab in therapeutics if ab['phase'] == 'Approved']
    clinical = [ab for ab in therapeutics if 'Phase' in ab['phase']]

    return {
        'approved_count': len(approved),
        'clinical_count': len(clinical),
        'examples': approved[:3],
        'insights': extract_design_patterns(approved)
    }
```

### 1.4 Output for Report

```markdown
## 1. Input Characterization

### 1.1 Sequence Information

| Property | Heavy Chain (VH) | Light Chain (VL) |
|----------|------------------|------------------|
| **Length** | 118 aa | 107 aa |
| **Species** | Mouse (Mus musculus) | Mouse (Mus musculus) |
| **Humanness** | 62% | 68% |
| **Closest human germline** | IGHV1-69*01 (87% identity) | IGKV1-39*01 (90% identity) |

### 1.2 CDR Annotation (IMGT Numbering)

**Heavy Chain**:
- FR1: 1-26, CDR-H1: 27-38, FR2: 39-55, CDR-H2: 56-65, FR3: 66-104, CDR-H3: 105-117, FR4: 118-128

**CDR Sequences**:
| CDR | Sequence | Length | Canonical Class |
|-----|----------|--------|-----------------|
| CDR-H1 | GYTFTSYYMH | 10 | H1-13-1 |
| CDR-H2 | GIIPIFGTANY | 11 | H2-10-1 |
| CDR-H3 | ARDDGSYSPFDYWG | 14 | - (unique) |
| CDR-L1 | RASQSISSYLN | 11 | L1-11-1 |
| CDR-L2 | AASSLQS | 7 | L2-8-1 |
| CDR-L3 | QQSYSTPLT | 9 | L3-9-cis7-1 |

### 1.3 Target Information

| Property | Value |
|----------|-------|
| **Target** | PD-L1 (Programmed death-ligand 1) |
| **UniProt** | Q9NZQ7 |
| **Function** | Immune checkpoint, inhibits T-cell activation |
| **Disease relevance** | Cancer immunotherapy target |

### 1.4 Clinical Precedents

**Approved antibodies targeting PD-L1**:
1. **Atezolizumab** (Tecentriq) - IgG1, approved 2016
2. **Durvalumab** (Imfinzi) - IgG1, approved 2017
3. **Avelumab** (Bavencio) - IgG1, approved 2017

**Key insights**: All approved anti-PD-L1 antibodies use human IgG1 scaffolds with effector function modifications.

*Source: TheraSAbDab, UniProt*
```

---

## Phase 2: Humanization Strategy

### 2.1 Framework Selection

```python
def select_human_framework(tu, mouse_sequence, cdr_sequences):
    """Select optimal human framework for CDR grafting."""

    # Search IMGT for human germline genes
    vh_genes = tu.tools.IMGT_search_genes(
        gene_type="IGHV",
        species="Homo sapiens"
    )

    # For each candidate framework:
    # 1. Calculate sequence identity to mouse FR
    # 2. Check CDR canonical class compatibility
    # 3. Assess structural compatibility
    # 4. Consider clinical precedents

    candidates = []
    for gene in vh_genes[:20]:  # Top 20 human germlines
        gene_seq = tu.tools.IMGT_get_sequence(
            accession=gene['accession'],
            format='fasta'
        )

        score = calculate_framework_score(
            mouse_fr=extract_framework(mouse_sequence),
            human_fr=extract_framework(gene_seq),
            cdr_compatibility=check_cdr_compatibility(cdr_sequences, gene_seq)
        )

        candidates.append({
            'germline': gene['name'],
            'identity': score['identity'],
            'cdr_compatibility': score['cdr_compatibility'],
            'clinical_use': count_clinical_uses(gene['name']),
            'overall_score': score['total']
        })

    # Sort by overall score
    return sorted(candidates, key=lambda x: x['overall_score'], reverse=True)
```

### 2.2 CDR Grafting Design

```python
def design_cdr_grafting(mouse_sequence, human_framework, cdr_sequences):
    """Design CDR grafting with backmutation identification."""

    # Graft mouse CDRs onto human framework
    grafted_sequence = graft_cdrs(
        human_framework=human_framework,
        mouse_cdrs=cdr_sequences
    )

    # Identify Vernier zone residues (affect CDR conformation)
    vernier_residues = [2, 27, 28, 29, 30, 47, 48, 67, 69, 71, 78, 93, 94]

    # Identify potential backmutations
    backmutations = []
    for pos in vernier_residues:
        if mouse_sequence[pos] != human_framework[pos]:
            backmutations.append({
                'position': pos,
                'human_aa': human_framework[pos],
                'mouse_aa': mouse_sequence[pos],
                'reason': 'Vernier zone - may affect CDR conformation',
                'priority': 'High' if pos in [27, 29, 30, 48] else 'Medium'
            })

    return {
        'grafted_sequence': grafted_sequence,
        'backmutations': backmutations,
        'humanness_score': calculate_humanness(grafted_sequence)
    }
```

### 2.3 Humanization Scoring

```python
def calculate_humanization_score(sequence, human_germline):
    """Calculate comprehensive humanization score."""

    # Framework humanness (% identity to human germline)
    fr_identity = calculate_framework_identity(sequence, human_germline)

    # T-cell epitope content (lower is better)
    tcell_epitope_count = predict_tcell_epitopes(sequence)

    # Unusual residues in human context
    unusual_residues = count_unusual_residues(sequence)

    # Aggregation hotspots
    aggregation_motifs = find_aggregation_motifs(sequence)

    score = {
        'framework_humanness': fr_identity,  # 0-100%
        'cdr_preservation': 100,  # Always 100% initially
        'tcell_epitopes': tcell_epitope_count,
        'unusual_residues': unusual_residues,
        'aggregation_risk': len(aggregation_motifs),
        'overall_score': calculate_weighted_score(
            fr_identity, tcell_epitope_count, unusual_residues, aggregation_motifs
        )
    }

    return score
```

### 2.4 Output for Report

```markdown
## 2. Humanization Strategy

### 2.1 Framework Selection

**Selected Human Frameworks**:

| Chain | Germline | Identity | CDR Compatibility | Clinical Use | Score |
|-------|----------|----------|-------------------|--------------|-------|
| **VH** | IGHV1-69*01 | 87.2% | Excellent | 127 antibodies | 94/100 |
| **VL** | IGKV1-39*01 | 89.5% | Excellent | 89 antibodies | 92/100 |

**Rationale**:
- IGHV1-69*01: Most frequently used human germline in therapeutic antibodies
- High sequence identity minimizes risk of affinity loss
- Excellent CDR canonical class compatibility
- Proven clinical track record

### 2.2 CDR Grafting Design

**Grafting Strategy**: Direct CDR transfer with Vernier zone optimization

| Region | Source | Sequence | Rationale |
|--------|--------|----------|-----------|
| FR1 | IGHV1-69*01 | EVQLVQSGAEVKKPGA... | Human framework |
| CDR-H1 | Mouse | GYTFTSYYMH | Retain binding |
| FR2 | IGHV1-69*01 | VKWVRQAPGQGLE... | Human framework |
| CDR-H2 | Mouse | GIIPIFGTANY | Retain binding |
| FR3 | IGHV1-69*01 | RVTMTTDTSTSTYME... | Human framework |
| CDR-H3 | Mouse | ARDDGSYSPFDYWG | Retain binding |
| FR4 | IGHJ4*01 | WGQGTLVTVSS | Human framework |

### 2.3 Backmutation Analysis

**Identified Vernier Zone Residues** (may require backmutation):

| Position | Human | Mouse | Region | Impact | Priority |
|----------|-------|-------|--------|--------|----------|
| 27 | T | A | CDR-H1 boundary | CDR conformation | High |
| 48 | I | V | FR2 | VH-VL interface | High |
| 67 | A | S | FR3 | CDR-H2 support | Medium |
| 71 | R | K | FR3 | CDR-H2 support | Medium |
| 93 | A | T | FR3 | CDR-H3 base | Medium |

**Recommendation**: Test versions with/without backmutations at positions 27 and 48

### 2.4 Humanized Sequences

**Version 1: Full humanization** (no backmutations)
```
>VH_Humanized_v1 | 87% human framework
EVQLVQSGAEVKKPGASVKVSCKASGYTFTSYYMHWVRQAPGQGLEWMGGIIPIFGTANY
AQKFQGRVTMTTDTSTSTAYMELRSLRSDDTAVYYCARARDDGSYSPFDYWGQGTLVTVSS
```

**Version 2: With key backmutations** (positions 27, 48)
```
>VH_Humanized_v2 | 85% human framework + backmutations
EVQLVQSGAEVKKPGASVKVSCKASGYAFTSYYMHWVRQAPGQGLEWMVGIIPIFGTANY
AQKFQGRVTMTTDTSTSTAYMELRSLRSDDTAVYYCARARDDGSYSPFDYWGQGTLVTVSS
```

**Humanization Metrics**:
| Metric | Original (Mouse) | v1 (Full) | v2 (Backmut) |
|--------|------------------|-----------|--------------|
| Framework humanness | 62% | 87% | 85% |
| CDR preservation | 100% | 100% | 100% |
| Vernier zone match | Mouse | Human | Mixed |
| Predicted affinity | Baseline | 60-80% | 80-100% |

*Source: IMGT germline database, CDR analysis*
```

---

## Phase 3: Structure Modeling & Analysis

### 3.1 AlphaFold Structure Prediction

```python
def predict_antibody_structure(tu, vh_sequence, vl_sequence):
    """Predict antibody Fv structure using AlphaFold."""

    # Combine VH and VL with linker
    fv_sequence = vh_sequence + ":" + vl_sequence  # AlphaFold uses : for chain separator

    # Predict structure
    prediction = tu.tools.AlphaFold_get_prediction(
        sequence=fv_sequence,
        return_format='pdb'
    )

    # Extract pLDDT scores
    plddt_scores = extract_plddt(prediction)

    # Analyze by region
    regions = {
        'VH_FR': np.mean([plddt_scores[i] for i in range(0, 26)]),
        'CDR_H1': np.mean([plddt_scores[i] for i in range(26, 38)]),
        'CDR_H2': np.mean([plddt_scores[i] for i in range(55, 65)]),
        'CDR_H3': np.mean([plddt_scores[i] for i in range(104, 117)]),
        'VL_FR': np.mean([plddt_scores[i] for i in range(len(vh_sequence), len(vh_sequence)+26)]),
        'CDR_L1': np.mean([plddt_scores[i] for i in range(len(vh_sequence)+26, len(vh_sequence)+38)]),
    }

    return {
        'structure': prediction,
        'mean_plddt': np.mean(plddt_scores),
        'regional_plddt': regions,
        'cdr_confidence': np.mean([regions['CDR_H1'], regions['CDR_H2'], regions['CDR_H3']])
    }
```

### 3.2 CDR Conformation Analysis

```python
def analyze_cdr_conformation(structure):
    """Analyze CDR loop conformations and canonical classes."""

    # Extract CDR coordinates
    cdr_coords = extract_cdr_regions(structure)

    # Classify canonical structures
    cdr_classes = {
        'CDR-H1': classify_canonical_structure(cdr_coords['H1']),
        'CDR-H2': classify_canonical_structure(cdr_coords['H2']),
        'CDR-H3': 'Non-canonical (14 aa)',  # Usually unique
        'CDR-L1': classify_canonical_structure(cdr_coords['L1']),
        'CDR-L2': classify_canonical_structure(cdr_coords['L2']),
        'CDR-L3': classify_canonical_structure(cdr_coords['L3'])
    }

    # Calculate RMSD to known canonical structures
    rmsd_values = calculate_canonical_rmsd(cdr_coords, cdr_classes)

    return {
        'classes': cdr_classes,
        'rmsd': rmsd_values,
        'confidence': assess_conformation_confidence(rmsd_values)
    }
```

### 3.3 Epitope Mapping

```python
def map_epitope(tu, target_protein, antibody_structure):
    """Identify epitope on target protein."""

    # Get target structure or predict
    target_info = tu.tools.UniProt_get_protein_by_accession(
        accession=target_protein
    )

    # Search for known epitopes
    epitopes = tu.tools.iedb_search_epitopes(
        sequence_contains=target_protein,
        structure_type="Linear peptide",
        limit=20
    )

    # Search for structural antibody complexes
    sabdab_results = tu.tools.SAbDab_search_structures(
        query=target_info['protein_name']
    )

    # Analyze binding interface
    interface = {
        'epitope_candidates': epitopes,
        'structural_precedents': sabdab_results,
        'predicted_interface': predict_binding_interface(antibody_structure)
    }

    return interface
```

### 3.4 Output for Report

```markdown
## 3. Structure Modeling & Analysis

### 3.1 AlphaFold Predictions

**Structure Quality**:

| Variant | Mean pLDDT | VH pLDDT | VL pLDDT | CDR pLDDT | Confidence |
|---------|------------|----------|----------|-----------|------------|
| Original (Mouse) | 89.2 | 91.4 | 88.7 | 85.3 | High |
| VH_Humanized_v1 | 87.8 | 89.6 | 88.2 | 83.1 | High |
| VH_Humanized_v2 | 88.9 | 90.8 | 88.5 | 84.8 | High |

**Regional Confidence (v2)**:
- Framework regions: 92.3 (very high)
- CDR-H1, H2, L1, L2: 87-91 (high)
- CDR-H3: 78.4 (moderate - expected for unique CDR-H3)
- VH-VL interface: 90.1 (high)

### 3.2 CDR Conformation Analysis

**Canonical Classes** (Humanized v2):

| CDR | Length | Canonical Class | RMSD to Class | Status |
|-----|--------|-----------------|---------------|--------|
| CDR-H1 | 10 | H1-13-1 | 0.8 Å | ✓ Maintained |
| CDR-H2 | 11 | H2-10-1 | 1.1 Å | ✓ Maintained |
| CDR-H3 | 14 | Non-canonical | N/A | Unique structure |
| CDR-L1 | 11 | L1-11-1 | 0.9 Å | ✓ Maintained |
| CDR-L2 | 7 | L2-8-1 | 0.7 Å | ✓ Maintained |
| CDR-L3 | 9 | L3-9-cis7-1 | 1.0 Å | ✓ Maintained |

**Assessment**: All CDR conformations well-preserved in humanized variants. Low RMSD values indicate minimal structural perturbation from humanization.

### 3.3 Epitope Analysis

**Known PD-L1 Epitopes** (IEDB):

| Epitope | Sequence | Position | Binding Antibodies | Conservation |
|---------|----------|----------|-------------------|--------------|
| Epitope 1 | LQDAG...VPEPP | 19-113 | Durvalumab, Avelumab | 98% |
| Epitope 2 | FTVT...PGPN | 54-68 | Atezolizumab | 100% |
| Epitope 3 | RLEDL...NVSI | 115-127 | Research Abs | 95% |

**Predicted Binding Interface**:
- Primary contact residues: CDR-H3 (70%), CDR-H1 (15%), CDR-H2 (10%)
- Secondary contacts: CDR-L3 (5%)
- Estimated buried surface area: 820 Å²

### 3.4 Structural Comparison

**Superposition with Clinical Antibodies** (SAbDab):

| Reference | PDB ID | VH RMSD | VL RMSD | CDR-H3 RMSD | Notes |
|-----------|--------|---------|---------|-------------|-------|
| Atezolizumab | 5X8L | 1.2 Å | 1.4 Å | 2.8 Å | Similar approach angle |
| Durvalumab | 5X8M | 1.8 Å | 1.5 Å | 3.4 Å | Different epitope |
| Research Ab | 5C3T | 0.9 Å | 1.1 Å | 1.5 Å | Very similar |

*Source: AlphaFold, IEDB, SAbDab*
```

---

## Phase 4: Affinity Optimization

### 4.1 In Silico Mutation Screening

```python
def design_affinity_variants(antibody_structure, target_structure):
    """Design affinity maturation variants using computational screening."""

    # Identify interface residues
    interface_residues = identify_interface_residues(
        antibody_structure,
        target_structure,
        distance_cutoff=4.5  # Angstroms
    )

    # Focus on CDR residues
    cdr_interface = [res for res in interface_residues if is_cdr_residue(res)]

    # Design mutations for each position
    variants = []
    for position in cdr_interface:
        # Try all amino acids except original
        for aa in 'ACDEFGHIKLMNPQRSTVWY':
            if aa != antibody_structure.sequence[position]:
                predicted_ddg = predict_binding_energy_change(
                    structure=antibody_structure,
                    mutation=f"{antibody_structure.sequence[position]}{position}{aa}"
                )

                if predicted_ddg < -0.5:  # Favorable change (more negative = better)
                    variants.append({
                        'position': position,
                        'original': antibody_structure.sequence[position],
                        'mutant': aa,
                        'predicted_ddg': predicted_ddg,
                        'predicted_kd_fold': calculate_kd_change(predicted_ddg)
                    })

    # Rank by predicted improvement
    return sorted(variants, key=lambda x: x['predicted_ddg'])
```

### 4.2 CDR Optimization Strategies

```python
def cdr_optimization_strategies(cdr_sequence, cdr_name):
    """Identify CDR optimization strategies based on sequence and structure."""

    strategies = []

    # Strategy 1: Extend CDR for increased contact area
    if len(cdr_sequence) < 12 and cdr_name == 'CDR-H3':
        strategies.append({
            'strategy': 'CDR-H3 extension',
            'rationale': 'Add 1-2 residues to increase contact surface',
            'expected_impact': '+2-5x affinity improvement',
            'examples': ['Extension with Gly-Tyr', 'Extension with Ser-Asp']
        })

    # Strategy 2: Tyrosine enrichment
    tyr_count = cdr_sequence.count('Y')
    if tyr_count < 2:
        strategies.append({
            'strategy': 'Tyrosine enrichment',
            'rationale': 'Tyr provides pi-stacking and H-bonds',
            'expected_impact': '+2-3x affinity improvement',
            'targets': suggest_tyr_positions(cdr_sequence)
        })

    # Strategy 3: Charged residue optimization
    if 'PD' in cdr_sequence or 'EP' in cdr_sequence:
        strategies.append({
            'strategy': 'Salt bridge formation',
            'rationale': 'Add charged residues for electrostatic interactions',
            'expected_impact': '+1-2x affinity and pH sensitivity',
            'targets': identify_salt_bridge_opportunities(cdr_sequence)
        })

    return strategies
```

### 4.3 Output for Report

```markdown
## 4. Affinity Optimization

### 4.1 Current Affinity Assessment

| Property | Value | Method |
|----------|-------|--------|
| **Predicted KD** | 5.2 nM | Structure-based prediction |
| **Buried surface area** | 820 Å² | AlphaFold model |
| **Interface hotspots** | 6 residues | Energy decomposition |

**Target**: Single-digit nM affinity (KD < 5 nM)

### 4.2 Proposed Affinity Mutations

**High-Priority Mutations** (predicted >2x improvement):

| Position | Original | Mutant | Region | Predicted ΔΔG | KD Fold Improvement | Rationale |
|----------|----------|--------|--------|---------------|---------------------|-----------|
| H100a | S | Y | CDR-H3 | -1.2 kcal/mol | 7.4x | Pi-stacking with target Phe |
| H52 | I | W | CDR-H2 | -0.9 kcal/mol | 4.8x | Increased hydrophobic contact |
| L91 | Q | E | CDR-L3 | -0.7 kcal/mol | 3.3x | Salt bridge with target Arg |
| H58 | G | S | CDR-H2 | -0.6 kcal/mol | 2.7x | H-bond to target backbone |

**Medium-Priority Mutations** (predicted 1.5-2x improvement):

| Position | Original | Mutant | Region | Predicted ΔΔG | KD Fold Improvement | Rationale |
|----------|----------|--------|--------|---------------|---------------------|-----------|
| H33 | Y | F | CDR-H1 | -0.5 kcal/mol | 2.3x | Optimize stacking geometry |
| L50 | A | T | CDR-L2 | -0.4 kcal/mol | 2.0x | Additional H-bond |

### 4.3 Combination Strategy

**Recommended Testing Order**:

1. **Single mutants**: H100aY, H52W, L91E (test individually)
2. **Double mutants**: H100aY+H52W, H100aY+L91E (best combinations)
3. **Triple mutant**: H100aY+H52W+L91E (if additivity observed)

**Expected Outcome**:
- Single mutants: KD 1.5-2.5 nM (3-7x improvement)
- Best double mutant: KD 0.7-1.2 nM (7-15x improvement)
- Triple mutant: KD 0.3-0.6 nM (15-30x improvement) if additive

### 4.4 CDR Optimization Strategies

**Strategy 1: CDR-H3 Extension**
- Current length: 14 aa
- Proposed: Add Gly-Tyr at C-terminus (16 aa total)
- Rationale: Fill gap in binding interface, Tyr provides pi-stacking
- Expected impact: +2-3x affinity

**Strategy 2: Tyrosine Enrichment**
- Current Tyr count: 3 in CDRs
- Target positions: H33, H52a, L96
- Rationale: Tyr provides both hydrophobic and H-bond contacts
- Expected impact: +2-4x affinity

**Strategy 3: pH-Dependent Binding (Optional)**
- For tumor-selective uptake
- Add His residues at interface: H100a, L91
- pKa ~6.0: Bind at pH 7.4, release at pH 6.0
- Expected impact: Tumor selectivity, faster recycling

*Source: In silico modeling, structural analysis*
```

---


---

> **Extended Reference**: For detailed tool tables, examples, and templates, read `REFERENCE.md` in this skill directory.
> The agent can access it via: `read skills/tooluniverse-antibody-engineering/REFERENCE.md`
