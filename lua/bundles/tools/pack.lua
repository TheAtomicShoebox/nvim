local pack = require("util.pack")

local M = {}

---@class Pack.Op
---@field key string
---@field label string
---@field run fun()

---@type Pack.Op[]
local ops = {
  { key = "u", label = "Update plugins", run = function()
    pack.update()
  end },
  { key = "s", label = "Status (offline)", run = function()
    pack.update(nil, { offline = true })
  end },
  { key = "c", label = "Clean unused", run = pack.clean },
  { key = "l", label = "Open lockfile", run = pack.open_lock },
  { key = "S", label = "Sync to lockfile", run = pack.sync },
}

local function run(op)
  vim.schedule(op.run)
end

function M.open()
  local keys = {}
  for _, op in ipairs(ops) do
    keys[op.key] = {
      function(picker)
        picker:close()
        run(op)
      end,
      desc = op.label,
      mode = { "n" },
    }
  end

  vim.ui.select(ops, {
    prompt = "vim.pack",
    format_item = function(op)
      return op.key .. "  " .. op.label
    end,
    snacks = {
      preview = false,
      focus = "list",
      layout = {
        preset = "select",
        hidden = { "preview", "input" },
        layout = {
          width = 0.28,
          min_width = 36,
          max_width = 48,
          height = #ops + 2,
          min_height = #ops + 2,
        },
      },
      win = { list = { keys = keys } },
    },
  }, function(op)
    if op then
      run(op)
    end
  end)
end

vim.keymap.set("n", "<leader>p", M.open, { desc = "vim.pack" })
vim.keymap.set("n", "<leader>pu", function()
  pack.update()
end, { desc = "Update plugins" })
vim.keymap.set("n", "<leader>ps", function()
  pack.update(nil, { offline = true })
end, { desc = "Status (offline)" })
vim.keymap.set("n", "<leader>pc", pack.clean, { desc = "Clean unused" })
vim.keymap.set("n", "<leader>pl", pack.open_lock, { desc = "Open lockfile" })
vim.keymap.set("n", "<leader>pS", pack.sync, { desc = "Sync to lockfile" })

return M
