local gh = function(x) return 'https://github.com/' .. x end

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

vim.pack.add({
  gh('echasnovski/mini.nvim'),
  gh('ibhagwan/fzf-lua'),
  gh('nvim-tree/nvim-tree.lua'),
  {
    src = gh('nvim-treesitter/nvim-treesitter'),
    branch = 'main',
    build = ':TSUpdate',
  },
  gh('neovim/nvim-lspconfig'),
  gh('mason-org/mason.nvim'),
  gh('creativenull/efmls-configs-nvim'),
  {
    src = gh('saghen/blink.cmp'),
    version = vim.version.range('1.*')
  },
  gh('L3MON4D3/LuaSnip'),
})


vim.keymap.set('n', '<ESC>', ':nohlsearch<CR>', { desc = "Clear search highlights" })

local setup_treesitter = function()
  local treesitter = require('nvim-treesitter')
  treesitter.setup({})
  local ensure_installed = {
    "vim",
    "vimdoc",
    "rust",
    "c",
    "cpp",
    "go",
    "html",
    "css",
    "javascript",
    "json",
    "lua",
    "markdown",
    "python",
    "typescript",
    "vue",
    "svelte",
    "bash",
    "haskell"
  }

  local config = require('nvim-treesitter.config')

  local already_installed = config.get_installed()
  local parsers_to_install = {}

  for _, parser in ipairs(ensure_installed) do
    if not vim.tbl_contains(already_installed, parser) then
      table.insert(parsers_to_install, parser)
    end
  end

  if #parsers_to_install > 0 then
    treesitter.install(parsers_to_install)
  end

  local group = vim.api.nvim_create_augroup('TreeSitterConfig', { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      if vim.list_contains(config.get_installed(), vim.treesitter.language.get_lang(args.match)) then
        vim.treesitter.start(args.buf)
      end
    end,
  })
end

setup_treesitter()

require('nvim-tree').setup({
  view = { width = 35 },
  filters = { dotfiles = false },
  renderer = { group_empty = true },
})
vim.keymap.set('n', '<leader>e', function()
  require('nvim-tree.api').tree.toggle()
end, { desc = 'Toggle NvimTree' })


vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF Diagnostics Workspace" })

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "▎", change = "▎", delete = "▎" },
	},
})

require("mini.git").setup({})

local MiniDiff = require("mini.diff")
vim.keymap.set("n", "]h", function()
	MiniDiff.goto_hunk("next")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	MiniDiff.goto_hunk("prev")
end, { desc = "Prev git hunk" })
vim.keymap.set("n", "<leader>hs", MiniDiff.operator, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hp", function()
	MiniDiff.toggle_overlay()
end, { desc = "Preview diff overlay" })
vim.keymap.set("n", "<leader>hb", function()
	require("mini.git").show_at_cursor()
end, { desc = "Git blame/show" })

require("mason").setup({})

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

local function lsp_on_attach(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then
    return
  end

  local bufnr = ev.buf
  local base_opts = { noremap = true, silent = true, buffer = bufnr }
  ---@param desc string
  local function add_desc(desc)
    local opts = vim.deepcopy(base_opts)
    opts.desc = desc
    return opts
  end

  vim.keymap.set('n', '<leader>gd', function() require('fzf-lua').lsp_definitions({ jump_to_single_result = true }) end, add_desc("Go to definition"))
  vim.keymap.set('n', '<leader>gD', vim.lsp.buf.definition, add)
  vim.keymap.set('n', '<leader>gS', function()
    vim.cmd('vsplit')
    vim.lsp.buf.definition()
  end, add_desc("Open definition in vertical split"))
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, add_desc("Code Action"))
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, add_desc("Rename"))
  vim.keymap.set('n', '<leader>D', function() vim.diagnostic.open_float({ scope = 'line' }) end, add_desc("Peek diagnostic (line)"))
  vim.keymap.set('n', '<leader>d', function() vim.diagnostic.open_float({ scope = 'cursor' }) end, add_desc("Peek diagnostic (cursor)"))
  vim.keymap.set('n', '<leader>nd', function() vim.diagnostic.jump({ count = 1 }) end, add_desc("Increment diagnostic"))
  vim.keymap.set('n', '<leader>pd', function() vim.diagnostic.jump({ count = -1 }) end, add_desc("Decrement diagnostic"))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, base_opts)
  vim.keymap.set('n', '<leader>fr', function() require('fzf-lua').lsp_references() end, add_desc("Search references"))
  vim.keymap.set('n', '<leader>ft', function() require('fzf-lua').lsp_typedefs() end, add_desc("Search types"))
  vim.keymap.set('n', '<leader>fw', function() require('fzf-lua').lsp_worskpace_symbols() end, add_desc("Search workspace symbols"))
  vim.keymap.set('n', '<leader>fi', function() require('fzf-lua').lsp_implementations() end, add_desc("Search implementation"))

  if client:supports_method('textDocument/codeAction', bufnr) then
    vim.keymap.set('n', '<leader>oi', function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
        bufnr = bufnr,
      })
      vim.defer_fn(function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, 50)
    end, add_desc("Organize Imports"))
  end
end

vim.api.nvim_create_autocmd('LspAttach', { group = augroup, callback = lsp_on_attach })

vim.keymap.set('n', '<leader>q', function() vim.diagnostic.setloclist({ open = true }) end, { desc = "Open diagnostic list" })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.open_float, { desc = "Show line diagnostics" })

require('blink.cmp').setup({
  keymap =  {
    preset = "none",
    ["<C-Space>"] = { "show", "hide" },
    ["<CR>"] = { "accept", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    menu = {
      auto_show = function() return vim.bo.filetype ~= "markdown" end,
    },
  },
  sources = { default = { "lsp", "path", "buffer", "snippets" } },
  snippets = {
    expand = function(snippet)
      require('luasnip').lsp_expand(snippet)
    end,
  },
  fuzzy = {
    implementation = 'prefer_rust',
    prebuilt_binaries = { download = true },
  },
})

vim.lsp.config['*'] = {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
}

vim.g.rustaceanvim = {
  server = {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  },
}
