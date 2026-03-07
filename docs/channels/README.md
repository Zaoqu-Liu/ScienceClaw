# Channel Integrations

ScienceClaw connects to messaging platforms through the **OpenClaw** gateway, letting your AI agent respond to users on Telegram, Discord, Slack, WhatsApp, and more — all from a single running instance. Each channel runs as a separate adapter within the gateway, and you can enable as many as you need simultaneously.

## Quick Setup

The fastest way to add a channel is the interactive configuration wizard:

```bash
scienceclaw configure
```

This walks you through selecting a platform, entering credentials, and verifying the connection. For manual setup, see the individual guides below.

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

## Common Commands

```bash
# Enable a channel plugin (required before first use)
scienceclaw plugins enable <channel-name>

# Add a channel
scienceclaw channels add --channel <name> [options]

# Log in to a channel that requires interactive auth (e.g. WhatsApp QR)
scienceclaw channels login --channel <name>

# Check status of all configured channels
scienceclaw channels status

# Interactive setup wizard
scienceclaw configure
```

## Prerequisites

All channel guides assume:

1. **ScienceClaw is installed** and available on your `PATH`.
2. **The gateway is running** — start it with `scienceclaw run` if it is not. The gateway listens on `ws://127.0.0.1:18789` by default.
3. You have **admin or owner access** on the target platform to create bots or apps.

## Next Steps

Pick a channel from the table above and follow its guide. If you run into issues, each guide includes a troubleshooting section. You can also run `scienceclaw channels status` at any time to verify your connections.
