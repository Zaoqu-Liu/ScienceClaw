# Channel Integrations

ScienceClaw connects to messaging platforms through the **OpenClaw** gateway, letting your AI agent respond to users on Telegram, Discord, Slack, WhatsApp, and more — all from a single running instance. Each channel runs as a separate adapter within the gateway, and you can enable as many as you need simultaneously.

## Channel Comparison

| Channel | Group Chat | Images | Voice | Setup Difficulty | Guide |
|---------|-----------|--------|-------|-----------------|-------|
| Telegram | Yes | Yes | Yes | Easy | [telegram.md](telegram.md) |
| Discord | Yes | Yes | Yes | Medium | [discord.md](discord.md) |
| Slack | Yes | Yes | No | Medium | [slack.md](slack.md) |
| Feishu / Lark | Yes | Yes | No | Medium | [feishu.md](feishu.md) |
| WeChat / WeCom | Limited | Yes | No | Hard | [wechat.md](wechat.md) |
| WhatsApp | Yes | Yes | Yes | Easy | [whatsapp.md](whatsapp.md) |
| Web Dashboard | No | Yes | No | Easy | [web.md](web.md) |
| Matrix | Yes | Yes | No | Medium | [matrix.md](matrix.md) |

## How Channels Work

ScienceClaw is a zero-code wrapper around OpenClaw. Channel configuration lives in `openclaw.config.json` at the project root. The `scienceclaw` wrapper script reads your `.env` file, substitutes environment variables into the config, and starts the gateway.

- **Telegram** is pre-configured — just set `TELEGRAM_BOT_TOKEN` in `.env`.
- **Other channels** are added by editing `openclaw.config.json` directly.

## Common Commands

```bash
# Start gateway + TUI (auto-starts gateway on port 18789)
scienceclaw run

# Stop the gateway
scienceclaw stop

# Check gateway status
scienceclaw status

# Check channel status (delegated to OpenClaw)
scienceclaw channels status

# Interactive setup wizard (delegated to OpenClaw)
scienceclaw configure
```

## Prerequisites

All channel guides assume:

1. **ScienceClaw is installed** — `bash scripts/setup.sh` completed successfully.
2. **You have a `.env` file** with at least one LLM provider configured (copy from `.env.example`).
3. You have **admin or owner access** on the target platform to create bots or apps.

## China / Restricted Networks

If you are in China or behind a restrictive firewall, platforms like Telegram and Discord may be unreachable without a proxy. ScienceClaw supports proxy configuration via `.env`:

```bash
# Telegram proxy (SOCKS5 or HTTP)
TELEGRAM_PROXY=socks5://127.0.0.1:1080
```

See the [Telegram guide](telegram.md) for detailed proxy setup. For Discord and other channels, configure your system-level proxy or use a VPN.

## Next Steps

Pick a channel from the table above and follow its guide. If you run into issues, each guide includes a troubleshooting section.
