# Agent Instructions Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize `.config/agents/core.md` into area sections with repo modes and a self-improvement loop, tidy `host.md`, mark clients in the private file, and update docs.

**Architecture:** Single always-on `core.md` (no wiring changes for Claude, OpenCode, Antigravity, sandbox). Client orgs stay in `~/.claude/CLAUDE.private.md` (outside the repo).

**Tech Stack:** Markdown; verification via `grep`/`wc`.

**Spec:** `docs/superpowers/specs/2026-11-14-agent-instructions-design.md`

## Global Constraints

- `core.md` and `host.md` keep the `---\ntrigger: always_on\n---` frontmatter as the first 3 lines (Antigravity requires it).
- No client org names anywhere in the repo (they live only in `~/.claude/CLAUDE.private.md`).
- Owned orgs `pelotech` and `josmo` are named publicly in `core.md`.
- Every rule is one line; keep the file concise (target ≤ ~90 lines).
- Commits use Conventional Commits.

## Review Focus

- Frontmatter accidentally dropped or moved → Antigravity silently stops loading the rule. Task 1/2 verify line 1–3.
- Client org names leaking into public files → Task 4 greps the repo.
- Symlinks (`~/.config/agents/*`, `.gemini/config/rules/*`, `.config/sandbox/instructions/10-core.md`) broken by replacing the file instead of editing in place → Task 1 verifies `cat` through each link.
- "Keep this current" read as permission to edit silently → wording must say "propose", Task 1 greps for it.
- Unknown-owner repos treated as owned → Repo modes line must say unknown defaults to client mode.

---

### Task 1: Rewrite `core.md`

**Files:**
- Modify: `.config/agents/core.md` (full rewrite, edit in place — do not delete/recreate)

**Interfaces:**
- Produces: section headings `## Principles`, `## Flow & Improvement`, `## Infrastructure`, `## Platform`, `## Development`, `## Product`, `## Repo Modes`, `## Keep This Current`, `## Personal` (Task 4 README references these).

- [ ] **Step 1: Rewrite the file** with the frontmatter, the `# 🌐 Home Ops` title + one-line intro, then the sections above containing exactly the items in the spec's "Decided → `core.md` sections", with these specifics:
  - Infrastructure includes "Authenticate via `aws-sso-cli`" (moved from `host.md`).
  - Platform lists `kubie` (not kubeswitch).
  - Development languages: Go, Node.js, Java, Rust (no Deno).
  - Repo Modes: owned = `pelotech`, `josmo` orgs → improve as you go (leave it better) and say what changed; everything else, including unknown owners → match existing patterns, consistency first, suggest improvements without making them.
  - Keep This Current: when you notice a stale rule, gap, or repeated practice, end your reply with a *proposed* edit to the relevant section of `core.md`, `host.md`, or private notes; never edit them silently.
  - Keep the emoji-heading style of the current file (Modern Monochrome stays under Personal).

- [ ] **Step 2: Verify**

Run:
```bash
f=.config/agents/core.md
head -3 $f
grep -ciE 'deno|kubeswitch' $f
grep -c '^## ' $f
grep -nE 'kubie|pelotech|josmo|propose|unknown' $f
wc -l $f
cmp $f ~/.config/agents/core.md && cmp $f .gemini/config/rules/core.md && cmp $f .config/sandbox/instructions/10-core.md && echo links-ok
```
Expected: frontmatter lines `---`, `trigger: always_on`, `---`; deno/kubeswitch count `0`; 9 sections; each grep term present; ≤ ~90 lines; `links-ok`.

- [ ] **Step 3: Commit**

```bash
git add .config/agents/core.md
git commit -m "feat(agents): organize core practices by area with repo modes and improvement loop"
```

### Task 2: Tidy `host.md`

**Files:**
- Modify: `.config/agents/host.md`

- [ ] **Step 1: Ask the user** what the "Reasoning: structured ACP integration within IntelliJ/CLI" line should say (or whether to drop it). Do not guess.
- [ ] **Step 2: Edit** — remove the `Access: aws-sso-cli` line (now in `core.md` Infrastructure), apply the user's answer for the Reasoning line, keep frontmatter.
- [ ] **Step 3: Verify** — `head -3 .config/agents/host.md` shows the frontmatter; `grep -c aws-sso .config/agents/host.md` → `0`.
- [ ] **Step 4: Commit** — `git commit -am "chore(agents): tidy host tool preferences"` (only `host.md` staged).

### Task 3: Mark clients in private notes

**Files:**
- Modify: `~/.claude/CLAUDE.private.md` (outside repo; no commit)

- [ ] **Step 1: Edit** the "General locations of things" list so every org other than pelotech and josmo is labeled as a **client** org (client repo mode applies). Leave pelotech/josmo entries as-is. Keep frontmatter if present.
- [ ] **Step 2: Verify** — `grep -n -i client ~/.claude/CLAUDE.private.md` shows each non-owned org labeled client.

### Task 4: README, Deno leftovers, docs commit

**Files:**
- Modify: `README.md` (Agent instructions section, ~line 24–53)
- Modify: `.zshrc:171` (remove the `$HOME/.deno/env` source line)
- Add: spec + this plan

- [ ] **Step 1: Edit README** — `core.md` row in the table describes "Practices by area (principles, flow, infra, platform, development, product), repo modes, improvement loop"; add one sentence: client org names live only in the private file; agents propose edits to these files rather than editing silently.
- [ ] **Step 2: Remove** the Deno line from `.zshrc`.
- [ ] **Step 3: Verify**

```bash
grep -rniE 'deno|kubeswitch' --exclude-dir=.git --exclude-dir=.apm --exclude-dir=docs . ; echo "exit=$?"
# client-name check: build the pattern from the private file so names never enter the repo
pat=$(grep -i client ~/.claude/CLAUDE.private.md | grep -o "'[a-z-]*'" | tr -d "'" | paste -sd'|' -)
grep -rniE "$pat" --exclude-dir=.git --exclude-dir=.apm . ; echo "exit=$?"
```
Expected: both print only `exit=1` (no matches).

- [ ] **Step 4: Commit**

```bash
git add README.md .zshrc docs/superpowers/specs/2026-11-14-agent-instructions-design.md docs/superpowers/plans/2026-11-14-agent-instructions.md
git commit -m "docs(agents): document reorganized agent instructions and drop deno"
```
