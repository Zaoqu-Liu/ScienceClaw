<div align="center">

<img src="../../assets/hero-banner.png" width="800" alt="ScienceClaw Hero Banner" />

<br />

# ScienceClaw

**一句话启动完整基因分析流程。零自定义代码。**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](../../LICENSE)
[![Skills](https://img.shields.io/badge/Domain_Skills-266-orange.svg?style=for-the-badge)](#-266-个领域技能)
[![Databases](https://img.shields.io/badge/Databases-77+-green.svg?style=for-the-badge)](#-数据库访问)
[![Search Sources](https://img.shields.io/badge/Search_Sources-15+-purple.svg?style=for-the-badge)](#-深度检索)
[![Code](https://img.shields.io/badge/Custom_Code-0_lines-E64B35.svg?style=for-the-badge)](#架构)

[English](../../README.md) | **中文** | [日本語](README_JA.md) | [한국어](README_KO.md)

</div>

---

ScienceClaw 是一个科学研究 AI 智能体。输入 `"分析 TP53 在肝癌中的作用"`，它会自主搜索 15+ 文献源、查询 77+ 数据库、在 R 中运行生存分析、生成期刊级图表，最终交付一份完整报告——引用真实，零杜撰。

零自定义代码。完全基于 [OpenClaw](https://github.com/openclaw/openclaw) 构建，仅靠一个 Markdown 文件（[`SCIENCE.md`](../../SCIENCE.md)，约 600 行）和 266 个领域技能。模型完成 99% 的工作；Markdown 教会它如何成为一名科学家。

---

## 实战案例

### 案例 1 — 研究 THBS2 在肿瘤中的作用与意义

> **提示词：** *"Investigate the role and significance of THBS2 in tumors"*

ScienceClaw 自主搜索 PubMed，通过 cBioPortal 和 TIMER2.0 查询 TCGA 数据，在 R 中运行生存分析，最终生成 30 页报告，包含 87 条引用。

**主要发现：**

- THBS2 在 **33 种 TCGA 癌症类型中的 17 种**显著上调
- THBS2 + CA19-9 联合诊断在回顾性胰腺癌队列中 AUC 达 **0.96**——但在前瞻性验证集中降至 **0.69**
- 肿瘤微环境分析揭示 THBS2 与多种癌症类型中 M2 巨噬细胞浸润相关

[阅读完整案例 &rarr;](../cases/case-thbs2-tumor.md)

---

### 案例 2 — 综述 LLM 在生物医学中的应用

> **提示词：** *"Survey the applications of LLM in biomedicine"*

ScienceClaw 在 PubMed、Semantic Scholar 和 OpenAlex 上进行系统文献检索，并将发现整合为包含趋势分析和可视化的结构化综述。

**主要发现：**

- 医学 LLM 论文在两年内增长 **570 倍**——从 2022 年的 8 篇到 2024 年的 4,562 篇
- Med-PaLM 2 在 USMLE 上达到 **86.5%** 的准确率，超过专家医师阈值
- 医疗 LLM 市场预计到 2030 年将达到 **$110B**

[阅读完整案例 &rarr;](../cases/case-llm-biomedicine.md)

---

### 案例 3 — 研究模板：一句话启动完整流程

> **提示词：** *"分析 TP53 在肝癌中的作用"*

ScienceClaw 自动匹配 **gene-landscape** 模板，自主执行 6 步流程：文献检索 → TCGA 表达谱分析 → 生存分析 → 免疫浸润 → 通路富集 → 结构化报告 + METHODS.md。

<!-- TODO: add GIF/screenshot of Recipe execution -->

所有输出文件保存在 `~/.scienceclaw/workspace/projects/tp53-liver-cancer-<date>/`，可一键导出：`/export word`、`/export pptx` 或 `/export latex`。

[浏览全部 6 个研究模板 &rarr;](#研究模板)

---

## 快速开始

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git && cd ScienceClaw
bash scripts/setup.sh       # 安装依赖、配置 API Key（交互式）
./scienceclaw run            # 启动网关 + 打开终端界面 — 完成
```

> **国内用户：** setup 会要求填写 API Key。推荐 [DeepSeek](https://platform.deepseek.com/) — 国内直连，无需代理，¥1/百万 token。也可用 [OpenRouter](https://openrouter.ai/) 中转所有服务商。

---

## 功能概览

<div align="center">

| 功能 | 详情 |
|------|------|
| **文献搜索** | 15+ 数据源——PubMed、Semantic Scholar、OpenAlex、Europe PMC 等 |
| **数据库查询** | 77+ 数据库——UniProt、PDB、NCBI、ChEMBL、STRING、GTEx、ClinicalTrials.gov 等 |
| **代码执行** | 通过 bash 运行 Python、R、Julia——可即时安装依赖包 |
| **图表生成** | 期刊配色方案（NPG、Lancet、JCO、NEJM），出版级尺寸 |
| **报告撰写** | 引用来自真实搜索结果，绝不编造 |
| **研究评审** | 8 维度 ScholarEval 评分体系，系统评估研究质量 |
| **研究模板** | 6 个预设流程——基因全景、靶点验证、文献综述等，一句话启动 |
| **导出交付物** | 一键导出 Word、PowerPoint 或 LaTeX |
| **文献监控** | `/watch` 追踪 PubMed 主题，会话开始时提醒新论文 |

</div>

---

## 研究模板

六个预设研究流程，一句话启动完整分析。ScienceClaw 自动匹配最合适的模板并全自主执行。

<div align="center">

| 模板 | 触发示例 | 执行内容 |
|------|---------|----------|
| **gene-landscape** | "分析 TP53 在肝癌中的作用" | 文献 → TCGA 表达谱 → 生存 → 免疫 → 通路 → 报告 |
| **target-validation** | "评估 EGFR 的成药性" | 文献 → STRING → ChEMBL → DrugBank → 临床 → 专利 → 报告 |
| **literature-review** | "综述 CRISPR 在基因治疗中的应用" | 多源 50+ → 筛选 → 全文 → 趋势图 → 结构化综述 |
| **diff-expression** | "分析这个表达矩阵" | QC → DESeq2/limma → 火山图 + 热图 → GO/KEGG → 报告 |
| **clinical-query** | "NSCLC 的最新治疗方案" | 临床试验 → 指南 → 药物 → 汇总表 |
| **person-research** | "调研张三教授" | OpenAlex → PubMed → 引用 → 主题 → 学者画像 |

</div>

```bash
./scienceclaw recipes                    # 列出全部模板
./scienceclaw ask "分析 TP53 在肝癌中的作用"  # 自动匹配 gene-landscape
```

---

## 本版本新功能

<div align="center">

| 功能 | 说明 |
|------|------|
| **研究模板** | 6 个一句话启动完整流程的模板（见上方） |
| **导出 Word/PPT/LaTeX** | `/export word`、`/export pptx`、`/export latex` — 从项目结果生成格式化交付物 |
| **文献监控** | `/watch TOPIC` — 追踪 PubMed 新论文，会话开始时提醒 |
| **研究记忆** | 结构化发现存入 JSONL — 跨会话、跨项目通过 `/recall` 召回 |
| **METHODS.md** | 深度分析后自动生成 Methods 部分，可直接插入论文 |
| **智能任务路由** | 简单任务（单次查询）留在聊天；深度任务创建项目目录 |
| **后续建议** | 每次多步分析后提供数据驱动的下一步建议 |
| **会话问候** | 情境感知问候 — 老用户看到近期项目状态 + 待处理提醒 |
| **首次运行欢迎** | 新用户引导式入门，附带可操作示例 |
| **CLI `recipes` / `ask`** | `./scienceclaw recipes` 浏览模板，`./scienceclaw ask "..."` 一次性查询 |

</div>

---

## 渠道集成

<div align="center">
<img src="../../assets/channels-overview.png" width="700" alt="渠道集成概览" />
</div>

<br />

ScienceClaw 继承 OpenClaw 的所有渠道集成。连接你习惯的界面：

<div align="center">

| 渠道 | 使用方式 |
|------|----------|
| **终端 UI** | `scienceclaw tui` |
| **Web 面板** | `scienceclaw dashboard` |
| **Telegram** | [配置指南](../channels/telegram.md) |
| **Discord** | [配置指南](../channels/discord.md) |
| **Slack** | [配置指南](../channels/slack.md) |
| **飞书 / Lark** | [配置指南](../channels/feishu.md) |
| **微信** | [配置指南](../channels/wechat.md) |
| **WhatsApp** | [配置指南](../channels/whatsapp.md) |
| **Matrix** | [配置指南](../channels/matrix.md) |
| + 更多 | `scienceclaw channels --help` |

</div>

---

## 架构

<div align="center">
<img src="../../assets/architecture.png" width="700" alt="ScienceClaw 架构" />
</div>

<br />

```
ScienceClaw = OpenClaw engine + SCIENCE.md (~600 lines) + 266 Skills (markdown)
            = 0 lines of custom code
```

没有 TypeScript。没有 Python 服务器。没有 MCP。没有插件。没有中间件。`scienceclaw` bash 包装器（约 130 行）管理网关生命周期。其余全是 Markdown，教会模型如何成为一名科学家。

<div align="center">

| 层级 | 组件 |
|------|------|
| **用户层** | 终端 UI、Web 面板、Telegram、Discord、Slack、飞书、微信、WhatsApp、Matrix |
| **网关层** | OpenClaw 网关——消息路由、会话管理、工具调用（端口 18789） |
| **智能体层** | `SCIENCE.md`（身份 + 研究规范）+ 266 领域技能（按需加载） |
| **工具层** | `web_search`（Brave）、`bash`（Python/R/Julia + curl 调用 REST API）——两个工具搞定一切 |

</div>

---

## 🔍 深度检索

<div align="center">
<img src="../../assets/search-sources.png" width="700" alt="检索数据源" />
</div>

<br />

ScienceClaw 跨 15+ 数据源检索，交叉验证结果，确认引用后才纳入报告。

<div align="center">

| 类别 | 数据源 |
|------|--------|
| **生物医学文献** | PubMed、PubMed Central、Europe PMC |
| **综合学术** | Semantic Scholar、OpenAlex、CrossRef、CORE |
| **预印本** | bioRxiv、medRxiv、arXiv |
| **临床** | ClinicalTrials.gov、WHO ICTRP |
| **专利与基金** | Google Patents、NIH RePORTER |
| **综合搜索** | Google Scholar、Web search |

</div>

---

## 🗄 数据库访问

<div align="center">
<img src="../../assets/database-ecosystem.png" width="700" alt="数据库生态" />
</div>

<br />

77+ 数据库覆盖 9 个学科领域，全部通过 `bash` + `curl` 调用公开 REST API 访问。

<div align="center">

| 学科 | 数据库 | 数量 |
|------|--------|------|
| **基因组学与转录组学** | NCBI Gene、Ensembl、UCSC Genome Browser、GEO、TCGA、GTEx、ENCODE | 10+ |
| **蛋白质组学与结构** | UniProt、PDB、AlphaFold DB、InterPro、Pfam、SWISS-MODEL | 8+ |
| **通路与互作** | STRING、BioGRID、KEGG、Reactome、WikiPathways、IntAct | 8+ |
| **药理与药物发现** | ChEMBL、DrugBank、PubChem、PharmGKB、DGIdb、TTD | 8+ |
| **疾病与表型** | OMIM、DisGeNET、ClinVar、GWAS Catalog、HPO、Orphanet | 8+ |
| **免疫学** | IEDB、IMGT、ImmPort、TIMER2.0、TCIA | 6+ |
| **微生物组** | GMrepo、gutMDisorder、BugBase、MicrobiomeDB | 5+ |
| **临床与流行病学** | ClinicalTrials.gov、GBD、WHO GHO、SEER、cBioPortal | 7+ |
| **模式生物** | MGI、FlyBase、WormBase、ZFIN、RGD、SGD | 7+ |

</div>

---

## 📚 266 个领域技能

<div align="center">
<img src="../../assets/skills-domains.png" width="550" alt="技能领域" />
</div>

<br />

每个技能是一个 Markdown 文件，教会模型*如何*执行特定分析——包含 API 模式、代码模板和验证步骤。

<div align="center">

| 领域 | 数量 | 技能示例 |
|------|------|----------|
| **生物信息学** | 30+ | `scanpy`、`anndata`、`pydeseq2`、`arboreto`、`biopython`、`deeptools`、`pysam` |
| **可视化** | 35+ | `matplotlib`、`seaborn`、`plotly`、`visualization`、`networkx` |
| **药物发现** | 20+ | `chembl-database`、`rdkit`、`zinc-database`、`alphafold-database`、`adaptyv`、`medchem` |
| **临床与生存** | 15+ | `clinicaltrials-database`、`scikit-survival`、`clinical`、`fda-database` |
| **单细胞** | 10+ | `scanpy`、`scvi-tools`、`cellxgene-census`、`anndata` |
| **基因组学** | 15+ | `gene-database`、`ensembl-database`、`gwas-database`、`clinvar-database`、`geo-database` |
| **数据库** | 20+ | `uniprot-database`、`pdb-database`、`string-database`、`opentargets-database`、`reactome-database` |
| **机器学习** | 10+ | `scikit-learn`、`shap`、`aeon`、`statistics`、`exploratory-data-analysis` |
| **科学写作** | 15+ | `academic-literature-search`、`writing`、`review-writing`、`peer-review`、`venue-templates` |

</div>

```bash
./scienceclaw skills                    # 按领域浏览全部 266 个技能
./scienceclaw skills search "survival"  # 按关键词搜索
```

---

## 部署

### 本地部署（推荐用于开发）

已在[快速开始](#快速开始)中介绍。

### Docker

```bash
docker compose -f docker/docker-compose.yml up
```

### 云端部署

一键部署到你喜欢的平台：

<div align="center">

| 平台 | 部署 |
|------|------|
| **Railway** | [![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template) |
| **Fly.io** | `fly launch` — 详见[部署指南](../guides/deployment.md#flyio) |

</div>

---

## 贡献

欢迎贡献。提交 Pull Request 前请阅读 [CONTRIBUTING.md](../../CONTRIBUTING.md)。

---

## 作者

**LIU Zaoqu**

International Academy of Phronesis Medicine (Guangdong) · π-HuB infrastructure

联系方式：[liuzaoqu@163.com](mailto:liuzaoqu@163.com)

---

## 许可证

本项目基于 [MIT 许可证](../../LICENSE) 开源。

---

<div align="center">

<br />

<img src="../../assets/ScienceClaw-Logo.png" width="120" alt="ScienceClaw Logo" />

<br />

**ScienceClaw** — 你的 AI 科研伙伴。

</div>
