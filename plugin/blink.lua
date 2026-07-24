local gh = require("util").gh

vim.pack.add({
  gh('L3MON4D3/LuaSnip'),
  gh("saghen/blink.lib"),
  {
    src = gh('saghen/blink.cmp'),
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          }
        }
      }
    }
  }
})

local blink_cmp = require('blink.cmp')

blink_cmp.build():pwait()
blink_cmp.setup({
  keymap =  {
    preset = "default",
    -- "<C-Space>"] = { "show", "hide" },
    -- ["<CR>"] = { "accept", "fallback" },
    -- ["<C-j>"] = { "select_next", "fallback" },
    -- ["<C-k>"] = { "select_prev", "fallback" },
    -- ["<Tab>"] = { "snippet_forward", "fallback" },
    -- ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    menu = {
      auto_show = false --function() return vim.bo.filetype ~= "markdown" end,
    },
  },
  sources = { default = { "lsp", "path", "buffer", "snippets" } },
  snippets = {
    expand = function(snippet)
      require('luasnip').lsp_expand(snippet)
    end,
  },
  fuzzy = {
    implementation = 'rust',
    --prebuilt_binaries = { download = true },
  },
})
