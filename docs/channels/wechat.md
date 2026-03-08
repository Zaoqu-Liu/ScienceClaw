# WeChat / WeCom Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to WeChat or WeCom (企业微信). Direct WeChat personal account integration is not natively supported due to platform restrictions, so this guide covers two approaches.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured

---

## Approach A: WeCom (Enterprise WeChat) — Recommended

WeCom provides an official bot API and is the more stable, production-ready option.

### Step 1: Create a WeCom Application

1. Log in to the [WeCom Admin Console](https://work.weixin.qq.com/).
2. Go to **App Management** → **Create App**.
3. Fill in the app name and description.

### Step 2: Configure the Bot

1. In the app settings, enable **Receive Messages** and configure the callback URL.
2. Note the **Token** and **EncodingAESKey** for message verification.
3. Go to **Credentials** and copy the **Corp ID** and **Agent Secret**.

### Step 3: Add the Channel to ScienceClaw

Add credentials to `.env`:

```bash
WECOM_CORP_ID=your_corp_id
WECOM_AGENT_SECRET=your_agent_secret
WECOM_TOKEN=your_token
WECOM_AES_KEY=your_encoding_aes_key
```

Add the WeCom channel section to `openclaw.config.json` inside the `"channels"` object:

```json
{
  "channels": {
    "telegram": { ... },
    "wecom": {
      "enabled": true,
      "corpId": "${WECOM_CORP_ID}",
      "agentSecret": "${WECOM_AGENT_SECRET}",
      "token": "${WECOM_TOKEN}",
      "aesKey": "${WECOM_AES_KEY}",
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  }
}
```

Add the WeCom plugin to the `"plugins"` section:

```json
{
  "plugins": {
    "entries": {
      "telegram": { "enabled": true },
      "wecom": { "enabled": true }
    }
  }
}
```

### Step 4: Start and Test

```bash
scienceclaw stop && scienceclaw run
```

Add the bot to a WeCom group or send it a direct message.

---

## Approach B: Third-Party Bridge (Wechaty)

This approach bridges personal WeChat accounts to ScienceClaw through the Wechaty framework. It is less stable and may violate WeChat's terms of service.

### Step 1: Install Wechaty

```bash
npm install wechaty wechaty-puppet-wechat4u
```

Or use another puppet provider (e.g., `wechaty-puppet-padlocal` for better reliability).

### Step 2: Create a Bridge Script

Write a Node.js script that:

1. Initializes a Wechaty instance.
2. Forwards incoming messages to the OpenClaw gateway at `ws://127.0.0.1:18789`.
3. Sends responses back through Wechaty.

Refer to the [Wechaty documentation](https://wechaty.js.org/) for API details.

### Step 3: Run the Bridge

```bash
node wechat-bridge.js
```

Scan the QR code with your WeChat mobile app to log in.

---

## Comparison

| Aspect | WeCom (Approach A) | Wechaty Bridge (Approach B) |
|--------|-------------------|---------------------------|
| Stability | High — official API | Low — reverse-engineered protocols |
| ToS Compliance | Fully compliant | Risk of account suspension |
| Group Chat | Yes | Yes |
| Setup Effort | Medium | High |
| Maintenance | Low | High — puppets break with WeChat updates |

**Recommendation:** Use WeCom for any production or long-term deployment. The Wechaty bridge is suitable for personal experimentation only.

## Verify

```bash
scienceclaw channels status
```

You should see the WeCom/WeChat channel listed as running.

## Troubleshooting

**WeCom callback URL verification fails**
- Ensure the URL is publicly accessible. Use a tunnel (e.g., ngrok) for local development.
- Double-check the Token and EncodingAESKey match what is configured in the WeCom console.

**Wechaty QR code does not appear**
- Some puppets require a paid token. Check the puppet provider's documentation.
- Try a different puppet: `wechaty-puppet-wechat4u` is free but less reliable than padlocal.

**Messages are received but no reply is sent**
- Verify the gateway is running and the bridge script is correctly forwarding to `ws://127.0.0.1:18789`.
- Check WeCom app permissions — the bot may lack the "Send Messages" scope.
