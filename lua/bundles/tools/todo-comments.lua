local util = require("util")

vim.pack.add({
  util.gh("folke/todo-comments.nvim"),
})

-- NOTE: todo-comments defers its own setup past VimEnter and then registers
-- a Snacks picker source, so the Snacks global (bundles/ui) must exist by
-- the first event-loop tick. All bundles load during init today, so any
-- bundle order satisfies that.
require("todo-comments").setup({})

util.pack.keys({
  { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
  { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
  { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
  { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
  { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
  { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
})
