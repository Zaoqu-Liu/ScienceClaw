# ScienceClaw

**あなたのAI研究パートナー。**

カスタムコードゼロ。純粋なコンテキストエンジニアリング。[OpenClaw](https://github.com/openclaw/openclaw) 上に構築。

[English](../../README.md) | [中文](README_ZH.md) | 日本語 | [한국어](README_KO.md)

---

## 概要

ScienceClaw は科学研究エージェントです。文献検索、データベースクエリ、分析実行、図表作成、レポート作成を行います。使用するのは OpenClaw に組み込まれた3つのツール（`web_search`、`web_fetch`、`bash`）のみです。

製品全体のコアは1つのファイル：`SCIENCE.md`。これがモデルに科学者としての振る舞いを教えます。どのAPIをクエリするか、結果をどう検証するか、自身の出力をいつ疑うか、正しく引用する方法などです。

264のドメインスキルが、特定の技術に関する専門的なガイダンスを提供します（シングルセル解析、生存曲線、創薬など）。

## アーキテクチャ

```
ScienceClaw = OpenClaw + SCIENCE.md + 264スキル
```

TypeScriptなし。Pythonサーバーなし。MCPなし。プラグインなし。モデルが99%の作業を実行します。

---

## クイックスタート

### 前提条件

- Node.js 22以上
- pnpm
- 少なくとも1つのLLM APIキー（OpenAI / Claude / Gemini）

### インストール

```bash
# リポジトリをクローン（openclawとscienceclawは同じ階層に配置）
git clone https://github.com/openclaw/openclaw.git
git clone https://github.com/Zaoqu-Liu/scienceclaw.git

# セットアップ
cd scienceclaw
bash scripts/setup.sh
```

### 起動

```bash
# 1コマンドで起動（ゲートウェイ起動 + TUI表示）
./scienceclaw run
```

または2つのターミナルで：

```bash
# ターミナル1：ゲートウェイ起動
./scienceclaw start

# ターミナル2：TUI起動
./scienceclaw tui
```

### 試してみる

TUIで研究に関する質問を入力してください：

```
Search for recent papers on CRISPR base editing in sickle cell disease
```

エージェントが自動的にPubMed、OpenAlexなどを検索し、実際の引用に基づいた研究サマリーを返します。

---

## 主な機能

### 文献検索
PubMed、OpenAlex、Semantic Scholar、Europe PMC、bioRxiv、medRxiv、arXivにまたがる学術文献検索。

### データベースクエリ
**77以上の科学データベース**を直接クエリ：

| カテゴリ | データベース |
|---------|------------|
| ゲノミクス | NCBI Gene、Ensembl、GTEx、GEO、ClinVar、GWAS Catalog |
| プロテオミクス | UniProt、PDB、AlphaFold、STRING |
| 化学・創薬 | ChEMBL、PubChem、DrugBank、ZINC、Open Targets |
| 臨床 | ClinicalTrials.gov、ClinVar、FDA |
| パスウェイ | KEGG、Reactome、Enrichr |
| 文献 | PubMed、OpenAlex、Semantic Scholar |

### コード実行
`bash`経由でPython、R、Juliaコードを直接実行してデータ分析。

### 図表作成
ジャーナル仕様に準拠した出版品質の図表を生成：
- カラーパレット：NPG、Lancet、JCO、NEJM
- サイズプリセット：シングルカラム（8.5×7cm）、ダブルカラム（17.5×10cm）
- 300+ DPI

### レポート作成
検索結果に基づく研究レポートを作成。すべての引用は実際の検索結果から取得され、捏造は一切ありません。

### 研究レビュー
8次元のScholarEval評価フレームワークで研究品質を評価：新規性、厳密性、明瞭性、再現性、影響力、一貫性、限界の認識、倫理。

---

## スキルライブラリ

264のドメインスキルが10以上の分野をカバー：

| 分野 | スキル数 | 例 |
|------|---------|---|
| 文献・検索 | 20+ | pubmed-search, openalex-database, arxiv-search |
| ゲノミクス・バイオインフォ | 30+ | gene-database, scanpy, bioinformatics |
| プロテオミクス | 15+ | uniprot-database, pdb-database, alphafold-database |
| 化学・創薬 | 20+ | chembl-database, rdkit, drug-discovery-search |
| 臨床・医学 | 15+ | clinicaltrials-database, clinical, treatment-plans |
| データ分析・可視化 | 30+ | statistics, matplotlib, scikit-learn |
| 科学ライティング | 15+ | scientific-writing, review-writing, peer-review |
| 材料・地球科学 | 10+ | materials, pymatgen, astropy |
| ToolUniverse連携 | 50+ | 専門的バイオインフォワークフローAPI |

---

## 設計哲学

[エージェンティックプロダクトデザイン](https://docs.openclaw.ai)より：

- **苦い教訓**：スキャフォールディングなし。モデルが`web_fetch`でPubMedに直接クエリ。中間層なし。
- **6ヶ月ルール**：陳腐化するコードゼロ。モデルが進歩しても、削除するものなし。
- **最薄のラッパー**：TypeScript 0行。Markdown約224行。残りはモデルが担当。

---

## プロジェクト構成

```
scienceclaw/
  scienceclaw              # bashラッパー（openclawに委譲）
  SCIENCE.md               # エージェントの頭脳（約224行）
  openclaw.config.json     # 設定ファイル
  skills/                  # 264のドメインスキル
  scripts/setup.sh         # セットアップスクリプト
```

---

## ドキュメント

- [インストールガイド](../getting-started/installation.md)
- [クイックスタート](../getting-started/quickstart.md)
- [設定リファレンス](../getting-started/configuration.md)
- [デプロイガイド](../guides/deployment.md)
- [スキルガイド](../guides/skills.md)
- [データベースリファレンス](../guides/databases.md)
- [トラブルシューティング](../guides/troubleshooting.md)
- [アーキテクチャ](../architecture/ARCHITECTURE.md)

---

## 作者

[LIU Zaoqu](https://github.com/Zaoqu-Liu)

## ライセンス

[MIT](../../LICENSE)
