-- https://github.com/mrcjkb/haskell-tools.nvim?tab=readme-ov-file ~/.config/nvim/after/ftplugin/haskell.lua
-- local ht = require 'haskell-tools'
-- local bufnr = vim.api.nvim_get_current_buf()
-- local opts = { noremap = true, silent = true, buffer = bufnr }
-- local map = LazyVim.safe_keymap_set
--
-- -- haskell-language-server relies heavily on codeLenses,
-- -- so auto-refresh (see advanced configuration) is enabled by default
-- --[[opts.desc = 'Run all code lenses'
--  map('n', '<leader>cL', vim.lsp.codelens.run, opts)]]
-- -- Hoogle search for the type signature of the definition under the cursor
-- opts.desc = 'Hoogle search type signature'
-- map('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
-- -- Evaluate all code snippets
-- opts.desc = 'Evaluate all code snippets'
-- map('n', '<leader>ce', ht.lsp.buf_eval_all, opts)
-- -- Toggle a GHCi repl for the current package
-- opts.desc = 'Toggle GHCi repl (current package)'
-- map('n', '<leader>rr', ht.repl.toggle, opts)
-- -- Toggle a GHCi repl for the current buffer
-- opts.desc = 'Toggle GHCi repl (current buffer)'
-- map('n', '<leader>rf', function()
--   ht.repl.toggle(vim.api.nvim_buf_get_name(0))
-- end, opts)
-- opts.desc = 'Quit repl'
-- map('n', '<leader>rq', ht.repl.quit, opts)
if not vim.g.vscode then
  local function find_stack_yaml()
    local found = vim.fs.find({ 'stack.yaml' }, { upward = true, path = vim.loop.cwd() })
    if found and #found > 0 then
      return found[1]
    end
    return nil
  end

  local stack_yml = find_stack_yaml()

  local haskell_tools = vim.g.haskell_tools or {}

  ---@type haskell-tools.Opts
  local opts = type(haskell_tools) == 'function' and haskell_tools() or haskell_tools

  ---@type ((fun():string[]) | string[])?
  local hls_cmd
  if stack_yml then
    hls_cmd = { 'stack', 'exec', '--', 'haskell-language-server-wrapper', '--lsp' }
  else
    hls_cmd = opts.hls.cmd
  end

  haskell_tools.hls.cmd = hls_cmd

  if haskell_tools then
    vim.g.haskell_tools = haskell_tools
  end
end
