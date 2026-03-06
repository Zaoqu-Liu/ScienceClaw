# Case Study: LLM in Biomedicine — Quick Research Mode

> **User prompt:** "Survey the applications of LLM in biomedicine"

---

## Agent Workflow

Monica dispatched two agents in lightweight research mode:

| Agent | Role | Task |
|-------|------|------|
| Phoebe | Literature | Searched Nature, Science, NEJM, JAMA, arXiv for LLM applications in medicine |
| Ross | Data Analysis | Queried PubMed API for real-time publication trends; collected market data, benchmark scores, regulatory stats |

---

## Key Findings

### Clinical Decision Support (Phoebe)

| Application | Model | Performance | Source |
|-------------|-------|-------------|--------|
| USMLE exam | Med-PaLM 2 | 86.5% (expert level) | arXiv:2305.09617 |
| USMLE exam | GPT-4 (zero-shot) | Pass + 20 points above cutoff | arXiv:2303.13375 |
| USMLE exam | OpenAI o1 | 96.7% (chain-of-thought) | 2024 |
| Differential diagnosis | GPT-4 (Top-3) | 64% accuracy | Approaching senior resident level |
| Drug interaction | LLM-based detection | F1 = 0.87 | — |
| Patient communication | ChatGPT vs physicians | 3.6x higher quality, 9.8x higher empathy | JAMA Internal Medicine 2023 |

### Drug Discovery (Phoebe)

- **Target identification**: BioGPT relation extraction F1 = 44.98%, outperforming traditional methods by 27%
- **Molecular design**: DrugGPT/MolGPT improved ADME prediction accuracy by 20-30%
- **Milestone**: Insilico Medicine's AI drug ISM001-055 went from design to Phase I in just 30 months (Science 2023)

### Genomics & Precision Medicine (Phoebe)

- **Single-cell**: scGPT (Nature Methods 2024) surpassed specialized methods across 5 tasks
- **DNA modeling**: HyenaDNA processes 1M bp sequences, breaking Transformer length limits
- **Target discovery**: Geneformer (Nature 2023) discovered novel heart failure targets in the CACNA1C network

### Publication Trends — Real-Time PubMed Data (Ross)

| Year | Medical LLM Papers | YoY Growth |
|------|-------------------|------------|
| 2022 | 8 | — |
| 2023 | 2,270 | +28,000% |
| 2024 | 4,562 | +101% |

**570x growth in 2 years** — the fastest-growing research direction in life sciences.

### Market Size (Ross)

| Source | 2024 | 2030 Forecast | CAGR |
|--------|------|---------------|------|
| MarketsandMarkets | $14.9B | $110.6B | 38.6% |
| Grand View Research | — | $505.6B (2033) | 38.9% |

### Regulatory Status (Ross)

- FDA approved **700+ AI medical devices** (as of 2023), 75%+ are imaging diagnostics
- LLM-specific regulatory framework still being developed
- Epic, Cerner (major EHR systems) have integrated GPT-4 for clinical documentation

### Investment Landscape (Ross)

- Global healthcare AI funding (2023): ~$60-70B
- Google/Microsoft/Amazon: cumulative healthcare AI investment each exceeding $100B
- Tempus AI (genomics + LLM): IPO in 2024, valued at ~$6B

---

## Key Challenges

| Challenge | Data Point |
|-----------|-----------|
| Hallucination | Medical citation fabrication rate 15.5%; complex reasoning hallucination up to 40% |
| Explainability | Black-box decisions difficult to satisfy FDA/EMA requirements |
| Data privacy | HIPAA/GDPR limit cloud API use; differential privacy training reduces performance 3-8% |
| Bias & fairness | Female atypical cardiac symptom recognition 12% lower than male |
| Clinical validation | Most studies use standardized tests, lack prospective RCT validation |

---

## Future Directions

1. **Multimodal foundation models** — Pathology images + genomics + clinical records fusion for precision oncology
2. **Autonomous research agents** — AI Scientist prototypes emerging; full automation of certain biological experiments within 5 years
3. **Personalized digital twin patients** — Auto-generated treatment plans updated in real-time on admission
4. **Edge small models** — 1B-7B parameter medical-specific models solving cost and privacy issues
5. **Causal reasoning** — Beyond correlation to counterfactual clinical decisions

---

## Data Sources

- PubMed statistics: Real-time NCBI E-utilities API query (as of March 2026)
- Market size: MarketsandMarkets (page metadata), Grand View Research (page metadata)
- Benchmarks: arXiv:2305.09617 (Med-PaLM 2), arXiv:2303.13375 (GPT-4 medical evaluation)
- FDA device count: Published academic analysis (2023 data)
