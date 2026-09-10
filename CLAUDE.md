# dotfiles — command center

Personal dotfiles managed with **GNU Stow**. This repo is the source of truth;
it gets cloned onto a machine and `stow`'d into `$HOME`, not edited in place
from `~`. Public repo: `git@github.com:FlipLucky/dotfiles.git`, default
branch `main`. Owner: bnoblesse (b.noblesse@netants.nl).

## Layout

Each top-level directory is a Stow **package** — its contents mirror the
target layout under `$HOME` exactly (e.g. `nvim/.config/nvim/...` →
`~/.config/nvim/...`). Stowing/restowing is `stow <package>` from the repo
root, or `stow */` to link everything (what `bootstrap.sh` does).

```
bash/    .bashrc
git/     .gitconfig
nvim/    .config/nvim/  (init.lua, lua/config/, snippets/, lsp/, pack/)
tmux/    .tmux.conf
zsh/     .zshrc
bootstrap.sh   fresh-machine setup (Ubuntu/apt-based)
```

When adding a new tool's config, create a new top-level package directory
that mirrors its `$HOME` path — don't dump files flat at the repo root, Stow
depends on the mirrored structure.

## Working conventions

- Commits go straight to `main`; there's no PR workflow here, commit
  messages are often terse/batched ("another update with too much to
  list"). Match that style rather than imposing conventional-commit
  formatting — this is a personal config repo, not a team project.
- After editing a dotfile, the change isn't "live" until re-sourced /
  re-stowed on an actual machine. Don't claim a shell/editor change is in
  effect just because the file was edited — say what the user still needs
  to run (`source ~/.zshrc`, restart `nvim`, `tmux source-file ~/.tmux.conf`,
  re-run `stow`).
- This repo is public. Never commit secrets/API keys/tokens. Machine-specific
  absolute paths (e.g. `/home/bnoblesse/...`) already exist in `zsh/.zshrc`
  for tool integrations (gcloud, gvm) — that's accepted as-is for now, but
  don't add *new* hardcoded personal paths without flagging it, since the
  whole point of this repo is portability across machines.

## Neovim (`nvim/.config/nvim/`)

Neovim 0.12, using **native `vim.pack`** as the package manager — no
lazy.nvim/packer. Native LSP APIs (`vim.lsp.enable`, `vim.lsp.config`), not a
framework. Stated philosophy: **practical over popular** — don't suggest a
plugin just because it's the common community choice; check whether a
builtin or an already-installed plugin covers it first.

Structural note: **`init.lua` is monolithic** and contains everything
(options, `vim.pack.add`, plugin setup, LSP, keymaps, autocmds). The
`lua/config/*.lua` files (`autocmd.lua`, `colorscheme.lua`, `keymap.lua` are
empty; `globals.lua`, `options.lua`, `lsp.lua` hold older/smaller versions of
what's now inline in `init.lua`) are **not `require`d by `init.lua`** — they're
leftovers from an earlier modular layout. Don't assume editing them does
anything; if reviving the modular split is wanted, that's a real refactor
(extract + add `require("config.x")` calls), not a small edit. Same for
`lsp/` and `pack/` — currently empty, unused.

### vim.pack specifics to remember when debugging
- `vim.pack.add({...})` loads **everything eagerly** at startup, in list
  order — no lazy-loading by event/filetype/command like lazy.nvim. "Lazy
  loading" here means deferring the `require(...).setup()` call itself via
  an autocmd, not deferring install.
- A `build = "..."` field (e.g. `blink.cmp`'s `cargo build --release`) runs
  once at install/update. If the toolchain wasn't on `$PATH` then, the
  plugin directory exists but is non-functional — looks like an unrelated
  runtime bug (completion/hover broken) rather than an install failure.
- No lockfile auto-sync; updates are explicit (`vim.pack.update`).

### Native LSP stack
`nvim-lspconfig` supplies default server configs, `vim.lsp.enable({...})` +
`vim.lsp.config(name, {...})` turn servers on and customize them, `mason.nvim`
+ `mason-lspconfig` + `mason-tool-installer` install the binaries, `blink.cmp`
supplies `capabilities`. When something LSP-related misbehaves for one
server only: check `caps` is actually passed into *that* `vim.lsp.config`
call, and check for a second `vim.lsp.config` call for the same server name
(`go.nvim`/`flutter-tools.nvim` configure LSP themselves and can fight the
manual config — `vim.lsp.config` **merges**, it doesn't replace).

### Known issues in this config (worth fixing, flag before "reviewing" cruft)
- **`require("match-up").setup({})` (init.lua:144)** — `vim-matchup`
  (`andymass/vim-matchup`) is a Vimscript-configured plugin (`vim.g.matchup_*`
  globals), not a Lua module. This call either errors or silently no-ops;
  it's not doing what it looks like it's doing.
- **Duplicate `<leader>fk` keymap** (init.lua:492 and init.lua:545) — two
  full definitions of "find keymaps" via `mini.pick`; the second (with
  source-attribution logic) silently wins. The first is dead code and can be
  deleted.
- **`local map = vim.keymap.set` declared twice in a row** (init.lua:446,
  448) — harmless but redundant, delete one.
- **`FixCursorHold.nvim` is installed** — it exists only to patch
  `CursorHold`/`CursorHoldI` reliability in old Neovim, fixed upstream years
  ago; this config also defines its own native `CursorHold` autocmds (for
  diagnostics float and autosave), so the plugin is dead weight. Safe
  candidate for removal.

### Diagnostic workflow when something's broken
1. `:checkhealth` (or `:checkhealth <plugin>`) first for anything dependency-shaped.
2. `:messages` for silent/scrolled-past errors.
3. Isolate with `nvim --clean -u minimal_init.lua` before assuming it's this config's fault.
4. If it only breaks with the full config, suspect `vim.pack.add` load order before the plugin itself.
5. Grep for duplicate keymap/autocmd definitions (`vim.keymap.set` doesn't warn on overwrite).

### Linux-level causes (this machine: Ubuntu, per `bootstrap.sh`)
| Symptom | Likely cause | Fix |
|---|---|---|
| `build` step plugin (blink.cmp) has no working binary | missing Rust toolchain | `sudo apt install cargo` (or rustup for newer) |
| Treesitter parser compile fails | missing C compiler | `sudo apt install build-essential` |
| Clipboard (`"+`/`"*`) not syncing | wrong/missing provider for session type | `sudo apt install wl-clipboard` (Wayland) or `xclip`/`xsel` (X11) |
| Pickers can't grep/find files | missing ripgrep/fd | `sudo apt install ripgrep fd-find` (binary is `fdfind` — symlink to `fd` if a plugin needs it) |
| DAP adapter installed but won't launch | its underlying language toolchain isn't on `$PATH` (delve needs Go, dart-debug-adapter needs Flutter SDK) | verify the toolchain independently of Mason |

## Zsh (`zsh/.zshrc`)

Oh My Zsh, `fino` theme, `plugins=(git)`. Auto-attaches/creates a tmux
session named `default` on interactive shell start (guarded by
`$TMUX`/`$PS1` checks) — be aware of this when debugging "why did a new
shell open in tmux" reports. Tool integrations sourced: NVM (`~/.config/nvm`),
Go, gvm, krew, gcloud SDK (path under `~/Downloads/google-cloud-sdk`, machine-specific).

## Tmux (`tmux/.tmux.conf`)

Prefix remapped `C-b` → `C-a`. vi copy-mode keys. Custom pane-split binds:
`v` = split horizontal, `s` = split vertical, `h/j/k/l` = pane navigation
(note these are plain-prefix binds, not `-n`, so they don't collide with
normal `hjkl` typing). Plugins via TPM: `tmux-plugins/tpm`,
`catppuccin/tmux` (mocha flavor). Status line sourced from
`~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux` — if the status bar
looks unstyled, check TPM actually installed plugins (`prefix + I`) before
assuming a config typo.

## Git (`git/.gitconfig`)

`delta` as pager/diff-filter, `zdiff3` merge conflict style, histogram diff
algorithm, `push.autoSetupRemote = true`. Identity is set directly in this
file (name/email) — since it's stowed to every machine, that's intentional,
not a leak to clean up.

## bootstrap.sh

Fresh-machine setup script (Ubuntu/apt only — no Arch branch, unlike the
Neovim-config assumptions above). Installs Oh My Zsh, clones this repo,
`stow */`, then Neovim nightly (AppImage), Go, Docker, NVM, tmux, and chsh's
to zsh.

**Known issue:** `DOTFILES_REPO` (near the top) is still the placeholder
`https://github.com/your-username/dotfiles.git` — it was never updated to
the actual repo (`git@github.com:FlipLucky/dotfiles.git`). Running this
script fresh will fail to clone. Fix before relying on it for a new machine.

## Neovim config helper skill

A more detailed Claude Code skill/plugin for debugging and extending this
Neovim setup (deeper `vim.pack`/native-LSP diagnostic playbook, a curated
gotchas reference) exists at
`~/Downloads/Neovim config helper-v1/skills/neovim-config-helper/`. The
Neovim section above is a condensed version of it tailored to this specific
config; install the plugin if deeper step-by-step diagnostic help is needed.
