# WhatsApp Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to WhatsApp so users can interact with your agent through WhatsApp messages. This integration uses a QR-code login flow similar to WhatsApp Web.

## Prerequisites

- ScienceClaw installed and on your `PATH`
- Gateway running (`scienceclaw run`) on `ws://127.0.0.1:18789`
- A phone with WhatsApp installed and an active account

## Step 1: Enable the WhatsApp Plugin

The WhatsApp plugin is disabled by default. Enable it first:

```bash
scienceclaw plugins enable whatsapp
```

## Step 2: Ensure the Gateway Is Running

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

## Re-authentication

If the bot stops responding and `scienceclaw channels status` shows WhatsApp as disconnected:

1. Stop the gateway: `scienceclaw stop`
2. Re-login: `scienceclaw channels login --channel whatsapp`
3. Scan the QR code again.
4. Restart: `scienceclaw run`

## Troubleshooting

**QR code does not appear**
- Make sure the gateway is running before calling the login command.
- Check terminal encoding — some terminals do not render QR codes correctly. Try a different terminal emulator or resize the window.

**Bot disconnects frequently**
- This can happen if WhatsApp detects unusual activity. Avoid sending a high volume of messages in a short period.
- Ensure your phone has a stable internet connection — the linked device requires the phone to be online periodically.

**Messages are delivered but no reply is sent**
- Run `scienceclaw channels status` to confirm the WhatsApp channel is active.
- Check gateway logs for errors related to message processing.
