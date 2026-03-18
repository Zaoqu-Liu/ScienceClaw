---
name: manuscript-review-revise
description: AI-powered manuscript review and revision system inspired by APRES (ICLR 2026). Evaluates scientific manuscripts using ScholarEval 8-dimension rubric plus citation-predictive heuristics, then performs targeted revisions while preserving core scientific claims. Outputs before/after comparison with improvement metrics. Use when the user says "/review", "帮我审一下", "review my manuscript", "improve this paper", "polish this draft", or provides a manuscript for quality improvement. Also triggered by "审稿", "修改论文", "润色".
---

# Manuscript Review & Revision System

Evaluate and improve scientific manuscripts through a closed-loop process: **Score → Identify Weaknesses → Revise → Re-score → Compare**. Inspired by APRES (Meta Superintelligence Labs, ICLR 2026).

## Core Principles

1. **Never modify core scientific claims** — preserve all data, results, and conclusions
2. **Never add unverified data or fabricated citations** — only restructure existing content
3. **Every revision has a stated reason** — traceable, auditable changes
4. **Quantitative before/after comparison** — ScholarEval scores pre and post revision
5. **Improve presentation, not science** — clarity, structure, flow, completeness

## When to Use

- User says `/review` or `/review <path-to-manuscript>`
- User asks "帮我审一下这篇论文" or "review my manuscript"
- User asks "润色" or "polish this draft"
- After ScienceClaw generates a research report, offer: "需要用审修系统优化这份报告吗？"

---

## Workflow

### Phase 1: ScholarEval Assessment (8 Dimensions)

Score the manuscript on each dimension (0.00–1.00):

| Dimension | Weight | Evaluation Criteria |
|-----------|--------|-------------------|
| **Novelty** | 15% | Does this advance knowledge? Are claims clearly differentiated from prior work? |
| **Rigor** | 25% | Methodology sound? Statistics correct? Controls adequate? Sample sizes reported? |
| **Clarity** | 10% | Writing clear? Figures self-explanatory? Logical flow between sections? |
| **Reproducibility** | 15% | Methods detailed enough to replicate? Software versions stated? Data accessible? |
| **Impact** | 20% | Does this matter for the field? Broad or narrow implications? |
| **Coherence** | 10% | Do all parts fit together? Introduction → Methods → Results → Discussion aligned? |
| **Limitations** | 3% | Are limitations honestly acknowledged? Not buried or trivialized? |
| **Ethics** | 2% | Ethical standards met? IRB mentioned if applicable? Conflicts disclosed? |

Compute weighted average. Output initial verdict: `accept` (≥0.75), `minor_revision` (≥0.60), `major_revision` (≥0.40), `reject` (<0.40).

### Phase 2: Citation-Impact Heuristics

Evaluate 10 presentation factors that predict higher citation impact:

| # | Factor | Check | Weight |
|---|--------|-------|--------|
| 1 | **Title specificity** | Contains key finding or quantitative result? Not vague? | High |
| 2 | **Abstract conclusion** | Has a clear, quantitative take-home message? | High |
| 3 | **Figure self-sufficiency** | Can each figure be understood from its caption alone? | High |
| 4 | **Methods reproducibility** | Software versions, parameters, thresholds all stated? | Medium |
| 5 | **Statistical reporting** | Effect sizes + CIs alongside p-values? Test assumptions verified? | Medium |
| 6 | **Discussion balance** | Presents counter-arguments and alternative interpretations? | Medium |
| 7 | **Limitations honesty** | Dedicated section with specific (not generic) limitations? | Medium |
| 8 | **Introduction funnel** | Narrows from broad context → gap → specific question? | Low |
| 9 | **Reference recency** | Includes papers from last 2 years? Not relying on outdated reviews? | Low |
| 10 | **Data availability** | States where data/code can be accessed? | Low |

Score each 0–1. Flag factors scoring below 0.5 as revision targets.

### Phase 3: Generate Revision Plan

Sort all identified weaknesses by estimated impact on manuscript quality. Output a numbered revision plan:

```
## 修订计划（按影响力排序）

1. [HIGH] 标题过于笼统 → 改为包含主要发现的具体标题
   当前: "The Role of THBS2 in Cancer"
   建议: "THBS2 Overexpression Associates with M2 Macrophage Infiltration and Poor Survival Across 17 Cancer Types"
   理由: 具体标题平均被引用量高 22%（Paiva et al., 2012）

2. [HIGH] 摘要缺少定量结论 → 添加关键数字
   当前: "THBS2 was significantly upregulated in multiple cancers"
   建议: "THBS2 was significantly upregulated in 17/33 TCGA cancer types (Wilcoxon p<0.001), with highest expression in PAAD (HR=2.31, 95%CI: 1.45-3.68)"
   理由: 摘要中包含具体数字的论文被引用量高 29%

3. [MEDIUM] Figure 2 caption 缺少统计方法说明
   ...
```

### Phase 4: Execute Revisions

Apply each revision to the manuscript text. For each change:
- Quote the original text (2-3 lines of context)
- Show the revised text
- State the reason

**Constraints**:
- Do NOT change any data values, p-values, effect sizes, or sample sizes
- Do NOT add citations that were not in the original or verified through tools
- Do NOT change the interpretation of results
- Do NOT add new claims or conclusions
- DO improve: titles, headings, topic sentences, transitions, figure captions, methods detail, limitation specificity, discussion balance

### Phase 5: Re-score and Compare

Re-run ScholarEval on the revised manuscript. Output comparison:

```
## 审修效果对比

| Dimension      | Before | After | Change |
|---------------|--------|-------|--------|
| Novelty       | 0.72   | 0.72  | —      |
| Rigor         | 0.68   | 0.75  | +0.07  |
| Clarity       | 0.55   | 0.78  | +0.23  |
| Reproducibility| 0.60  | 0.82  | +0.22  |
| Impact        | 0.70   | 0.70  | —      |
| Coherence     | 0.65   | 0.80  | +0.15  |
| Limitations   | 0.40   | 0.75  | +0.35  |
| Ethics        | 0.90   | 0.90  | —      |
|               |        |       |        |
| **Weighted**  | **0.66**| **0.76** | **+0.10** |
| **Verdict**   | minor_revision | accept | ⬆ |

Citation-impact heuristics: 4/10 → 8/10 factors above threshold

共执行 12 处修订，主要改善了清晰度（+0.23）和可复现性（+0.22）。
核心科学主张和数据未做任何修改。
```

### Phase 6: Output

Save revised manuscript and revision report:

```
outputs:
  📄 reports/manuscript_revised.md      — 修订后的完整稿件
  📋 reports/revision_report.md         — 修订报告（所有变更 + 理由）
  📊 reports/scholareval_comparison.md  — 评分对比表
```

---

## Revision Patterns Library

### Title Improvements

| Pattern | Before | After |
|---------|--------|-------|
| Add key finding | "Role of X in Y" | "X Promotes Y Through Z Mechanism" |
| Add quantitative | "X is associated with Y" | "X Overexpression in N/M Cancers Associates with Poor Survival (HR=...)" |
| Add scope | "Study of X" | "Pan-Cancer Analysis Reveals X as..." |

### Abstract Improvements

- Add sample sizes: "patients" → "patients (n=438)"
- Add effect sizes: "significantly different" → "significantly different (Cohen's d=0.82)"
- Add confidence intervals: "HR=2.31" → "HR=2.31 (95%CI: 1.45–3.68)"

### Methods Improvements

- Add software versions: "R" → "R 4.3.2"
- Add package versions: "survival package" → "survival package (v3.5-7)"
- Add thresholds: "significant genes" → "genes with |log2FC|>1 and FDR<0.05"
- Add normalization: "normalized data" → "TMM-normalized counts (edgeR v3.40.2)"

### Discussion Improvements

- Add counter-argument paragraph: "However, alternative explanations include..."
- Add comparison with conflicting studies: "In contrast to [Author, Year] who found..."
- Convert generic limitations to specific: "small sample size" → "limited sample size in the PAAD cohort (n=178) may reduce power to detect survival differences in subgroup analyses"

---

## Integration with Other Skills

- After any Research Recipe completion, offer: "需要用审修系统优化报告吗？输入 /review"
- Works on any markdown file in the project directory
- Can be applied to user-uploaded manuscripts (paste text or provide file path)
