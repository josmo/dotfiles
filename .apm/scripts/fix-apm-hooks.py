#!/usr/bin/env python3
"""Repairs hooks that APM writes into Claude Code's settings.json for Claude plugins.

APM rewrites ~/.claude/settings.json's hooks on every install and update, so this runs as a
lifecycle script (see `lifecycle:` in apm.yml). Each fix targets one APM gap:

1. context-mode v2: APM ignores the plugin's `"hooks": "./hooks/claude-code.json"` and merges
   every file in hooks/ (codex, copilot, qwen, vscode, kiro), so drop context-mode hooks that
   aren't `--agent claude-code`. Its matchers also name the native-plugin tools
   (mcp__plugin_context-mode_context-mode__*), but APM registers the server as `context-mode`.
2. ponytail: its hook commands read `process.env.CLAUDE_PLUGIN_ROOT` inside `node -e`, which
   APM can't rewrite and Claude Code only sets for native plugins. Point them at apm_modules.
3. superpowers: its session-start script finds skills/ relative to itself, but APM deploys the
   hook to ~/.claude/hooks/ and the skills to ~/.claude/skills/, and without CLAUDE_PLUGIN_ROOT
   it writes the wrong output key. Run the apm_modules copy with CLAUDE_PLUGIN_ROOT set.
4. Removed or replaced packages: APM deletes their hook scripts but leaves the hooks in
   settings.json, and a missing script fails every call (python exits 2, which blocks the
   tool). Drop hooks whose script file is gone, and exact duplicate entries.

Usage: fix-apm-hooks.py [SETTINGS_JSON]
"""
import json
import os
import re
import sys

# context-mode v2 hooks all run `node [path/]hook.mjs --agent <host>`; APM deploys them under
# hooks/claude-code/ (the subdirectory's name), so the commands never say "context-mode".
CONTEXT_MODE_HOOK = re.compile(r'hook\.mjs"?\s+--agent\s+(\S+)')
PONYTAIL_ROOT = os.path.expanduser("~/.apm/apm_modules/dietrichgebert/ponytail")
SUPERPOWERS_ROOT = os.path.expanduser("~/.apm/apm_modules/obra/superpowers")
SUPERPOWERS_DEPLOYED = os.path.expanduser("~/.claude/hooks/superpowers/hooks/run-hook.cmd")
SUPERPOWERS_COMMAND = f'CLAUDE_PLUGIN_ROOT="{SUPERPOWERS_ROOT}" "{SUPERPOWERS_ROOT}/hooks/run-hook.cmd" session-start'
# A script path in a hook command, e.g. python3 "/Users/x/.claude/hooks/pkg/hooks/stop.py"
SCRIPT_PATH = re.compile(r'"(/[^"]+\.(?:py|mjs|js|cjs|sh|cmd))"')

path = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/.claude/settings.json")
try:
    with open(path) as f:
        settings = json.load(f)
except FileNotFoundError:
    sys.exit(0)

hooks = settings.get("hooks", {})
changes = []


def foreign_context_mode_agent(command):
    match = CONTEXT_MODE_HOOK.search(command)
    return match.group(1) if match and match.group(1) != "claude-code" else None


def missing_script(command):
    match = SCRIPT_PATH.search(command)
    return match.group(1) if match and not os.path.exists(match.group(1)) else None


for event in list(hooks):
    kept_entries = []
    seen = set()
    for entry in hooks[event]:
        for h in entry.get("hooks", []):
            if SUPERPOWERS_DEPLOYED in h.get("command", "") and "session-start" in h["command"]:
                h["command"] = SUPERPOWERS_COMMAND
                h.pop("powershell", None)
                changes.append(f"pointed {event} superpowers hook at {SUPERPOWERS_ROOT}")
        key = json.dumps([entry.get("matcher"), [h.get("command") for h in entry.get("hooks", [])]])
        if key in seen:
            changes.append(f"dropped duplicate {event} hook")
            continue
        seen.add(key)
        missing = [missing_script(h.get("command", "")) for h in entry.get("hooks", [])]
        if missing and all(missing):
            changes.append(f"dropped {event} hook for missing {missing[0]}")
            continue
        agents = [foreign_context_mode_agent(h.get("command", "")) for h in entry.get("hooks", [])]
        if agents and all(agents):
            changes.append(f"dropped {event} context-mode hook for {agents[0]}")
            continue
        matcher = entry.get("matcher", "")
        if "mcp__plugin_context-mode_context-mode__" in matcher:
            entry["matcher"] = matcher.replace("mcp__plugin_context-mode_context-mode__", "mcp__context-mode__")
            changes.append(f"renamed {event} context-mode tool matcher")
        for h in entry.get("hooks", []):
            command = h.get("command", "")
            if "ponytail" in command and "process.env.CLAUDE_PLUGIN_ROOT" in command:
                h["command"] = command.replace("process.env.CLAUDE_PLUGIN_ROOT", repr(PONYTAIL_ROOT))
                changes.append(f"pointed {event} ponytail hook at {PONYTAIL_ROOT}")
        kept_entries.append(entry)
    if kept_entries:
        hooks[event] = kept_entries
    else:
        del hooks[event]
        changes.append(f"removed empty {event}")

if changes:
    with open(path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    for c in changes:
        print(c)
