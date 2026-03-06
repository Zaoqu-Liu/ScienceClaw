# Discord Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Discord so users can interact with your agent in Discord servers.

## Prerequisites

- ScienceClaw installed and on your `PATH`
- Gateway running (`scienceclaw run`) on `ws://127.0.0.1:18789`
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

## Step 4: Add the Channel

```bash
scienceclaw openclaw channels add --channel discord --token <BOT_TOKEN>
```

Replace `<BOT_TOKEN>` with the token from Step 2.

## Step 5: Restart the Gateway and Test

```bash
scienceclaw stop && scienceclaw run
```

Go to your Discord server and send a message in a channel the bot can see. The bot should reply.

## Troubleshooting

**Bot is online but does not respond**
- Confirm **Message Content Intent** is enabled in the Developer Portal. Without it, the bot receives empty message payloads.
- Check that the bot has Read and Send permissions in the channel you are testing.

**"Used disallowed intents" error in logs**
- You enabled intents in the code but not in the Developer Portal. Go to **Bot** → **Privileged Gateway Intents** and toggle them on.

**Bot does not appear in the server member list**
- The invite URL may not have included the `bot` scope. Regenerate the OAuth2 URL with the correct scopes and re-invite.
