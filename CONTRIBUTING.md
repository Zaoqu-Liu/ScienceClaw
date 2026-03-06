# Contributing to ScienceClaw

Thank you for your interest in contributing to ScienceClaw! This guide will help you get started.

## How to contribute

1. **Fork** the repository and create a feature branch.
2. **Make your changes** following the guidelines below.
3. **Submit a pull request** with a clear description of what you changed and why.

## Adding a new skill

Skills are the core building blocks of ScienceClaw. To add a new skill:

1. Create a new folder under `skills/` with a descriptive name (e.g., `skills/my-new-skill/`).
2. Add a `SKILL.md` file inside the folder with the following frontmatter format:

```markdown
---
name: My New Skill
description: A brief description of what this skill does.
category: analysis
tags: [statistics, data]
---

Detailed instructions for the AI agent on how to use this skill.
```

3. Include any supporting files (templates, scripts) in the same folder.
4. Run the smoke tests to verify everything works: `bash tests/smoke_test.sh`

## Reporting bugs

Found a bug? Please [open a bug report](../../issues/new?template=bug_report.yml) using our issue template. Include steps to reproduce, expected behavior, and any relevant logs.

## Development setup

```bash
# Clone the repository
git clone https://github.com/sogen-ai/scienceclaw.git
cd scienceclaw

# Install dependencies
npm install

# Verify your setup
bash tests/smoke_test.sh

# Run ScienceClaw
./scienceclaw
```

## Code of conduct

- Be respectful and constructive in all interactions.
- Welcome newcomers and help them get oriented.
- Focus on the work — critique ideas, not people.
- If you see something wrong, say something. If you're unsure, ask.

## License

By contributing to ScienceClaw, you agree that your contributions will be licensed under the [MIT License](LICENSE).
