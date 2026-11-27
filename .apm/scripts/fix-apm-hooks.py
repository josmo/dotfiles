#!/usr/bin/env python3
"""Repairs hooks that APM writes into Claude Code's settings.json for Claude plugins.

APM rewrites ~/.claude/settings.json's hooks on every install and update, so this runs as a
lifecycle script (see `lifecycle:` in apm.yml). Each fix targets one APM gap:

APM 0.39+ installs context-mode and superpowers as native Claude plugins, which set
CLAUDE_PLUGIN_ROOT and pick their own hook files, so they need no repair here.

1. ponytail: APM parks it (it ships userConfig), so it stays a loose install. Its hook commands
   read `process.env.CLAUDE_PLUGIN_ROOT` inside `node -e`, which APM can't rewrite and Claude
   Code only sets for native plugins. Point them at apm_modules.
2. Removed or replaced packages: APM deletes their hook scripts but leaves the hooks in
   settings.json, and a missing script fails every call (python exits 2, which blocks the
   tool). Drop hooks whose script file is gone, exact duplicates, and the loose superpowers
   hook this script used to write (the native plugin runs its own; keeping both doubles it).

Usage: fix-apm-hooks.py [SETTINGS_JSON]
"""
import json
import os
import re
import sys

PONYTAIL_ROOT = os.path.expanduser("~/.apm/apm_modules/dietrichgebert/ponytail")
# Pre-0.39 loose superpowers hook, as this script used to rewrite it.
LEGACY_SUPERPOWERS = os.path.expanduser("~/.apm/apm_modules/obra/superpowers/hooks/run-hook.cmd")
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


def missing_script(command):
    match = SCRIPT_PATH.search(command)
    return match.group(1) if match and not os.path.exists(match.group(1)) else None


for event in list(hooks):
    kept_entries = []
    seen = set()
    for entry in hooks[event]:
        commands = [h.get("command", "") for h in entry.get("hooks", [])]
        if commands and all(LEGACY_SUPERPOWERS in c for c in commands):
            changes.append(f"dropped legacy {event} superpowers hook")
            continue
        key = json.dumps([entry.get("matcher"), [h.get("command") for h in entry.get("hooks", [])]])
        if key in seen:
            changes.append(f"dropped duplicate {event} hook")
            continue
        seen.add(key)
        missing = [missing_script(h.get("command", "")) for h in entry.get("hooks", [])]
        if missing and all(missing):
            changes.append(f"dropped {event} hook for missing {missing[0]}")
            continue
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
