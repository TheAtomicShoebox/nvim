local gh = require("util").gh

vim.pack.add({
  gh("theHamsta/nvim-dap-virtual-text"),
})

require("nvim-dap-virtual-text").setup({
  commented = true,
})
