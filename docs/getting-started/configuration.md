# Configuration Reference

ScienceClaw is configured through two files: `.env` (API keys and secrets) and `openclaw.config.json` (agent behavior, models, gateway, skills).

---

## `.env` -- Environment Variables

This file holds API keys and runtime settings. It is sourced automatically when you run `./scienceclaw`.

### LLM Provider Keys

You need at least one provider configured. All three use the OpenAI-compatible API format.

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENAI_API_KEY` | API key for OpenAI or compatible relay | `sk-abc123...` |
| `OPENAI_BASE_URL` | API endpoint for OpenAI | `https://api.openai.com/v1` |
| `CLAUDE_API_KEY` | API key for Anthropic Claude or relay | `sk-ant-abc123...` |
| `CLAUDE_BASE_URL` | API endpoint for Claude | `https://api.anthropic.com/v1` |
| `GEMINI_API_KEY` | API key for Google Gemini or relay | `AIza...` |
| `GEMINI_BASE_URL` | API endpoint for Gemini | `https://generativelanguage.googleapis.com/v1beta` |

When using a relay service like yunwu.ai, all three `*_BASE_URL` values point to the same endpoint and you can use a single key:

```bash
OPENAI_API_KEY=sk-your-relay-key
OPENAI_BASE_URL=https://yunwu.ai/v1
CLAUDE_API_KEY=sk-your-relay-key
CLAUDE_BASE_URL=https://yunwu.ai/v1
GEMINI_API_KEY=sk-your-relay-key
GEMINI_BASE_URL=https://yunwu.ai/v1
```

### Optional Service Keys

| Variable | Description | How to Get |
|----------|-------------|------------|
| `NCBI_API_KEY` | NCBI E-utilities (higher rate limits for PubMed) | [NCBI Account](https://www.ncbi.nlm.nih.gov/account/) |
| `EXA_API_KEY` | Exa semantic search | [exa.ai](https://exa.ai) |
| `MP_API_KEY` | Materials Project database | [materialsproject.org](https://materialsproject.org) |
| `LLM_API_KEY` | Gemini image generation API | Google AI Studio |

### Sandbox Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `SCIENCECLAW_SANDBOX_IMAGE` | Docker image for code sandbox | `scienceclaw-sandbox:latest` |
| `SCIENCECLAW_WORKSPACE` | Workspace directory for file storage | `~/.scienceclaw/workspace` |
| `SCIENCECLAW_PYTHON` | Python interpreter path | `python3` |

---

## `openclaw.config.json` -- Main Configuration

This is the primary configuration file. It controls model providers, agent behavior, gateway settings, and skills loading.

### Full Structure

```json
{
  "$schema": "https://docs.openclaw.ai/config-schema.json",
  "models": { ... },
  "agents": { ... },
  "commands": { ... },
  "channels": { ... },
  "gateway": { ... },
  "skills": { ... },
  "plugins": { ... },
  "meta": { ... }
}
```

### `models.providers` -- Model Provider Configuration

Each provider defines a base URL, API key, API format, and available models.

```json
{
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://yunwu.ai/v1",
        "apiKey": "sk-your-key",
        "api": "openai-completions",
        "models": [
          { "id": "gpt-4o", "name": "GPT-4o" },
          { "id": "o4-mini", "name": "o4 Mini" }
        ]
      },
      "claude": {
        "baseUrl": "https://yunwu.ai/v1",
        "apiKey": "sk-your-key",
        "api": "openai-completions",
        "models": [
          { "id": "claude-sonnet-4-6", "name": "Claude Sonnet 4.6" },
          { "id": "claude-opus-4-6", "name": "Claude Opus 4.6" }
        ]
      },
      "gemini": {
        "baseUrl": "https://yunwu.ai/v1",
        "apiKey": "sk-your-key",
        "api": "openai-completions",
        "models": [
          { "id": "gemini-2.5-flash", "name": "Gemini 2.5 Flash" },
          { "id": "gemini-2.5-pro", "name": "Gemini 2.5 Pro" }
        ]
      }
    }
  }
}
```

**Key fields:**

| Field | Description |
|-------|-------------|
| `baseUrl` | API endpoint URL |
| `apiKey` | Authentication key (can also use env vars) |
| `api` | API format -- `openai-completions` for all OpenAI-compatible endpoints |
| `models` | Array of `{ id, name }` objects listing available models |

### `agents` -- Agent Configuration

```json
{
  "agents": {
    "defaults": {
      "model": "claude/claude-sonnet-4-6",
      "workspace": "~/.scienceclaw/workspace",
      "bootstrapMaxChars": 30000,
      "bootstrapTotalMaxChars": 200000,
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "1h"
      },
      "compaction": {
        "mode": "safeguard"
      },
      "heartbeat": {
        "every": "30m"
      }
    },
    "list": [
      {
        "id": "scienceclaw",
        "default": true,
        "name": "ScienceClaw",
        "model": "claude/claude-sonnet-4-6",
        "identity": {
          "name": "ScienceClaw",
          "theme": "AI Research Colleague",
          "emoji": "🔬"
        },
        "tools": {
          "profile": "full"
        }
      }
    ]
  }
}
```

**Key fields:**

| Field | Description | Default |
|-------|-------------|---------|
| `defaults.model` | Default model in `provider/model-id` format | `claude/claude-sonnet-4-6` |
| `defaults.workspace` | Directory for agent file operations | `~/.scienceclaw/workspace` |
| `defaults.bootstrapMaxChars` | Max characters per skill file loaded at startup | `30000` |
| `defaults.bootstrapTotalMaxChars` | Total character budget for all skills at startup | `200000` |
| `defaults.contextPruning.ttl` | How long context entries stay before pruning | `1h` |
| `defaults.compaction.mode` | Context compaction strategy | `safeguard` |
| `agents.list[].model` | Model override for this specific agent | inherits from defaults |
| `agents.list[].tools.profile` | Tool access level: `full`, `read`, or `none` | `full` |

### Switching Models

To change the model ScienceClaw uses, update the `model` field in the agent definition. The format is `provider/model-id`:

```json
"model": "claude/claude-sonnet-4-6"    // Claude Sonnet 4.6
"model": "claude/claude-opus-4-6"      // Claude Opus 4.6 (highest quality)
"model": "openai/gpt-4o"              // GPT-4o
"model": "openai/o4-mini"             // o4 Mini (fast reasoning)
"model": "gemini/gemini-2.5-pro"      // Gemini 2.5 Pro
"model": "gemini/gemini-2.5-flash"    // Gemini 2.5 Flash (fastest)
```

Restart the gateway after changing models:

```bash
./scienceclaw stop && ./scienceclaw run
```

### `gateway` -- Gateway Settings

```json
{
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "token",
      "token": "your-auth-token-here"
    }
  }
}
```

| Field | Description | Options |
|-------|-------------|---------|
| `mode` | Gateway operation mode | `local` (default), `remote` |
| `auth.mode` | Authentication method | `token`, `none` |
| `auth.token` | Auth token for gateway connections | any string |

The gateway listens on port **18789** by default (set in the `scienceclaw` wrapper script).

### `skills` -- Skills Loading Configuration

```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "/absolute/path/to/scienceclaw/skills"
      ]
    },
    "limits": {
      "maxSkillsLoadedPerSource": 300,
      "maxCandidatesPerRoot": 300
    }
  }
}
```

| Field | Description | Default |
|-------|-------------|---------|
| `load.extraDirs` | Array of directories to scan for SKILL.md files | `[]` |
| `limits.maxSkillsLoadedPerSource` | Max skills loaded from a single source directory | `300` |
| `limits.maxCandidatesPerRoot` | Max skill candidates considered per root directory | `300` |

**How `extraDirs` works:**

The engine scans each directory in `extraDirs` recursively, looking for `SKILL.md` files. Each directory containing a `SKILL.md` is treated as a skill. Skills are loaded into the agent's context at startup, subject to the character limits in `agents.defaults`.

To add your own skills, create a new directory with a `SKILL.md` file and add its parent path to `extraDirs`:

```json
"extraDirs": [
  "/path/to/scienceclaw/skills",
  "/path/to/my-custom-skills"
]
```

### `commands` -- Command Settings

```json
{
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw"
  }
}
```

| Field | Description |
|-------|-------------|
| `native` | Enable native command handling | 
| `nativeSkills` | Enable native skill commands |
| `restart` | Allow agent restart command |
| `ownerDisplay` | How to display command ownership |

### `channels` -- Channel Configuration

Chat channels (Telegram, Discord, Slack, etc.) are configured here. Each channel must also have its plugin enabled via the `plugins` section.

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "botToken": "<YOUR_BOT_TOKEN>",
      "groupPolicy": "open",
      "groupAllowFrom": ["*"],
      "streaming": "partial",
      "commands": {
        "native": false
      }
    }
  }
}
```

| Field | Description |
|-------|-------------|
| `enabled` | Whether the channel is active |
| `dmPolicy` | DM access policy: `"open"` (anyone) or `"pairing"` (paired users only) |
| `allowFrom` | Array of allowed sender IDs; `["*"]` allows all (required when `dmPolicy` is `"open"`) |
| `botToken` | Bot authentication token from the platform |
| `groupPolicy` | Group access policy: `"open"` or `"allowlist"` |
| `groupAllowFrom` | Array of allowed group IDs; `["*"]` allows all |
| `streaming` | Response streaming mode: `"partial"` (live updates) or `"full"` (send on complete) |
| `commands.native` | Set to `false` to disable slash command registration (recommended — ScienceClaw has 264+ skills which exceeds Telegram's command limit) |

See the [Channel Integrations](../channels/README.md) guide for setup instructions for each platform.

### `plugins` -- Plugin Configuration

Channel plugins must be explicitly enabled before use:

```json
{
  "plugins": {
    "entries": {
      "telegram": { "enabled": true },
      "discord": { "enabled": true }
    }
  }
}
```

Enable plugins via CLI: `scienceclaw plugins enable <name>`. List available plugins: `scienceclaw plugins list`.

### `meta` -- Metadata

```json
{
  "meta": {
    "lastTouchedVersion": "2026.3.3",
    "lastTouchedAt": "2026-03-06T10:03:52.265Z"
  }
}
```

Automatically updated by the engine. Do not edit manually.

---

## Configuration Recipes

### Minimal Setup (Single Provider)

If you only have an OpenAI key:

```json
{
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://api.openai.com/v1",
        "apiKey": "sk-your-key",
        "api": "openai-completions",
        "models": [
          { "id": "gpt-4o", "name": "GPT-4o" }
        ]
      }
    }
  },
  "agents": {
    "list": [
      {
        "id": "scienceclaw",
        "default": true,
        "name": "ScienceClaw",
        "model": "openai/gpt-4o"
      }
    ]
  }
}
```

### Cost-Optimized Setup

Use a cheaper model for routine tasks:

```json
"model": "gemini/gemini-2.5-flash"
```

Gemini 2.5 Flash is the fastest and cheapest option while still being capable for most research queries.

### Quality-Maximized Setup

Use the strongest model for complex analyses:

```json
"model": "claude/claude-opus-4-6"
```

Claude Opus 4.6 provides the highest reasoning quality but is slower and more expensive.

---

## See Also

- [Installation](installation.md) -- initial setup steps
- [Deployment](../guides/deployment.md) -- production deployment options
- [Troubleshooting](../guides/troubleshooting.md) -- common configuration issues
