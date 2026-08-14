local M = {}

local current_file = debug.getinfo(1, "S").source:sub(2)
local current_dir = vim.fs.dirname(current_file)

-- Expose each submodule as util.<name> (e.g. util.root) instead of merging
-- their keys into this table, so callable modules keep their metatables.
for name, t in vim.fs.dir(current_dir) do
  if t == "file" and name:match("%.lua$") and name ~= "init.lua" then
    local mod_name = name:gsub("%.lua$", "")

    local ok, submodule = pcall(require, "util." .. mod_name)

    if ok and type(submodule) == "table" then
      M[mod_name] = submodule
    end
  end
end

function M.gh(path)
  return 'https://github.com/' .. path
end

---True for `nvim --headless` and `nvim -es` (silent ex). Those sessions
---never get a UI, so UI plugins must not hijack messages / `vim.notify`.
function M.headless()
  for _, arg in ipairs(vim.v.argv) do
    if arg == "--headless" or arg == "-es" then
      return true
    end
  end
  return false
end

return M
