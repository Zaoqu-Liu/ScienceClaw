<div align="center">

<img src="../../assets/hero-banner.png" width="800" alt="ScienceClaw Hero Banner" />

<br />

# ScienceClaw

**하나의 프롬프트. 완전한 유전자 분석 파이프라인. 커스텀 코드 제로.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](../../LICENSE)
[![Skills](https://img.shields.io/badge/Domain_Skills-266-orange.svg?style=for-the-badge)](#-266-도메인-스킬)
[![Databases](https://img.shields.io/badge/Databases-77+-green.svg?style=for-the-badge)](../../README.md#-database-access)
[![Search Sources](https://img.shields.io/badge/Search_Sources-15+-purple.svg?style=for-the-badge)](../../README.md#-deep-research)
[![Code](https://img.shields.io/badge/Custom_Code-0_lines-E64B35.svg?style=for-the-badge)](#아키텍처)

[English](../../README.md) | [中文](README_ZH.md) | [日本語](README_JA.md) | **한국어**

</div>

---

ScienceClaw는 과학 연구 AI 에이전트입니다. `"TP53의 간암에서의 역할 분석"`이라고 입력하면, 15개 이상의 문헌 소스를 자율적으로 검색하고, 77개 이상의 데이터베이스를 쿼리하고, R에서 생존 분석을 실행하고, 저널 품질의 그래프를 생성하고, 실제 인용이 포함된 완전한 보고서를 제공합니다 — 조작 없음, 환각 없음.

커스텀 코드 제로. [OpenClaw](https://github.com/openclaw/openclaw) 위에 구축되어 하나의 Markdown 파일([`SCIENCE.md`](../../SCIENCE.md), 약 600줄)과 266개의 도메인 스킬만으로 동작합니다. 모델이 99%의 작업을 수행하고, Markdown이 과학자가 되는 방법을 가르칩니다.

---

## 실제 동작 예시

### 케이스 1 — 종양에서 THBS2의 역할과 의미 조사

> **프롬프트:** *"Investigate the role and significance of THBS2 in tumors"*

ScienceClaw는 자율적으로 PubMed를 검색하고, cBioPortal과 TIMER2.0을 통해 TCGA 데이터를 쿼리하고, R에서 생존 분석을 실행하여 87개의 인용이 포함된 30페이지 보고서를 작성했습니다.

**주요 발견:**

- THBS2는 **33개 TCGA 암종 중 17개**에서 유의하게 상향 조절
- THBS2 + CA19-9 복합 진단 패널이 후향적 췌장암 코호트에서 AUC **0.96** 달성 — 그러나 전향적 검증 세트에서 **0.69**로 하락
- 종양 미세환경 분석에서 여러 암종에서 THBS2와 M2 대식세포 침윤의 상관관계 확인

[전체 케이스 스터디 읽기 &rarr;](../cases/case-thbs2-tumor.md)

---

### 케이스 2 — 바이오메디슨에서 LLM 응용 조사

> **프롬프트:** *"Survey the applications of LLM in biomedicine"*

ScienceClaw는 PubMed, Semantic Scholar, OpenAlex에서 체계적 문헌 검색을 수행하고, 추세 분석과 시각화를 포함한 구조화된 서베이로 정리했습니다.

**주요 발견:**

- 의료 LLM 논문이 2년 동안 **570배** 증가 — 2022년 8편에서 2024년 4,562편으로
- Med-PaLM 2가 USMLE에서 **86.5%** 정확도 달성, 전문의 기준점 초과
- 헬스케어 LLM 시장은 2030년까지 **$110B** 도달 전망

[전체 케이스 스터디 읽기 &rarr;](../cases/case-llm-biomedicine.md)

---

### 케이스 3 — 리서치 레시피: 원라이너에서 풀 파이프라인까지

> **프롬프트:** *"分析 TP53 在肝癌中的作用"*

ScienceClaw는 **gene-landscape** 레시피를 자동 매칭하고 6단계 파이프라인을 자율 실행: 문헌 검색 → TCGA 발현 프로파일링 → 생존 분석 → 면역 침윤 → 경로 풍부화 → METHODS.md 포함 구조화 보고서.

<!-- TODO: add GIF/screenshot of Recipe execution -->

모든 출력 파일은 `~/.scienceclaw/workspace/projects/tp53-liver-cancer-<date>/`에 저장되며, 명령 하나로 내보내기: `/export word`, `/export pptx`, `/export latex`.

[6개 리서치 레시피 모두 보기 &rarr;](#리서치-레시피)

---

## 빠른 시작

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git && cd ScienceClaw
bash scripts/setup.sh       # 의존성 설치, API 키 설정 (대화식)
./scienceclaw run            # 게이트웨이 시작 + TUI 열기 — 완료
```

> **중국 사용자:** [DeepSeek](https://platform.deepseek.com/) 추천 — 직접 접속, 프록시 불필요. 또는 [OpenRouter](https://openrouter.ai/)를 릴레이로 사용.

---

## 기능 개요

<div align="center">

| 기능 | 상세 |
|------|------|
| **문헌 검색** | 15개 이상의 소스 — PubMed, Semantic Scholar, OpenAlex, Europe PMC 등 |
| **데이터베이스 쿼리** | 77개 이상의 DB — UniProt, PDB, NCBI, ChEMBL, STRING, GTEx, ClinicalTrials.gov 등 |
| **코드 실행** | bash를 통해 Python, R, Julia — 패키지 즉시 설치 |
| **그래프 생성** | 저널 사양 색상 팔레트 (NPG, Lancet, JCO, NEJM), 출판 품질 크기 |
| **보고서 작성** | 검색 결과에서 실제 인용, 절대 조작하지 않음 |
| **연구 리뷰** | 8차원 ScholarEval 루브릭으로 체계적 품질 평가 |
| **리서치 레시피** | 6개 프리빌트 워크플로우 — 유전자 랜드스케이프, 타겟 검증, 문헌 리뷰 등 |
| **결과물 내보내기** | 프로젝트 결과를 Word, PowerPoint, LaTeX로 한 번에 내보내기 |
| **문헌 모니터링** | `/watch`로 PubMed 주제 추적, 세션 시작 시 신규 논문 알림 |

</div>

---

## 리서치 레시피

6개의 프리빌트 연구 워크플로우. 단일 프롬프트로 완전한 멀티스텝 분석을 실행.

<div align="center">

| 레시피 | 트리거 예시 | 실행 내용 |
|--------|----------|----------|
| **gene-landscape** | "TP53의 간암에서의 역할 분석" | 문헌 → TCGA 발현 → 생존 → 면역 → 경로 → 보고서 |
| **target-validation** | "EGFR의 약물 가능성 평가" | 문헌 → STRING → ChEMBL → DrugBank → 임상시험 → 특허 → 보고서 |
| **literature-review** | "유전자 치료에서 CRISPR 총설" | 멀티소스 50+ → 필터 → 전문 → 트렌드 → 구조화 리뷰 |
| **diff-expression** | "이 발현 매트릭스 분석" | QC → DESeq2/limma → 화산 플롯 + 히트맵 → GO/KEGG → 보고서 |
| **clinical-query** | "NSCLC 최신 치료 방법" | ClinicalTrials → 가이드라인 → 약물 → 요약 테이블 |
| **person-research** | "김교수 리서치" | OpenAlex → PubMed → 인용 → 테마 → 프로필 보고서 |

</div>

---

## 이번 릴리스의 새 기능

<div align="center">

| 기능 | 설명 |
|------|------|
| **리서치 레시피** | 6개 원라이너→풀 워크플로우 템플릿 (위 참조) |
| **Word/PPT/LaTeX 내보내기** | `/export word`, `/export pptx`, `/export latex` — 프로젝트 결과에서 포맷된 문서 생성 |
| **문헌 모니터링** | `/watch TOPIC` — PubMed 신규 논문 추적, 세션 시작 시 알림 |
| **연구 메모리** | 구조화된 발견을 JSONL에 저장 — 세션/프로젝트 간 `/recall`로 호출 |
| **METHODS.md** | 심층 분석 후 Methods 섹션 자동 생성, 논문에 바로 삽입 가능 |
| **스마트 태스크 라우팅** | 간단한 태스크(단일 조회)는 채팅에 유지; 심층 태스크는 프로젝트 디렉터리 생성 |
| **후속 제안** | 모든 멀티스텝 분석 후 데이터 기반 다음 단계 제안 |
| **CLI `recipes` / `ask`** | `./scienceclaw recipes`로 브라우즈, `./scienceclaw ask "..."`로 원샷 쿼리 |

</div>

---

## 채널 통합

<div align="center">
<img src="../../assets/channels-overview.png" width="700" alt="채널 통합 개요" />
</div>

<br />

ScienceClaw는 OpenClaw의 모든 채널 통합을 상속합니다. 선호하는 인터페이스로 연결:

<div align="center">

| 채널 | 사용 방법 |
|------|----------|
| **터미널 UI** | `scienceclaw tui` |
| **웹 대시보드** | `scienceclaw dashboard` |
| **Telegram** | [설정 가이드](../channels/telegram.md) |
| **Discord** | [설정 가이드](../channels/discord.md) |
| **Slack** | [설정 가이드](../channels/slack.md) |
| **Feishu / Lark** | [설정 가이드](../channels/feishu.md) |
| **WeChat** | [설정 가이드](../channels/wechat.md) |
| **WhatsApp** | [설정 가이드](../channels/whatsapp.md) |
| **Matrix** | [설정 가이드](../channels/matrix.md) |
| + 기타 | `scienceclaw channels --help` |

</div>

---

## 아키텍처

<div align="center">
<img src="../../assets/architecture.png" width="700" alt="ScienceClaw 아키텍처" />
</div>

<br />

```
ScienceClaw = OpenClaw 엔진 + SCIENCE.md (~600줄) + 266 스킬 (마크다운)
            = 0줄의 커스텀 코드
```

TypeScript 없음. Python 서버 없음. MCP 없음. 플러그인 없음. 미들웨어 없음. `scienceclaw` bash 래퍼(~130줄)가 게이트웨이 생명주기를 관리합니다. 나머지는 모델에게 과학자가 되는 방법을 가르치는 마크다운입니다.

<div align="center">

| 레이어 | 컴포넌트 |
|-------|---------|
| **사용자** | 터미널 UI, 웹 대시보드, Telegram, Discord, Slack, Feishu, WeChat, WhatsApp, Matrix |
| **게이트웨이** | OpenClaw 게이트웨이 — 메시지 라우팅, 세션 관리, 도구 호출 (포트 18789) |
| **에이전트** | `SCIENCE.md` (정체성 + 연구 규율) + 266 도메인 스킬 (수요 시 로드) |
| **도구** | `web_search` (Brave), `bash` (Python/R/Julia + REST API용 curl) — 두 도구로 모든 것 수행 |

</div>

---

## 🔍 딥 리서치

<div align="center">
<img src="../../assets/search-sources.png" width="700" alt="검색 소스" />
</div>

<br />

ScienceClaw는 15개 이상의 소스에서 검색하고, 결과를 교차 참조하고, 인용을 확인한 후 보고서에 포함합니다.

<div align="center">

| 카테고리 | 소스 |
|---------|------|
| **생물의학 문헌** | PubMed, PubMed Central, Europe PMC |
| **종합 학술** | Semantic Scholar, OpenAlex, CrossRef, CORE |
| **프리프린트** | bioRxiv, medRxiv, arXiv |
| **임상** | ClinicalTrials.gov, WHO ICTRP |
| **특허 및 보조금** | Google Patents, NIH RePORTER |
| **종합 검색** | Google Scholar, Web search |

</div>

---

## 🗄 데이터베이스 접근

<div align="center">
<img src="../../assets/database-ecosystem.png" width="700" alt="데이터베이스 생태계" />
</div>

<br />

9개 분야에 걸친 77개 이상의 데이터베이스. 모두 `bash` + `curl`를 통한 공개 REST API로 접근.

<div align="center">

| 분야 | 데이터베이스 | 수 |
|------|-----------|-----|
| **유전체학 및 전사체학** | NCBI Gene, Ensembl, UCSC Genome Browser, GEO, TCGA, GTEx, ENCODE | 10+ |
| **단백질체학 및 구조** | UniProt, PDB, AlphaFold DB, InterPro, Pfam, SWISS-MODEL | 8+ |
| **경로 및 상호작용** | STRING, BioGRID, KEGG, Reactome, WikiPathways, IntAct | 8+ |
| **약리학 및 약물 발견** | ChEMBL, DrugBank, PubChem, PharmGKB, DGIdb, TTD | 8+ |
| **질환 및 표현형** | OMIM, DisGeNET, ClinVar, GWAS Catalog, HPO, Orphanet | 8+ |
| **면역학** | IEDB, IMGT, ImmPort, TIMER2.0, TCIA | 6+ |
| **마이크로바이옴** | GMrepo, gutMDisorder, BugBase, MicrobiomeDB | 5+ |
| **임상 및 역학** | ClinicalTrials.gov, GBD, WHO GHO, SEER, cBioPortal | 7+ |
| **모델 생물** | MGI, FlyBase, WormBase, ZFIN, RGD, SGD | 7+ |

</div>

---

## 📚 266 도메인 스킬

<div align="center">
<img src="../../assets/skills-domains.png" width="550" alt="스킬 도메인" />
</div>

<br />

각 스킬은 마크다운 파일로, 모델에게 특정 분석의 *수행 방법*을 가르칩니다 — API 패턴, 코드 템플릿, 검증 단계 포함.

<div align="center">

| 도메인 | 수 | 스킬 |
|--------|-----|------|
| **생물정보학** | 30+ | `scanpy`, `anndata`, `pydeseq2`, `arboreto`, `biopython`, `deeptools`, `pysam` |
| **시각화** | 35+ | `matplotlib`, `seaborn`, `plotly`, `visualization`, `networkx` |
| **약물 발견** | 20+ | `chembl-database`, `rdkit`, `zinc-database`, `alphafold-database`, `adaptyv`, `medchem` |
| **임상 및 생존** | 15+ | `clinicaltrials-database`, `scikit-survival`, `clinical`, `fda-database` |
| **단일 세포** | 10+ | `scanpy`, `scvi-tools`, `cellxgene-census`, `anndata` |
| **유전체학** | 15+ | `gene-database`, `ensembl-database`, `gwas-database`, `clinvar-database`, `geo-database` |
| **데이터베이스** | 20+ | `uniprot-database`, `pdb-database`, `string-database`, `opentargets-database`, `reactome-database` |
| **머신러닝** | 10+ | `scikit-learn`, `shap`, `aeon`, `statistics`, `exploratory-data-analysis` |
| **과학 글쓰기** | 15+ | `academic-literature-search`, `writing`, `review-writing`, `peer-review`, `venue-templates` |

</div>

---

## 배포

### 로컬 (개발용 권장)

[빠른 시작](#빠른-시작)에서 설명 완료.

### Docker

```bash
docker compose -f docker/docker-compose.yml up
```

### 클라우드

원클릭 배포:

<div align="center">

| 플랫폼 | 배포 |
|-------|------|
| **Railway** | [![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template) |
| **Fly.io** | `fly launch` — [배포 가이드](../guides/deployment.md#flyio) 참조 |

</div>

---

## 기여

기여를 환영합니다. Pull Request를 제출하기 전에 [CONTRIBUTING.md](../../CONTRIBUTING.md)를 읽어주세요.

---

## 저자

**LIU Zaoqu**

International Academy of Phronesis Medicine (Guangdong) · π-HuB infrastructure

연락처: [liuzaoqu@163.com](mailto:liuzaoqu@163.com)

---

## 라이선스

이 프로젝트는 [MIT 라이선스](../../LICENSE) 하에 배포됩니다.

---

<div align="center">

<br />

<img src="../../assets/ScienceClaw-Logo.png" width="120" alt="ScienceClaw Logo" />

<br />

**ScienceClaw** — 하나의 프롬프트. 완전한 유전자 분석 파이프라인. 커스텀 코드 제로.

</div>
