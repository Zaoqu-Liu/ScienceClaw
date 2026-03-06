# Feishu / Lark Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to Feishu (飞书) or Lark so users can interact with your agent in Feishu groups and direct messages.

## Prerequisites

- ScienceClaw installed and on your `PATH`
- Gateway running (`scienceclaw run`) on `ws://127.0.0.1:18789`
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
2. Set the **Request URL** to the address where OpenClaw can receive events. If running locally, you may need a tunnel (e.g., ngrok) or configure Feishu's long-polling mode.
3. Subscribe to these events:
   - `im.message.receive_v1` — receive messages
   - `im.message.message_read_v1` — read receipts (optional)
4. Save.

## Step 4: Get Credentials

1. Go to **Credentials & Basic Info**.
2. Copy the **App ID** and **App Secret**.

## Step 5: Add the Channel

```bash
scienceclaw openclaw channels add --channel feishu --app-id <APP_ID> --app-secret <APP_SECRET>
```

Replace `<APP_ID>` and `<APP_SECRET>` with the values from Step 4.

## Step 6: Publish and Deploy

1. Go to **App Release** → **Version Management**.
2. Create a new version and submit for review. For enterprise-internal apps, approval is usually instant.
3. Once published, add the bot to a Feishu group or send it a direct message.

## Step 7: Restart the Gateway and Test

```bash
scienceclaw stop && scienceclaw run
```

In a Feishu group, @mention the bot. It should reply through ScienceClaw.

## Event Subscription Configuration

Feishu supports two event delivery modes:

- **Webhook (push):** Feishu sends HTTP POST requests to your server. Requires a publicly accessible URL.
- **Long-polling (pull):** Your app pulls events from Feishu. No public URL needed — better for local development.

If you are behind a firewall or running locally, use long-polling. Check the Feishu Open Platform docs for details on enabling it.

## Troubleshooting

**Bot does not receive messages**
- Verify the app has been published and is not still in draft.
- Check that `im.message.receive_v1` is subscribed under Events & Callbacks.
- If using webhook mode, confirm the Request URL is reachable from Feishu's servers.

**"app not activated" error**
- The app needs to be published (even for internal use). Go to Version Management and create a release.

**Bot replies with "permission denied"**
- The app may lack required scopes. Under **Permissions & Scopes**, ensure `im:message`, `im:message:send_as_bot`, and `im:chat:readonly` are granted and approved.
