if vim.g.vscode then
  return {}
end

return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "mason-org/mason-registry",
      "github:Crashdummyy:mason-registry",
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "williamboman/mason.nvim",
      },
      "williamboman/mason-lspconfig.nvim",
    },
  },
}
