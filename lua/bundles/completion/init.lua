---@type Bundle
local M = {
  load = { event = "InsertEnter", once = true },
}

function M.deps()
  return {}
end

function M.setup()
  require("bundles.completion.blink")
end

return M
