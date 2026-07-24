local util = require("util")

local gh = util.gh
local root = util.root

vim.pack.add({
  gh('folke/snacks.nvim'),
  {
    src = gh('folke/which-key.nvim'),
    opts_extend = { "spec" },
    opts = {
      preset = "helix",
      defaults = {},
      spec = {
        {
          mode = { "n", "x" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui" },
          { "<leader>x", group = "diagnostics/quickfix" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          -- better descriptions
          { "gx", desc = "Open with system app" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      if not vim.tbl_isempty(opts.defaults) then
        vim.notify("which-key: opts.defaults is deprecated. Please use opts.spec instead.", vim.log.levels.WARN)
        wk.register(opts.defaults)
      end
    end,
  },
  {
    src = gh("akinsho/bufferline.nvim"),
    options = {
      close_command = function(n) Snacks.bufdelete(n) end,
      right_mouse_command = function(n) Snacks.bufdelete(n) end,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
    }
  }
})

local Snacks = require("snacks")

Snacks.setup({
  animate = { enabled = true },
  bigfile = { enabled = true },
  dashboard = { enabled = false },
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
              ["<C-y>"] = { "yazi_copy_relative_path", mode = { "n", "i" }},
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
        diagnostic_open =  true,
        focus = "list",
        follow_file = true,
        git_status = true,
        git_status_open = false,
        git_untracked  = true,
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
        -- keys = {
        --   --{ "<leader>fe", function() Snacks.explorer({ cwd = get_root() }) end, desc = "Explorer Snacks (root dir)" },
        --   { "<leaer>fE", function() Snacks.explorer() end, desc = "Explorer snacks (cwd)" },
        --   --{ "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
        --   { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
        -- }
      },
    },
  },
})

require("which-key").setup({})

vim.keymap.set('n', '<leader>fE', function() Snacks.explorer() end, { desc = "Explorer snacks (cwd)" })
vim.keymap.set('n', '<leader>fe', function() Snacks.explorer({ cwd = root() }) end, { desc = "Explorer snacks (root dir)" })
vim.keymap.set('n', '<leader>e', '<leader>fe', { desc = "Explorer snacks (root dir)", remap = true })
vim.keymap.set('n', '<leader>E', '<leader>fE', { desc = "Explorer snacks (cwd)", remap = true })

vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
vim.keymap.set('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
vim.keymap.set('n', '<leader>bi', function() Snacks.bufdelete.invisible() end, { desc = "Delete Invisible Buffers" })
vim.keymap.set('n', '<leader>bD', "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
