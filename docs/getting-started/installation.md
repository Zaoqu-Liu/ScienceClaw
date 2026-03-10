# Installation

This guide walks you through installing ScienceClaw from scratch. No programming experience needed.

---

## System Requirements

| Requirement | Minimum | Notes |
|-------------|---------|-------|
| **Node.js** | 22+ | Required — [nodejs.org](https://nodejs.org/) |
| **pnpm** | 9.0+ | Required — installed automatically by setup |
| **Python** | 3.10+ | For code execution (optional but recommended) |
| **OS** | macOS 13+, Ubuntu 22.04+, Windows (WSL2) | macOS or Linux recommended |
| **Docker** | 24.0+ | Optional — for sandboxed code execution |

### Check Your System

```bash
node -v        # Should print v22.x.x or higher
python3 -V     # Should print Python 3.10+
```

**Node.js not installed?**

```bash
# macOS (Homebrew)
brew install node@22

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Any platform (fnm — fastest)
curl -fsSL https://fnm.vercel.app/install | bash && fnm install 22
```

---

## Step 1 — Clone

```bash
git clone https://github.com/Zaoqu-Liu/ScienceClaw.git
cd ScienceClaw
```

## Step 2 — Run Setup

The interactive setup handles everything: dependencies, API key, language.

```bash
bash scripts/setup.sh
```

The setup wizard will ask for your **API Key** and **Base URL**. Choose the option that fits your situation:

### Option A: DeepSeek (recommended for China — no proxy needed)

The simplest option for users in mainland China. DeepSeek V3 is powerful, cheap (¥1/million tokens), and works without a proxy.

1. Sign up at [platform.deepseek.com](https://platform.deepseek.com/)
2. Create an API key in the console
3. When setup asks:

```
API Key: sk-your-deepseek-key
Base URL: https://api.deepseek.com/v1
```

### Option B: yunwu.ai Relay (access all models from China)

A single key gives you access to Claude, GPT-4o, Gemini, and more through a relay that works in China.

1. Sign up at [yunwu.ai](https://yunwu.ai/)
2. When setup asks:

```
API Key: sk-your-relay-key
Base URL: https://yunwu.ai/v1
```

### Option C: OpenRouter (300+ models, one key)

Access to hundreds of models including free ones. Works best outside China.

1. Sign up at [openrouter.ai](https://openrouter.ai/)
2. When setup asks:

```
API Key: sk-or-your-openrouter-key
Base URL: https://openrouter.ai/api/v1
```

> **Important:** Free-tier models (with `:free` suffix) on OpenRouter are unstable — they may be rate-limited, region-blocked, or removed without notice. Paid models are much more reliable.

### Option D: Direct API Access

Use official provider endpoints directly. Requires overseas network access for OpenAI and Claude.

```
API Key: sk-your-openai-key
Base URL: https://api.openai.com/v1
```

---

## Step 3 — Start

```bash
./scienceclaw run
```

This starts the gateway and opens the terminal UI. You should see the ScienceClaw agent ready for questions.

### Verify It Works

Try a simple query in the TUI:

```
Search for recent reviews on CRISPR base editing
```

The agent should return real papers with titles, authors, and years. If this works, you're all set.

---

## Useful Commands

| Command | What it does |
|---------|-------------|
| `./scienceclaw run` | Start gateway + open terminal UI |
| `./scienceclaw models` | Check which models work (diagnose 404/403 errors) |
| `./scienceclaw doctor` | Full system health check |
| `./scienceclaw status` | Check if the gateway is running |
| `./scienceclaw stop` | Stop the gateway |
| `./scienceclaw ask "question"` | One-shot mode (no TUI) |
| `./scienceclaw help` | See all commands |

---

## Troubleshooting

### Model errors (404 / 403 / 429)

If you see errors like "No endpoints found" or "not available in your region":

```bash
# Check which models are working
./scienceclaw models
```

This command tests every configured model and tells you which ones work. Follow its recommendations.

**Common causes:**
- **404** — The model was removed from the provider. Switch to another model.
- **403** — Region-blocked. Use DeepSeek or yunwu.ai relay instead.
- **429** — Too many people using the free model. Wait or switch to a paid model.
- **402** — Account balance depleted. Top up or switch to a free model.

**Quick fix:** Use `/model` inside the TUI to switch to a working model.

### "OpenClaw engine not found"

```bash
bash scripts/setup.sh    # Re-run setup to install dependencies
```

### Gateway won't start

```bash
# Check what's wrong
./scienceclaw doctor

# Check the log
tail -20 ~/.scienceclaw/gateway.log

# Kill a stuck process and restart
./scienceclaw stop && ./scienceclaw run
```

### API key doesn't work

```bash
# Run the built-in diagnostics
./scienceclaw doctor

# Or test manually
source .env
curl -s "$OPENAI_BASE_URL/models" -H "Authorization: Bearer $OPENAI_API_KEY" | head -5
```

---

## Adding Channels (Optional)

Connect ScienceClaw to your favorite messaging platform:

```bash
./scienceclaw add telegram   # Easiest — just need a bot token from @BotFather
./scienceclaw add discord
./scienceclaw add slack
./scienceclaw add whatsapp
./scienceclaw add feishu     # 飞书
./scienceclaw add wechat     # 企业微信
./scienceclaw channels       # See what's configured
```

---

## Next Steps

- [Quickstart Guide](quickstart.md) — Ask your first research question
- [Configuration Reference](configuration.md) — Customize models, skills, and settings
- [Skills Guide](../guides/skills.md) — Explore 264 domain-specific capabilities
- [Troubleshooting](../guides/troubleshooting.md) — Common issues and solutions
