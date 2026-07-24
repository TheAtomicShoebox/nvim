local M = {}

local current_file = debug.getinfo(1, "S").source:sub(2)
local current_dir = vim.fs.dirname(current_file)

for name, t in vim.fs.dir(current_dir) do
  if t == "file" and name:match("%.lua$") and name ~= "init.lua" then
    local mod_name = name:gsub(".lua$", "")

    local ok, submodule = pcall(require, "util." .. mod_name)

    if ok and type(submodule) == "table" then
      for key, value in pairs(submodule) do
        M[key] = value
      end
    end
  end
end

function M.gh(path)
  return 'https://github.com/' .. path
end

return M
