# Agent instructions reorganization — design

Size: small change (short design).

## Intent

Codify personal engineering practices by area, make agents behave differently in owned vs
client repos, and have agents keep the practices current as they work anywhere.

## Goals

- Remove stale stack items (Deno; kubeswitch → kubie).
- Organize `core.md` into areas: Principles, Infrastructure, Platform, Development, Product.
- Add repo modes: owned repos improve now; client repos match patterns and suggest.
- Add a "Keep this current" loop so agents propose edits when they spot gaps.

## Non-goals

- No new instruction files, skills, or hooks.
- No client-specific practices beyond marking which orgs are clients.

## Anti-goals

- Client org names in this public repo.
- Agents silently editing instruction files.
- Bloat: `core.md` must stay short enough to load every session without cost.

## Constraints

- `core.md` is loaded always-on by four agents (Claude `@` import, OpenCode `instructions`,
  Antigravity symlink with `trigger: always_on`, sandbox `10-core.md` symlink). Keeping one
  file means no wiring changes.
- Repo is public; client orgs live only in `~/.claude/CLAUDE.private.md`.

## Approaches

1. **Standing instruction in `core.md`** (chosen): one file with sections; improvement loop is
   a short section asking agents to propose edits. Works in all four agents, no tooling;
   relies on the agent noticing.
2. **Dedicated `update-practices` skill:** more thorough review, but only runs when invoked.
   Kept as a later add-on if suggestions slip through.
3. **End-of-session hook:** automatic, but Claude-only and noisy.

Splitting into one file per area was also considered and rejected: every file loads every
session anyway, so splitting only multiplies wiring (4 places per file). Revisit if one area
grows large enough to become an on-demand skill.

## Decided

### `core.md` sections

- **Principles:** KISS, cattle not pets (ephemeral), security by default.
- **Flow & improvement** (Toyota Kata, Lean, small batches):
  - Improvement kata: for non-trivial changes, state current condition → target condition →
    next step → what we expect to see.
  - Blameless 5 whys: bugs and incidents get a root-cause pass and a fix to the system.
  - Eliminate waste (YAGNI): no speculative features, abstractions, or config.
  - Decide late: defer irreversible decisions; prefer choices that are cheap to change.
  - Build quality in: tests and automation ship with the change.
  - Finish before starting: limit WIP; close the current task before opening new threads.
  - Small PRs: one concern per PR, reviewable in minutes.
  - Trunk-based + flags: short-lived branches, merge often, ship incomplete work dark.
  - Fastest check first: quick tests/lint before slow suites; keep CI ~10 min.
  - Deploy often: every merge can reach prod through an automated pipeline.
  - ("Leave it better" is covered by Repo modes.)
- **Infrastructure:** AWS (AL2023), GCP, Terraform, Packer, OpenSCAP hardening baked into
  AMIs, nftables, `aws-sso-cli`.
- **Platform:** EKS/GKE, kubie, GitHub Actions, Trivy scanning, Cosign signing, Renovate
  (review PRs for breaking changes only).
- **Development:** Go, Node.js, Java, Rust; Conventional Commits + release-please; fpm.
- **Product** (incl. customer development, Steve Blank):
  - Problem first: state the user problem and success before proposing a solution.
  - Hypotheses, not facts: name the assumption behind a feature and how it gets validated.
  - Cheapest test first: validate with the lowest-cost experiment (mock, spike, manual)
    before a full build.
  - Evidence over opinion: prefer user data, interviews, and usage signals.
  - Pivot or persevere: after a slice ships and is measured, decide continue / change / kill.
  - Thin slices: ship the smallest useful vertical slice; avoid big-bang releases.
  - Buy before build: prefer managed services, SaaS, or existing OSS over custom code.
  - Measure it: each feature ships with how we'll know it worked.
  - ADRs for one-way doors: short decision record for hard-to-reverse choices.
  - Docs are part of done: README/runbook updated in the same change.
  - Plain-language updates: stakeholder writing leads with impact, skips jargon.
- **Repo modes:**
  - Owned (`pelotech`, `josmo` orgs): improve as you go (leave it better); fix stale
    patterns, upgrade, refactor toward these principles, and say what changed.
  - Everything else (clients, unknown): match the repo's existing patterns; consistency
    first; note improvements as suggestions, don't make them unasked.
- **Keep this current:** when an agent notices a stale rule, a gap, or a repeated practice,
  it ends its reply with a proposed edit to the relevant section of `core.md` (or
  `host.md` / private notes). Never edit them silently.
- **Personal:** Style: Modern Monochrome.

### Other files

- `CLAUDE.private.md`: label every non-owned org already listed there as a client. Nothing else changes.
- `host.md`: tighten; ask the user what the vague "Reasoning: ACP integration" line should say.
- `README.md`: update the agent-instructions section to match; sweep repo for `kubeswitch`.

## Left to the builder

- Exact wording and ordering within sections; keep the file concise.
- Whether Personal stays a section or folds into Principles.
