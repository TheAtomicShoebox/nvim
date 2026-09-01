local gh = require("util").gh

vim.pack.add({
  gh("L3MON4D3/LuaSnip"),
  gh("saghen/blink.lib"),
  gh("saghen/blink.cmp"),
})

local blink_cmp = require("blink.cmp")

-- blink's rust fuzzy matcher needs a build step before setup
blink_cmp.build():pwait()
blink_cmp.setup({
  keymap = { preset = "super-tab" },
  -- Don't preselect while a snippet can still jump forward, so Tab
  -- advances placeholders instead of accepting a new completion.
  completion = {
    list = {
      selection = {
        preselect = function()
          return not blink_cmp.snippet_active({ direction = 1 })
        end,
      },
    },
  },
  appearance = { nerd_font_variant = "mono" },
  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },
  },
  snippets = {
    expand = function(snippet)
      require("luasnip").lsp_expand(snippet)
    end,
  },
  fuzzy = {
    implementation = "rust",
    --prebuilt_binaries = { download = true },
  },
})

-- Advertise blink's completion capabilities to every LSP server. Lives here
-- (not in the lsp bundle) so no other file needs blink.cmp at load time.
-- Servers resolve their config at FileType attach, after all bundles loaded.
-- NOTE for future lazy loading: if this bundle moves to InsertEnter, this
-- assignment must still happen before the first LSP attach.
local capabilities = blink_cmp.get_lsp_capabilities()

vim.lsp.config["*"] = {
  capabilities = capabilities,
}

vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
  },
}
