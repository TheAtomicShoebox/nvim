---@type Bundle
local M = {
  load = "eager",
}

function M.deps()
  return {}
end

function M.setup()
  require("bundles.editing.mini")
  require("bundles.editing.flash")
end

return M
