---@type Bundle
local M = {
  load = "eager",
}

function M.deps()
  return {}
end

function M.setup()
  require("bundles.ui.notify")
  require("bundles.ui.snacks")
  require("bundles.ui.which-key")
  require("bundles.ui.bufferline")
  require("bundles.ui.lualine")
end

return M
