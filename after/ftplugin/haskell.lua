-- https://github.com/mrcjkb/haskell-tools.nvim?tab=readme-ov-file
-- ~/.config/nvim/after/ftplugin/haskell.lua
local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr }
local map = LazyVim.safe_keymap_set

-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
--[[opts.desc = 'Run all code lenses'
 map('n', '<leader>cL', vim.lsp.codelens.run, opts)]]
-- Hoogle search for the type signature of the definition under the cursor
opts.desc = 'Hoogle search type signature'
map('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
-- Evaluate all code snippets
opts.desc = 'Evaluate all code snippets'
map('n', '<leader>ce', ht.lsp.buf_eval_all, opts)
-- Toggle a GHCi repl for the current package
opts.desc = 'Toggle GHCi repl (current package)'
map('n', '<leader>rr', ht.repl.toggle, opts)
-- Toggle a GHCi repl for the current buffer
opts.desc = 'Toggle GHCi repl (current buffer)'
map('n', '<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, opts)
opts.desc = 'Quit repl'
map('n', '<leader>rq', ht.repl.quit, opts)
