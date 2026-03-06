# ScienceClaw

**AI 연구 동료.**

커스텀 코드 제로. 순수 컨텍스트 엔지니어링. [OpenClaw](https://github.com/openclaw/openclaw) 기반.

[English](../../README.md) | [中文](README_ZH.md) | [日本語](README_JA.md) | 한국어

---

## 개요

ScienceClaw는 과학 연구 에이전트입니다. 문헌 검색, 데이터베이스 쿼리, 분석 실행, 그래프 생성, 보고서 작성을 수행합니다. OpenClaw에 내장된 세 가지 도구(`web_search`, `web_fetch`, `bash`)만 사용합니다.

제품의 핵심은 하나의 파일: `SCIENCE.md`. 이 파일이 모델에게 과학자가 되는 방법을 가르칩니다. 어떤 API를 쿼리할지, 결과를 어떻게 검증할지, 자체 출력을 언제 의심할지, 올바르게 인용하는 방법 등을 포함합니다.

264개의 도메인 스킬이 특정 기술에 대한 전문 지식을 제공합니다 (단일 세포 분석, 생존 곡선, 약물 발견 등).

## 아키텍처

```
ScienceClaw = OpenClaw + SCIENCE.md + 264개 스킬
```

TypeScript 없음. Python 서버 없음. MCP 없음. 플러그인 없음. 모델이 99%의 작업을 수행합니다.

---

## 빠른 시작

### 사전 요구사항

- Node.js 22 이상
- pnpm
- LLM API 키 최소 1개 (OpenAI / Claude / Gemini)

### 설치

```bash
# 저장소 클론 (openclaw과 scienceclaw는 같은 레벨에 배치)
git clone https://github.com/openclaw/openclaw.git
git clone https://github.com/Zaoqu-Liu/scienceclaw.git

# 설정
cd scienceclaw
bash scripts/setup.sh
```

### 실행

```bash
# 한 명령어로 시작 (게이트웨이 시작 + TUI 열기)
./scienceclaw run
```

또는 두 개의 터미널에서:

```bash
# 터미널 1: 게이트웨이 시작
./scienceclaw start

# 터미널 2: TUI 열기
./scienceclaw tui
```

### 사용해 보기

TUI에서 연구 질문을 입력하세요:

```
Search for recent papers on CRISPR base editing in sickle cell disease
```

에이전트가 자동으로 PubMed, OpenAlex 등을 검색하고, 실제 인용이 포함된 연구 요약을 반환합니다.

---

## 주요 기능

### 문헌 검색
PubMed, OpenAlex, Semantic Scholar, Europe PMC, bioRxiv, medRxiv, arXiv에서 학술 문헌을 검색합니다.

### 데이터베이스 쿼리
**77개 이상의 과학 데이터베이스**를 직접 쿼리:

| 카테고리 | 데이터베이스 |
|---------|------------|
| 유전체학 | NCBI Gene, Ensembl, GTEx, GEO, ClinVar, GWAS Catalog |
| 단백질체학 | UniProt, PDB, AlphaFold, STRING |
| 화학 및 약물 | ChEMBL, PubChem, DrugBank, ZINC, Open Targets |
| 임상 | ClinicalTrials.gov, ClinVar, FDA |
| 경로 | KEGG, Reactome, Enrichr |
| 문헌 | PubMed, OpenAlex, Semantic Scholar |

### 코드 실행
`bash`를 통해 Python, R, Julia 코드를 직접 실행하여 데이터 분석을 수행합니다.

### 그래프 생성
저널 사양에 맞는 출판 품질의 그래프 생성:
- 저널 색상 팔레트: NPG, Lancet, JCO, NEJM
- 크기 프리셋: 단일 열 (8.5×7cm), 이중 열 (17.5×10cm)
- 300+ DPI

### 보고서 작성
검색 결과를 기반으로 연구 보고서를 작성합니다. 모든 인용은 실제 검색 결과에서 가져오며, 절대 조작하지 않습니다.

### 연구 리뷰
8차원 ScholarEval 평가 프레임워크로 연구 품질을 평가: 신규성, 엄밀성, 명확성, 재현성, 영향력, 일관성, 한계 인식, 윤리.

---

## 스킬 라이브러리

264개의 도메인 스킬이 10개 이상의 분야를 커버:

| 분야 | 스킬 수 | 예시 |
|------|---------|-----|
| 문헌 및 검색 | 20+ | pubmed-search, openalex-database, arxiv-search |
| 유전체학 및 생물정보학 | 30+ | gene-database, scanpy, bioinformatics |
| 단백질체학 | 15+ | uniprot-database, pdb-database, alphafold-database |
| 화학 및 약물 발견 | 20+ | chembl-database, rdkit, drug-discovery-search |
| 임상 및 의학 | 15+ | clinicaltrials-database, clinical, treatment-plans |
| 데이터 분석 및 시각화 | 30+ | statistics, matplotlib, scikit-learn |
| 과학 글쓰기 | 15+ | scientific-writing, review-writing, peer-review |
| 재료 및 지구과학 | 10+ | materials, pymatgen, astropy |
| ToolUniverse 통합 | 50+ | 전문 생물정보학 워크플로우 API |

---

## 설계 철학

[에이전틱 프로덕트 디자인](https://docs.openclaw.ai)에서:

- **쓰라린 교훈**: 스캐폴딩 없음. 모델이 `web_fetch`로 PubMed에 직접 쿼리. 중간 계층 없음.
- **6개월 규칙**: 노후화되는 코드 제로. 모델이 개선되어도 삭제할 것이 없음.
- **가장 얇은 래퍼**: TypeScript 0줄. Markdown 약 224줄. 나머지는 모델이 담당.

---

## 프로젝트 구조

```
scienceclaw/
  scienceclaw              # bash 래퍼 (openclaw에 위임)
  SCIENCE.md               # 에이전트의 두뇌 (약 224줄)
  openclaw.config.json     # 설정 파일
  skills/                  # 264개 도메인 스킬
  scripts/setup.sh         # 설정 스크립트
```

---

## 문서

- [설치 가이드](../getting-started/installation.md)
- [빠른 시작](../getting-started/quickstart.md)
- [설정 레퍼런스](../getting-started/configuration.md)
- [배포 가이드](../guides/deployment.md)
- [스킬 가이드](../guides/skills.md)
- [데이터베이스 레퍼런스](../guides/databases.md)
- [문제 해결](../guides/troubleshooting.md)
- [아키텍처](../architecture/ARCHITECTURE.md)

---

## 저자

[LIU Zaoqu](https://github.com/Zaoqu-Liu)

## 라이선스

[MIT](../../LICENSE)
