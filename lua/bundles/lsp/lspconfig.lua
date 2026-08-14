local util = require("util")

vim.pack.add({ util.gh("neovim/nvim-lspconfig") })

local function lsp_on_attach(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then
    return
  end

  local bufnr = ev.buf
  ---@param desc string
  ---@param extra? vim.keymap.set.Opts
  local function opts(desc, extra)
    return vim.tbl_extend("force", { silent = true, buffer = bufnr, desc = desc }, extra or {})
  end

  -- goto (Snacks LSP pickers jump directly when there is a single result)
  vim.keymap.set('n', 'gd', function() Snacks.picker.lsp_definitions() end, opts("Goto Definition"))
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts("Goto Declaration"))
  vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end, opts("References", { nowait = true }))
  vim.keymap.set('n', 'gI', function() Snacks.picker.lsp_implementations() end, opts("Goto Implementation"))
  vim.keymap.set('n', 'gy', function() Snacks.picker.lsp_type_definitions() end, opts("Goto Type Definition"))
  vim.keymap.set('n', 'gS', function()
    vim.cmd('vsplit')
    vim.lsp.buf.definition()
  end, opts("Goto Definition (vsplit)"))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts("Hover"))

  -- code
  vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts("Code Action"))
  vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts("Rename"))

  -- search
  vim.keymap.set('n', '<leader>ss', function() Snacks.picker.lsp_symbols() end, opts("LSP Symbols (document)"))
  vim.keymap.set('n', '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, opts("LSP Symbols (workspace)"))

  if client:supports_method('textDocument/codeAction', bufnr) then
    vim.keymap.set('n', '<leader>co', function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
        bufnr = bufnr,
      })
      vim.defer_fn(function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, 50)
    end, opts("Organize Imports"))
  end

  -- Inlay hints on by default where the server offers them (lua_ls, vtsls
  -- and gopls are configured to in after/lsp/). Toggle: <leader>uh.
  if client:supports_method('textDocument/inlayHint', bufnr) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

-- Diagnostics (global, not LSP-dependent)
---@param next boolean
---@param severity? "ERROR"|"WARN"
local function diagnostic_goto(next, severity)
  return function()
    vim.diagnostic.jump({
      count = next and 1 or -1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
    })
  end
end

vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
vim.keymap.set("n", "<leader>xl", function()
  vim.diagnostic.setloclist({ open = true })
end, { desc = "Diagnostics Location List" })
vim.keymap.set("n", "<leader>xq", function()
  vim.diagnostic.setqflist({ open = true })
end, { desc = "Diagnostics Quickfix List" })

local augroup = vim.api.nvim_create_augroup("UserLsp", { clear = true })
vim.api.nvim_create_autocmd('LspAttach', { group = augroup, callback = lsp_on_attach })

vim.lsp.enable('lua_ls')

-- Completion capabilities (vim.lsp.config['*'], vim.g.rustaceanvim) are
-- advertised by bundles/completion/blink.lua: blink owns them, so this file
-- has no dependency on the completion bundle.
