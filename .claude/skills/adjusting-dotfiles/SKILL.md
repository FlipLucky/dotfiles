---
name: adjusting-dotfiles
description: Use when changing, adding, committing, pulling or merging anything in the ~/dotfiles Stow repo (zsh, bash, nvim, tmux, git, hypr), or when a shell, editor or desktop breaks right after a dotfiles pull/merge from another machine.
---

# Adjusting dotfiles

## Overview
This repo is stowed onto several machines: the Ubuntu work laptop (GNOME + Hyprland/DMS) and the Arch T14 (Hyprland/DMS).
A change that's right on one machine can break another.
Per-tool facts live in `CLAUDE.md`. This skill is the procedure around a change.

## Before editing
1. Run `git status`. Changes you didn't make are the user's work in progress. Leave them out of your commits unless the user asks you to commit them.
2. Work in the repo, never in `~` directly. Use `ls -l` on the target to check whether it's a Stow symlink. A folded directory symlink like `~/.config/hypr` means writes in `~` already land in the repo.

## Portability check (every edit and every incoming merge)
Paths, package managers and installed tools differ per distro. Before writing or accepting a change, scan it for:
- absolute paths: `/usr/share/...`, `/opt/...`, `/usr/lib/jvm/...`, `/home/<user>/...`
- tool calls that assume the tool exists, e.g. `$(go env GOPATH)`

Guard each one so it's a no-op where the path or tool is missing:
```zsh
[[ -s /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
command -v go >/dev/null && export PATH=$PATH:$(go env GOPATH)/bin
```

**Incoming changes** (`git pull`, a rebase, a stash pop) from the other machine:
1. Run `git diff HEAD..origin/main` first.
2. Tell the user which shell, editor and desktop configs change, before applying anything.
3. Fix unguarded paths in the same step.

## Generated files
DMS rewrites some `hypr/.config/hypr/dms/*.lua` files at runtime (see `CLAUDE.md`). Changes to them in `git status` are expected. Commit them only when the user wants the current layout, colors or monitors saved.

## Before committing
- **Secrets:** the repo is public. Run `git diff --cached` and look for tokens, passwords, hostnames and VPN details.
- **Syntax:** use `zsh -n` / `bash -n` for shell files.
  - Never source a config to check it.
  - Never run `nvim` headless on the user's `init.lua` to check it: that executes plugins and autocmds.
  - `luac` isn't installed. Compile Lua without running it: `nvim --clean --headless +'lua assert(loadfile("FILE"))' +qa`. Read the output, because the exit code is 0 even on an error.
- **Commit style:** terse messages straight to `main`, matching the existing history. Push only when the user asks.

## After the change: make it live
An edited file isn't in effect yet. Tell the user what to run:

| Changed | Make it live |
|---|---|
| zsh / bash | open a new shell, or `source ~/.zshrc` |
| tmux | `tmux source-file ~/.tmux.conf` |
| nvim | restart nvim; plugin changes need `vim.pack.update()` |
| hypr | `hyprctl reload` |
| new or renamed file | `stow -R <package>` |

Any git operation that rewrites files (rebase, checkout, stash) also needs `hyprctl reload`. Otherwise Hyprland keeps reporting "cannot open hyprland.lua".

## Not in the repo
Some machine state lives outside the repo: the systemd drop-ins, `~/.config/environment.d/`, and NetworkManager connections. When a fix lands there, say so, and add a note to `CLAUDE.md` so it can be recreated on another machine.
