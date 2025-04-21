-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

map('n', '<leader>vs', function()
  vim.g.vscode = not vim.g.vscode
end, { desc = 'Toggle VS Code mode' })

--[[require('dap').listeners.after.event_exited['refresh_after_exit'] = function()
  require('nvim-dap-virtual-text').refresh()
  --require('dap').repl.close()
  --vim.cmd('checktime') -- Refresh buffers to detect changes
end]]
