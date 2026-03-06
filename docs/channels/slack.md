# Slack Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Slack so users can interact with your agent in Slack workspaces.

## Prerequisites

- ScienceClaw installed and on your `PATH`
- Gateway running (`scienceclaw run`) on `ws://127.0.0.1:18789`
- Admin access to a Slack workspace

## Step 1: Create a Slack App

1. Go to [api.slack.com/apps](https://api.slack.com/apps).
2. Click **Create New App** → **From a manifest**.
3. Select your workspace.
4. Paste the following minimal manifest (YAML format):

```yaml
display_information:
  name: ScienceClaw Bot
  description: AI assistant powered by ScienceClaw
features:
  bot_user:
    display_name: ScienceClaw
    always_online: true
  app_home:
    messages_tab_enabled: true
oauth_config:
  scopes:
    bot:
      - app_mentions:read
      - chat:write
      - im:history
      - im:read
      - im:write
      - channels:history
      - groups:history
      - mpim:history
settings:
  event_subscriptions:
    bot_events:
      - app_mention
      - message.im
  interactivity:
    is_enabled: false
  org_deploy_enabled: false
  socket_mode_enabled: true
```

5. Click **Create**.

## Step 2: Enable Socket Mode

1. In the left sidebar, go to **Settings** → **Socket Mode**.
2. Toggle **Enable Socket Mode** on.
3. You will be prompted to create an **App-Level Token**. Name it (e.g., `scienceclaw-socket`) and add the `connections:write` scope.
4. Copy the generated token — it starts with `xapp-`. This is your **App-Level Token**.

## Step 3: Install the App to Your Workspace

1. In the left sidebar, go to **Settings** → **Install App**.
2. Click **Install to Workspace** and authorize.
3. Copy the **Bot User OAuth Token** — it starts with `xoxb-`.

## Step 4: Add the Channel

```bash
scienceclaw openclaw channels add --channel slack --app-token <XAPP_TOKEN> --bot-token <XOXB_TOKEN>
```

Replace `<XAPP_TOKEN>` with the `xapp-...` token and `<XOXB_TOKEN>` with the `xoxb-...` token.

## Step 5: Restart the Gateway and Test

```bash
scienceclaw stop && scienceclaw run
```

In Slack, open a channel the bot is in (or DM the bot directly) and type `@ScienceClaw hello`. The bot should reply.

## Slash Commands (Optional)

To add a slash command:

1. Go to **Features** → **Slash Commands** → **Create New Command**.
2. Set the command (e.g., `/ask`), a short description, and a usage hint.
3. Save, then reinstall the app when prompted.

Slash command payloads are forwarded to ScienceClaw through the gateway automatically.

## Troubleshooting

**Bot does not respond to mentions**
- Make sure the bot has been invited to the channel. Type `/invite @ScienceClaw` in the channel.
- Verify Socket Mode is enabled — without it, Slack cannot deliver events.

**"not_authed" or "invalid_auth" errors**
- Double-check both tokens. The app-level token (`xapp-`) is for the socket connection; the bot token (`xoxb-`) is for API calls. They are not interchangeable.
- If you regenerated tokens, update the channel config and restart.

**Bot responds in DMs but not in channels**
- The `app_mentions:read` and `channels:history` scopes may be missing. Add them under **OAuth & Permissions** → **Scopes**, then reinstall the app.
