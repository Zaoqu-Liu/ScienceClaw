# Installation

This guide walks you through installing ScienceClaw from scratch.

---

## System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **Node.js** | 22.12.0+ | Latest LTS (22.x) |
| **Python** | 3.10+ | 3.12+ |
| **pnpm** | 9.0+ | Latest |
| **OS** | macOS 13+, Ubuntu 22.04+, Windows (WSL2) | macOS or Linux |
| **Docker** | 24.0+ (optional, for sandbox) | Latest |
| **RAM** | 4 GB | 8 GB+ |
| **Disk** | 500 MB | 2 GB (with Python packages) |

### Verify Prerequisites

```bash
node -v        # Should print v22.x.x or higher
python3 -V     # Should print Python 3.10+
pnpm -v        # Should print 9.x+
```

If Node.js is not installed or is too old:

```bash
# macOS (Homebrew)
brew install node@22

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Any platform (nvm)
nvm install 22
nvm use 22
```

If pnpm is not installed:

```bash
npm install -g pnpm
```

---

## Step 1: Clone and Configure

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git
cd ScienceClaw
cp .env.example .env        # add your API keys
```

Edit `.env` with your preferred editor. You need **at least one LLM provider** configured.

### Option A: Direct API Access

Use your API keys directly with the official provider endpoints:

```bash
# OpenAI
OPENAI_API_KEY=sk-your-openai-key
OPENAI_BASE_URL=https://api.openai.com/v1

# Anthropic (Claude)
CLAUDE_API_KEY=sk-ant-your-claude-key
CLAUDE_BASE_URL=https://api.anthropic.com/v1

# Google (Gemini)
GEMINI_API_KEY=your-gemini-key
GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta
```

### Option B: Relay via yunwu.ai (Recommended for China)

Use a single API key to access all providers through an OpenAI-compatible relay:

```bash
OPENAI_API_KEY=sk-your-relay-key
OPENAI_BASE_URL=https://yunwu.ai/v1
CLAUDE_API_KEY=sk-your-relay-key
CLAUDE_BASE_URL=https://yunwu.ai/v1
GEMINI_API_KEY=sk-your-relay-key
GEMINI_BASE_URL=https://yunwu.ai/v1
```

### Option C: OpenRouter

```bash
OPENAI_API_KEY=sk-or-your-openrouter-key
OPENAI_BASE_URL=https://openrouter.ai/api/v1
CLAUDE_API_KEY=sk-or-your-openrouter-key
CLAUDE_BASE_URL=https://openrouter.ai/api/v1
GEMINI_API_KEY=sk-or-your-openrouter-key
GEMINI_BASE_URL=https://openrouter.ai/api/v1
```

> **Note:** ScienceClaw auto-detects OpenRouter and remaps model IDs (e.g. `claude-sonnet-4-6` → `anthropic/claude-sonnet-4.6`). No manual config changes needed.

### Optional Keys

These are not required but unlock additional capabilities:

```bash
# NCBI/PubMed (higher rate limits)
NCBI_API_KEY=your-ncbi-key

# Exa semantic search
EXA_API_KEY=your-exa-key

# Materials Project database
MP_API_KEY=your-mp-key

# Gemini image generation
LLM_API_KEY=your-gemini-key
```

---

## Step 2: Run Setup

The setup script checks prerequisites, installs the OpenClaw engine from npm, and configures your API key:

```bash
bash scripts/setup.sh
```

What the script does:

1. **Checks prerequisites** -- verifies Node.js >= 22 and pnpm (or npm) are installed
2. **Installs dependencies** -- runs `pnpm install` which pulls the OpenClaw engine from npm automatically
3. **Configures API key** -- if `.env` doesn't exist, prompts you interactively

Expected output:

```
  ScienceClaw Setup
  =================================

  [1/3] Checking prerequisites...
    Node.js v22.12.0, pnpm 9.15.4

  [2/3] Installing dependencies...
    Done.

  [3/3] API Key...
    .env exists. Skipping.

  =================================
  Setup complete!

    ./scienceclaw run            # Start gateway + open TUI
    ./scienceclaw ask "query"    # One-shot mode
    ./scienceclaw stop           # Stop background gateway
```

---

## Step 3: Verify Installation

### Check the CLI

```bash
./scienceclaw status
```

This reports whether the gateway is running and on which port.

### Start and Test

```bash
# One-command start (starts gateway + opens TUI)
./scienceclaw run
```

If everything is configured correctly, the TUI will open and connect to the gateway. You should see the ScienceClaw agent ready to accept queries.

### Health Check

Once in the TUI, try a simple query to verify all systems are working:

```
Search for recent reviews on CRISPR base editing
```

The agent should:
1. Query PubMed and/or OpenAlex
2. Return real papers with titles, authors, and years
3. Provide a brief synthesis

If this works, your installation is complete.

---

## Troubleshooting Installation

### "OpenClaw engine not found"

Run setup again to install dependencies:

```bash
bash scripts/setup.sh
```

### "Node.js >= 22 required"

Upgrade Node.js:

```bash
nvm install 22 && nvm use 22
# or
brew upgrade node
```

### "pnpm not found"

```bash
npm install -g pnpm
```

### Gateway fails to start

Check the log file:

```bash
cat /tmp/scienceclaw-gateway.log
```

Common causes:
- Port 18789 already in use (another instance or different service)
- Missing or invalid API key in `.env`

### API key errors

Verify your key works by testing directly:

```bash
curl -s https://yunwu.ai/v1/models \
  -H "Authorization: Bearer sk-your-key" | head -20
```

If this returns a list of models, your key is valid.

---

## Next Steps

- [Quickstart Guide](quickstart.md) -- ask your first research question in 5 minutes
- [Configuration Reference](configuration.md) -- customize models, skills, and gateway settings
- [Skills Guide](../guides/skills.md) -- explore 264 domain-specific skills
