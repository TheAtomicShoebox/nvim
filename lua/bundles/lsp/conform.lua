local util = require("util")

vim.pack.add({ util.gh('stevearc/conform.nvim') })

-- Global autoformat default; <leader>uf toggles it (see bundles/ui),
-- vim.b.autoformat overrides it per buffer.
if vim.g.autoformat == nil then
  vim.g.autoformat = true
end

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    scss = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    -- Filetypes without an entry fall back to LSP formatting
    -- (gopls, clangd, rust-analyzer, ...) via lsp_format = "fallback".
  },
  default_format_opts = {
    timeout_ms = 3000,
    lsp_format = "fallback",
  },
  format_on_save = function(bufnr)
    local baf = vim.b[bufnr].autoformat
    if baf == false or (baf == nil and not vim.g.autoformat) then
      return
    end
    return {}
  end,
})

util.pack.keys({
  {
    "<leader>cf",
    function() require("conform").format() end,
    mode = { "n", "v" },
    desc = "Format buffer/range",
  },
})
