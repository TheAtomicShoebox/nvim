---@type Bundle
local M = {
  load = { event = "VimEnter", once = true },
}

function M.deps()
  return { require("bundles.ui") }
end

function M.setup()
  require("bundles.tools.trouble")
  require("bundles.tools.todo-comments")
  require("bundles.tools.picker")
  require("bundles.tools.pack")
  require("bundles.tools.persistence")
end

return M
