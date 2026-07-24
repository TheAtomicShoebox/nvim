local gh = require("util").gh

vim.pack.add({
  gh('nvim-mini/mini.nvim'),
  gh('mason-org/mason.nvim'),
  gh('creativenull/efmls-configs-nvim'),
})

require("mason").setup({})

