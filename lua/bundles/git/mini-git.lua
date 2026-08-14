-- Git-bundle mini.nvim modules (editing modules live in bundles/editing).
-- Both modules self-attach to already-open buffers on setup, so this whole
-- bundle is safe to defer (later()-style) when it goes lazy.
local util = require("util")

vim.pack.add({
  util.gh('nvim-mini/mini.nvim'),
})

require("mini.diff").setup({
  view = {
    style = "sign",
    signs = { add = "▎", change = "▎", delete = "▎" },
  },
})

require("mini.git").setup({})

local MiniDiff = require("mini.diff")
vim.keymap.set("n", "]h", function()
  MiniDiff.goto_hunk("next")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
  MiniDiff.goto_hunk("prev")
end, { desc = "Prev git hunk" })
-- <leader>gh = "hunks" group (see which-key spec in bundles/ui)
vim.keymap.set("n", "<leader>ghs", function()
  return MiniDiff.operator("apply")
end, { expr = true, desc = "Stage hunk (operator)" })
vim.keymap.set("n", "<leader>ghp", function()
  MiniDiff.toggle_overlay(vim.api.nvim_get_current_buf())
end, { desc = "Preview diff overlay" })
vim.keymap.set("n", "<leader>ghb", function()
  require("mini.git").show_at_cursor()
end, { desc = "Git blame/show" })
