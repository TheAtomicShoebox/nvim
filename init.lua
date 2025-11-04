if vim.g.vscode then
  local vscode = require('vscode')
  vim.notify = vscode.notify
  vim.notify('VS Code Enabled')
end
require('config.lazy')

---@type utils.Util
local util = require('utils')

util.Log('VS Code Disabled')
util.Log('package path' .. package.path)
