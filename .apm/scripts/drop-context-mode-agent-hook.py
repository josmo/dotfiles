#!/usr/bin/env python3
"""Removes context-mode's PreToolUse hook on the Agent tool from Claude Code's settings.

That hook appends guidance to every subagent's prompt. Claude Code's auto mode reviews the
prompt before hooks run, so it refuses any subagent launch whose input a hook then changes.
context-mode's other hooks (Bash, Read, Grep, WebFetch, its own tools) stay.

APM rewrites the hooks on every install and update, so this runs as a lifecycle script
(see `lifecycle:` in apm.yml). Usage: drop-context-mode-agent-hook.py [SETTINGS_JSON]
"""
import json
import os
import sys

path = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser("~/.claude/settings.json")
try:
    with open(path) as f:
        settings = json.load(f)
except FileNotFoundError:
    sys.exit(0)

entries = settings.get("hooks", {}).get("PreToolUse", [])


def is_context_mode_agent(entry):
    commands = [h.get("command", "") for h in entry.get("hooks", [])]
    return entry.get("matcher") == "Agent" and commands and all("context-mode" in c for c in commands)


kept = [e for e in entries if not is_context_mode_agent(e)]
if len(kept) != len(entries):
    settings["hooks"]["PreToolUse"] = kept
    with open(path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    print(f"removed context-mode's Agent hook from {path}")
