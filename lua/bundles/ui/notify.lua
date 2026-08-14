local util = require("util")
local gh = util.gh

-- nui is noice's UI toolkit; noice must set up *after* snacks so it can
-- detect snacks.notifier and route vim.notify through it (LazyVim-style).
vim.pack.add({
  gh("MunifTanjim/nui.nvim"),
  gh("folke/noice.nvim"),
})

local function setup_noice()
  require("noice").setup({
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
  })
end

-- Headless / `nvim -es` must keep stock messages. `--embed` without a UI
-- yet waits for UIEnter so noice does not `vim.ui_attach` into the void.
if not util.headless() then
  if #vim.api.nvim_list_uis() > 0 then
    setup_noice()
  else
    vim.api.nvim_create_autocmd("UIEnter", {
      group = vim.api.nvim_create_augroup("UserNoice", { clear = true }),
      once = true,
      callback = setup_noice,
    })
  end
end

vim.keymap.set("n", "<leader>snl", function()
  require("noice").cmd("last")
end, { desc = "Noice Last Message" })
vim.keymap.set("n", "<leader>snh", function()
  require("noice").cmd("history")
end, { desc = "Noice History" })
vim.keymap.set("n", "<leader>sna", function()
  require("noice").cmd("all")
end, { desc = "Noice All" })
vim.keymap.set("n", "<leader>snd", function()
  require("noice").cmd("dismiss")
end, { desc = "Dismiss All" })
vim.keymap.set("n", "<leader>snt", function()
  require("noice").cmd("pick")
end, { desc = "Noice Picker" })
vim.keymap.set("c", "<S-Enter>", function()
  require("noice").redirect(vim.fn.getcmdline())
end, { desc = "Redirect Cmdline" })
vim.keymap.set({ "i", "n", "s" }, "<c-f>", function()
  if not require("noice.lsp").scroll(4) then
    return "<c-f>"
  end
end, { silent = true, expr = true, desc = "Scroll Forward" })
vim.keymap.set({ "i", "n", "s" }, "<c-b>", function()
  if not require("noice.lsp").scroll(-4) then
    return "<c-b>"
  end
end, { silent = true, expr = true, desc = "Scroll Backward" })
