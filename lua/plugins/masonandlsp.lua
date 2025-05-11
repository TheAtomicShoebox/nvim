if vim.g.vscode then
  return {}
end

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'mason-org/mason.nvim',
        opts = {
          registries = {
            'github:mason-org/mason-registry',
            'github:Crashdummyy/mason-registry',
          },
        },
      },
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'mason-org/mason-lspconfig.nvim',
    },
  },
}
