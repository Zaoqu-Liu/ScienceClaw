# Discord Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Discord so users can interact with your agent in Discord servers.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured
- A Discord account with permission to add bots to a server

## Step 1: Create a Discord Application

1. Go to [discord.com/developers/applications](https://discord.com/developers/applications).
2. Click **New Application**, give it a name, and create it.

## Step 2: Configure the Bot

1. In the left sidebar, click **Bot**.
2. Under **Privileged Gateway Intents**, enable all three:
   - **Presence Intent**
   - **Server Members Intent**
   - **Message Content Intent**
3. Click **Save Changes**.
4. Click **Reset Token** (or **Copy** if the token is still visible) to get your bot token. Save it — you will not be able to view it again.

## Step 3: Invite the Bot to Your Server

1. In the left sidebar, click **OAuth2** → **URL Generator**.
2. Under **Scopes**, check:
   - `bot`
   - `applications.commands`
3. Under **Bot Permissions**, check **Administrator** (or select granular permissions: Send Messages, Read Message History, Embed Links, Attach Files, Add Reactions).
4. Copy the generated URL and open it in your browser.
5. Select the server you want to add the bot to and authorize it.

## Step 4: Add the Channel to ScienceClaw

Add your bot token to `.env`:

```bash
DISCORD_BOT_TOKEN=your-discord-bot-token
```

Then add the Discord channel section to `openclaw.config.json`. Insert this inside the `"channels"` object (alongside the existing `"telegram"` section):

```json
{
  "channels": {
    "telegram": { ... },
    "discord": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"],
      "botToken": "${DISCORD_BOT_TOKEN}",
      "groupPolicy": "open",
      "groupAllowFrom": ["*"],
      "commands": {
        "native": false
      }
    }
  }
}
```

Also add the Discord plugin to the `"plugins"` section:

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

> **Why `commands.native: false`?** ScienceClaw has 266+ skills. Discord's slash command limit may cause registration errors. Disable native commands and use natural language instead.

## Step 5: Start and Test

```bash
scienceclaw stop && scienceclaw run
```

Go to your Discord server and send a message in a channel the bot can see. The bot should reply.

## Verify

```bash
scienceclaw channels status
```

You should see the Discord channel listed as running.

## Troubleshooting

**Bot is online but does not respond**
- Confirm **Message Content Intent** is enabled in the Developer Portal. Without it, the bot receives empty message payloads.
- Check that the bot has Read and Send permissions in the channel you are testing.

**"Used disallowed intents" error in logs**
- You enabled intents in the config but not in the Developer Portal. Go to **Bot** → **Privileged Gateway Intents** and toggle them on.

**Bot does not appear in the server member list**
- The invite URL may not have included the `bot` scope. Regenerate the OAuth2 URL with the correct scopes and re-invite.

**Connection issues in China**
- Discord servers may be unreachable without a VPN or system-level proxy. ScienceClaw does not have a built-in proxy for Discord (unlike Telegram). Configure your system proxy or VPN before starting.
