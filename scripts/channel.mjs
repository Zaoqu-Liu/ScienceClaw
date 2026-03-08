#!/usr/bin/env node
/**
 * ScienceClaw Channel Manager
 *
 * Usage:
 *   node channel.mjs add <channel> [token] [token2]
 *   node channel.mjs remove <channel>
 *   node channel.mjs list
 */

import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { createInterface } from "node:readline";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, "..");
const CONFIG_PATH = resolve(ROOT, "openclaw.config.json");
const ENV_PATH = resolve(ROOT, ".env");

// ── Channel definitions ─────────────────────────────────────────────

const CHANNELS = {
  telegram: {
    name: "Telegram",
    envKeys: ["TELEGRAM_BOT_TOKEN"],
    prompts: ["Telegram bot token (from @BotFather)"],
    config: {
      enabled: true,
      dmPolicy: "open",
      allowFrom: ["*"],
      botToken: "${TELEGRAM_BOT_TOKEN}",
      groupPolicy: "open",
      groupAllowFrom: ["*"],
      streaming: "partial",
      commands: { native: false },
      timeoutSeconds: 90,
      retry: { attempts: 5, minDelayMs: 500, maxDelayMs: 30000, jitter: 0.2 },
      network: { autoSelectFamily: false, dnsResultOrder: "ipv4first" },
    },
    plugin: true,
    hint: "Create a bot at @BotFather on Telegram, then paste the token here.",
  },
  discord: {
    name: "Discord",
    envKeys: ["DISCORD_BOT_TOKEN"],
    prompts: ["Discord bot token"],
    config: {
      enabled: true,
      token: "${DISCORD_BOT_TOKEN}",
      dmPolicy: "open",
      allowFrom: ["*"],
      streaming: "partial",
      commands: { native: false },
      retry: { attempts: 3, minDelayMs: 500, maxDelayMs: 30000, jitter: 0.1 },
    },
    plugin: true,
    hint: "Create a bot at discord.com/developers/applications → Bot → Copy Token.\n  Enable all Privileged Gateway Intents (Presence, Server Members, Message Content).",
  },
  slack: {
    name: "Slack",
    envKeys: ["SLACK_BOT_TOKEN", "SLACK_APP_TOKEN"],
    prompts: ["Slack bot token (xoxb-...)", "Slack app token (xapp-...)"],
    config: {
      enabled: true,
      botToken: "${SLACK_BOT_TOKEN}",
      appToken: "${SLACK_APP_TOKEN}",
      dmPolicy: "open",
      allowFrom: ["*"],
      streaming: "partial",
    },
    plugin: true,
    hint: "Create a Slack app at api.slack.com/apps → Socket Mode → get App Token (xapp-).\n  Install to workspace → get Bot Token (xoxb-).",
  },
  whatsapp: {
    name: "WhatsApp",
    envKeys: [],
    prompts: [],
    config: {
      dmPolicy: "open",
      allowFrom: ["*"],
      sendReadReceipts: true,
      groups: { "*": { requireMention: true } },
    },
    extraConfig: {
      web: {
        enabled: true,
        heartbeatSeconds: 60,
        reconnect: { initialMs: 2000, maxMs: 120000, factor: 1.4, jitter: 0.2, maxAttempts: 0 },
      },
    },
    plugin: false,
    hint: "After adding, run:  ./scienceclaw channels login --channel whatsapp\n  Then scan the QR code with WhatsApp on your phone.",
  },
  feishu: {
    name: "Feishu / Lark",
    envKeys: ["FEISHU_APP_ID", "FEISHU_APP_SECRET"],
    prompts: ["Feishu App ID", "Feishu App Secret"],
    config: {
      enabled: true,
      appId: "${FEISHU_APP_ID}",
      appSecret: "${FEISHU_APP_SECRET}",
      dmPolicy: "open",
      allowFrom: ["*"],
    },
    plugin: true,
    hint: "Create a custom app at open.feishu.cn → add Bot capability → get App ID & Secret.",
  },
  matrix: {
    name: "Matrix",
    envKeys: ["MATRIX_HOMESERVER", "MATRIX_USER_ID", "MATRIX_ACCESS_TOKEN"],
    prompts: [
      "Matrix homeserver URL (e.g., https://matrix.org)",
      "Bot user ID (e.g., @scienceclaw:matrix.org)",
      "Access token",
    ],
    config: {
      enabled: true,
      homeserver: "${MATRIX_HOMESERVER}",
      userId: "${MATRIX_USER_ID}",
      accessToken: "${MATRIX_ACCESS_TOKEN}",
      dmPolicy: "open",
      allowFrom: ["*"],
    },
    plugin: true,
    hint: "Create a bot account on your homeserver, then get an access token via Element or the login API.",
  },
  wechat: {
    name: "WeCom (企业微信)",
    envKeys: ["WECOM_CORP_ID", "WECOM_AGENT_SECRET", "WECOM_TOKEN", "WECOM_AES_KEY"],
    prompts: ["WeCom Corp ID", "WeCom Agent Secret", "Callback Token", "Callback EncodingAESKey"],
    config: {
      enabled: true,
      corpId: "${WECOM_CORP_ID}",
      agentSecret: "${WECOM_AGENT_SECRET}",
      token: "${WECOM_TOKEN}",
      aesKey: "${WECOM_AES_KEY}",
      dmPolicy: "open",
      allowFrom: ["*"],
    },
    plugin: true,
    hint: "Create an app at work.weixin.qq.com → App Management → get credentials.",
  },
};

// ── Utilities ────────────────────────────────────────────────────────

function readConfig() {
  try {
    return JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
  } catch (err) {
    console.error(`  ❌ Cannot read ${CONFIG_PATH}: ${err.message}`);
    console.error("  Run: bash scripts/setup.sh");
    process.exit(1);
  }
}

function writeConfig(cfg) {
  writeFileSync(CONFIG_PATH, JSON.stringify(cfg, null, 2) + "\n");
}

function readEnv() {
  if (!existsSync(ENV_PATH)) return {};
  const lines = readFileSync(ENV_PATH, "utf8").split("\n");
  const env = {};
  for (const line of lines) {
    const m = line.match(/^([A-Za-z_][A-Za-z_0-9]*)=(.*)/);
    if (m) env[m[1]] = m[2];
  }
  return env;
}

function setEnvVar(key, value) {
  if (!existsSync(ENV_PATH)) {
    writeFileSync(ENV_PATH, `${key}=${value}\n`);
    return;
  }
  let content = readFileSync(ENV_PATH, "utf8");
  const regex = new RegExp(`^${key}=.*$`, "m");
  if (regex.test(content)) {
    content = content.replace(regex, `${key}=${value}`);
  } else {
    content = content.trimEnd() + `\n${key}=${value}\n`;
  }
  writeFileSync(ENV_PATH, content);
}

function removeEnvVar(key) {
  if (!existsSync(ENV_PATH)) return;
  let content = readFileSync(ENV_PATH, "utf8");
  content = content.replace(new RegExp(`^${key}=.*\n?`, "m"), "");
  writeFileSync(ENV_PATH, content);
}

async function prompt(question) {
  const rl = createInterface({ input: process.stdin, output: process.stderr });
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

// ── Commands ─────────────────────────────────────────────────────────

async function addChannel(channelId, args) {
  const def = CHANNELS[channelId];
  if (!def) {
    const supported = Object.keys(CHANNELS).join(", ");
    console.error(`  ❌ Unknown channel: ${channelId}`);
    console.error(`  Supported: ${supported}`);
    process.exit(1);
  }

  console.error("");
  console.error(`  Adding ${def.name} channel`);
  console.error(`  ${"─".repeat(40)}`);
  if (def.hint) {
    console.error(`  💡 ${def.hint}`);
    console.error("");
  }

  const cfg = readConfig();
  if (cfg.channels?.[channelId]?.enabled) {
    console.error(`  ⚠️  ${def.name} is already configured.`);
    const answer = await prompt("  Overwrite? (y/N): ");
    if (answer.toLowerCase() !== "y") {
      console.error("  Cancelled.");
      process.exit(0);
    }
  }

  const values = [];
  for (let i = 0; i < def.envKeys.length; i++) {
    let value = args[i] || "";
    if (!value) {
      value = await prompt(`  ${def.prompts[i]}: `);
    }
    if (!value) {
      console.error(`  ❌ ${def.prompts[i]} is required.`);
      process.exit(1);
    }
    values.push(value);
  }

  for (let i = 0; i < def.envKeys.length; i++) {
    setEnvVar(def.envKeys[i], values[i]);
  }

  if (!cfg.channels) cfg.channels = {};
  cfg.channels[channelId] = def.config;

  if (def.extraConfig) {
    for (const [key, val] of Object.entries(def.extraConfig)) {
      cfg[key] = val;
    }
  }

  if (def.plugin) {
    if (!cfg.plugins) cfg.plugins = { entries: {} };
    if (!cfg.plugins.entries) cfg.plugins.entries = {};
    cfg.plugins.entries[channelId] = { enabled: true };
  }

  writeConfig(cfg);

  console.error("");
  console.error(`  ✅ ${def.name} added!`);
  if (def.envKeys.length > 0) {
    console.error(`  📝 Credentials saved to .env`);
  }
  if (channelId === "whatsapp") {
    console.error("");
    console.error("  Next: scan QR code to link WhatsApp:");
    console.error("    ./scienceclaw channels login --channel whatsapp");
  }
  console.error("");
  console.error("  Apply changes:");
  console.error("    ./scienceclaw restart");
  console.error("");
}

function removeChannel(channelId) {
  const def = CHANNELS[channelId];
  if (!def) {
    console.error(`  ❌ Unknown channel: ${channelId}`);
    process.exit(1);
  }

  const cfg = readConfig();
  if (cfg.channels && cfg.channels[channelId]) {
    delete cfg.channels[channelId];
  }
  if (cfg.plugins?.entries?.[channelId]) {
    delete cfg.plugins.entries[channelId];
  }
  if (channelId === "whatsapp" && cfg.web) {
    delete cfg.web;
  }
  writeConfig(cfg);

  for (const key of def.envKeys) {
    removeEnvVar(key);
  }

  console.error("");
  console.error(`  ✅ ${def.name} removed.`);
  console.error("  Apply changes: ./scienceclaw restart");
  console.error("");
}

function listChannels() {
  const cfg = readConfig();
  const env = readEnv();
  const active = [];
  const inactive = [];

  for (const [id, def] of Object.entries(CHANNELS)) {
    const ch = cfg.channels?.[id];
    if (ch && ch.enabled !== false) {
      const hasCredentials = def.envKeys.length === 0 ||
        def.envKeys.every((k) => env[k]);
      active.push({ id, name: def.name, hasCredentials });
    } else {
      inactive.push({ id, name: def.name });
    }
  }

  console.error("");
  if (active.length === 0) {
    console.error("  No channels configured.");
    console.error("  Add one:  ./scienceclaw add <channel>");
    console.error(`  Options:  ${Object.keys(CHANNELS).join(", ")}`);
  } else {
    console.error("  Active channels:");
    for (const ch of active) {
      const status = ch.hasCredentials ? "✅" : "⚠️  (missing credentials in .env)";
      console.error(`    ${status} ${ch.name} (${ch.id})`);
    }
    if (inactive.length > 0) {
      console.error("");
      console.error("  Available to add:");
      for (const ch of inactive) {
        console.error(`    ○  ${ch.name} — ./scienceclaw add ${ch.id}`);
      }
    }
  }

  console.error("");
  console.error("  Web Dashboard and Terminal UI are always available:");
  console.error("    ./scienceclaw run          # Terminal UI");
  console.error("    ./scienceclaw dashboard     # Web browser");
  console.error("");
}

// ── Main ─────────────────────────────────────────────────────────────

const [, , command, channelId, ...rest] = process.argv;

switch (command) {
  case "add":
    if (!channelId) {
      console.error("  Usage: ./scienceclaw add <channel> [token...]");
      console.error(`  Channels: ${Object.keys(CHANNELS).join(", ")}`);
      process.exit(1);
    }
    await addChannel(channelId, rest);
    break;
  case "remove":
    if (!channelId) {
      console.error("  Usage: ./scienceclaw remove <channel>");
      process.exit(1);
    }
    removeChannel(channelId);
    break;
  case "list":
    listChannels();
    break;
  default:
    console.error("  Usage:");
    console.error("    ./scienceclaw add <channel> [token...]");
    console.error("    ./scienceclaw remove <channel>");
    console.error("    ./scienceclaw channels");
    process.exit(1);
}
