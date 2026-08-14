local util = require("util")

vim.pack.add({ util.gh('nvim-lualine/lualine.nvim') })

vim.opt.laststatus = 3 -- single global statusline

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    disabled_filetypes = { statusline = { "snacks_dashboard" } },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { function() return util.root.pretty_path() end },
      {
        "diagnostics",
        symbols = { error = "\u{f057} ", warn = "\u{f071} ", info = "\u{f05a} ", hint = "\u{ea61} " },
      },
    },
    lualine_x = {
      {
        "diff",
        -- mini.diff keeps its per-buffer summary here
        source = function()
          local summary = vim.b.minidiff_summary
          return summary and {
            added = summary.add,
            modified = summary.change,
            removed = summary.delete,
          }
        end,
      },
    },
    lualine_y = {
      { "progress", separator = " ", padding = { left = 1, right = 0 } },
      { "location", padding = { left = 0, right = 1 } },
    },
    lualine_z = {
      function()
        return "\u{f017} " .. os.date("%R")
      end,
    },
  },
  extensions = {},
})
