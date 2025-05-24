if vim.g.vscode then
  return {}
end

return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    ft = { "cs", "csproj", "sln", "slnx", "props", "csx", "targets" },
    --cmd = "Dotnet",
    opts = {},
    config = function()
      require("easy-dotnet").setup()
    end,
  },
}
