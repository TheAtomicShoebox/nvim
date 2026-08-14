local gh = require("util").gh

vim.pack.add({
  -- mini.nvim also carries mini.icons; this file owns its setup because
  -- bufferline is the only setup-time consumer of the devicons mock.
  gh("nvim-mini/mini.nvim"),
  gh("akinsho/bufferline.nvim"),
})

require("mini.icons").setup({})
-- Let plugins that expect nvim-web-devicons (bufferline below, lualine at
-- render time) use mini.icons. Must run before bufferline.setup().
require("mini.icons").mock_nvim_web_devicons()

require("bufferline").setup({
  options = {
    close_command = function(n)
      Snacks.bufdelete(n)
    end,
    right_mouse_command = function(n)
      Snacks.bufdelete(n)
    end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = true,
    -- We manage showtabline ourselves below; keep bufferline from fighting it.
    auto_toggle_bufferline = false,
    -- No tab for unnamed buffers (e.g. the empty startup buffer).
    custom_filter = function(buf)
      return vim.api.nvim_buf_get_name(buf) ~= ""
    end,
    -- Shift the bufferline right of sidebar windows instead of drawing over them.
    offsets = {
      {
        filetype = "snacks_layout_box",
        text = "Explorer",
        highlight = "Directory",
        text_align = "left",
      },
      {
        filetype = "snacks_picker_list",
        text = "Explorer",
        highlight = "Directory",
        text_align = "left",
      },
    },
  },
})

-- Only show the bufferline when at least one listed buffer has a name,
-- so a fresh nvim (or explorer-only session) has no tab bar.
local function update_tabline()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= "" then
      vim.o.showtabline = 2
      return
    end
  end
  vim.o.showtabline = 0
end

vim.api.nvim_create_autocmd({ "VimEnter", "BufAdd", "BufDelete", "BufFilePost" }, {
  group = vim.api.nvim_create_augroup("UserTabline", { clear = true }),
  -- schedule so BufDelete runs the check after the buffer is actually gone
  callback = vim.schedule_wrap(update_tabline),
})
update_tabline()
