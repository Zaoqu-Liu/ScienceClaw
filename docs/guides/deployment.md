# Deployment Guide

ScienceClaw can run locally for personal use, in Docker for isolated environments, or as a persistent service for teams.

---

## Local Development (Default)

The simplest way to run ScienceClaw. The gateway runs on your machine and the TUI connects locally.

```bash
# One command: starts gateway + opens TUI
./scienceclaw run
```

This is equivalent to:

```bash
# Terminal 1: Start gateway in background
./scienceclaw start

# Terminal 2: Connect TUI
./scienceclaw tui
```

**Details:**
- Gateway listens on `localhost:18789`
- Gateway log at `~/.scienceclaw/gateway.log`
- PID file at `~/.scienceclaw/gateway.pid`
- Agent workspace at `~/.scienceclaw/workspace`

### Managing the Gateway

```bash
./scienceclaw status    # Check if running
./scienceclaw stop      # Graceful shutdown
./scienceclaw run       # Restart everything
```

---

## Docker Deployment

Docker provides an isolated sandbox for code execution, preventing the agent from modifying your host system.

### Prerequisites

- Docker 24.0+ installed and running
- Docker Compose v2+

### Build the Sandbox Image

```bash
cd docker
docker build -t scienceclaw-sandbox:latest .
```

### Docker Compose

Create a `docker-compose.yml` in the project root:

```yaml
version: "3.9"

services:
  gateway:
    image: node:22-slim
    working_dir: /app
    volumes:
      - .:/app
      - scienceclaw-data:/root/.scienceclaw
    ports:
      - "18789:18789"
    env_file:
      - .env
    environment:
      - OPENCLAW_CONFIG_PATH=/app/openclaw.config.json
      - SCIENCECLAW_WORKSPACE=/root/.scienceclaw/workspace
    command: >
      sh -c "cd /app && npm install --silent &&
             node /app/node_modules/openclaw/openclaw.mjs gateway run --force --port 18789"
    restart: unless-stopped

  sandbox:
    image: scienceclaw-sandbox:latest
    volumes:
      - scienceclaw-data:/workspace
    network_mode: "host"
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: "2.0"

volumes:
  scienceclaw-data:
```

### Start the Stack

```bash
docker compose up -d
```

### Connect the TUI

From your host machine:

```bash
./scienceclaw tui --gateway ws://localhost:18789
```

### Environment Variables in Docker

Pass API keys via `.env` file or environment section:

```yaml
environment:
  - OPENAI_API_KEY=sk-your-key
  - OPENAI_BASE_URL=https://openrouter.ai/api/v1
  - CLAUDE_API_KEY=sk-your-key
  - CLAUDE_BASE_URL=https://openrouter.ai/api/v1
```

Never bake API keys into Docker images.

---

## Production Deployment

For persistent, always-on deployment on a Linux server.

### systemd Service

Create `/etc/systemd/system/scienceclaw.service`:

```ini
[Unit]
Description=ScienceClaw Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=scienceclaw
Group=scienceclaw
WorkingDirectory=/opt/scienceclaw
ExecStart=/usr/bin/node /opt/scienceclaw/node_modules/openclaw/openclaw.mjs gateway run --force --port 18789
Restart=on-failure
RestartSec=10
Environment=OPENCLAW_CONFIG_PATH=/opt/scienceclaw/openclaw.config.json
EnvironmentFile=/opt/scienceclaw/.env

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ReadWritePaths=/opt/scienceclaw /home/scienceclaw/.scienceclaw
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

### Install and Enable

```bash
# Create service user
sudo useradd -r -m -s /bin/bash scienceclaw

# Copy project files
sudo mkdir -p /opt/scienceclaw
sudo cp -r . /opt/scienceclaw/
sudo chown -R scienceclaw:scienceclaw /opt/scienceclaw

# Install dependencies as service user
sudo -u scienceclaw bash -c "cd /opt/scienceclaw && pnpm install"

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable scienceclaw
sudo systemctl start scienceclaw

# Check status
sudo systemctl status scienceclaw
sudo journalctl -u scienceclaw -f
```

### Reverse Proxy with Nginx

For HTTPS and WebSocket proxying:

```nginx
server {
    listen 443 ssl;
    server_name scienceclaw.example.com;

    ssl_certificate /etc/letsencrypt/live/scienceclaw.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/scienceclaw.example.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:18789;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 86400;
    }
}
```

---

## Cloud Deployment

### Fly.io

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Initialize
fly launch --no-deploy

# Set secrets
fly secrets set OPENAI_API_KEY=sk-your-key
fly secrets set OPENAI_BASE_URL=https://openrouter.ai/api/v1
fly secrets set CLAUDE_API_KEY=sk-your-key
fly secrets set CLAUDE_BASE_URL=https://openrouter.ai/api/v1

# Deploy
fly deploy
```

Example `fly.toml`:

```toml
app = "scienceclaw"
primary_region = "sjc"

[build]
  dockerfile = "Dockerfile"

[http_service]
  internal_port = 18789
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 1024
```

### Railway

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and initialize
railway login
railway init

# Set environment variables
railway variables set OPENAI_API_KEY=sk-your-key
railway variables set OPENAI_BASE_URL=https://openrouter.ai/api/v1

# Deploy
railway up
```

---

## Security Considerations

### API Key Management

- Never commit `.env` to version control (it's in `.gitignore`)
- Use environment variables or secret managers in production
- Rotate keys periodically
- Use separate keys for development and production

### Gateway Authentication

The gateway uses token-based auth by default. The token is set in `openclaw.config.json`:

```json
{
  "gateway": {
    "auth": {
      "mode": "token",
      "token": "generate-a-strong-random-token"
    }
  }
}
```

Generate a secure token:

```bash
openssl rand -hex 24
```

### Network Security

- In production, always run behind a reverse proxy with HTTPS
- Never expose port 18789 directly to the internet without authentication
- Use firewall rules to restrict access to trusted IPs
- The gateway accepts WebSocket connections -- ensure your proxy handles WS correctly

### Code Execution Sandbox

When the agent runs code via `bash`, it executes on the host by default. For production:

- Use the Docker sandbox to isolate code execution
- Set resource limits (CPU, memory) on the sandbox container
- Mount only the workspace directory, not the entire filesystem
- Consider running with `--read-only` root filesystem

---

## Monitoring

### Health Check

```bash
# Check gateway status
./scienceclaw status

# View gateway logs
tail -f ~/.scienceclaw/gateway.log

# For systemd deployments
sudo journalctl -u scienceclaw -f --no-pager
```

### Log Rotation

For long-running deployments, configure log rotation:

```bash
# /etc/logrotate.d/scienceclaw
~/.scienceclaw/gateway.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
```

---

## See Also

- [Installation](../getting-started/installation.md) -- initial setup
- [Configuration](../getting-started/configuration.md) -- all config options
- [Troubleshooting](troubleshooting.md) -- common deployment issues
