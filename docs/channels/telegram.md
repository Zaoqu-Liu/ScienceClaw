# Telegram Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Telegram so users can interact with your agent through a Telegram bot.

## Prerequisites

- ScienceClaw installed and on your `PATH` (`bash scripts/setup.sh` completed)
- A Telegram account

## Step 1: Create a Telegram Bot

1. Open Telegram and search for **@BotFather**.
2. Start a chat and send `/newbot`.
3. Follow the prompts — choose a display name and a username (must end in `bot`).
4. BotFather replies with your **bot token**. It looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`. Copy it and keep it safe.

## Step 2: Enable the Telegram Plugin

ScienceClaw ships with Telegram support as a built-in plugin, but it is disabled by default. Enable it first:

```bash
scienceclaw plugins enable telegram
```

You should see: `Enabled plugin "telegram". Restart the gateway to apply.`

## Step 3: Add the Channel

```bash
scienceclaw channels add --channel telegram --token <YOUR_BOT_TOKEN>
```

Replace `<YOUR_BOT_TOKEN>` with the token from BotFather.

This writes the Telegram configuration into `openclaw.config.json`. The default settings use `dmPolicy: "pairing"` and `groupPolicy: "allowlist"`, meaning the bot only responds to paired users and explicitly allowed groups.

**To make the bot open to everyone** (recommended for public-facing bots), edit `openclaw.config.json` and update the `channels.telegram` section:

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

> **Why `commands.native: false`?** ScienceClaw has 264+ skills that register as slash commands. Telegram limits bots to ~100 commands, so native command registration will fail. Setting this to `false` disables command registration while keeping all skills fully functional via natural language.

## Step 4: Start the Gateway

```bash
scienceclaw run
```

Or if the gateway is already running, restart it:

```bash
scienceclaw stop && scienceclaw run
```

The gateway picks up the new channel configuration on startup. You should see a log line like:

```
[telegram] [default] starting provider (@YourBot)
```

## Step 5: Test

Open Telegram, find your bot by its username, and send a message. You should receive a reply from ScienceClaw.

## Verify the Connection

```bash
scienceclaw channels status
```

You should see:

```
- Telegram default: enabled, configured, running, mode:polling
```

## Bot Privacy Settings

By default, Telegram bots only receive messages that are directly addressed to them in group chats (commands or @mentions). If you want the bot to see all messages in a group:

1. Open a chat with **@BotFather**.
2. Send `/mybots`, select your bot, then **Bot Settings** → **Group Privacy** → **Turn off**.

With group privacy disabled, the bot receives every message in groups it belongs to.

## Troubleshooting

**"Unknown channel: telegram"**
- You forgot to enable the plugin. Run `scienceclaw plugins enable telegram` first.

**"BOT_COMMANDS_TOO_MUCH" errors in logs**
- ScienceClaw has too many skills for Telegram's command limit. Add `"commands": { "native": false }` to the `channels.telegram` section in `openclaw.config.json`.

**"channels.telegram.allowFrom: dmPolicy=open requires allowFrom to include *"**
- When using `dmPolicy: "open"`, you must also set `"allowFrom": ["*"]` in the telegram channel config.

**Bot does not respond at all**
- Verify the token is correct: `scienceclaw channels status` should show the Telegram channel as running.
- Make sure the gateway is running: `scienceclaw status`.
- Check that you did not create multiple bots with the same token — only one process can poll a given token.

**Bot responds in DMs but not in groups**
- Disable group privacy as described above.
- Make sure the bot has been added to the group as a member.
- If using `groupPolicy: "allowlist"`, add the group's chat ID to `groupAllowFrom`, or set `groupPolicy: "open"`.

**"401 Unauthorized" in logs**
- The bot token is invalid or was revoked. Generate a new token with `/token` in BotFather and re-add the channel.
