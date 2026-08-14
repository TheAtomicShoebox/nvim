---@type Bundle
local M = {
  load = { event = "FileType", once = false },
}

function M.deps()
  return {}
end

function M.setup()
  require("bundles.syntax.treesitter")
end

return M
