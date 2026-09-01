local gh = require("util").gh

vim.pack.add({
  gh("gbprod/yanky.nvim"),
})

require("yanky").setup({
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  },
  preserve_cursor_position = {
    enabled = true,
  },
  ring = {
    permanent_wrapper = require("yanky.wrappers").remove_carriage_return,
  },
})

vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)", { desc = "Yank Text" })
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Put Text After Cursor" })
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Put Text Before Cursor" })
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Put Text After Selection" })
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Put Text Before Selection" })
vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)", { desc = "Previous Yank" })
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)", { desc = "Next Yank" })
vim.keymap.set({ "n", "x" }, "[y", "<Plug>(YankyCycleForward)", { desc = "Cycle Forward Through Yank History" })
vim.keymap.set({ "n", "x" }, "]y", "<Plug>(YankyCycleBackward)", { desc = "Cycle Backward Through Yank History" })
vim.keymap.set({ "n", "x" }, "]p", "<Plug>(YankyPutIndentAfterLinewise)", { desc = "Put Indented After Cursor (Linewise)" })
vim.keymap.set({ "n", "x" }, "[p", "<Plug>(YankyPutIndentBeforeLinewise)", { desc = "Put Indented Before Cursor (Linewise)" })
vim.keymap.set({ "n", "x" }, "]P", "<Plug>(YankyPutIndentAfterLinewise)", { desc = "Put Indented After Cursor (Linewise)" })
vim.keymap.set({ "n", "x" }, "[P", "<Plug>(YankyPutIndentBeforeLinewise)", { desc = "Put Indented Before Cursor (Linewise)" })
vim.keymap.set({ "n", "x" }, ">p", "<Plug>(YankyPutIndentAfterShiftRight)", { desc = "Put and Indent Right" })
vim.keymap.set({ "n", "x" }, "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", { desc = "Put and Indent Left" })
vim.keymap.set({ "n", "x" }, ">P", "<Plug>(YankyPutIndentAfterShiftRight)", { desc = "Put and Indent Right" })
vim.keymap.set({ "n", "x" }, "<P", "<Plug>(YankyPutIndentAfterShiftLeft)", { desc = "Put and Indent Left" })
vim.keymap.set({ "n", "x" }, "=p", "<Plug>(YankyPutAfterFilter)", { desc = "Put After Applying a Filter" })
vim.keymap.set({ "n", "x" }, "=P", "<Plug>(YankyPutBeforeFilter)", { desc = "Put Before Applying a Filter" })

vim.keymap.set({ "n", "x" }, "<leader>yy", function()
  Snacks.picker.pick("yanky")
end, { desc = "Yank History" })
vim.keymap.set("n", "<leader>yc", "<cmd>YankyClearHistory<cr>", { desc = "Clear Yank History" })
vim.keymap.set({ "n", "x" }, "<leader>yn", "<Plug>(YankyCycleForward)", { desc = "Cycle Forward Through Yank History" })
vim.keymap.set({ "n", "x" }, "<leader>yN", "<Plug>(YankyCycleBackward)", { desc = "Cycle Backward Through Yank History" })
