---
name: apm-repo-setup
description: Use when asked to set up APM (Agent Package Manager) for a repo, add project or domain agent packs, or decide which apm packages, skills, plugins or MCP servers a repo needs. Proposes packs from repo signals, installs them pinned after approval, and commits the project apm.yml.
---

# APM repo setup

Global `~/.apm/apm.yml` holds daily drivers only. This skill gives a repo its domain packs in a
project `apm.yml`, so they load only where they're useful.

## Flow

1. **Detect signals.** Read the repo root and manifests. Look for the files in the table below.
   Record each signal with the file that proves it.
2. **Map signals.** First the table below (vetted). Then the `# --- Disabled` notes in
   `~/.apm/apm.yml`: a "Bring back: in a … repo" line matching a signal makes that pack vetted too.
3. **Search gaps.** For each signal with no vetted pack:
   - `apm marketplace list`, then `COLUMNS=200 apm search <signal>@<marketplace> --limit 3` per
     marketplace.
   - `COLUMNS=200 apm mcp search <signal>`.
   - Keep at most 3 hits per signal that actually match the signal, not the word. Mark them
     **unvetted**. No hits or a command error: write "no hits" for that signal and continue.
4. **Drop what's there.** Remove any pack already listed in `~/.apm/apm.yml` dependencies (active,
   not the commented Disabled ones) or in the repo's own `apm.yml`. Also drop anything the
   global file's `# NOTE:` / Disabled comments say APM can't install (e.g. LSP-only `*-lsp`
   plugins have no plugin manifest).
5. **Propose and stop.** Show the table below and wait for the user to pick. Do not run
   `apm init`, `apm install` or `git commit` before they answer.

   | Signal (file) | Pack | Pin | Vetted? | Why |
   |---|---|---|---|---|

   Nothing left after step 4: say "nothing to add", write nothing, stop.
6. **Apply the approved packs.**
   - No `apm.yml` in the repo: `apm init -y`. One exists: keep it, add to it. Don't set or
     narrow `targets`; let apm detect them.
   - Pin each pack: newest release tag from `apm view <owner/repo> versions`; no tags →
     full SHA from `git ls-remote https://github.com/<owner/repo> HEAD`. Install as
     `apm install <owner/repo[/path]>#<tag-or-sha>` (MCP: `apm mcp install …`).
   - Commit only the apm files, never the user's other changes:
     `git add apm.yml apm.lock.yaml && git commit -m "chore(apm): add project agent packs"`.
   - Never push. Never edit `~/.apm/apm.yml`.

## Signal table

| Signal | Files | Pack (vetted) |
|---|---|---|
| ML / Hugging Face | `transformers`, `torch`, `datasets`, `diffusers` in `requirements*.txt` / `pyproject.toml` | `huggingface/skills` |
| Figma designs | Figma URLs or `@figma/*` deps | `figma/mcp-server-guide` |
| Supabase | `supabase/` dir, `@supabase/*` deps | `supabase-community/supabase-plugin` |
| GitLab | `.gitlab-ci.yml`, gitlab remote | `anthropics/claude-plugins-official/external_plugins/gitlab` |
| Browser tests | `playwright.config.*`, `@playwright/test` | `anthropics/claude-plugins-official/external_plugins/playwright` |
| Terraform | `*.tf` | search |
| Kubernetes / Helm | `Chart.yaml`, `kustomization.yaml`, manifests with `apiVersion:` + `kind:` | search |
| Go | `go.mod` | search |
| Rust | `Cargo.toml` | search |
| Java | `pom.xml`, `build.gradle*` | search |
| Node / frontend | `package.json` | search |
| Containers / images | `Dockerfile`, `*.pkr.hcl` | search |

When the user adopts a search hit, offer to add it to this table as a vetted row.

## Rules

- Applies to every repo, client repos included; don't ask about repo ownership.
- Never install anything unpinned; never re-suggest a pack that's already global.
- Unvetted hits are suggestions, never defaults.
