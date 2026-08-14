local util = require("util")

vim.pack.add({ util.gh('folke/persistence.nvim') })

-- Saves a session per directory+branch on exit; nothing is auto-restored,
-- use <leader>qs after launching from a project directory.
require("persistence").setup({})

util.pack.keys({
  { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
  { "<leader>qS", function() require("persistence").select() end, desc = "Select Session" },
  { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
  { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
})
