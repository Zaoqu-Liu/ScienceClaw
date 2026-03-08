# Matrix Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to the Matrix network so users can interact with your agent in Matrix rooms. Matrix is a decentralized, open-standard protocol for real-time communication.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured
- Access to a Matrix homeserver (self-hosted or a public one like matrix.org)

## Step 1: Create a Bot Account

Create a dedicated user account on your Matrix homeserver for the bot. You can do this through:

- **Element (web/desktop):** Register a new account at your homeserver's Element instance.
- **Command line:** Use your homeserver's admin API or registration tools.

Choose a descriptive username such as `@scienceclaw-bot:yourhomeserver.org`.

## Step 2: Obtain an Access Token

You need an access token to authenticate the bot.

### Option A: From Element

1. Log in to Element with the bot account.
2. Go to **Settings** → **Help & About** → **Advanced**.
3. Copy the **Access Token**.

### Option B: Via the Matrix API

```bash
curl -X POST "https://yourhomeserver.org/_matrix/client/v3/login" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "m.login.password",
    "user": "scienceclaw-bot",
    "password": "YOUR_PASSWORD"
  }'
```

The response contains an `access_token` field.

## Step 3: Add the Channel to ScienceClaw

Add credentials to `.env`:

```bash
MATRIX_HOMESERVER=https://yourhomeserver.org
MATRIX_USER_ID=@scienceclaw-bot:yourhomeserver.org
MATRIX_ACCESS_TOKEN=your_access_token
```

Add the Matrix channel section to `openclaw.config.json` inside the `"channels"` object:

```json
{
  "channels": {
    "telegram": { ... },
    "matrix": {
      "enabled": true,
      "homeserver": "${MATRIX_HOMESERVER}",
      "userId": "${MATRIX_USER_ID}",
      "accessToken": "${MATRIX_ACCESS_TOKEN}",
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  }
}
```

Add the Matrix plugin to the `"plugins"` section:

```json
{
  "plugins": {
    "entries": {
      "telegram": { "enabled": true },
      "matrix": { "enabled": true }
    }
  }
}
```

## Step 4: Invite the Bot to Rooms

In any Matrix client (Element, etc.), invite the bot user to the rooms where you want it to be active. The bot auto-accepts invites when the gateway is running.

## Step 5: Start and Test

```bash
scienceclaw stop && scienceclaw run
```

Send a message in a room the bot has joined. It should reply through ScienceClaw.

## End-to-End Encryption

Matrix supports end-to-end encryption (E2EE) for rooms:

- In **unencrypted rooms**, the bot works out of the box.
- In **encrypted rooms**, the bot needs to handle key verification and device management. This adds complexity and may not be fully supported by all gateway versions.

**Recommendation:** Use the bot in unencrypted rooms for the most reliable experience. If you need encryption, test thoroughly.

## Homeserver Recommendations

| Homeserver | Notes |
|-----------|-------|
| [matrix.org](https://matrix.org) | Largest public homeserver. Good for testing. |
| [Synapse](https://github.com/element-hq/synapse) | Reference implementation. Self-host for full control. |
| [Conduit](https://conduit.rs) | Lightweight Rust implementation. Lower resource usage. |
| [Dendrite](https://github.com/matrix-org/dendrite) | Second-generation homeserver in Go. |

For production use, self-hosting gives you control over rate limits, storage, and federation policies.

## Verify

```bash
scienceclaw channels status
```

You should see the Matrix channel listed as running.

## Troubleshooting

**Bot does not respond in a room**
- Verify the bot has been invited and has joined the room.
- Some homeservers rate-limit new accounts. Wait a few minutes after account creation before testing.

**"M_UNKNOWN_TOKEN" error**
- The access token is invalid or expired. Generate a new one using the login API and update `.env`.

**Bot joins the room but messages are empty**
- This usually indicates an encrypted room where the bot cannot decrypt messages. Move to an unencrypted room or verify that E2EE support is enabled in your gateway version.
