local util = require("util")

vim.pack.add({
  {
    src = util.gh('folke/lazydev.nvim'),
    ft = "lua",
    opts = {
      runtime = vim.env.VIMRUNTIME --[[@as string]],
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      }, ---@type lazydev.Library.spec[]
      ---@type boolean|(fun(root:string):boolean?)
      enabled = function(root_dir)
        return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
      end,
      integrations = {
        lspconfig = true,
        cmp = true,
      }
    }
  }
})

require("lazydev").setup({})
