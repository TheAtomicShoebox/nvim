local util = require("util")

vim.pack.add({ util.gh("neovim/nvim-lspconfig") })

local function lsp_on_attach(ev)
  print('got here')
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
  vim.keymap.set('n', '<leader>gD', vim.lsp.buf.definition, add_desc("Go to definition (cursor)"))
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
  vim.keymap.set('n', '<leader>fw', function() require('fzf-lua').lsp_workspace_symbols() end, add_desc("Search workspace symbols"))
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

vim.keymap.set('n', '<leader>q', function() vim.diagnostic.setloclist({ open = true }) end, { desc = "Open diagnostic list" })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.api.nvim_create_autocmd('LspAttach', { group = augroup, callback = lsp_on_attach })

vim.lsp.enable('lua_ls')

vim.lsp.config['*'] = {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
}

vim.g.rustaceanvim = {
  server = {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  },
}
