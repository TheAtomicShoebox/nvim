---This file is evaluated at config resolution (mason-lspconfig's
---automatic_enable triggers that during its own startup), so it must add its
---own dependency: relying on another config file having pack.add'ed
---SchemaStore would reintroduce a source-order hazard.
vim.pack.add({ require("util").gh("b0o/SchemaStore.nvim") })

---@type vim.lsp.Config
return {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
      format = { enable = true },
    },
  },
}
