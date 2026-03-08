# Web Dashboard Setup Guide

[← Back to Channel Overview](README.md)

ScienceClaw includes a built-in web dashboard that lets you interact with your agent through a browser. No external platform credentials are needed.

## Prerequisites

- ScienceClaw installed (`bash scripts/setup.sh` completed)
- A `.env` file with at least one LLM provider configured

## Step 1: Start the Gateway

```bash
scienceclaw run
```

This starts the gateway on port 18789 and opens the TUI.

## Step 2: Launch the Dashboard

```bash
scienceclaw dashboard
```

This starts the web dashboard server. Your default browser opens automatically. If it does not, copy the URL printed in the terminal (typically `http://127.0.0.1:<port>`).

## Step 3: Log In

The terminal displays a one-time login token. Enter it in the browser when prompted. This token authenticates your session without requiring a separate account system.

## Step 4: Test

Type a message in the chat interface. ScienceClaw processes it through the gateway and replies in the browser.

## Remote Access

The dashboard binds to `127.0.0.1` by default and is only accessible from the local machine. To access it from another device:

### SSH Tunnel (Recommended)

From your local machine, create an SSH tunnel to the remote server:

```bash
ssh -L 8080:127.0.0.1:<DASHBOARD_PORT> user@remote-server
```

Then open `http://127.0.0.1:8080` in your local browser.

### Reverse Proxy

For persistent remote access, place the dashboard behind a reverse proxy (e.g., Nginx, Caddy) with HTTPS and authentication:

```nginx
server {
    listen 443 ssl;
    server_name scienceclaw.example.com;

    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://127.0.0.1:<DASHBOARD_PORT>;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}
```

Include WebSocket upgrade headers since the dashboard uses WebSocket connections.

## Security Notes

- Never expose the dashboard directly to the public internet without authentication and HTTPS.
- The login token is printed to the terminal and should be treated as a secret.
- If running on a shared server, ensure file permissions on ScienceClaw's configuration directory are restricted to your user.

## Verify

Confirm the gateway is running:

```bash
scienceclaw status
```

## Troubleshooting

**Browser does not open automatically**
- Copy the URL from the terminal output and open it manually.
- On headless servers, there is no browser to open — use SSH tunneling to access the dashboard from your local machine.

**"Connection refused" in the browser**
- The gateway may not be running. Start it with `scienceclaw run` before launching the dashboard.
- Check that the port is not blocked by a firewall.

**WebSocket connection drops**
- If using a reverse proxy, confirm that WebSocket upgrade headers are configured correctly.
- Some corporate proxies block WebSocket traffic. Try accessing via SSH tunnel instead.
