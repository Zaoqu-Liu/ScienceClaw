# ScienceClaw

**你的 AI 科研伙伴。**

零自定义代码。纯上下文工程。基于 [OpenClaw](https://github.com/openclaw/openclaw) 构建。

[English](../../README.md) | 中文 | [日本語](README_JA.md) | [한국어](README_KO.md)

---

## 概述

ScienceClaw 是一个科学研究智能体。它搜索文献、查询数据库、运行分析、生成图表、撰写报告——仅使用 OpenClaw 内置的三个工具（`web_search`、`web_fetch`、`bash`）。

整个产品的核心是一个文件：`SCIENCE.md`。它教会模型如何成为一名科学家——查询哪些 API、如何验证结果、何时质疑自身输出、如何正确引用文献。

264 个领域技能提供了特定技术的专业指导（单细胞分析、生存曲线、药物发现等）。

## 架构

```
ScienceClaw = OpenClaw + SCIENCE.md + 264 个技能
```

没有 TypeScript。没有 Python 服务器。没有 MCP。没有插件。模型完成 99% 的工作。

---

## 快速开始

### 前置要求

- Node.js 22+
- pnpm
- 至少一个 LLM API 密钥（OpenAI / Claude / Gemini）

### 安装

```bash
# 克隆仓库（openclaw 和 scienceclaw 需在同级目录）
git clone https://github.com/openclaw/openclaw.git
git clone https://github.com/Zaoqu-Liu/scienceclaw.git

# 一键设置
cd scienceclaw
bash scripts/setup.sh
```

设置脚本会：
1. 检查 Node.js 和 pnpm
2. 构建 OpenClaw 引擎
3. 配置 API 密钥

### 运行

```bash
# 一条命令启动（自动启动网关 + 打开终端界面）
./scienceclaw run
```

或分两个终端运行：

```bash
# 终端 1：启动网关
./scienceclaw start

# 终端 2：打开界面
./scienceclaw tui
```

### 体验一下

在终端界面中输入你的研究问题：

```
搜索近期关于 CRISPR 碱基编辑治疗镰状细胞病的论文
```

智能体会自动查询 PubMed、OpenAlex 等数据库，返回带有真实引用的研究综述。

---

## 功能特点

### 文献搜索
跨 PubMed、OpenAlex、Semantic Scholar、Europe PMC、bioRxiv、medRxiv、arXiv 搜索学术文献。

### 数据库查询
直接查询 **77+ 科学数据库**：

| 类别 | 数据库 |
|------|--------|
| 基因组学 | NCBI Gene、Ensembl、GTEx、GEO、ClinVar、GWAS Catalog |
| 蛋白质组学 | UniProt、PDB、AlphaFold、STRING |
| 化学与药物 | ChEMBL、PubChem、DrugBank、ZINC、Open Targets |
| 临床 | ClinicalTrials.gov、ClinVar、FDA |
| 通路 | KEGG、Reactome、Enrichr |
| 文献 | PubMed、OpenAlex、Semantic Scholar |

### 代码执行
通过 `bash` 直接运行 Python、R、Julia 代码进行数据分析。

### 图表生成
生成符合期刊规范的出版级图表：
- 期刊配色方案：NPG、Lancet、JCO、NEJM
- 标准尺寸：单栏（8.5×7cm）、双栏（17.5×10cm）
- 300+ DPI 分辨率

### 报告撰写
基于搜索结果撰写研究报告，所有引用均来自实际检索，绝不编造。

### 研究评审
使用 8 维度 ScholarEval 评审框架评估研究质量：新颖性、严谨性、清晰度、可重复性、影响力、连贯性、局限性、伦理。

---

## 技能库

264 个领域技能覆盖 10+ 学科领域：

| 领域 | 技能数量 | 示例 |
|------|----------|------|
| 文献与搜索 | 20+ | pubmed-search, openalex-database, arxiv-search |
| 基因组学与生信 | 30+ | gene-database, scanpy, bioinformatics |
| 蛋白质组学 | 15+ | uniprot-database, pdb-database, alphafold-database |
| 化学与药物发现 | 20+ | chembl-database, rdkit, drug-discovery-search |
| 临床与医学 | 15+ | clinicaltrials-database, clinical, treatment-plans |
| 数据分析与可视化 | 30+ | statistics, matplotlib, scikit-learn |
| 科学写作 | 15+ | scientific-writing, review-writing, peer-review |
| 材料与地球科学 | 10+ | materials, pymatgen, astropy |
| ToolUniverse 集成 | 50+ | 专业生信工作流 API |

---

## 设计哲学

来自[智能体产品设计](https://docs.openclaw.ai)：

- **苦涩的教训**：不做脚手架。模型通过 `web_fetch` 直接查询 PubMed，没有中间层。
- **六个月法则**：零易过时代码。当模型进步时，无需删除任何东西。
- **最薄封装**：0 行 TypeScript。约 224 行 Markdown。模型负责其余一切。

---

## 项目结构

```
scienceclaw/
  scienceclaw              # bash 包装器（委托给 openclaw）
  SCIENCE.md               # 智能体的大脑（约 224 行）
  openclaw.config.json     # 配置文件（1 个智能体、模型配置、技能路径）
  skills/                  # 264 个领域技能
  scripts/setup.sh         # 一键安装脚本
```

---

## 文档

- [安装指南](docs/getting-started/installation.md)
- [快速入门](docs/getting-started/quickstart.md)
- [配置参考](docs/getting-started/configuration.md)
- [部署指南](docs/guides/deployment.md)
- [技能指南](docs/guides/skills.md)
- [数据库参考](docs/guides/databases.md)
- [故障排除](docs/guides/troubleshooting.md)
- [架构概述](docs/architecture/ARCHITECTURE.md)

---

## 作者

[LIU Zaoqu](https://github.com/Zaoqu-Liu)

## 许可证

[MIT](../../LICENSE)
