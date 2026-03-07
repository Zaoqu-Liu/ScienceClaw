<div align="center">

<img src="../../assets/hero-banner.png" width="800" alt="ScienceClaw Hero Banner" />

<br />

# ScienceClaw

**あなたのAI研究パートナー**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](../../LICENSE)
[![Skills](https://img.shields.io/badge/Skills-264+-orange.svg?style=for-the-badge)](../../README.md#-skills)
[![Databases](https://img.shields.io/badge/Databases-77+-green.svg?style=for-the-badge)](../../README.md#-database-access)
[![Search Sources](https://img.shields.io/badge/Search_Sources-15+-purple.svg?style=for-the-badge)](../../README.md#-deep-research)
[![Node](https://img.shields.io/badge/Node-22+-339933.svg?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)

[English](../../README.md) | [中文](README_ZH.md) | **日本語** | [한국어](README_KO.md)

</div>

---

ScienceClaw は科学研究エージェントです。文献検索、データベースクエリ、分析実行、図表作成、レポート作成を行います。カスタムコードゼロ — [OpenClaw](https://github.com/openclaw/openclaw) 上に構築され、1つのMarkdownファイル（`SCIENCE.md`、約200行）と264のドメインスキルのみで動作します。モデルが99%の作業を実行し、Markdownが科学者としての振る舞いを教えます。

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

## クイックスタート

### 前提条件

<div align="center">

| 要件 | バージョン | 備考 |
|------|-----------|------|
| Node.js | >= 22 | 必須 |
| Python | >= 3.10 | コード実行用（R、Juliaはオプション） |
| Docker | 最新版 | オプション — コンテナ化デプロイ用 |

</div>

### ステップ1 — クローンと設定

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git
cd ScienceClaw
cp .env.example .env        # APIキーを追加
```

### ステップ2 — 依存関係のインストール

```bash
bash scripts/setup.sh
```

### ステップ3 — 実行

```bash
scienceclaw run              # ゲートウェイ起動 + TUI表示を自動実行
```

以上です。1コマンドだけ。

ワンショットモード（TUI不要）：

```bash
scienceclaw ask "Search TREM2 in Alzheimer's disease and summarize recent findings"
```

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
ScienceClaw = OpenClaw + SCIENCE.md + 264スキル
```

TypeScriptなし。Pythonサーバーなし。MCPなし。プラグインなし。モデルがすべてを実行。

<div align="center">

| レイヤー | コンポーネント |
|---------|-------------|
| **ユーザー** | ターミナルUI、Webダッシュボード、Telegram、Discord、Slack、Feishu、WeChat、WhatsApp、Matrix |
| **ゲートウェイ** | OpenClaw ゲートウェイ — メッセージルーティング、セッション管理、ツールコール |
| **エージェント** | 単一の `ScienceClaw` エージェント：`SCIENCE.md`（約200行）+ 264ドメインスキル |
| **インフラ** | `web_search`、`web_fetch`、`bash` — OpenClaw内蔵の3つのツールですべてを実現 |

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

9つの分野にわたる77以上のデータベース。すべて `web_fetch` 経由の公開APIでアクセス。

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

## 📚 スキル

<div align="center">
<img src="../../assets/skills-domains.png" width="550" alt="スキルドメイン" />
</div>

<br />

264のドメインスキルが特定の技術に関する詳細なガイダンスを提供。各スキルは1つのMarkdownファイルで、モデルに特定の分析の *実行方法* を教えます。

<div align="center">

| ドメイン | スキル例 |
|---------|---------|
| **バイオインフォマティクス** | 差次的発現、遺伝子セット富化、パスウェイ解析、ネットワーク構築 |
| **シングルセル** | クラスタリング、軌道推定、細胞タイプアノテーション、RNA velocity |
| **生存分析** | Kaplan-Meier曲線、Cox回帰、フォレストプロット、ノモグラム |
| **可視化** | 火山プロット、ヒートマップ、マンハッタンプロット、Circosプロット、UMAP/tSNE |
| **創薬** | ターゲット同定、分子ドッキング、ADMET予測、ドラッグリポジショニング |
| **臨床** | メタアナリシス、診断検査評価、リスクファクター解析、メンデルランダム化 |
| **ゲノミクス** | バリアントアノテーション、GWAS解析、コピー数変動、変異シグネチャー |
| **免疫学** | 免疫浸潤、ネオアンチゲン予測、TCR/BCRレパトア解析 |
| **機械学習** | 特徴選択、モデル訓練、交差検証、SHAP解釈 |

</div>

---

## デプロイ

### ローカル（開発用に推奨）

[クイックスタート](#クイックスタート)で説明済み。

### Docker

```bash
docker-compose up
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

**ScienceClaw** — あなたのAI研究パートナー。

</div>
