<div align="center">

<img src="../../assets/hero-banner.png" width="800" alt="ScienceClaw Hero Banner" />

<br />

# ScienceClaw

**你的 AI 科研伙伴**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](../../LICENSE)
[![Skills](https://img.shields.io/badge/Skills-264+-orange.svg?style=for-the-badge)](../../README.md#-skills)
[![Databases](https://img.shields.io/badge/Databases-77+-green.svg?style=for-the-badge)](../../README.md#-database-access)
[![Search Sources](https://img.shields.io/badge/Search_Sources-15+-purple.svg?style=for-the-badge)](../../README.md#-deep-research)
[![Node](https://img.shields.io/badge/Node-22+-339933.svg?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)

[English](../../README.md) | **中文** | [日本語](README_JA.md) | [한국어](README_KO.md)

</div>

---

ScienceClaw 是一个科学研究智能体。它搜索文献、查询数据库、运行分析、生成图表、撰写报告——零自定义代码，完全基于 [OpenClaw](https://github.com/openclaw/openclaw) 构建，仅靠一个 Markdown 文件（`SCIENCE.md`，约 200 行）和 264 个领域技能。模型完成 99% 的工作；Markdown 教会它如何成为一名科学家。

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

## 快速开始

### 前置要求

<div align="center">

| 要求 | 版本 | 说明 |
|------|------|------|
| Node.js | >= 22 | 必需 |
| Python | >= 3.10 | 用于代码执行（R、Julia 可选） |
| Docker | 最新版 | 可选——用于容器化部署 |

</div>

### 第 1 步 — 克隆并配置

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git
cd ScienceClaw
cp .env.example .env        # 添加你的 API 密钥
```

### 第 2 步 — 安装依赖

```bash
bash scripts/setup.sh
```

### 第 3 步 — 运行

```bash
scienceclaw run              # 自动启动网关 + 打开终端界面
```

就这么简单。一条命令。

一次性查询模式，无需 TUI：

```bash
scienceclaw ask "搜索近期关于 TREM2 在阿尔茨海默病中的研究进展"
```

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
ScienceClaw = OpenClaw + SCIENCE.md + 264 个技能
```

没有 TypeScript。没有 Python 服务器。没有 MCP。没有插件。模型完成所有工作。

<div align="center">

| 层级 | 组件 |
|------|------|
| **用户层** | 终端 UI、Web 面板、Telegram、Discord、Slack、飞书、微信、WhatsApp、Matrix |
| **网关层** | OpenClaw 网关——消息路由、会话管理、工具调用 |
| **智能体层** | 单一 `ScienceClaw` 智能体，由 `SCIENCE.md`（约 200 行）+ 264 领域技能驱动 |
| **基础设施层** | `web_search`、`web_fetch`、`bash`——OpenClaw 内置的三个工具搞定一切 |

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

77+ 数据库覆盖 9 个学科领域，全部通过 `web_fetch` 调用公开 API 访问。

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

## 📚 技能库

<div align="center">
<img src="../../assets/skills-domains.png" width="550" alt="技能领域" />
</div>

<br />

264 个领域技能为特定技术提供详细指导。每个技能是一个 Markdown 文件，教会模型*如何*执行特定分析。

<div align="center">

| 领域 | 示例技能 |
|------|----------|
| **生物信息学** | 差异表达、基因集富集、通路分析、网络构建 |
| **单细胞** | 聚类、轨迹推断、细胞类型注释、RNA velocity |
| **生存分析** | Kaplan-Meier 曲线、Cox 回归、森林图、列线图 |
| **可视化** | 火山图、热图、曼哈顿图、Circos 图、UMAP/tSNE |
| **药物发现** | 靶点鉴定、分子对接、ADMET 预测、药物重定位 |
| **临床** | Meta 分析、诊断试验评估、危险因素分析、孟德尔随机化 |
| **基因组学** | 变异注释、GWAS 分析、拷贝数变异、突变特征 |
| **免疫学** | 免疫浸润、新抗原预测、TCR/BCR 组库分析 |
| **机器学习** | 特征选择、模型训练、交叉验证、SHAP 解释 |

</div>

---

## 部署

### 本地部署（推荐用于开发）

已在[快速开始](#快速开始)中介绍。

### Docker

```bash
docker-compose up
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
