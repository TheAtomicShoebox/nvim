local gh = require("util").gh

-- Notifications are first-paint UI, so mini.notify belongs to this bundle
-- (the editing/git mini modules live in bundles/editing and bundles/git).
vim.pack.add({
  gh('nvim-mini/mini.nvim'),
})

require("mini.notify").setup({})
