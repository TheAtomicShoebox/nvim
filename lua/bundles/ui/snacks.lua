local util = require("util")

local root = util.root

vim.pack.add({
  util.gh("folke/snacks.nvim"),
})

require("snacks").setup({
  animate = { enabled = true },
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      -- Stock keys minus the lazy.nvim entry. "Restore Session" is hardwired
      -- to persistence.nvim because the stock `section = "session"` key only
      -- detects session plugins through lazy.nvim.
      -- stylua: ignore
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      -- Replaces the stock `startup` section, which requires lazy.nvim stats.
      function()
        return {
          align = "center",
          text = {
            { "⚡ Neovim with ", hl = "footer" },
            -- info = false: the default runs git queries per plugin (~100ms)
            { tostring(#vim.pack.get(nil, { info = false })), hl = "special" },
            { " plugins", hl = "footer" },
          },
        }
      end,
    },
  },
  dim = { enabled = true },
  explorer = { enabled = true, replace_netrw = true },
  image = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  layout = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scratch = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  terminal = { enabled = true },
  toggle = {
    enabled = true,
    which_key = true,
    notify = true,
  },
  words = { enabled = true },
  zen = { enabled = true },
  picker = {
    sources = {
      files = {
        hidden = true,
        ignored = true,
        win = {
          input = {
            keys = {
              ["<S-h>"] = "toggle_hidden",
              ["<S-i>"] = "toggle_ignored",
              ["<S-f>"] = "toggle_follow",
              ["<C-y>"] = { "yazi_copy_relative_path", mode = { "n", "i" } },
            },
          },
        },
        exclude = {
          "**/.git/*",
          "**/node_modules/*",
          "**/.yarn/cache/*",
          "**/.yarn/install/*",
          "**/.yarn/releases/*",
          "**/.pnpm-store/*",
          "**/.venv/*",
          "**/.idea/*",
          "**/.DS_Store",
          "builde/*",
          "coverage/*",
          "dist/*",
          "hodor-types/*",
          "**/target/*",
          "**/public/*",
          "**/digest*.txt",
          "**/.node-gyp/**",
        },
      },
      grep = {
        hidden = true,
        ignored = true,
        win = {
          input = {
            keys = {
              ["<S-h>"] = "toggle_hidden",
              ["<S-i>"] = "toggle_ignored",
              ["<S-f>"] = "toggle_follow",
            },
          },
        },
        exclude = {
          "**/.git/*",
          "**/node_modules/*",
          "**/.yarn/cache/*",
          "**/.yarn/install/*",
          "**/.yarn/releases/*",
          "**/.pnpm-store/*",
          "**/venv/*",
          "**/.idea/*",
          "**/.DS_Store",
          "builde/*",
          "coverage/*",
          "dist/*",
          "hodor-types/*",
          "**/target/*",
          "**/public/*",
          "**/digest*.txt",
          "**/.node-gyp/**",
        },
      },
      grep_buffers = {},
      explorer = {
        hidden = true,
        ignored = true,
        supports_live = true,
        auto_close = false,
        diagnostics = true,
        diagnostic_open = true,
        focus = "list",
        follow_file = true,
        git_status = true,
        git_status_open = false,
        git_untracked = true,
        jump = { close = false },
        tree = true,
        watch = true,
        exclude = {
          ".git",
          ".pnpm-store",
          "venv",
          ".DS_Store",
          "**/.node-gyp/**",
        },
      },
    },
  },
})

-- Toggles (<leader>u*, LazyVim-style; current state shows in the which-key popup)
Snacks.toggle({
  name = "Auto Format (Global)",
  get = function()
    return vim.g.autoformat
  end,
  set = function(state)
    vim.g.autoformat = state
  end,
}):map("<leader>uf")

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle
  .option("conceallevel", {
    off = 0,
    on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
    name = "Conceal Level",
  })
  :map("<leader>uc")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.zen():map("<leader>uz")
Snacks.toggle.zoom():map("<leader>uZ")
Snacks.toggle.scroll():map("<leader>uS")
Snacks.toggle.animate():map("<leader>ua")

-- Profiler (<leader>dp group in the which-key spec)
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")

util.pack.keys({
  -- snacks explorer
  {
    "<leader>fE",
    function()
      Snacks.explorer()
    end,
    desc = "Explorer Snacks (cwd)",
  },
  {
    "<leader>fe",
    function()
      Snacks.explorer({ cwd = root() })
    end,
    desc = "Explorer Snacks (root dir)",
  },
  { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
  { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
  -- snacks buffers
  {
    "<leader>bd",
    function()
      Snacks.bufdelete()
    end,
    desc = "Delete Buffer",
  },
  {
    "<leader>bo",
    function()
      Snacks.bufdelete.other()
    end,
    desc = "Delete Other Buffers",
  },
  {
    "<leader>bi",
    function()
      Snacks.bufdelete.invisible()
    end,
    desc = "Delete Invisible Buffers",
  },
  { "<leader>bD", "<cmd>:bd<cr>", desc = "Delete Buffer and Window" },
  -- snacks scratch buffers
  {
    "<leader>.",
    function()
      Snacks.scratch()
    end,
    desc = "Toggle Scratch Buffer",
  },
  {
    "<leader>S",
    function()
      Snacks.scratch.select()
    end,
    desc = "Select Scratch Buffer",
  },
  -- snacks terminal
  {
    "<leader>ft",
    function()
      Snacks.terminal(nil, { cwd = root() })
    end,
    desc = "Terminal (root)",
  },
  {
    "<leader>fT",
    function()
      Snacks.terminal()
    end,
    desc = "Terminal (cwd)",
  },
  {
    "<c-/>",
    function()
      Snacks.terminal(nil, { cwd = root() })
    end,
    desc = "Terminal (root)",
  },
  {
    "<c-_>",
    function()
      Snacks.terminal(nil, { cwd = root() })
    end,
    desc = "which_key_ignore",
  },
  -- snacks notifier
  {
    "<leader>un",
    function()
      Snacks.notifier.hide()
    end,
    desc = "Dismiss All Notifications",
  },
})
