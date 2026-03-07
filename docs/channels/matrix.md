# Matrix Setup Guide

[← Back to Channel Overview](README.md)

Connect ScienceClaw to the Matrix network so users can interact with your agent in Matrix rooms. Matrix is a decentralized, open-standard protocol for real-time communication.

## Prerequisites

- ScienceClaw installed and on your `PATH`
- Gateway running (`scienceclaw run`) on `ws://127.0.0.1:18789`
- Access to a Matrix homeserver (self-hosted or a public one like matrix.org)

## Step 1: Create a Bot Account

Create a dedicated user account on your Matrix homeserver for the bot. You can do this through:

- **Element (web/desktop):** Register a new account at your homeserver's Element instance.
- **Command line:** Use your homeserver's admin API or registration tools.

Choose a descriptive username such as `@scienceclaw-bot:yourhomeserver.org`.

## Step 2: Obtain an Access Token

You need an access token to authenticate the bot. There are several ways to get one:

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

## Step 3: Enable the Matrix Plugin

The Matrix plugin is disabled by default. Enable it first:

```bash
scienceclaw plugins enable matrix
```

## Step 4: Add the Channel

```bash
scienceclaw channels add --channel matrix \
  --homeserver https://yourhomeserver.org \
  --user-id @scienceclaw-bot:yourhomeserver.org \
  --access-token <TOKEN>
```

Replace:
- `https://yourhomeserver.org` with your homeserver URL
- `@scienceclaw-bot:yourhomeserver.org` with the bot's full Matrix user ID
- `<TOKEN>` with the access token from Step 2

## Step 5: Invite the Bot to Rooms

In any Matrix client (Element, etc.), invite the bot user to the rooms where you want it to be active. The bot auto-accepts invites when the gateway is running.

## Step 6: Restart the Gateway and Test

```bash
scienceclaw stop && scienceclaw run
```

Send a message in a room the bot has joined. It should reply through ScienceClaw.

## End-to-End Encryption

Matrix supports end-to-end encryption (E2EE) for rooms. However, bot support for E2EE varies:

- In **unencrypted rooms**, the bot works out of the box.
- In **encrypted rooms**, the bot needs to handle key verification and device management. This adds complexity and may not be fully supported by all gateway versions.

**Recommendation:** For the most reliable experience, use the bot in unencrypted rooms. If you need encryption, test thoroughly and ensure the gateway version supports E2EE device keys.

## Homeserver Recommendations

| Homeserver | Notes |
|-----------|-------|
| [matrix.org](https://matrix.org) | Largest public homeserver. Good for testing. |
| [Synapse](https://github.com/element-hq/synapse) | Reference implementation. Self-host for full control. |
| [Conduit](https://conduit.rs) | Lightweight Rust implementation. Lower resource usage. |
| [Dendrite](https://github.com/matrix-org/dendrite) | Second-generation homeserver in Go. |

For production use, self-hosting gives you control over rate limits, storage, and federation policies.

## Troubleshooting

**Bot does not respond in a room**
- Verify the bot has been invited and has joined the room. Check with `scienceclaw channels status`.
- Some homeservers rate-limit new accounts. Wait a few minutes after account creation before testing.

**"M_UNKNOWN_TOKEN" error**
- The access token is invalid or expired. Generate a new one using the login API and update the channel configuration.

**Bot joins the room but messages are empty**
- This usually indicates an encrypted room where the bot cannot decrypt messages. Move to an unencrypted room or verify that E2EE support is enabled in your gateway version.
