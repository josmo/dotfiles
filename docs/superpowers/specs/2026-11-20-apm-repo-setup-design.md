# apm-repo-setup skill — design

## Why

The global `~/.apm/apm.yml` stays limited to daily drivers (core.md: "add domain packs per
project"). Choosing and wiring a repo's domain packs by hand is tedious and easy to skip, so
packs either never get added or creep back into the global set.

## Goal

One global skill, run inside any repo, that proposes the domain packs that repo needs and,
once approved, writes and commits a project `apm.yml` + `apm.lock.yaml`.

- **Non-goals:** changing the global `apm.yml`; MCP auth setup; picking packs for the user
  without approval.
- **Anti-goals:** suggesting a pack that is already global, or one the Disabled notes rejected
  outright; unpinned refs; touching anything other than the project's apm files.

## Approaches

1. **Curated signal→pack table + marketplace search for gaps** (chosen). Table holds vetted
   picks; the Disabled notes in the global `apm.yml` are read as a second source; `apm search`
   / `apm mcp search` fill signals the table doesn't cover, labelled unvetted. Reliable picks,
   learns from past decisions; one line to maintain per adopted pack.
2. Search only: zero upkeep, but noisy, drifts between runs, can re-suggest rejected packs.
3. Detection script + skill: testable detection, but code to maintain for something the agent
   can read directly. Revisit only if detection proves flaky.

## Decided

- **All repos, including client repos:** the skill writes and commits the project apm files
  everywhere (user's call, overriding client repo mode for this one file set).
- **Approach 1** above.

## Design

- **Location:** new vendored package `.apm/packages/josmo-skills/` (same pattern as
  `voltagent-pinned`), skill at `.apm/skills/apm-repo-setup/SKILL.md`, added to the global
  `apm.yml`.
- **Flow:**
  1. Detect signals by reading the repo: `go.mod`, `Cargo.toml`, `pom.xml`/`build.gradle`,
     `package.json` deps, `pyproject.toml`/`requirements.txt` (ML libs), `*.tf`, `Chart.yaml`,
     `kustomization.yaml`/k8s manifests, `Dockerfile`, Packer files, `.gitlab-ci.yml`,
     Playwright config, Figma/Supabase usage.
  2. Map signals via the table, then the global Disabled notes ("Bring back: in a … repo").
  3. For unmapped signals: `apm search <signal>@<marketplace>` over `apm marketplace list`,
     and `apm mcp search <signal>`. Mark hits unvetted.
  4. Drop anything already in the global `apm.yml` or the project's `apm.yml`.
  5. Show the proposal (pack, ref, why, vetted/unvetted) and stop for approval.
  6. On approval: `apm init -y` if no `apm.yml`; `apm install <ref>` per pack, pinned
     (`owner/repo#tag-or-sha`, resolved with `apm view`); commit `apm.yml` + `apm.lock.yaml`
     as `chore(apm): add project agent packs`. Never push.
- **Seed table:** ML (torch/transformers/HF) → `huggingface/skills`; Figma → `figma/mcp-server-guide`;
  Supabase → `supabase-community/supabase-plugin`; GitLab → `.../external_plugins/gitlab`;
  Playwright → `.../external_plugins/playwright`. Terraform, k8s, Go, Rust, Java, Node start
  empty and are filled from search results the user adopts.
- **Check:** run the skill against a throwaway repo in the scratchpad with a `go.mod`, a
  `*.tf` and `transformers` in `requirements.txt`; expect HF vetted, Terraform/Go from search,
  nothing global re-suggested.

## Left to the builder

Exact SKILL.md wording, table formatting, and how many search hits to show per signal (default 3).
