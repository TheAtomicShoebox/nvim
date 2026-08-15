---@type Bundle
local M = {
  load = {
    event = "FileType",
    pattern = { "haskell", "lhaskell", "cabal", "cabalproject" },
    once = true,
  },
}

function M.deps()
  -- LspAttach keymaps + blink capabilities before HLS starts.
  return { require("bundles.lsp") }
end

function M.setup()
  require("bundles.haskell.tools")
end

return M
