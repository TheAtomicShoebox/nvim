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
- **Thin helpers only** (`lua/util/pack.lua`): `util.pack.keys()` applies
  lazy.nvim-style `keys = {...}` tables (so LazyVim snippets can be pasted
  nearly verbatim), and `util.pack.build()` registers a command to run when
  vim.pack installs/updates a plugin (lazy's `build`).
- **Bundles.** Config files live under `lua/bundles/<name>/`. Each folder’s
  `init.lua` returns a spec: `load` (eager or an autocmd), `deps()` (other
  bundle **modules**, not names), and `setup()` (the `vim.pack.add` /
  `require(...).setup` work). `init.lua` calls `require("bundles").bootstrap()`,
  which discovers every spec, runs eager bundles, and merges the rest onto
  shared autocmds. `ensure()` is a single-pass post-order walk: a dependency
  is always set up before its consumer, and `setup()` runs at most once.
  Bundles: `ui` (eager: snacks, which-key, bufferline, lualine, mini
  icons/notify), `editing` (eager: mini modules, flash), `syntax` (FileType:
  treesitter), `lsp` (FileType, depends on completion: mason, lspconfig,
  lazydev, conform), `completion` (InsertEnter, also pulled by lsp: blink,
  LuaSnip), `git` (VimEnter, depends on ui: mini.diff/git, snacks git
  keymaps), `tools` (VimEnter, depends on ui: trouble, todo-comments,
  picker, persistence).
- **No load-order dependencies between sibling files.** Each file
  `vim.pack.add`s what it needs (duplicate adds are supported no-ops) and
  owns what it exports: blink.lua advertises LSP capabilities
  (`vim.lsp.config['*']`), bufferline.lua sets up mini.icons + the devicons
  mock. Cross-bundle order is the `deps()` graph, not filename sort.

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
- Update everything with `:lua vim.pack.update()` (review the diff buffer it
  opens), remove a plugin by deleting its `add` call and running
  `:lua vim.pack.del({ "name" })`.
- `nvim-treesitter` is pinned to its `main` branch; `util.pack.build` runs
  `:TSUpdate` for it after updates.

## Health check

`:checkhealth Config` verifies bundles, plugins, external tools, keymaps, and
parsers. Deferred bundles (not yet `setup()` because their autocmd has not
fired) are reported as OK, and their plugins/keymaps as info rather than
errors. It runs first in a full `:checkhealth` (uppercase names sort before
lowercase). When adding a plugin/tool/keymap, extend the tables at the top of
`lua/Config/health.lua` — and this README.

External tools expected: `git`, `rg`, `fd`, `lua-language-server`, `stylua`,
`shfmt`, `lazygit` (mason-installed tools live in
`~/.local/share/nvim/mason/bin`, which mason puts on nvim's PATH).

## Features and keymaps

`<leader>` is Space. Press it and wait for the which-key popup (helix preset);
`<leader>?` shows buffer-local maps, `<c-w><space>` enters window hydra mode.

### Files and pickers (snacks.picker)

"Root" = project root from `util.root` (LSP workspace → `.git`/`lua` marker →
cwd). `:Root` shows the detection result.

| Key | Action |
|---|---|
| `<leader><space>` | Smart find files |
| `<leader>ff` / `fF` | Find files (root / cwd) |
| `<leader>fg` / `fG`, `<leader>/` | Grep (root / cwd) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help pages |
| `<leader>fx` / `fX` | Diagnostics (buffer / workspace) |
| `<leader>:` | Command history |
| `<leader>sk` / `sr` / `su` / `sn` | Keymaps / resume picker / undo tree / notifications |
| `<leader>e` / `fe` | Explorer (root) |
| `<leader>E` / `fE` | Explorer (cwd) |

Inside pickers: `<S-h>` toggle hidden, `<S-i>` toggle ignored.

### LSP

Servers are mason-managed (`bundles/lsp/mason.lua`): mason-lspconfig enables every
installed server automatically (configs from nvim-lspconfig, overrides in
`after/lsp/<server>.lua`), and ensure-installs `lua_ls`, `bashls`, `gopls`,
`clangd`, `vtsls`, `html`, `cssls`, `jsonls`. Install more via `:Mason` —
no config needed. Node.js (pacman) is required for the npm-based servers.

lazydev pre-declares every vim.pack plugin as a lua_ls library
(`bundles/lsp/lazydev.lua`): lua_ls loads the workspace once per session instead
of doing a full reload each time a newly-opened file references another
plugin.

Per-server settings live in `after/lsp/<server>.lua` (merged over
nvim-lspconfig's defaults at first attach):

- `lua_ls` — inlay hints, `callSnippet = "Replace"` completion, code lens,
  no third-party prompts.
- `vtsls` — inlay hints, complete function calls, move-to-file code action,
  update imports on file move.
- `gopls` — gofumpt, staticcheck, inlay hints, extra analyses, code lenses.
- `jsonls` — every schema from [SchemaStore](https://www.schemastore.org)
  (`b0o/SchemaStore.nvim`, loaded lazily at first json attach) + validation.

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

Trouble (pretty lists): `<leader>xx` / `xX` diagnostics (workspace / buffer),
`<leader>xL` / `xQ` loclist / quickfix, `<leader>cs` document symbols sidebar,
`<leader>cS` LSP references/definitions panel. `]q` / `[q` step through
trouble items when a trouble window is open, otherwise through the quickfix
list.

Todo comments (todo-comments.nvim): highlights `TODO:`/`FIX:`/`HACK:`/... in
code. `]t` / `[t` next/prev todo, `<leader>st` / `sT` snacks picker (all /
todo+fix+fixme only), `<leader>xt` / `xT` same in Trouble.

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
| `<leader>gg` / `gG` | Lazygit (root / cwd) |
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
| `<C-h/j/k/l>` | Window navigation |
| `<leader>qq` | Quit all |
| `<leader>qs` / `qS` / `ql` / `qd` | Restore / select / last session / stop saving (persistence.nvim) |

Sessions are saved per directory+branch on exit; nothing auto-restores —
use `<leader>qs` after launching in a project.

The bufferline only appears when a named file is open (unnamed buffers get no
tab) and offsets itself around the explorer sidebar.

### Terminal

`<leader>ft` / `<C-/>` toggles a terminal in the project root, `<leader>fT`
in cwd (snacks terminal; same key toggles it closed).

### Toggles (`<leader>u`, state shown in which-key)

`uf` autoformat · `us` spelling · `uw` wrap · `ul`/`uL` line/relative numbers ·
`ud` diagnostics · `uc` conceal · `uT` treesitter highlight · `ub` dark/light
background · `uh` inlay hints · `ug` indent guides · `uD` dim · `uz`/`uZ`
zen/zoom · `uS` smooth scroll · `ua` animations · `un` dismiss notifications.
Profiler: `<leader>dpp` toggle, `<leader>dph` highlights.

### Motions (flash.nvim)

`s` + two chars jumps anywhere on screen (labels appear); `S` selects
treesitter nodes; in operator-pending mode `r` does a remote action (e.g.
`yr` + jump = yank from over there) and `R` a treesitter search; `<C-s>`
toggles flash during `/` search. Normal `r`/`s`-ubstitute semantics: `r`
replace-char is untouched (flash only claims it after an operator), and `s`
(synonym for `cl`) is taken over — use `cl` if you ever need it.

### Editing (mini.nvim, defaults unless noted)

mini.nvim is one plugin, but its modules are set up per bundle:
`bundles/editing/mini.lua` (below), `bundles/git/mini-git.lua` (diff/git,
see the Git section) and `bundles/ui/` (icons + notify).

- **mini.ai** — better `a`/`i` textobjects (`vaf` function, `via` argument, ...)
- **mini.surround** — LazyVim-style `gs*`: `gsa` add, `gsd` delete, `gsr`
  replace, `gsf`/`gsF` find, `gsh` highlight, `gsn` update lines
- **mini.comment** — `gcc`, `gc` + motion
- **mini.move** — `<M-h/j/k/l>` move line/selection
- **mini.pairs**, **mini.trailspace**, **mini.cursorword**
- **mini.icons** (in ui.lua; also mocks nvim-web-devicons for
  bufferline/lualine), **mini.notify** (in ui.lua)

### UI

- **snacks**: statuscolumn, indent guides + scope, notifier, input, words
  (LSP reference highlights), quickfile, bigfile, image, dim, zen, scroll
  animations, explorer (netrw replaced), dashboard (custom keys/footer; the
  stock session key and `startup` section need lazy.nvim)
- **bufferline**: tabs for named buffers only, explorer offset, LSP
  diagnostics in tabs
- **lualine**: global statusline — mode, branch, root-relative path
  (`util.root.pretty_path`), diagnostics, mini.diff counts, clock
