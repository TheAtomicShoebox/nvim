local gh = require("util").gh

vim.pack.add({
  gh("nvim-neotest/nvim-nio"),
  gh("rcarriga/nvim-dap-ui"),
})

local dap = require("dap")
local dapui = require("dapui")

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▶" },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.40 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.15 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        { id = "repl", size = 0.55 },
        { id = "console", size = 0.45 },
      },
      size = 10,
      position = "bottom",
    },
  },
})

local function open() dapui.open({ reset = true }) end

local function close() dapui.close() end

-- Open the debug layout when a session starts; restore the previous
-- windows when it ends. attach/launch cover both request types.
dap.listeners.before.attach.dapui_config = open
dap.listeners.before.launch.dapui_config = open
dap.listeners.after.event_initialized.dapui_config = open
dap.listeners.before.event_terminated.dapui_config = close
dap.listeners.before.event_exited.dapui_config = close
dap.listeners.before.disconnect.dapui_config = close

vim.keymap.set(
  "n",
  "<leader>du",
  function() dapui.toggle({ reset = true }) end,
  { silent = true, desc = "Toggle Debug UI" }
)
vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end, { silent = true, desc = "Eval Expression" })
