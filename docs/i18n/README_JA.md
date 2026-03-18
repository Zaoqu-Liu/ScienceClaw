<div align="center">

<img src="../../assets/hero-banner.png" width="800" alt="ScienceClaw Hero Banner" />

<br />

# ScienceClaw

**ワンプロンプト。完全な遺伝子解析パイプライン。カスタムコードゼロ。**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](../../LICENSE)
[![Skills](https://img.shields.io/badge/Domain_Skills-266-orange.svg?style=for-the-badge)](../../README.md#-266-domain-skills)
[![Databases](https://img.shields.io/badge/Databases-77+-green.svg?style=for-the-badge)](../../README.md#-database-access)
[![Search Sources](https://img.shields.io/badge/Search_Sources-15+-purple.svg?style=for-the-badge)](../../README.md#-deep-research)
[![Code](https://img.shields.io/badge/Custom_Code-0_lines-E64B35.svg?style=for-the-badge)](../../README.md#architecture)

[English](../../README.md) | [中文](README_ZH.md) | **日本語** | [한국어](README_KO.md)

</div>

---

ScienceClaw は科学研究AIエージェントです。`「TP53の肝癌における役割を分析」`と入力するだけで、15以上の文献ソースを自律的に検索し、77以上のデータベースをクエリし、Rで生存分析を実行し、ジャーナル品質の図表を生成し、実際の引用付きの完全なレポートを提供します — 捏造なし、幻覚なし。

カスタムコードゼロ。[OpenClaw](https://github.com/openclaw/openclaw) 上に構築され、1つのMarkdownファイル（[`SCIENCE.md`](../../SCIENCE.md)、約600行）と266のドメインスキルのみで動作します。モデルが99%の作業を実行し、Markdownが科学者としての振る舞いを教えます。

---

## 実際の動作例

### ケース1 — 腫瘍におけるTHBS2の役割と意義の調査

> **プロンプト：** *"Investigate the role and significance of THBS2 in tumors"*

ScienceClaw は自律的にPubMedを検索し、cBioPortalとTIMER2.0を通じてTCGAデータをクエリし、Rで生存分析を実行して、87件の引用を含む30ページのレポートを作成しました。

**主な発見：**

- THBS2は **33種のTCGAがん種のうち17種**で有意に上方制御
- THBS2 + CA19-9 の複合診断パネルは膵臓がん後方視コホートでAUC **0.96** を達成 — しかし前方視検証セットでは **0.69** に低下
- 腫瘍微小環境分析により、複数のがん種でTHBS2とM2マクロファージ浸潤の相関が判明

[完全なケーススタディを読む &rarr;](../cases/case-thbs2-tumor.md)

---

### ケース2 — バイオメディシンにおけるLLMの応用調査

> **プロンプト：** *"Survey the applications of LLM in biomedicine"*

ScienceClaw はPubMed、Semantic Scholar、OpenAlexにわたる体系的な文献検索を実施し、トレンド分析と可視化を含む構造化されたサーベイにまとめました。

**主な発見：**

- 医療LLM論文は2年間で **570倍** に増加 — 2022年の8件から2024年の4,562件へ
- Med-PaLM 2 はUSMLEで **86.5%** の精度を達成し、専門医の閾値を超過
- ヘルスケアLLM市場は2030年までに **$110B** に到達する見込み

[完全なケーススタディを読む &rarr;](../cases/case-llm-biomedicine.md)

---

### ケース3 — リサーチレシピ：ワンライナーからフルパイプライン

> **プロンプト：** *"分析 TP53 在肝癌中的作用"*

ScienceClaw は **gene-landscape** レシピを自動マッチし、6ステップのパイプラインを自律実行：文献検索 → TCGA発現プロファイリング → 生存分析 → 免疫浸潤 → パスウェイ富化 → METHODS.md付き構造化レポート。

<!-- TODO: add GIF/screenshot of Recipe execution -->

全出力ファイルは `~/.scienceclaw/workspace/projects/tp53-liver-cancer-<date>/` に保存され、コマンド一つでエクスポート：`/export word`、`/export pptx`、`/export latex`。

[全6つのリサーチレシピを見る &rarr;](#リサーチレシピ)

---

## クイックスタート

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git && cd ScienceClaw
bash scripts/setup.sh       # 依存関係インストール、APIキー設定（対話式）
./scienceclaw run            # ゲートウェイ起動 + TUI表示 — 完了
```

> **中国ユーザー：** [DeepSeek](https://platform.deepseek.com/) を推奨 — 直接アクセス、プロキシ不要。または [OpenRouter](https://openrouter.ai/) をリレーとして使用。

---

## 機能概要

<div align="center">

| 機能 | 詳細 |
|------|------|
| **文献検索** | 15以上のソース — PubMed、Semantic Scholar、OpenAlex、Europe PMCなど |
| **データベースクエリ** | 77以上のDB — UniProt、PDB、NCBI、ChEMBL、STRING、GTEx、ClinicalTrials.govなど |
| **コード実行** | bash経由でPython、R、Julia — パッケージを随時インストール |
| **図表作成** | ジャーナル仕様の配色（NPG、Lancet、JCO、NEJM）、出版品質のサイズ |
| **レポート作成** | 検索結果からの実際の引用、捏造なし |
| **研究レビュー** | 8次元ScholarEval評価フレームワークによる体系的品質評価 |
| **リサーチレシピ** | 6つのプリビルトワークフロー — 遺伝子ランドスケープ、ターゲット検証、文献レビューなど |
| **エクスポート** | プロジェクト結果からワンコマンドでWord、PowerPoint、LaTeXへ |
| **文献モニタリング** | `/watch` でPubMedのトピックを追跡、セッション開始時に新着論文をアラート |

</div>

---

## リサーチレシピ

6つのプリビルト研究ワークフロー。シングルプロンプトで完全なマルチステップ分析を実行。

<div align="center">

| レシピ | トリガー例 | 実行内容 |
|--------|----------|----------|
| **gene-landscape** | "TP53の肝癌における役割を分析" | 文献 → TCGA発現 → 生存 → 免疫 → パスウェイ → レポート |
| **target-validation** | "EGFRのドラッガビリティを評価" | 文献 → STRING → ChEMBL → DrugBank → 臨床試験 → 特許 → レポート |
| **literature-review** | "遺伝子治療におけるCRISPRを総説" | マルチソース50+ → フィルター → 全文 → トレンド → 構造化レビュー |
| **diff-expression** | "この発現マトリックスを分析" | QC → DESeq2/limma → 火山プロット + ヒートマップ → GO/KEGG → レポート |
| **clinical-query** | "NSCLCの最新治療法" | ClinicalTrials → ガイドライン → 薬剤 → サマリーテーブル |
| **person-research** | "田中教授をリサーチ" | OpenAlex → PubMed → 引用 → テーマ → プロフィールレポート |

</div>

---

## 本リリースの新機能

<div align="center">

| 機能 | 説明 |
|------|------|
| **リサーチレシピ** | 6つのワンライナー→フルワークフローテンプレート（上記参照） |
| **Word/PPT/LaTeXエクスポート** | `/export word`、`/export pptx`、`/export latex` — プロジェクト結果からフォーマット済みドキュメントを生成 |
| **文献モニタリング** | `/watch TOPIC` — PubMedの新着論文を追跡、セッション開始時にアラート |
| **研究メモリ** | 構造化された発見をJSONLに保存 — セッション横断、プロジェクト横断で `/recall` で呼び出し |
| **METHODS.md** | 深い分析後にMethodsセクションを自動生成、論文にそのまま挿入可能 |
| **スマートタスクルーティング** | 簡単なタスク（単一検索）はチャットに留まり、深いタスクはプロジェクトディレクトリを作成 |
| **フォローアップ提案** | すべてのマルチステップ分析後にデータ駆動の次ステップ提案 |
| **CLI `recipes` / `ask`** | `./scienceclaw recipes` でブラウズ、`./scienceclaw ask "..."` でワンショットクエリ |

</div>

---

## チャネル統合

<div align="center">
<img src="../../assets/channels-overview.png" width="700" alt="チャネル統合概要" />
</div>

<br />

ScienceClaw はOpenClawのすべてのチャネル統合を継承しています。お好みのインターフェースで接続：

<div align="center">

| チャネル | 使い方 |
|---------|--------|
| **ターミナルUI** | `scienceclaw tui` |
| **Webダッシュボード** | `scienceclaw dashboard` |
| **Telegram** | [セットアップガイド](../channels/telegram.md) |
| **Discord** | [セットアップガイド](../channels/discord.md) |
| **Slack** | [セットアップガイド](../channels/slack.md) |
| **Feishu / Lark** | [セットアップガイド](../channels/feishu.md) |
| **WeChat** | [セットアップガイド](../channels/wechat.md) |
| **WhatsApp** | [セットアップガイド](../channels/whatsapp.md) |
| **Matrix** | [セットアップガイド](../channels/matrix.md) |
| + その他 | `scienceclaw channels --help` |

</div>

---

## アーキテクチャ

<div align="center">
<img src="../../assets/architecture.png" width="700" alt="ScienceClaw アーキテクチャ" />
</div>

<br />

```
ScienceClaw = OpenClaw engine + SCIENCE.md (~600 lines) + 266 Skills (markdown)
            = 0 lines of custom code
```

TypeScriptなし。Pythonサーバーなし。MCPなし。プラグインなし。ミドルウェアなし。`scienceclaw` bashラッパー（約130行）がゲートウェイのライフサイクルを管理。その他はすべてMarkdownで、モデルに科学者としての振る舞いを教えます。

<div align="center">

| レイヤー | コンポーネント |
|---------|-------------|
| **ユーザー** | ターミナルUI、Webダッシュボード、Telegram、Discord、Slack、Feishu、WeChat、WhatsApp、Matrix |
| **ゲートウェイ** | OpenClaw ゲートウェイ — メッセージルーティング、セッション管理、ツールコール（ポート18789） |
| **エージェント** | `SCIENCE.md`（アイデンティティ + 研究規律）+ 266ドメインスキル（オンデマンド読み込み） |
| **ツール** | `web_search`（Brave）、`bash`（Python/R/Julia + curlでREST API）— 2つのツールですべてを実現 |

</div>

---

## 🔍 ディープリサーチ

<div align="center">
<img src="../../assets/search-sources.png" width="700" alt="検索ソース" />
</div>

<br />

ScienceClaw は15以上のソースにまたがって検索し、結果をクロスリファレンスし、引用を確認してからレポートに含めます。

<div align="center">

| カテゴリ | ソース |
|---------|--------|
| **生物医学文献** | PubMed、PubMed Central、Europe PMC |
| **総合学術** | Semantic Scholar、OpenAlex、CrossRef、CORE |
| **プレプリント** | bioRxiv、medRxiv、arXiv |
| **臨床** | ClinicalTrials.gov、WHO ICTRP |
| **特許・助成金** | Google Patents、NIH RePORTER |
| **総合検索** | Google Scholar、Web search |

</div>

---

## 🗄 データベースアクセス

<div align="center">
<img src="../../assets/database-ecosystem.png" width="700" alt="データベースエコシステム" />
</div>

<br />

9つの分野にわたる77以上のデータベース。すべて `bash` + `curl` 経由の公開REST APIでアクセス。

<div align="center">

| 分野 | データベース | 数 |
|------|-----------|-----|
| **ゲノミクス・トランスクリプトミクス** | NCBI Gene、Ensembl、UCSC Genome Browser、GEO、TCGA、GTEx、ENCODE | 10+ |
| **プロテオミクス・構造** | UniProt、PDB、AlphaFold DB、InterPro、Pfam、SWISS-MODEL | 8+ |
| **パスウェイ・相互作用** | STRING、BioGRID、KEGG、Reactome、WikiPathways、IntAct | 8+ |
| **薬理学・創薬** | ChEMBL、DrugBank、PubChem、PharmGKB、DGIdb、TTD | 8+ |
| **疾患・表現型** | OMIM、DisGeNET、ClinVar、GWAS Catalog、HPO、Orphanet | 8+ |
| **免疫学** | IEDB、IMGT、ImmPort、TIMER2.0、TCIA | 6+ |
| **マイクロバイオーム** | GMrepo、gutMDisorder、BugBase、MicrobiomeDB | 5+ |
| **臨床・疫学** | ClinicalTrials.gov、GBD、WHO GHO、SEER、cBioPortal | 7+ |
| **モデル生物** | MGI、FlyBase、WormBase、ZFIN、RGD、SGD | 7+ |

</div>

---

## 📚 266 ドメインスキル

<div align="center">
<img src="../../assets/skills-domains.png" width="550" alt="スキルドメイン" />
</div>

<br />

各スキルはMarkdownファイルで、モデルに特定の分析の *実行方法* を教えます — APIパターン、コードテンプレート、検証ステップを含む。

<div align="center">

| ドメイン | 数 | スキル |
|---------|-----|--------|
| **バイオインフォマティクス** | 30+ | `scanpy`、`anndata`、`pydeseq2`、`arboreto`、`biopython`、`deeptools`、`pysam` |
| **可視化** | 35+ | `matplotlib`、`seaborn`、`plotly`、`visualization`、`networkx` |
| **創薬** | 20+ | `chembl-database`、`rdkit`、`zinc-database`、`alphafold-database`、`adaptyv`、`medchem` |
| **臨床・生存** | 15+ | `clinicaltrials-database`、`scikit-survival`、`clinical`、`fda-database` |
| **シングルセル** | 10+ | `scanpy`、`scvi-tools`、`cellxgene-census`、`anndata` |
| **ゲノミクス** | 15+ | `gene-database`、`ensembl-database`、`gwas-database`、`clinvar-database`、`geo-database` |
| **データベース** | 20+ | `uniprot-database`、`pdb-database`、`string-database`、`opentargets-database`、`reactome-database` |
| **機械学習** | 10+ | `scikit-learn`、`shap`、`aeon`、`statistics`、`exploratory-data-analysis` |
| **科学論文執筆** | 15+ | `academic-literature-search`、`writing`、`review-writing`、`peer-review`、`venue-templates` |

</div>

---

## デプロイ

### ローカル（開発用に推奨）

[クイックスタート](#クイックスタート)で説明済み。

### Docker

```bash
docker compose -f docker/docker-compose.yml up
```

### クラウド

ワンクリックデプロイ：

<div align="center">

| プラットフォーム | デプロイ |
|---------------|---------|
| **Railway** | [![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template) |
| **Fly.io** | `fly launch` — [デプロイガイド](../guides/deployment.md#flyio) 参照 |

</div>

---

## コントリビュート

コントリビュートを歓迎します。Pull Request を提出する前に [CONTRIBUTING.md](../../CONTRIBUTING.md) をお読みください。

---

## 著者

**LIU Zaoqu**

International Academy of Phronesis Medicine (Guangdong) · π-HuB infrastructure

連絡先：[liuzaoqu@163.com](mailto:liuzaoqu@163.com)

---

## ライセンス

本プロジェクトは [MIT ライセンス](../../LICENSE) の下で公開されています。

---

<div align="center">

<br />

<img src="../../assets/ScienceClaw-Logo.png" width="120" alt="ScienceClaw Logo" />

<br />

**ScienceClaw** — ワンプロンプト。完全な遺伝子解析パイプライン。カスタムコードゼロ。

</div>
