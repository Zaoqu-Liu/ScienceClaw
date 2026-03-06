<div align="center">

<img src="../../assets/hero-banner.png" width="800" alt="ScienceClaw Hero Banner" />

<br />

# ScienceClaw

**AI 연구 동료**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](../../LICENSE)
[![Skills](https://img.shields.io/badge/Skills-264+-orange.svg?style=for-the-badge)](../../README.md#-skills)
[![Databases](https://img.shields.io/badge/Databases-77+-green.svg?style=for-the-badge)](../../README.md#-database-access)
[![Search Sources](https://img.shields.io/badge/Search_Sources-15+-purple.svg?style=for-the-badge)](../../README.md#-deep-research)
[![Node](https://img.shields.io/badge/Node-22+-339933.svg?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)

[English](../../README.md) | [中文](README_ZH.md) | [日本語](README_JA.md) | **한국어**

</div>

---

ScienceClaw는 과학 연구 에이전트입니다. 문헌 검색, 데이터베이스 쿼리, 분석 실행, 그래프 생성, 보고서 작성을 수행합니다. 커스텀 코드 제로 — [OpenClaw](https://github.com/openclaw/openclaw) 위에 구축되어 하나의 Markdown 파일(`SCIENCE.md`, 약 200줄)과 264개의 도메인 스킬만으로 동작합니다. 모델이 99%의 작업을 수행하고, Markdown이 과학자가 되는 방법을 가르칩니다.

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

## 빠른 시작

### 사전 요구사항

<div align="center">

| 요구사항 | 버전 | 비고 |
|---------|------|------|
| Node.js | >= 22 | 필수 |
| Python | >= 3.10 | 코드 실행용 (R, Julia 선택 사항) |
| Docker | 최신 | 선택 사항 — 컨테이너 배포용 |

</div>

### 1단계 — 클론 및 설정

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git
cd ScienceClaw
cp .env.example .env        # API 키 추가
```

### 2단계 — 의존성 설치

```bash
bash scripts/setup.sh
```

### 3단계 — 실행

```bash
scienceclaw run              # 게이트웨이 시작 + TUI 자동 열기
```

이게 전부입니다. 명령어 하나.

원샷 모드 (TUI 없이):

```bash
scienceclaw ask "Search TREM2 in Alzheimer's disease and summarize recent findings"
```

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
| **웹 대시보드** | `scienceclaw openclaw dashboard` |
| **Telegram** | [설정 가이드](../channels/telegram.md) |
| **Discord** | [설정 가이드](../channels/discord.md) |
| **Slack** | [설정 가이드](../channels/slack.md) |
| **Feishu / Lark** | [설정 가이드](../channels/feishu.md) |
| **WeChat** | [설정 가이드](../channels/wechat.md) |
| **WhatsApp** | [설정 가이드](../channels/whatsapp.md) |
| **Matrix** | [설정 가이드](../channels/matrix.md) |
| + 기타 | `scienceclaw openclaw channels --help` |

</div>

---

## 아키텍처

<div align="center">
<img src="../../assets/architecture.png" width="700" alt="ScienceClaw 아키텍처" />
</div>

<br />

```
ScienceClaw = OpenClaw + SCIENCE.md + 264개 스킬
```

TypeScript 없음. Python 서버 없음. MCP 없음. 플러그인 없음. 모델이 모든 것을 수행.

<div align="center">

| 레이어 | 컴포넌트 |
|-------|---------|
| **사용자** | 터미널 UI, 웹 대시보드, Telegram, Discord, Slack, Feishu, WeChat, WhatsApp, Matrix |
| **게이트웨이** | OpenClaw 게이트웨이 — 메시지 라우팅, 세션 관리, 도구 호출 |
| **에이전트** | 단일 `ScienceClaw` 에이전트: `SCIENCE.md` (약 200줄) + 264 도메인 스킬 |
| **인프라** | `web_search`, `web_fetch`, `bash` — OpenClaw 내장 3개 도구로 모든 것을 실현 |

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

9개 분야에 걸친 77개 이상의 데이터베이스. 모두 `web_fetch`를 통한 공개 API로 접근.

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

## 📚 스킬

<div align="center">
<img src="../../assets/skills-domains.png" width="550" alt="스킬 도메인" />
</div>

<br />

264개의 도메인 스킬이 특정 기법에 대한 상세한 가이던스를 제공합니다. 각 스킬은 하나의 Markdown 파일로, 모델에게 특정 분석의 *수행 방법*을 가르칩니다.

<div align="center">

| 도메인 | 스킬 예시 |
|-------|---------|
| **생물정보학** | 차등 발현, 유전자 세트 풍부화, 경로 분석, 네트워크 구축 |
| **단일 세포** | 클러스터링, 궤적 추론, 세포 유형 주석, RNA velocity |
| **생존 분석** | Kaplan-Meier 곡선, Cox 회귀, 포레스트 플롯, 노모그램 |
| **시각화** | 화산 플롯, 히트맵, 맨해튼 플롯, Circos 플롯, UMAP/tSNE |
| **약물 발견** | 타겟 식별, 분자 도킹, ADMET 예측, 약물 재배치 |
| **임상** | 메타분석, 진단 검사 평가, 위험 요인 분석, 멘델 무작위화 |
| **유전체학** | 변이 주석, GWAS 분석, 복제수 변이, 돌연변이 시그니처 |
| **면역학** | 면역 침윤, 신항원 예측, TCR/BCR 레퍼토리 분석 |
| **머신러닝** | 특성 선택, 모델 훈련, 교차 검증, SHAP 해석 |

</div>

---

## 배포

### 로컬 (개발용 권장)

[빠른 시작](#빠른-시작)에서 설명 완료.

### Docker

```bash
docker-compose up
```

### 클라우드

원클릭 배포:

<div align="center">

| 플랫폼 | 배포 |
|-------|------|
| **Railway** | [![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template) |
| **Fly.io** | `fly launch` — [docs/deploy/fly.md](../deploy/fly.md) 참조 |

</div>

---

## 기여

기여를 환영합니다. Pull Request를 제출하기 전에 [CONTRIBUTING.md](../../CONTRIBUTING.md)를 읽어주세요.

---

## 저자

**LIU Zaoqu**

International Academy of Phronesis Medicine (Guangdong) · [π-HuB infrastructure](https://github.com/pi-HuB)

연락처: [liuzaoqu@163.com](mailto:liuzaoqu@163.com)

---

## 라이선스

이 프로젝트는 [MIT 라이선스](../../LICENSE) 하에 배포됩니다.

---

<div align="center">

<br />

<img src="../../assets/ScienceClaw-Logo.png" width="120" alt="ScienceClaw Logo" />

<br />

**ScienceClaw** — AI 연구 동료.

</div>
