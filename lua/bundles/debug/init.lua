---@type Bundle
local M = {
  load = { event = "VimEnter", once = true },
}

function M.deps() return { require("bundles.ui") } end

function M.setup()
  require("bundles.debug.dap")
  require("bundles.debug.ui")
  require("bundles.debug.virtual-text")
end

return M
