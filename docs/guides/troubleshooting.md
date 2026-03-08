# Troubleshooting

Common issues and their solutions when running ScienceClaw.

---

## Gateway Issues

### Gateway Won't Start

**Symptom:** `scienceclaw run` hangs or prints "Gateway failed to start."

**Check the log:**

```bash
cat /tmp/scienceclaw-gateway.log
```

**Common causes:**

#### Port 18789 Already in Use

Another process (or a previous ScienceClaw instance) is occupying the port.

```bash
# Find what's using the port
lsof -i :18789

# Kill the old process
./scienceclaw stop

# Or kill manually
kill $(lsof -i :18789 -t)

# Try again
./scienceclaw run
```

#### Node.js Version Too Old

The gateway requires Node.js 22+.

```bash
node -v
# If < v22:
nvm install 22 && nvm use 22
```

#### OpenClaw Engine Not Installed

```bash
# Check if the engine exists
ls node_modules/openclaw/openclaw.mjs

# If missing, re-run setup
bash scripts/setup.sh
```

#### OpenClaw Engine Not Found

The OpenClaw engine is installed as an npm dependency. Re-run setup to install it:

```bash
bash scripts/setup.sh
```

If the problem persists, try a clean install:

```bash
rm -rf node_modules
bash scripts/setup.sh
```

---

### Gateway Starts but TUI Can't Connect

**Symptom:** TUI shows "not connected" or "connecting..."

**Verify the gateway is actually running:**

```bash
./scienceclaw status
```

If it reports "Gateway not running", the gateway may have crashed after starting. Check the log:

```bash
tail -50 /tmp/scienceclaw-gateway.log
```

**Verify the port:**

```bash
lsof -i :18789
```

If the port is open but TUI can't connect, the auth token may be mismatched. Both the gateway and TUI read from the same `openclaw.config.json`, so this should not happen unless the file was modified mid-session. Restart everything:

```bash
./scienceclaw stop && ./scienceclaw run
```

---

## Agent Issues

### Agent Not Responding

**Symptom:** You send a message but get no response, or the agent takes extremely long.

**Check API key validity:**

```bash
# Test your API key directly
source .env
curl -s "$OPENAI_BASE_URL/models" \
  -H "Authorization: Bearer $OPENAI_API_KEY" | head -20
```

If this returns an error, your API key is invalid or expired.

**Check the model exists:**

Verify the model ID in `openclaw.config.json` matches what your provider offers. For relay services, the model ID may differ from the official name.

**Common fixes:**

- Regenerate your API key from the provider dashboard
- Check your account balance/credits
- Try a different model (e.g., switch from `claude-opus-4-6` to `gpt-4o`)
- Check if the relay service (yunwu.ai, openrouter) is operational

### Agent Returns Errors About Tools

**Symptom:** Agent says it can't use `web_fetch` or `bash`.

The agent needs `"tools": { "profile": "full" }` in its config. Check `openclaw.config.json`:

```json
{
  "agents": {
    "list": [
      {
        "id": "scienceclaw",
        "tools": {
          "profile": "full"
        }
      }
    ]
  }
}
```

Restart after changing.

### Agent Gives Wrong/Generic Answers

If the agent responds like a generic assistant instead of a science agent:

1. Verify `SCIENCE.md` exists in the project root
2. Check that `OPENCLAW_CONFIG_PATH` points to the correct config file
3. Restart the gateway to reload the agent identity

---

## Skills Issues

### Skills Not Loading

**Symptom:** Agent doesn't seem to know about specific databases or techniques that have skills.

**Check skills path in config:**

```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "/absolute/path/to/scienceclaw/skills"
      ]
    }
  }
}
```

The path must be **absolute**, not relative.

**Check the skills directory exists and has content:**

```bash
ls skills/ | wc -l
# Should show 264+ entries
```

**Check loading limits:**

If you have more skills than the limits allow:

```json
{
  "skills": {
    "limits": {
      "maxSkillsLoadedPerSource": 300,
      "maxCandidatesPerRoot": 300
    }
  }
}
```

Increase these values if needed.

**Check character budget:**

Skills compete for context space. If `bootstrapTotalMaxChars` is too low, some skills may be dropped:

```json
{
  "agents": {
    "defaults": {
      "bootstrapMaxChars": 30000,
      "bootstrapTotalMaxChars": 200000
    }
  }
}
```

### Custom Skills Not Appearing

If you added a custom skill directory:

1. Verify the directory contains a `SKILL.md` file (not `skill.md` or `README.md`)
2. Verify the parent directory is listed in `extraDirs`
3. Restart the gateway after adding new skills

---

## Docker & Sandbox Issues

### Docker Not Installed

**Symptom:** Sandbox features fail with "docker: command not found."

Docker is optional -- ScienceClaw works without it. Code execution falls back to running directly on the host via `bash`. To enable Docker sandbox:

```bash
# macOS
brew install --cask docker

# Ubuntu
sudo apt-get install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in for group changes
```

### Docker Permission Errors

**Symptom:** "permission denied while trying to connect to the Docker daemon"

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Apply without logout (current shell only)
newgrp docker

# Verify
docker ps
```

### Sandbox Image Not Found

```bash
# Build the sandbox image
cd docker
docker build -t scienceclaw-sandbox:latest .
```

### Container Resource Limits

If analyses crash with out-of-memory errors in Docker:

```yaml
# In docker-compose.yml, increase limits:
deploy:
  resources:
    limits:
      memory: 8G
      cpus: "4.0"
```

---

## Common Warnings

### "State dir migration" Warning

**Message:** Something about state directory migration or legacy paths.

This is **benign** and can be safely ignored. It occurs when the engine detects an older state directory format and offers to migrate. The agent functions normally regardless.

### "Model not found" Warning at Startup

The engine may warn about models that are configured but not available from the provider. This is harmless if at least one model works. Remove unused model entries from `openclaw.config.json` to silence the warnings.

### Slow First Response

The first query after starting may take longer (30-60 seconds) because:

1. The engine loads and indexes all 264 skills
2. The model processes SCIENCE.md and relevant skills
3. The first API call may have cold-start latency

Subsequent queries are faster.

---

## Diagnostic Commands

```bash
# Check gateway status
./scienceclaw status

# View gateway log
cat /tmp/scienceclaw-gateway.log

# View recent gateway log
tail -50 /tmp/scienceclaw-gateway.log

# Check Node.js version
node -v

# Check if dependencies are installed
ls node_modules/openclaw/openclaw.mjs

# Test API key
source .env && curl -s "$OPENAI_BASE_URL/models" -H "Authorization: Bearer $OPENAI_API_KEY" | head -5

# Check port availability
lsof -i :18789

# Check skills count
ls skills/ | wc -l

# Full reset (nuclear option)
./scienceclaw stop
rm -rf node_modules
bash scripts/setup.sh
./scienceclaw run
```

---

## Getting Help

If none of the above resolves your issue:

1. Check the [GitHub Issues](https://github.com/Zaoqu-Liu/scienceclaw/issues) for known problems
2. Open a new issue with:
   - Your OS and Node.js version (`node -v`)
   - The error message or unexpected behavior
   - Contents of `/tmp/scienceclaw-gateway.log`
   - Your `openclaw.config.json` (with API keys redacted)

---

## See Also

- [Installation](../getting-started/installation.md) -- setup from scratch
- [Configuration](../getting-started/configuration.md) -- all configuration options
- [Deployment](deployment.md) -- production deployment
