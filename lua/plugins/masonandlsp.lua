if vim.g.vscode then
  return {}
end

return {
  -- {
  --   "williamboman/mason.nvim",
  --   dependencies = {
  --     "mason-org/mason-registry",
  --     "Crashdummyy/mason-registry",
  --   },
  -- },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry",
          },
        },
      },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },
}
