# Feishu / Lark Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Feishu (飞书) or Lark so users can interact with your agent in Feishu groups and direct messages.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured
- Admin access to a Feishu or Lark tenant

## Step 1: Create a Custom App

1. Go to the Feishu Open Platform:
   - **Feishu (China):** [open.feishu.cn](https://open.feishu.cn)
   - **Lark (International):** [open.larksuite.com](https://open.larksuite.com)
2. Click **Create Custom App**.
3. Fill in the app name (e.g., "ScienceClaw Bot") and description.

## Step 2: Add Bot Capability

1. In your app's console, go to **Features** → **Bot**.
2. Toggle the bot capability on.

## Step 3: Configure Event Subscriptions

1. Go to **Features** → **Events & Callbacks**.
2. Set the **Request URL** to the address where the gateway can receive events. If running locally, use a tunnel (e.g., ngrok) or configure Feishu's long-polling mode.
3. Subscribe to these events:
   - `im.message.receive_v1` — receive messages
   - `im.message.message_read_v1` — read receipts (optional)
4. Save.

## Step 4: Get Credentials

1. Go to **Credentials & Basic Info**.
2. Copy the **App ID** and **App Secret**.

## Step 5: Add the Channel to ScienceClaw

Add credentials to `.env`:

```bash
FEISHU_APP_ID=cli_your_app_id
FEISHU_APP_SECRET=your_app_secret
```

Add the Feishu channel section to `openclaw.config.json` inside the `"channels"` object:

```json
{
  "channels": {
    "telegram": { ... },
    "feishu": {
      "enabled": true,
      "appId": "${FEISHU_APP_ID}",
      "appSecret": "${FEISHU_APP_SECRET}",
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  }
}
```

Add the Feishu plugin to the `"plugins"` section:

```json
{
  "plugins": {
    "entries": {
      "telegram": { "enabled": true },
      "feishu": { "enabled": true }
    }
  }
}
```

## Step 6: Publish the App

1. Go to **App Release** → **Version Management**.
2. Create a new version and submit for review. For enterprise-internal apps, approval is usually instant.
3. Once published, add the bot to a Feishu group or send it a direct message.

## Step 7: Start and Test

```bash
scienceclaw stop && scienceclaw run
```

In a Feishu group, @mention the bot. It should reply through ScienceClaw.

## Event Delivery Modes

Feishu supports two event delivery modes:

- **Webhook (push):** Feishu sends HTTP POST requests to your server. Requires a publicly accessible URL.
- **Long-polling (pull):** Your app pulls events from Feishu. No public URL needed — better for local development.

If you are behind a firewall or running locally, use long-polling. See the Feishu Open Platform docs for details.

## Verify

```bash
scienceclaw channels status
```

You should see the Feishu channel listed as running.

## Troubleshooting

**Bot does not receive messages**
- Verify the app has been published and is not still in draft.
- Check that `im.message.receive_v1` is subscribed under Events & Callbacks.
- If using webhook mode, confirm the Request URL is reachable from Feishu's servers.

**"app not activated" error**
- The app needs to be published (even for internal use). Go to Version Management and create a release.

**Bot replies with "permission denied"**
- The app may lack required scopes. Under **Permissions & Scopes**, ensure `im:message`, `im:message:send_as_bot`, and `im:chat:readonly` are granted and approved.
