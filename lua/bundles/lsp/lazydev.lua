local util = require("util")

vim.pack.add({
  util.gh('folke/lazydev.nvim'),
})

-- Pre-declare every vim.pack plugin as a library. lazydev would otherwise
-- grow the library one plugin at a time as requires/words show up in opened
-- buffers, and lua_ls reloads the ENTIRE workspace on every library change
-- ("Loading workspace" again after opening each new file). One upfront list
-- trades a slightly longer initial (async) load for zero mid-session reloads.
-- vim.pack.get() lists everything installed on disk, so plugins added by
-- bundles that load after this one are still included.
---@type lazydev.Library.spec[]
local library = {
  -- No `words` gate: a gated entry gets appended the first time a buffer
  -- mentions the word, which is itself a full workspace reload.
  { path = "${3rd}/luv/library" },
}
-- info = false skips per-plugin git queries (~100ms with default info = true)
for _, p in ipairs(vim.pack.get(nil, { info = false })) do
  library[#library + 1] = { path = p.path }
end

require("lazydev").setup({
  runtime = vim.env.VIMRUNTIME --[[@as string]],
  library = library,
  ---@type boolean|(fun(root:string):boolean?)
  enabled = function(root_dir)
    return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
  end,
  integrations = {
    lspconfig = true,
    cmp = true,
  },
})
