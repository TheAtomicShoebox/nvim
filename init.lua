local util = require("util")

util.root.setup()

vim.g.debug = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.signcolumn = "yes"
vim.opt.showmatch = true
vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<ESC>", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Format-on-save is handled by conform.nvim (bundles/lsp/conform.lua).

-- Re-apply after colorscheme so the transparent sign column survives theme load.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserSignColumn", { clear = true }),
  callback = function() vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" }) end,
})
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

local diagnostic_signs = {
  Error = "\u{f057} ",
  Warn = "\u{f071} ",
  Hint = "\u{ea61}",
  Info = "\u{f05a}",
}

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
      [vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
      [vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
      [vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
    focusable = false,
    style = "minimal",
  },
})

do
  local orig = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig(contents, syntax, opts, ...)
  end
end

-- vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
-- vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
-- vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
-- vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

vim.keymap.set({ "n", "t" }, "<C-j>", function() vim.cmd.wincmd("j") end, { desc = "Go to Lower Window" })
vim.keymap.set({ "n", "t" }, "<C-h>", function() vim.cmd.wincmd("h") end, { desc = "Go to Left Window" })
vim.keymap.set({ "n", "t" }, "<C-k>", function() vim.cmd.wincmd("k") end, { desc = "Go to Upper Window" })
vim.keymap.set({ "n", "t" }, "<C-l>", function() vim.cmd.wincmd("l") end, { desc = "Go to Right Window" })

vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
vim.keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Discover lua/bundles/<name>/init.lua specs, run eager ones, merge the
-- rest onto shared autocmds. Deps are module tables; ensure() is a
-- single-pass post-order walk (see lua/bundles/init.lua).
require("bundles").bootstrap()
