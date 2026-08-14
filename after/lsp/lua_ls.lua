---Merged on top of nvim-lspconfig's lsp/lua_ls.lua when the config resolves
---(first attach). Workspace libraries come from lazydev (bundles/lsp/lazydev.lua).
---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      workspace = {
        -- lazydev provides exactly the libraries we want; the third-party
        -- prompt ("luassert found, apply?") is just noise.
        checkThirdParty = false,
      },
      codeLens = { enable = true },
      completion = { callSnippet = "Replace" },
      doc = { privateName = { "^_" } },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
    },
  },
}
