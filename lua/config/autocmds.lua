-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--[[vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    if vim.filetype == 'hs' then
      vim.cmd(string.format('fourmolu -i, %s', vim.hl))
    end
  end
})]]

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('wezterm_colorscheme', { clear = true }),
  callback = function(args)
    local colorschemes = {
      ['tokyonight-day'] = 'Tokyo Night Day',
      ['catpuccin-frappe'] = 'Catpuccin Frappe',
      ['catpuccin-latte'] = 'Catpuccin Latte',
      ['catpuccin-macchiato'] = 'Catpuccin Macchiato',
      ['catpuccin-mocha'] = 'Catpuccin Mocha',
      ['gruvbox'] = 'GruvboxDark',
      ['kanagawa-dragon'] = 'Kanagawa Dragon (Gogh)',
    }
    local colorscheme = colorschemes[args.match]
    if not colorscheme then
      return
    end
    -- Write to a file
    local filename = vim.fn.expand('$XDG_CONFIG_HOME/wezterm/colorscheme')
    assert(type(filename) == 'string')
    local file = io.open(filename, 'w')
    assert(file)
    file:write(colorscheme)
    file:close()
    Snacks.notifier.notify('Setting WezTerm color scheme to' .. colorscheme, 'info')
  end,
})
