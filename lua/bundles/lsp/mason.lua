local gh = require("util").gh

vim.pack.add({
  gh("mason-org/mason.nvim"),
  gh("mason-org/mason-lspconfig.nvim"),
})

require("mason").setup({})

-- Bridges mason packages to vim.lsp.enable: every server installed via
-- :Mason is enabled automatically (nvim-lspconfig provides the configs),
-- and ensure_installed installs missing ones at startup (async).
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "bashls",
    "gopls",
    "clangd",
    "vtsls",
    "html",
    "cssls",
    "jsonls",
  },
})
