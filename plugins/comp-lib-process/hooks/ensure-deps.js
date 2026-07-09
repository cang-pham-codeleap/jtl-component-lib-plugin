#!/usr/bin/env node
// ensure-deps.js — JTL plugin SessionStart hook
// Reads deps.json at the plugin root, checks installed companions,
// and installs any that are missing via `claude plugin install`.

const fs = require("fs");
const path = require("path");
const os = require("os");
const { execSync } = require("child_process");

// deps.json lives in plugins/comp-lib-process/ — one level above hooks/
const depsPath = path.join(__dirname, "../deps.json");
const claudeDir =
  process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), ".claude");
const installedPath = path.join(claudeDir, "plugins", "installed_plugins.json");

function getRequiredDeps() {
  try {
    const raw = fs.readFileSync(depsPath, "utf8");
    return JSON.parse(raw).required ?? [];
  } catch {
    return [];
  }
}

function getInstalledPlugins() {
  try {
    const raw = fs.readFileSync(installedPath, "utf8");
    return JSON.parse(raw);
  } catch {
    return { plugins: {} };
  }
}

// Handle both array-of-paths and object-with-metadata storage formats.
function isInstalled(pluginId, installed) {
  const entry = installed.plugins?.[pluginId];
  if (!entry) return false;
  if (Array.isArray(entry)) return entry.length > 0;
  if (typeof entry === "object") return Object.keys(entry).length > 0;
  return Boolean(entry);
}

const required = getRequiredDeps();
const installed = getInstalledPlugins();
const missing = required.filter((p) => !isInstalled(p.id, installed));

if (missing.length === 0) {
  process.stdout.write("OK");
  process.exit(0);
}

const labels = missing.map((p) => p.label).join(", ");
process.stderr.write(`[jtl-plugin] Installing missing plugins: ${labels}\n`);

for (const plugin of missing) {
  try {
    execSync(`claude plugin install ${plugin.id}`, { stdio: "inherit" });
  } catch (err) {
    process.stderr.write(
      `[jtl-plugin] Failed to install ${plugin.label}: ${err.message}\n`,
    );
  }
}

process.stdout.write("OK");
process.exit(0);
