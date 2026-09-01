# Neovim config

A from-scratch config built on Neovim's native plugin manager (`vim.pack`,
Neovim 0.12+), borrowing the good ideas from [LazyVim](https://www.lazyvim.org/)
without using lazy.nvim. Reference material:
[echasnovski's vim.pack guide](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack).

Design choices:

- **Explicit setup calls.** Plugins are added with plain `vim.pack.add()` and
  configured with `require(...).setup({...})`. This gives full lua_ls typing on
  every opts table (the setup function's own annotations flow into the literal)
  with no wrapper indirection.
- **Thin helpers only** (`lua/util/pack.lua`): `util.pack.build()` registers
  a command to run when vim.pack installs/updates a plugin (lazy's `build`).
  Keymaps are plain `vim.keymap.set`.
- **Bundles.** Config files live under `lua/bundles/<name>/`. Each folder’s
  `init.lua` returns a spec: `load` (eager or an autocmd), `deps()` (other
  bundle **modules**, not names), and `setup()` (the `vim.pack.add` /
  `require(...).setup` work). `init.lua` calls `require("bundles").bootstrap()`,
  which discovers every spec, runs eager bundles, and merges the rest onto
  shared autocmds. `ensure()` is a single-pass post-order walk: a dependency
  is always set up before its consumer, and `setup()` runs at most once.
- **No load-order dependencies between sibling files.** Each file
  `vim.pack.add`s what it needs (duplicate adds are supported no-ops) and
  owns what it exports: blink.lua advertises LSP capabilities
  (`vim.lsp.config['*']`), bufferline.lua sets up mini.icons + the devicons
  mock. Cross-bundle order is the `deps()` graph, not filename sort.

Bundles:

| Bundle | Load | Depends on | What it sets up |
|---|---|---|---|
| `ui` | eager | — | colorschemes, snacks, noice, which-key, bufferline, lualine, mini.icons |
| `editing` | VimEnter | — | mini modules, flash |
| `syntax` | FileType | — | nvim-treesitter |
| `completion` | InsertEnter (also pulled by `lsp`) | — | blink.cmp, LuaSnip |
| `lsp` | FileType | completion | mason, lspconfig, lazydev, conform |
| `git` | VimEnter | ui | mini.diff/git, snacks git keymaps |
| `tools` | VimEnter | ui | trouble, todo-comments, picker, pack UI, persistence |
| `debug` | VimEnter | ui | nvim-dap, nvim-dap-ui, virtual text |
| `test` | VimEnter | ui, debug | neotest (language bundles register adapters) |
| `haskell` | FileType haskell/cabal | lsp | haskell-tools.nvim (not mason HLS) |
| `dotnet` | FileType cs/csproj/sln/… | lsp, debug, test | easy-dotnet.nvim (not mason Roslyn) |

## Structure

| Path | Purpose |
|---|---|
| `init.lua` | Options, basic keymaps, diagnostics config, `require("bundles").bootstrap()` |
| `lua/bundles/<bundle>/init.lua` | Bundle spec: `load`, `deps()`, `setup()` |
| `lua/bundles/<bundle>/*.lua` | One small file per plugin/topic, required from `setup()` |
| `lua/util/` | Helpers: `util.gh`, `util.root`, `util.pack` |
| `lua/Config/health.lua` | Config sanity checks (`:checkhealth Config`) |
| `after/lsp/<server>.lua` | Per-server LSP overrides |
| `.stylua.toml` | 2-space formatting for this repo's Lua |

## Plugin management

- Plugins install automatically at startup via `vim.pack.add()` in each
  bundle file.
- UI: `<leader>p` or `:Pack` is a short operations menu (update, status,
  clean, lockfile, sync). Letter keys in the list match the action
  (`u`/`s`/`c`/`l`/`S`); the same actions are also `<leader>pu` / `ps` /
  `pc` / `pl` / `pS`. `vim.pack` still owns the review buffers.
- Update: `:PackUpdate` (review the diff tab, `:write` to confirm; bang
  applies without review). Browse without fetching: `:PackStatus`.
  Align disk to the lockfile (after pulling this config on another
  machine): `:PackSync`.
- Remove unused plugins: delete the `add` call, restart, `:PackClean`
  (loads every bundle first so deferred plugins like blink/mason are not
  treated as unused). Or `:lua vim.pack.del({ "name" })`.
- Lockfile is `nvim-pack-lock.json` in this directory (`:PackLock` opens
  it). Treat it as part of the config (VCS) so other machines install at
  the same revisions.
- `nvim-treesitter` is pinned to its `main` branch; `util.pack.build` runs
  `:TSUpdate` for it after updates.

## Health check

`:checkhealth Config` verifies bundles, plugins, external tools, keymaps, and
parsers. Deferred bundles (not yet `setup()` because their autocmd has not
fired) are reported as OK, and their plugins/keymaps as info rather than
errors. It runs first in a full `:checkhealth` (uppercase names sort before
lowercase). When adding a plugin/tool/keymap, extend the tables at the top of
`lua/Config/health.lua` — and this README.

External tools (`:checkhealth Config`):

- Always: `git`, `rg`; optional `fd`, `lazygit`
- After `lsp` loads: `lua-language-server`, `stylua`, `shfmt`, plus the
  mason-installed servers (`bash-language-server`, `gopls`, `clangd`,
  `vtsls`, `vscode-html-language-server`, `vscode-css-language-server`,
  `vscode-json-language-server`). Mason puts them on nvim's PATH at
  `~/.local/share/nvim/mason/bin`.
- After `haskell` loads: `haskell-language-server-wrapper`, optional
  `stack`, `cabal`, `hoogle`
- After `dotnet` loads: `dotnet`, `dotnet-easydotnet`

## Features and keymaps

`<leader>` is Space. Press it and wait for the which-key popup (helix preset);
`<leader>?` shows buffer-local maps, `<c-w><space>` enters window hydra mode.

### Files and pickers (snacks.picker)

"Root" = project root from `util.root` (LSP workspace → `.git` / `lua` /
`.sln` / `.csproj` marker → cwd). `:Root` shows the detection result.

| Key | Action |
|---|---|
| `<leader><space>` | Smart find files |
| `<leader>ff` / `fF` | Find files (root / cwd) |
| `<leader>fg` / `fG`, `<leader>/` | Grep (root / cwd) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help pages |
| `<leader>fx` / `fX` | Diagnostics (buffer / workspace) |
| `<leader>:` | Command history |
| `<leader>sk` / `sr` / `su` | Keymaps / resume picker / undo tree |
| `<leader>p` | vim.pack operations (also `pu`/`ps`/`pc`/`pl`/`pS`) |
| `<leader>e` / `fe` | Explorer (root) |
| `<leader>E` / `fE` | Explorer (cwd) |

Inside pickers: `<S-h>` toggle hidden, `<S-i>` toggle ignored, `<S-f>` toggle
follow.

### LSP

Servers are mason-managed (`bundles/lsp/mason.lua`): mason-lspconfig enables
every installed server automatically except `hls` (haskell-tools owns that)
and `omnisharp` / `csharp_ls` (easy-dotnet owns C#). Configs come from
nvim-lspconfig, overrides in `after/lsp/<server>.lua`. ensure-installs
`lua_ls`, `bashls`, `gopls`, `clangd`, `vtsls`, `html`, `cssls`, `jsonls`.
Install more via `:Mason` — no config needed. Node.js is required for the
npm-based servers.

lazydev pre-declares every vim.pack plugin as a lua_ls library
(`bundles/lsp/lazydev.lua`).

Per-server settings in `after/lsp/<server>.lua`:

- `lua_ls` — inlay hints, `callSnippet = "Replace"` completion, code lens,
  no third-party prompts.
- `vtsls` — inlay hints, complete function calls, move-to-file code action,
  update imports on file move.
- `gopls` — gofumpt, staticcheck, inlay hints, extra analyses, code lenses.
- `jsonls` — every schema from [SchemaStore](https://www.schemastore.org)
  (`b0o/SchemaStore.nvim`, loaded at first json attach) + validation.
- `easy_dotnet` — Roslyn inlay hints, references/tests CodeLens, organize
  imports on format. Linux/WSL keeps Roslyn's in-process file watcher.

Inlay hints are enabled on attach for servers that support them; toggle
with `<leader>uh`.

#### Keymaps (buffer-local, on attach)

| Key | Action |
|---|---|
| `gd` / `gD` | Goto definition (picker) / declaration |
| `gr` / `gI` / `gy` | References / implementations / type definition |
| `gS` | Definition in vsplit |
| `K` | Hover |
| `<leader>ca` / `cr` / `co` | Code action / rename / organize imports |
| `<leader>ss` / `sS` | Symbols (document / workspace) |

Diagnostics (global): `<leader>cd` line float, `]d [d` next/prev, `]e [e`
errors, `]w [w` warnings, `<leader>xl` / `xq` location/quickfix list.

Trouble: `<leader>xx` / `xX` diagnostics (workspace / buffer), `<leader>xL` /
`xQ` loclist / quickfix, `<leader>cs` document symbols sidebar, `<leader>cS`
LSP references/definitions panel. `]q` / `[q` step through trouble items
when a trouble window is open, otherwise through the quickfix list.

Todo comments: highlights `TODO:`/`FIX:`/`HACK:`/... `]t` / `[t` next/prev,
`<leader>st` / `sT` snacks picker (all / todo+fix+fixme), `<leader>xt` /
`xT` same in Trouble.

### Haskell

`haskell-tools.nvim` starts HLS itself (not mason). Install
`haskell-language-server-wrapper` via GHCup. The command walks to
`hie.yaml` / `cabal.project` / `stack.yaml` / `package.yaml`, asks the
wrapper for that project's GHC, and launches
`haskell-language-server-<ghc>` with `--cwd` at the project root. GHCup
`set hls` only exposes one release on PATH; the cmd also searches
`~/.ghcup/hls/*/bin/`. You need a bindist for each project GHC.

`<leader>hs` queries a **local** Hoogle database through Snacks
(`hoogle --json`); install `hoogle` and run `hoogle generate` once.

| Key | Action |
|---|---|
| `K` | haskell-tools hover actions |
| `<leader>cl` | Code lens |
| `<leader>ce` | Eval all snippets |
| `<leader>hs` | Hoogle signature |
| `<leader>hr` / `hf` / `hq` | GHCi repl (package / file / quit) |

### C# / F# / Razor

`easy-dotnet.nvim` starts the official Roslyn language server (installs
`roslyn-language-server` as a dotnet global tool if missing) and talks to
the EasyDotnet JSON-RPC server. Needs a .NET SDK on PATH and
`dotnet tool install -g EasyDotnet` (update with `:Dotnet _server update`).
`:Dotnet` is the command palette. The bundle loads on `.cs` / `.csproj` /
`.sln` / related filetypes. EasyDotnet registers the coreclr adapter with
the `debug` bundle. Tests go through the `test` bundle: EasyDotnet is a
neotest adapter (`neotest_integration`), so signs, nearest/file/suite
runs, and debug-nearest are neotest. Package completion in `.csproj` is a
blink source. Formatting falls back to Roslyn.

| Key | Action |
|---|---|
| `<leader>Nb` / `Nr` / `Nw` | Build / run / watch default project |
| `<leader>No` | Outdated packages (`<leader>Nu` / `Na` upgrade one / all) |
| `<leader>Np` | Dotnet command picker |
| `<leader>Nt` | Toggle EasyDotnet terminal panel |
| `<leader>cl` | Code lens |
| `<leader>tT` | Toggle EasyDotnet test runner (solution tree) |
| `<leader>dD` | Debug default project |

### Completion (blink.cmp, `default` preset)

The menu auto-shows while typing; `<C-space>` toggles it manually.
`<C-y>` accepts, `<C-n>`/`<C-p>` select, `<C-e>` cancels,
`<Tab>`/`<S-Tab>` jump snippet placeholders (LuaSnip). Lua files get
plugin/API completions via lazydev.

### Formatting (conform.nvim)

Format-on-save is on by default; `<leader>uf` toggles it globally
(`vim.b.autoformat = false` disables per buffer), `<leader>cf` formats
manually. Formatters: stylua (lua), shfmt (shell), prettierd/prettier (web,
install when needed); everything else falls back to LSP formatting.

### Git

| Key | Action |
|---|---|
| `<leader>gg` / `gG` | Lazygit (root / cwd; mapped only if `lazygit` is on PATH) |
| `<leader>gs` / `gS` | Git status / stash picker |
| `<leader>gd` | Git diff (hunks) picker |
| `<leader>gl` / `gL` / `gf` | Log (root / cwd) / current file history |
| `<leader>gb` | Blame line |
| `<leader>gB` / `gY` | Open / copy repo URL (works on visual ranges) |
| `]h` / `[h` | Next / prev hunk (mini.diff) |
| `<leader>ghs` | Stage hunk (operator: `ghs` + motion, `ghs`×2 for line) |
| `<leader>ghp` / `ghb` | Toggle diff overlay / blame at cursor |

### Buffers, windows, sessions

| Key | Action |
|---|---|
| `<S-h>` / `<S-l>`, `[b` / `]b` | Prev / next buffer |
| `<leader>bb` / `` <leader>` `` | Switch to other buffer |
| `<leader>bd` / `bo` / `bi` / `bD` | Delete buffer / others / invisible / buffer+window |
| `<leader>.` / `<leader>S` | Toggle / select scratch buffer |
| `<C-h/j/k/l>` | Window navigation (normal and terminal mode) |
| `<leader>qq` | Quit all |
| `<leader>qs` / `qS` / `ql` / `qd` | Restore / select / last session / stop saving (persistence.nvim) |

Sessions are saved per directory+branch on exit; nothing auto-restores —
use `<leader>qs` after launching in a project.

The bufferline only appears when a named file is open (unnamed buffers get no
tab) and offsets itself around the explorer sidebar.

### Terminal

`<leader>ft` / `<C-/>` toggles a snacks terminal in the project root (also
from terminal mode), `<leader>fT` in cwd. EasyDotnet's build/run/watch
panel is `<leader>Nt`.

### Test (neotest)

The `test` bundle loads on `VimEnter`. Language bundles register adapters
after setup (`bundles.test.add_adapter`); EasyDotnet is the C# adapter.
Failures open as diagnostics (and refresh Trouble if it is already open).
Gutter signs plus virtual text show pass/fail.

| Key | Action |
|---|---|
| `<leader>tr` / `tR` / `ta` | Run nearest / file / all tests |
| `<leader>tl` / `ts` | Run last / stop |
| `<leader>tw` | Watch tests in the current file |
| `<leader>to` / `tO` | Output float / output panel |
| `<leader>tt` | Toggle test summary |
| `<leader>dT` | Debug nearest test |
| `]T` / `[T` | Next / prev failed test |

### Debug (nvim-dap)

The `debug` bundle loads on `VimEnter`. A session opens the dap-ui layout
(scopes / breakpoints / stacks / watches + REPL / console) and closes it
when the session ends. `<leader>du` toggles that view; inline values come
from nvim-dap-virtual-text. Language bundles register adapters and may add
start actions on this prefix (EasyDotnet: `<leader>dD`; neotest: `<leader>dT`).

| Key | Action |
|---|---|
| `<leader>db` / `dB` / `dL` / `dx` | Toggle / condition / log point / clear breakpoints |
| `<leader>dc` | Continue / start |
| `<leader>dC` / `dl` | Run to cursor / run last |
| `<leader>dO` / `di` / `do` | Step over / into / out |
| `<leader>dP` / `dt` | Pause / terminate |
| `<leader>dr` | Toggle DAP REPL |
| `<leader>du` | Toggle debug UI |
| `<leader>de` | Eval expression (normal / visual) |
| `<leader>dh` | Hover |
| `<leader>dj` / `dk` | Down / up stack frame |
| `<F5>` / `<F10>` / `<F11>` / `<F12>` | Continue / step over / into / out |

### Toggles (`<leader>u`, state shown in which-key)

`uf` autoformat · `us` spelling · `uw` wrap · `ul`/`uL` line/relative numbers ·
`ud` diagnostics · `uc` conceal · `uC` colorscheme picker · `uR` random
colorscheme · `uT` treesitter highlight · `ub` dark/light background · `uh`
inlay hints · `ug` indent guides · `uD` dim · `uz`/`uZ` zen/zoom · `uS`
smooth scroll · `ua` animations · `un` dismiss notifications · `<leader>n`
notification history. Noice: `<leader>snh` history · `sna` all · `snl` last
· `snt` picker · `snd` dismiss. Profiler: `<leader>dpp` toggle, `<leader>dph`
highlights.

### Motions (flash.nvim)

`s` + two chars jumps anywhere on screen (labels appear); `S` selects
treesitter nodes; in operator-pending mode `r` does a remote action (e.g.
`yr` + jump = yank from over there) and `R` a treesitter search; `<C-s>`
toggles flash during `/` search. Normal `r`/`s`-substitute semantics: `r`
replace-char is untouched (flash only claims it after an operator), and `s`
(synonym for `cl`) is taken over — use `cl` if you ever need it.

### Editing (mini.nvim, defaults unless noted)

mini.nvim is one plugin; modules are set up per bundle:
`bundles/editing/mini.lua` (below), `bundles/git/mini-git.lua` (diff/git),
`bundles/ui/` (icons).

- **mini.ai** — better `a`/`i` textobjects (`vaf` function, `via` argument, ...)
- **mini.surround** — `gsa` add, `gsd` delete, `gsr` replace, `gsf`/`gsF`
  find, `gsh` highlight, `gsn` update lines
- **mini.comment** — `gcc`, `gc` + motion
- **mini.move** — `<M-h/j/k/l>` move line/selection
- **mini.pairs**, **mini.trailspace**, **mini.cursorword**, **mini.bufremove**
- **mini.icons** (in `bundles/ui/bufferline.lua`; also mocks nvim-web-devicons)

### UI

- **colorschemes**: a dark pool (Tokyo Night, Catppuccin, Kanagawa, Rosé Pine,
  Nightfox, Gruvbox Material, Everforest, One Dark, GitHub, Cyberdream,
  Oxocarbon, VS Code, Nordic, Melange, Moonfly, plus stock schemes like
  habamax/retrobox). A random one is applied at startup; the name is
  announced via `vim.notify` and shown on the dashboard footer.
  `<leader>uC` live-previews any installed scheme; `<leader>uR` re-rolls.
- **snacks**: statuscolumn, indent guides + scope, notifier (`vim.notify`
  popups + `<leader>n` history), input, words (LSP reference highlights),
  quickfile, bigfile, image, dim, zen, scroll animations, explorer (netrw
  replaced), dashboard (custom keys/footer; the stock session key and
  `startup` section need lazy.nvim)
- **noice**: cmdline / messages / LSP hover UI; routes `vim.notify` into
  snacks.notifier. Skipped under `nvim --headless` / `nvim -es`
  (`util.headless()`); otherwise waits for `UIEnter` so `--embed` without a
  UI does not steal messages.
- **bufferline**: tabs for named buffers only, explorer offset, LSP
  diagnostics in tabs
- **lualine**: global statusline — mode, branch, root-relative path
  (`util.root.pretty_path`), diagnostics, mini.diff counts, clock
