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
  -- Mason's HLS bindist is GHC-patch-specific (currently 9.10.3) and
  -- automatic_enable would start lspconfig's `hls` next to haskell-tools,
  -- which is what produces "ghcide compiled against X but using Y".
  automatic_enable = {
    exclude = { "hls" },
  },
})
vim.lsp.enable("hls", false)
