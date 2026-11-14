# dotfiles

Shell, git, editor, and tool config for my Mac. Linked into `$HOME` by
[nix-darwin](https://github.com/josmo/nix-darwin-config) on every `darwin-rebuild switch`.

## How linking works

The activation script runs `git ls-files` in this repo and symlinks every
tracked path that starts with a dot, except `.gitignore`, to the same path
under `$HOME`. Nested paths like `.config/direnv/direnvrc` are linked as
individual files, never whole directories, so caches and tokens stay out of git.

- **Add a file:** put it at the path it should have under `$HOME`, then `git add` it.
- **Remove a file:** `git rm` it. The stale symlink is pruned on the next activation.
- Untracked and ignored files are never linked.

## Never commit

Anything with a credential in it: `.npmrc`, `.netrc`, `.config/gh/hosts.yml`,
`.config/sops/`, `.aws/`, `.kube/`, and so on. Those stay unmanaged in `$HOME`.

## Agent instructions

Personal instructions for coding agents (Claude, OpenCode, Antigravity) are plain markdown
in `.config/agents/`:

| File | What | Who reads it |
|------|------|--------------|
| `core.md` | Principles, stack, commits, style | Every agent, on the Mac and in sandboxes |
| `host.md` | Tool preferences for this Mac (MCP servers, IntelliJ, aws-sso) | Agents on the Mac |

Each agent is pointed at them its own way:

- **Claude:** `.claude/CLAUDE.md` imports them (`@~/.config/agents/core.md`, …).
- **OpenCode:** the `instructions` list in `.config/opencode/opencode.json`.
- **Antigravity:** symlinks in `.gemini/config/rules/`. Antigravity doesn't follow `@`
  imports, and loads a rule only with `trigger: always_on` frontmatter, which is why
  `core.md` and `host.md` start with it.
- **[`sandbox`](https://github.com/josmo/nix-darwin-config/tree/main/sandbox):** joins every
  `.md` in `.config/sandbox/instructions/`, in name order, after its own sandbox notes:
  `10-core.md` (a symlink to `core.md`) and `20-host.md` (host tools that aren't in the VM).
  `host.md` stays out.

**Private notes** (client orgs, Slack server names, anything personal) never go in this
public repo. They live in `~/.claude/CLAUDE.private.md`, which every agent above also reads
when it exists. Give it the same `trigger: always_on` frontmatter, and link it for
Antigravity and `sandbox` once:
`ln -s ~/.claude/CLAUDE.private.md ~/.gemini/config/rules/private.md` and
`ln -s ~/.claude/CLAUDE.private.md ~/.config/sandbox/instructions/90-private.md`.

**Why plain files and not APM:** APM manages plugins (skills, agents, hooks) in `.apm/`.
Instructions are a few markdown files every agent reads directly, so a package manager adds
nothing.
