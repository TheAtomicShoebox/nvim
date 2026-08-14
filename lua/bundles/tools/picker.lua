local util = require("util")

local root = util.root

-- Snacks picker keymaps (snacks itself is set up in bundles/ui; source
-- options for files/grep/explorer live there too). Keymaps only run at
-- keypress, so bundle load order doesn't matter.
util.pack.keys({
  { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
  { "<leader>/", function() Snacks.picker.grep({ cwd = root() }) end, desc = "Grep (root dir)" },
  { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
  -- find
  { "<leader>ff", function() Snacks.picker.files({ cwd = root() }) end, desc = "Find Files (root dir)" },
  { "<leader>fF", function() Snacks.picker.files() end, desc = "Find Files (cwd)" },
  { "<leader>fg", function() Snacks.picker.grep({ cwd = root() }) end, desc = "Grep (root dir)" },
  { "<leader>fG", function() Snacks.picker.grep() end, desc = "Grep (cwd)" },
  { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
  { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
  { "<leader>fx", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnostics (buffer)" },
  { "<leader>fX", function() Snacks.picker.diagnostics() end, desc = "Diagnostics (workspace)" },
  -- search (LazyVim-style <leader>s group)
  { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
  { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
  { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
  { "<leader>sn", function() Snacks.picker.notifications() end, desc = "Notification History" },
})
