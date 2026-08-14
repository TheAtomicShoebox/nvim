---@type Bundle
local M = {
  load = "eager",
}

function M.deps()
  return {}
end

function M.setup()
  require("bundles.ui.colorscheme") -- before UI plugins so they inherit highlights
  require("bundles.ui.snacks")
  require("bundles.ui.notify") -- noice; after snacks so vim.notify routes to snacks.notifier
  require("bundles.ui.which-key")
  require("bundles.ui.bufferline")
  require("bundles.ui.lualine")
end

return M
