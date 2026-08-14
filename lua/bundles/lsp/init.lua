---@type Bundle
local M = {
  load = { event = "FileType", once = false },
}

function M.deps()
  return { require("bundles.completion") }
end

function M.setup()
  require("bundles.lsp.mason")
  require("bundles.lsp.lspconfig")
  require("bundles.lsp.lazydev")
  require("bundles.lsp.conform")
end

return M
