local util = require("util")

local root = util.root

-- Git keymaps, LazyVim-style. Snacks is set up in bundles/ui; hunk-level
-- maps (<leader>gh*) live in mini-git.lua next to mini.diff.
util.pack.keys({
  { "<leader>gb", function() Snacks.picker.git_log_line() end, desc = "Git Blame Line" },
  { "<leader>gB", function() Snacks.gitbrowse() end, mode = { "n", "x" }, desc = "Git Browse (open)" },
  {
    "<leader>gY",
    function()
      Snacks.gitbrowse({
        open = function(url) vim.fn.setreg("+", url) end,
        notify = false,
      })
    end,
    mode = { "n", "x" },
    desc = "Git Browse (copy url)",
  },
  { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
  { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
  { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
  { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Current File History" },
  { "<leader>gl", function() Snacks.picker.git_log({ cwd = root.git() }) end, desc = "Git Log (root)" },
  { "<leader>gL", function() Snacks.picker.git_log() end, desc = "Git Log (cwd)" },
})

-- Like LazyVim, only map lazygit when it's actually installed.
if vim.fn.executable("lazygit") == 1 then
  util.pack.keys({
    { "<leader>gg", function() Snacks.lazygit({ cwd = root.git() }) end, desc = "Lazygit (root)" },
    { "<leader>gG", function() Snacks.lazygit() end, desc = "Lazygit (cwd)" },
  })
end
