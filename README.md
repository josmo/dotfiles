# dotfiles

Shell, git, editor, and tool config for my Mac. Linked into `$HOME` by
[nix-darwin](https://github.com/josmo/nix-darwin) on every `darwin-rebuild switch`.

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
