# Slack Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Slack so users can interact with your agent in Slack workspaces.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured
- Admin access to a Slack workspace

## Step 1: Create a Slack App

1. Go to [api.slack.com/apps](https://api.slack.com/apps).
2. Click **Create New App** → **From a manifest**.
3. Select your workspace.
4. Paste the following manifest (YAML):

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

1. Go to **Settings** → **Socket Mode**.
2. Toggle **Enable Socket Mode** on.
3. Create an **App-Level Token** — name it (e.g., `scienceclaw-socket`) and add the `connections:write` scope.
4. Copy the generated token (starts with `xapp-`). This is your **App-Level Token**.

## Step 3: Install the App to Your Workspace

1. Go to **Settings** → **Install App**.
2. Click **Install to Workspace** and authorize.
3. Copy the **Bot User OAuth Token** (starts with `xoxb-`).

## Step 4: Add the Channel to ScienceClaw

Add both tokens to `.env`:

```bash
SLACK_APP_TOKEN=xapp-your-app-level-token
SLACK_BOT_TOKEN=xoxb-your-bot-user-token
```

Add the Slack channel section to `openclaw.config.json` inside the `"channels"` object:

```json
{
  "channels": {
    "telegram": { ... },
    "slack": {
      "enabled": true,
      "appToken": "${SLACK_APP_TOKEN}",
      "botToken": "${SLACK_BOT_TOKEN}",
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  }
}
```

Add the Slack plugin to the `"plugins"` section:

```json
{
  "plugins": {
    "entries": {
      "telegram": { "enabled": true },
      "slack": { "enabled": true }
    }
  }
}
```

## Step 5: Start and Test

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

## Verify

```bash
scienceclaw channels status
```

You should see the Slack channel listed as running.

## Troubleshooting

**Bot does not respond to mentions**
- Make sure the bot has been invited to the channel: type `/invite @ScienceClaw`.
- Verify Socket Mode is enabled — without it, Slack cannot deliver events.

**"not_authed" or "invalid_auth" errors**
- The app-level token (`xapp-`) is for the socket connection; the bot token (`xoxb-`) is for API calls. They are not interchangeable. Double-check both.
- If you regenerated tokens, update `.env` and restart.

**Bot responds in DMs but not in channels**
- The `app_mentions:read` and `channels:history` scopes may be missing. Add them under **OAuth & Permissions** → **Scopes**, then reinstall the app.
