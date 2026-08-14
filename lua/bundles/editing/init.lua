---@type Bundle
local M = {
  -- Not InsertEnter: flash (s/S), surround, comment, and mini.ai are
  -- normal-mode first. VimEnter is later()-style — after first paint,
  -- before the user can type. Merges with git + tools.
  load = { event = "VimEnter", once = true },
}

function M.deps()
  return {}
end

function M.setup()
  require("bundles.editing.mini")
  require("bundles.editing.flash")
end

return M
