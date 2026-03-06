# Telegram Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Telegram so users can interact with your agent through a Telegram bot.

## Prerequisites

- ScienceClaw installed and on your `PATH`
- Gateway running (`scienceclaw run`) on `ws://127.0.0.1:18789`
- A Telegram account

## Step 1: Create a Telegram Bot

1. Open Telegram and search for **@BotFather**.
2. Start a chat and send `/newbot`.
3. Follow the prompts — choose a display name and a username (must end in `bot`).
4. BotFather replies with your **bot token**. It looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`. Copy it and keep it safe.

## Step 2: Add the Channel

```bash
scienceclaw openclaw channels add --channel telegram --token <YOUR_BOT_TOKEN>
```

Replace `<YOUR_BOT_TOKEN>` with the token from BotFather.

## Step 3: Restart the Gateway

```bash
scienceclaw stop && scienceclaw run
```

The gateway picks up the new channel configuration on startup.

## Step 4: Test

Open Telegram, find your bot by its username, and send a message. You should receive a reply from ScienceClaw.

## Bot Privacy Settings

By default, Telegram bots only receive messages that are directly addressed to them in group chats (commands or @mentions). If you want the bot to see all messages in a group:

1. Open a chat with **@BotFather**.
2. Send `/mybots`, select your bot, then **Bot Settings** → **Group Privacy** → **Turn off**.

With group privacy disabled, the bot receives every message in groups it belongs to.

## Troubleshooting

**Bot does not respond at all**
- Verify the token is correct: `scienceclaw openclaw channels status` should show the Telegram channel as connected.
- Make sure the gateway is running: `scienceclaw run`.
- Check that you did not create multiple bots with the same token — only one process can poll a given token.

**Bot responds in DMs but not in groups**
- Disable group privacy as described above.
- Make sure the bot has been added to the group as a member.

**"401 Unauthorized" in logs**
- The bot token is invalid or was revoked. Generate a new token with `/token` in BotFather and re-add the channel.
