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
    local found = vim.fs.find({ 'stack.yaml' }, { upward = true, path = vim.uv.cwd() })
    if found and #found > 0 then
      return found[1]
    end
    return nil
  end

  ---@type utils.Util
  local util = require('utils')

  local stack_yml = find_stack_yaml()

  local haskell_tools = vim.g.haskell_tools or {}

  ---@type haskell-tools.Opts
  local tools_opts = type(haskell_tools) == 'function' and haskell_tools() or haskell_tools

  local lsp_opts = util.ToTable(vim.lsp.config['hls'])

  ---@type haskell-tools.Opts
  local opts = tools_opts ~= nil and vim.tbl_deep_extend('keep', tools_opts, lsp_opts) or lsp_opts

  util.Log(tools_opts.hls and 'found opts:\n' .. util.Serialize(tools_opts.hls) or 'tools_opts.hls is nil')
  util.Log(lsp_opts and 'vim lsp config:\n' .. util.Serialize(lsp_opts) or 'vim.lsp.config["hls"] is nil')
  util.Log(opts.hls and 'merged opts:\n' .. util.Serialize(opts.hls) or 'opts.hls is nil')

  ---@type ((fun():string[]) | string[])?
  local hls_cmd
  if stack_yml then
    hls_cmd = { 'stack', 'exec', '--', 'haskell-language-server-wrapper', '--lsp' }
    util.Log('I got to place 1, hls_cmd was set. Found ' .. stack_yml)
  else
    hls_cmd = opts.hls.cmd
  end
  util.Log('hls cmd: ' .. (hls_cmd ~= nil and util.Serialize(hls_cmd) or 'nil'))
  opts.hls.cmd = hls_cmd

  if opts then
    vim.g.haskell_tools = opts
    util.Log('I got to place 2, vim.g.haskell_tools.hls.cmd was set to ' .. util.Serialize(vim.g.haskell_tools.hls.cmd))
    util.Log('Final opts: ' .. util.Serialize(vim.g.haskell_tools))
  end

  return vim.g.haskell_tools
end
