local gh = require("util").gh

vim.pack.add({
  gh("mfussenegger/nvim-dap"),
})

local dap = require("dap")

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "CursorLine" })

-- Lives under the existing `<leader>d` which-key group (profiler is `dp*`).
-- Language bundles register adapters; they may add start actions on this
-- prefix (e.g. `<leader>dD`) but session control stays here.
local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc }) end

map("n", "<leader>db", dap.toggle_breakpoint, "Toggle Breakpoint")
map(
  "n",
  "<leader>dB",
  function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
  "Breakpoint Condition"
)
map("n", "<leader>dL", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, "Log Point")
map("n", "<leader>dx", dap.clear_breakpoints, "Clear Breakpoints")

map("n", "<leader>dc", dap.continue, "Continue / Start")
map("n", "<leader>dC", dap.run_to_cursor, "Run to Cursor")
map("n", "<leader>dl", dap.run_last, "Run Last")
map("n", "<leader>dP", dap.pause, "Pause")
map("n", "<leader>dt", dap.terminate, "Terminate")

map("n", "<leader>dO", dap.step_over, "Step Over")
map("n", "<leader>di", dap.step_into, "Step Into")
map("n", "<leader>do", dap.step_out, "Step Out")

map("n", "<leader>dr", dap.repl.toggle, "DAP REPL")
map("n", "<leader>dj", dap.down, "Down Stack Frame")
map("n", "<leader>dk", dap.up, "Up Stack Frame")
map("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, "Hover")

-- F-keys while a session is active (standard debugger chords).
map("n", "<F5>", dap.continue, "Continue / Start")
map("n", "<F10>", dap.step_over, "Step Over")
map("n", "<F11>", dap.step_into, "Step Into")
map("n", "<F12>", dap.step_out, "Step Out")
