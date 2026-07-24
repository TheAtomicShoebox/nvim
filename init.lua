local util = require("util")

local gh = util.gh

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

vim.keymap.set('n', '<ESC>', ':nohlsearch<CR>', { desc = "Clear search highlights" })

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = {
   "*.lua",
   "*.py",
   "*.go",
   "*.js",
   "*.jsx",
   "*.ts",
   "*.tsx",
   "*.json",
   "*.css",
   "*.scss",
   "*.html",
   "*.sh",
   "*.bash",
   "*.zsh",
   "*.c",
   "*.cpp",
   "*.h",
   "*.hpp",
  },
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    if not vim.bo[args.buf].modifiable then
      return
    end
    if vim.api.nvim_buf_get_name(args.buf) == "" then
      return
    end

    local has_efm = false

    for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
      if c.name == "efm" then
        has_efm = true
        break
      end
    end
    if not has_efm then
      return
    end

    pcall(vim.lsp.buf.format, {
      bufnr = args.buf,
      timeout_ms = 2000,
      filter = function(c)
        return c.name == "efm"
      end,
    })
  end,
})

-- require('nvim-tree').setup({
--   view = { width = 35 },
--   filters = { dotfiles = false },
--   renderer = { group_empty = true },
-- })
-- vim.keymap.set('n', '<leader>e', function()
--   require('nvim-tree.api').tree.toggle()
-- end, { desc = 'Toggle NvimTree' })

vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

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


vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Go to Lower Window", remap = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Go to Left Window", remap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Go to Upper Window", remap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Go to Right Window", remap = true })

vim.keymap.set('n', '<S-h>', '<cmd>bprevious<cr>', { desc = "Prev Buffer" })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<cr>', { desc = "Next Buffer" })
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = "Prev Buffer" })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = "Next Buffer" })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<cr>', { desc = "Switch to Other Buffer" })
vim.keymap.set('n', '<leader>`', '<cmd>e #<cr>', { desc = "Switch to Other Buffer" })
