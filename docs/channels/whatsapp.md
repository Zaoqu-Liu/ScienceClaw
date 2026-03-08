# WhatsApp Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to WhatsApp so users can interact with your agent through WhatsApp messages. This integration uses a QR-code login flow similar to WhatsApp Web.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured
- A phone with WhatsApp installed and an active account

## Step 1: Add the Channel to ScienceClaw

Add the WhatsApp channel section to `openclaw.config.json` inside the `"channels"` object:

```json
{
  "channels": {
    "telegram": { ... },
    "whatsapp": {
      "enabled": true,
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  }
}
```

Add the WhatsApp plugin to the `"plugins"` section:

```json
{
  "plugins": {
    "entries": {
      "telegram": { "enabled": true },
      "whatsapp": { "enabled": true }
    }
  }
}
```

## Step 2: Start the Gateway

```bash
scienceclaw run
```

## Step 3: Log In to WhatsApp

```bash
scienceclaw channels login --channel whatsapp
```

A QR code is displayed in your terminal.

## Step 4: Scan the QR Code

1. Open WhatsApp on your phone.
2. Go to **Settings** → **Linked Devices** → **Link a Device**.
3. Scan the QR code shown in the terminal.

Once linked, the terminal confirms the connection and the gateway begins receiving messages.

## Step 5: Test

Send a message to the WhatsApp number from another phone or ask someone to message you. ScienceClaw should reply automatically.

## Session Persistence

The WhatsApp session is stored locally after the first QR scan. On subsequent gateway restarts, the session reconnects automatically without requiring a new scan — as long as the session has not expired.

Sessions can expire if:

- You manually unlink the device from WhatsApp on your phone.
- The device has not connected for more than 14 days.
- WhatsApp performs a server-side session reset.

If the session expires, run the login command again:

```bash
scienceclaw channels login --channel whatsapp
```

## Verify

```bash
scienceclaw channels status
```

You should see the WhatsApp channel listed as running.

## Troubleshooting

**QR code does not appear**
- Make sure the gateway is running before calling the login command.
- Some terminals do not render QR codes correctly. Try a different terminal emulator or resize the window.

**Bot disconnects frequently**
- This can happen if WhatsApp detects unusual activity. Avoid sending a high volume of messages in a short period.
- Ensure your phone has a stable internet connection — the linked device requires the phone to be online periodically.

**Messages are delivered but no reply is sent**
- Run `scienceclaw channels status` to confirm the WhatsApp channel is active.
- Check gateway logs for errors: `tail -50 ~/.scienceclaw/gateway.log`

**Re-authentication needed**
1. Stop the gateway: `scienceclaw stop`
2. Re-login: `scienceclaw channels login --channel whatsapp`
3. Scan the QR code again.
4. Restart: `scienceclaw run`
