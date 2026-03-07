# WeChat / WeCom Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to WeChat or WeCom (企业微信). Direct WeChat personal account integration is not natively supported due to platform restrictions, so this guide covers two alternative approaches.

## Prerequisites

- ScienceClaw installed and on your `PATH`
- Gateway running (`scienceclaw run`) on `ws://127.0.0.1:18789`

---

## Approach A: WeCom (Enterprise WeChat) Robot — Recommended

WeCom provides an official bot API and is the more stable, production-ready option.

### Step 1: Create a WeCom Application

1. Log in to the [WeCom Admin Console](https://work.weixin.qq.com/).
2. Go to **App Management** → **Create App**.
3. Fill in the app name and description.

### Step 2: Configure the Bot

1. In the app settings, enable **Receive Messages** and configure the callback URL.
2. Note the **Token** and **EncodingAESKey** for message verification.
3. Go to **Credentials** and copy the **Corp ID** and **Agent Secret**.

### Step 3: Add the Channel

```bash
scienceclaw channels add --channel wecom --corp-id <CORP_ID> --agent-secret <AGENT_SECRET> --token <TOKEN> --aes-key <AES_KEY>
```

### Step 4: Restart the Gateway and Test

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

Write a small Node.js script that:

1. Initializes a Wechaty instance.
2. Forwards incoming messages to the OpenClaw gateway at `ws://127.0.0.1:18789`.
3. Sends responses back through Wechaty.

Refer to the [Wechaty documentation](https://wechaty.js.org/) for detailed API usage.

### Step 3: Run the Bridge

```bash
node wechat-bridge.js
```

Scan the QR code with your WeChat mobile app to log in.

---

## Comparison

| Aspect | WeCom (Approach A) | Wechaty Bridge (Approach B) |
|--------|-------------------|---------------------------|
| Stability | High — official API | Low — depends on reverse-engineered protocols |
| ToS Compliance | Fully compliant | Risk of account suspension |
| Group Chat | Yes | Yes |
| Setup Effort | Medium | High |
| Maintenance | Low | High — puppets break with WeChat updates |

**Recommendation:** Use WeCom for any production or long-term deployment. The Wechaty bridge is suitable for personal experimentation only.

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
