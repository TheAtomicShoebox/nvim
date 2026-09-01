-- Editing-bundle mini.nvim modules. The plugin itself is one vim.pack entry;
-- its modules are set up per bundle: editing here, diff/git in
-- bundles/git/mini-git.lua, icons + notify in bundles/ui (duplicate adds
-- are no-ops).
local gh = require("util").gh

vim.pack.add({
  gh("nvim-mini/mini.nvim"),
})

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
-- LazyVim-style gs* mappings (defaults are sa/sd/... which shadow `s`),
-- matching the which-key "gs" = surround group.
require("mini.surround").setup({
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
})
require("mini.cursorword").setup({})
-- mini.indentscope intentionally not enabled: snacks indent already draws
-- indent guides plus an animated scope highlight, and both together double up.
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
