# tooluniverse-chemical-safety — Extended Reference

> This file contains detailed tool tables, examples, and templates extracted from SKILL.md.
> The core workflow is in SKILL.md. Read this file for additional details.

## 7. Chemical-Protein Interactions
[Phase 6 results - STITCH network]

## 8. Structural Alerts
[Phase 7 results - ChEMBL alerts]

## 9. Integrated Risk Assessment
[Synthesis - risk classification, evidence summary, data gaps, recommendations]

## Appendix: Methods and Data Sources
[Tool versions, databases queried, date of access]
```

---

## Limitations & Known Issues

### Tool-Specific
- **ADMET-AI**: Predictions are computational [T3]; should not replace experimental testing
- **CTD**: Curated but may lag behind latest literature by 6-12 months
- **FDA**: Only covers FDA-approved drugs; not applicable to environmental chemicals or supplements
- **DrugBank**: Primarily drugs; limited coverage of industrial chemicals
- **STITCH**: Score thresholds affect sensitivity; lower scores increase false positives
- **ChEMBL**: Structural alerts require ChEMBL ID; not all compounds have one

### Analysis
- **Novel compounds**: May only have ADMET-AI predictions (no database evidence)
- **Environmental chemicals**: FDA/DrugBank phases will be empty; rely on CTD and ADMET-AI
- **Batch mode**: ADMET-AI can handle batches; other tools require individual queries
- **Species specificity**: Most data is human-centric; animal data noted where applicable

### Technical
- **SMILES validity**: Invalid SMILES will cause ADMET-AI failures
- **Name ambiguity**: Chemical names can be ambiguous; always verify with CID
- **Rate limits**: Some FDA endpoints may rate-limit for rapid queries

---

## Summary

**Chemical Safety & Toxicology Assessment Skill** provides comprehensive safety evaluation by integrating:

1. **Predictive toxicology** (ADMET-AI) - 9 tools covering toxicity, ADMET, physicochemical properties
2. **Toxicogenomics** (CTD) - Chemical-gene-disease relationship mapping
3. **Regulatory safety** (FDA) - 6 tools for label-based safety extraction
4. **Drug safety** (DrugBank) - Curated toxicity and contraindication data
5. **Chemical interactions** (STITCH) - Chemical-protein interaction networks
6. **Structural alerts** (ChEMBL) - Known toxic substructure detection

**Outputs**: Structured markdown report with risk classification, evidence grading, and actionable recommendations

**Best for**: Drug safety assessment, chemical hazard profiling, environmental toxicology, ADMET characterization, toxicogenomic analysis

**Total tools integrated**: 25+ tools across 6 databases
