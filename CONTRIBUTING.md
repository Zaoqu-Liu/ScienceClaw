# Contributing to ScienceClaw

Thank you for your interest in contributing to ScienceClaw! This guide will help you get started.

## How to contribute

1. **Fork** the repository and create a feature branch.
2. **Make your changes** following the guidelines below.
3. **Submit a pull request** with a clear description of what you changed and why.

## Adding a new skill

Skills are the core building blocks of ScienceClaw. To add a new skill:

1. Create a new folder under `skills/` with a descriptive name (e.g., `skills/my-new-skill/`).
2. Add a `SKILL.md` file inside the folder. Use the YAML frontmatter format:

```markdown
---
name: my-new-skill
description: A brief description of what this skill does and when to use it.
keywords:
  - keyword1
  - keyword2
license: MIT
---

# My New Skill

Brief overview of the skill's purpose. Use when [trigger conditions].

## When to Use

- When the user asks about [topic]
- When the task involves [specific technique]

## Key Resources

- **API Endpoint**: https://example.com/api/v1/...
- **Documentation**: https://docs.example.com

## Workflow

1. First, do X
2. Then, query Y with parameters Z
3. Verify results by checking W

## Code Templates

### Python Example

\`\`\`python
import requests

response = requests.get("https://api.example.com/query", params={
    "term": "QUERY",
    "format": "json"
})
data = response.json()
\`\`\`

## Common Pitfalls

- Pitfall 1: description and how to avoid

## Quality Checks

- Verify: condition 1
- Verify: condition 2
```

3. Include any supporting files (templates, scripts) in the same folder.
4. Run the smoke tests to verify everything works: `bash tests/smoke_test.sh`

## Reporting bugs

Found a bug? Please [open a bug report](https://github.com/Zaoqu-Liu/ScienceClaw/issues/new?template=bug_report.yml) using our issue template. Include steps to reproduce, expected behavior, and any relevant logs.

## Development setup

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git
cd ScienceClaw

# pnpm is required (npm install -g pnpm if you don't have it)
bash scripts/setup.sh

bash tests/smoke_test.sh

./scienceclaw run
```

## Code of conduct

- Be respectful and constructive in all interactions.
- Welcome newcomers and help them get oriented.
- Focus on the work — critique ideas, not people.
- If you see something wrong, say something. If you're unsure, ask.

## License

By contributing to ScienceClaw, you agree that your contributions will be licensed under the [MIT License](LICENSE).
