# apm-repo-setup Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Use superpowers:writing-skills when authoring SKILL.md.

**Goal:** A global skill that proposes, installs (pinned) and commits a repo's domain APM packs.

**Architecture:** One SKILL.md in a new vendored local package `.apm/packages/josmo-skills/`, wired into the global `.apm/apm.yml` like `voltagent-pinned`. No scripts: the agent reads the repo, a curated table in the skill, and the global Disabled notes, then uses the `apm` CLI.

**Tech Stack:** APM 0.35.0 CLI, Markdown skill.

**Spec:** `docs/superpowers/specs/2026-11-20-apm-repo-setup-design.md`

## Global Constraints

- Applies to all repos, client repos included; commits `apm.yml` + `apm.lock.yaml` only.
- Never pushes; never edits the global `~/.apm/apm.yml`.
- Every installed ref is pinned `owner/repo[/path]#<tag-or-sha>`; tags from `apm view <pkg> versions`.
- Stop for user approval before any `apm init` / `apm install`.
- Commit message: `chore(apm): add project agent packs`.
- Search hits per unmapped signal: max 3, labelled "unvetted".
- Only CLI commands verified on apm 0.35.0: `apm marketplace list`, `apm search Q@MKT --limit N`, `apm mcp search Q`, `apm view PKG versions`, `apm init -y`, `apm install REF`.

## Review Focus

- Repo already has `apm.yml`: skill must add to it, not re-init or overwrite.
- Repo with no signals (e.g. docs-only): skill says "nothing to add" and writes nothing.
- Signal whose pack is already global: not proposed (fixture includes one).
- `apm search` returns nothing / marketplace errors: skill reports "no hits" for that signal and continues.
- Dirty working tree: commit stages only `apm.yml` and `apm.lock.yaml`, not the user's other changes.

Each is covered as an explicit rule in SKILL.md (Task 1) and the first three by the fixture run (Task 2).

---

### Task 1: Package, skill and wiring

**Files:**
- Create: `.apm/packages/josmo-skills/apm.yml`
- Create: `.apm/packages/josmo-skills/.apm/skills/apm-repo-setup/SKILL.md`
- Modify: `.apm/apm.yml` (dependencies, after the `voltagent-pinned` line)
- Modify: `README.md` (one line under the APM section naming the skill)

**Interfaces:**
- Produces: skill `apm-repo-setup`, triggered by "set up apm for this repo", "add project agent packs", "which apm packages does this repo need".

- [ ] **Step 1: Baseline (writing-skills RED).** Dispatch a subagent without the skill: "In <fixture repo from Task 2>, set up project apm packs." Record what it gets wrong (expected: unpinned refs, re-suggests global packs, installs without asking).
- [ ] **Step 2: Write `josmo-skills/apm.yml`** mirroring `voltagent-pinned/apm.yml` fields: `name: josmo-skills`, `version: 1.0.0`, `description`, `author: Joachim Hill-Grannec`, `license: MIT`, `type: hybrid`.
- [ ] **Step 3: Write SKILL.md** with frontmatter `name: apm-repo-setup` + trigger description, and sections: Flow (spec steps 1–6), Signal table (spec seed rows; empty rows for Terraform, k8s, Go, Rust, Java, Node with "search"), Rules (each Global Constraint and Review Focus line), Proposal format (table: pack | ref | why | vetted/unvetted). Refs for seed rows are written unpinned in the table; the skill pins at install time.
- [ ] **Step 4: Wire it.** Add `- ~/.apm/packages/josmo-skills` to `.apm/apm.yml` with a one-line comment; add README line.
- [ ] **Step 5: Verify.** `python3 -c "import yaml;yaml.safe_load(open('.apm/apm.yml'));yaml.safe_load(open('.apm/packages/josmo-skills/apm.yml'))"` → no error; SKILL.md frontmatter parses the same way.
- [ ] **Step 6: Commit** `feat(apm): add apm-repo-setup skill for per-repo domain packs`.

### Task 2: Fixture run (writing-skills GREEN)

**Files:**
- Test fixture (scratchpad, not committed): `<scratchpad>/fixture-repo/` with `go.mod`, `main.tf`, `requirements.txt` containing `transformers`, a `.github/workflows/ci.yml`, `git init` + one commit.

- [ ] **Step 1: Run with the skill.** Dispatch a fresh subagent with SKILL.md's content: "Follow this skill in <fixture-repo>; stop at the proposal."
- [ ] **Step 2: Check the proposal.** Expected: `huggingface/skills` marked vetted; Terraform and Go rows from `apm search` marked unvetted (or "no hits"); no pack from the global `apm.yml`; nothing installed or committed yet.
- [ ] **Step 3: Refactor.** Fix any rule the subagent broke in SKILL.md; re-run Step 1 until Step 2 passes.
- [ ] **Step 4: Commit** SKILL.md changes (if any) `fix(apm): tighten apm-repo-setup rules`, then `git push origin main`.
