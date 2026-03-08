# Telegram Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Telegram so users can interact with your agent through a Telegram bot. Telegram is the default channel — it is pre-configured in `openclaw.config.json` and ready to use once you provide a bot token.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured
- A Telegram account

## Step 1: Create a Telegram Bot

1. Open Telegram and search for **@BotFather**.
2. Start a chat and send `/newbot`.
3. Follow the prompts — choose a display name and a username (must end in `bot`).
4. BotFather replies with your **bot token**. It looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`. Copy it.

## Step 2: Set Your Bot Token

Open your `.env` file and set the token:

```bash
TELEGRAM_BOT_TOKEN=123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

That's it. The Telegram channel is already configured in `openclaw.config.json` with sensible defaults: open DM and group policies, partial streaming, and native command registration disabled.

## Step 3: Start ScienceClaw

```bash
scienceclaw run
```

This starts the gateway (port 18789) and the TUI. You should see a log line like:

```
[telegram] [default] starting provider (@YourBot)
```

## Step 4: Test

Open Telegram, find your bot by its username, and send a message. You should receive a reply.

## China / Restricted Networks

If you are in China or behind a firewall that blocks `api.telegram.org`, you need a proxy. ScienceClaw has built-in proxy support.

### Configure the Proxy

Add one of these to your `.env` file:

```bash
# SOCKS5 proxy (most common with local proxy tools like Clash, V2Ray)
TELEGRAM_PROXY=socks5://127.0.0.1:1080

# HTTP proxy
TELEGRAM_PROXY=http://127.0.0.1:7890
```

The `scienceclaw` wrapper automatically injects this into the Telegram channel config at startup. No changes to `openclaw.config.json` are needed.

### How It Works

When the wrapper detects `TELEGRAM_PROXY` in `.env`, it adds a `proxy` field to the Telegram channel section of the runtime config before starting the gateway. The gateway routes all Telegram API traffic through this proxy.

### Verify Proxy Connectivity

Before starting ScienceClaw, test that your proxy can reach Telegram:

```bash
# With SOCKS5
curl --socks5 127.0.0.1:1080 https://api.telegram.org/bot<YOUR_TOKEN>/getMe

# With HTTP proxy
curl -x http://127.0.0.1:7890 https://api.telegram.org/bot<YOUR_TOKEN>/getMe
```

A successful response returns a JSON object with your bot's details.

## Built-in Resilience

The Telegram channel in `openclaw.config.json` ships with retry and network settings tuned for unreliable connections:

```json
{
  "timeoutSeconds": 90,
  "retry": {
    "attempts": 5,
    "minDelayMs": 500,
    "maxDelayMs": 30000,
    "jitter": 0.2
  },
  "network": {
    "autoSelectFamily": false,
    "dnsResultOrder": "ipv4first"
  }
}
```

- **Retry**: up to 5 attempts with exponential backoff (500ms–30s) and 20% jitter to avoid thundering herd.
- **IPv4 first**: forces IPv4 DNS resolution. Many China networks have broken IPv6 routing to Telegram servers, causing timeouts. This setting avoids that.
- **Timeout**: 90 seconds, generous enough for slow proxy chains.

You generally do not need to change these values.

## Pre-configured Defaults

The full Telegram section in `openclaw.config.json`:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "groupPolicy": "open",
      "groupAllowFrom": ["*"],
      "streaming": "partial",
      "commands": {
        "native": false
      },
      "timeoutSeconds": 90,
      "retry": { ... },
      "network": { ... }
    }
  }
}
```

Key defaults:

| Setting | Value | Meaning |
|---------|-------|---------|
| `dmPolicy` | `"open"` | Anyone can DM the bot |
| `groupPolicy` | `"open"` | Bot responds in any group |
| `commands.native` | `false` | Disables Telegram slash command registration (ScienceClaw has 264+ skills, exceeding Telegram's ~100 command limit) |
| `streaming` | `"partial"` | Bot edits its message as the response streams in |

To restrict access, change `dmPolicy` to `"pairing"` or `groupPolicy` to `"allowlist"` and specify allowed user/group IDs.

## Bot Privacy Settings

By default, Telegram bots only receive messages that are directly addressed to them in group chats (commands or @mentions). If you want the bot to see all messages in a group:

1. Open a chat with **@BotFather**.
2. Send `/mybots`, select your bot, then **Bot Settings** → **Group Privacy** → **Turn off**.

With group privacy disabled, the bot receives every message in groups it belongs to.

## Verify

```bash
scienceclaw channels status
```

Expected output:

```
- Telegram default: enabled, configured, running, mode:polling
```

## Troubleshooting

### Network Issues (China / Proxy)

**Bot starts but never responds, logs show connection timeouts**
- Verify your proxy is running and reachable: `curl --socks5 127.0.0.1:1080 https://api.telegram.org`
- Check that `TELEGRAM_PROXY` is set in `.env` (not in `openclaw.config.json` — the wrapper handles injection).
- Restart ScienceClaw after changing `.env`: `scienceclaw stop && scienceclaw run`

**"ETIMEDOUT" or "ENETUNREACH" errors targeting IPv6 addresses**
- The default config already sets `dnsResultOrder: "ipv4first"`. If you overrode this, restore it.
- Some DNS resolvers return IPv6 (AAAA) records that are unreachable in China. The `ipv4first` setting forces IPv4.

**"ECONNREFUSED" on proxy address**
- Your proxy process is not running on the specified port. Start it or correct the port in `.env`.

### General Issues

**"BOT_COMMANDS_TOO_MUCH" errors in logs**
- ScienceClaw has too many skills for Telegram's command limit. The default config already sets `commands.native: false`. If you changed it, revert.

**"401 Unauthorized" in logs**
- The bot token is invalid or was revoked. Generate a new token with `/token` in BotFather and update `.env`.

**Bot does not respond at all**
- Verify the token: `scienceclaw channels status` should show the Telegram channel as running.
- Make sure the gateway is running: `scienceclaw status`.
- Only one process can poll a given token — check for duplicate instances.

**Bot responds in DMs but not in groups**
- Disable group privacy as described above.
- Make sure the bot has been added to the group as a member.
- If using `groupPolicy: "allowlist"`, add the group's chat ID to `groupAllowFrom`, or set `groupPolicy: "open"`.

**"channels.telegram.allowFrom: dmPolicy=open requires allowFrom to include *"**
- When using `dmPolicy: "open"`, you must also set `"allowFrom": ["*"]` in the telegram channel config. The default config already does this.
