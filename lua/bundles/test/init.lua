---@type Bundle
local M = {
  load = { event = "VimEnter", once = true },
}

function M.deps()
  -- nvim-nio + DAP strategy for `<leader>dT`.
  return { require("bundles.ui"), require("bundles.debug") }
end

function M.setup() require("bundles.test.neotest") end

---Register a language adapter after this bundle's setup (deps run first).
---Mutates neotest's live adapter list so a second setup() is not needed.
---@param adapter neotest.Adapter
function M.add_adapter(adapter)
  local adapters = require("neotest.config").adapters
  for _, existing in ipairs(adapters) do
    if existing == adapter or (existing.name and existing.name == adapter.name) then
      return
    end
  end
  adapters[#adapters + 1] = adapter
end

return M
