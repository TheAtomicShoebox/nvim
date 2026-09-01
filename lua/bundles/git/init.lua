---@type Bundle
local M = {
  load = { event = "VimEnter", once = true },
}

function M.deps() return { require("bundles.ui") } end

function M.setup()
  require("bundles.git.mini-git")
  require("bundles.git.snacks-git")
end

return M
