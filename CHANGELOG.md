# Changelog

All notable changes to ScienceClaw will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.2.0] - 2026-03-07

### Added
- 264 domain skills covering bioinformatics, drug discovery, clinical analysis, and more
- Multi-model fallback support (primary + fallback chain)
- Telegram channel integration
- Docker sandbox for isolated code execution (Python 3.11, R, Julia)
- CI pipeline with lint, smoke tests, and security scanning
- Comprehensive documentation: architecture, configuration, skills guide, database reference
- i18n README translations (Chinese, Japanese, Korean)
- Case studies: THBS2 tumor analysis, LLM in biomedicine survey

### Changed
- Timeout increased from 1800s to 3600s for complex research tasks
- Skills path changed from absolute to relative (`./skills`)
- API keys moved from config to environment variables (`.env`)

### Security
- Removed all hardcoded API keys and tokens from tracked files
- Gateway auth token now sourced from `GATEWAY_AUTH_TOKEN` env var

## [0.1.0] - 2026-02-15

### Added
- Initial release
- Core agent prompt (`SCIENCE.md`)
- Literature search across PubMed, OpenAlex, Semantic Scholar, Europe PMC
- 77+ scientific database integrations via REST APIs
- Code execution sandbox (Python, R, Julia)
- Journal-quality visualization (NPG, Lancet, JCO, NEJM palettes)
- ScholarEval 8-dimension research quality rubric
- OpenClaw gateway wrapper script
