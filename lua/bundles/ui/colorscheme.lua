local gh = require("util").gh

local M = {}

M.default = "tokyonight-moon"

---@class ColorChoice
---@field name string display name (and colorscheme name unless `apply` is set)
---@field apply? fun()

-- Dark-only pool: popular Lua themes plus a few stock Neovim schemes.
-- Light variants are omitted; `<leader>uC` can still preview anything installed.
---@type ColorChoice[]
local pool = {
  { name = "tokyonight-moon" },
  { name = "tokyonight-night" },
  { name = "tokyonight-storm" },
  { name = "catppuccin-mocha" },
  { name = "catppuccin-macchiato" },
  { name = "catppuccin-frappe" },
  { name = "kanagawa-wave" },
  { name = "kanagawa-dragon" },
  { name = "rose-pine" },
  { name = "rose-pine-moon" },
  { name = "nightfox" },
  { name = "duskfox" },
  { name = "nordfox" },
  { name = "terafox" },
  { name = "carbonfox" },
  { name = "gruvbox-material" },
  { name = "everforest" },
  {
    name = "onedark-dark",
    apply = function()
      require("onedark").setup({ style = "dark" })
      require("onedark").load()
    end,
  },
  {
    name = "onedark-darker",
    apply = function()
      require("onedark").setup({ style = "darker" })
      require("onedark").load()
    end,
  },
  {
    name = "onedark-cool",
    apply = function()
      require("onedark").setup({ style = "cool" })
      require("onedark").load()
    end,
  },
  { name = "github_dark" },
  { name = "github_dark_dimmed" },
  { name = "cyberdream" },
  { name = "oxocarbon" },
  { name = "vscode" },
  { name = "nordic" },
  { name = "melange" },
  { name = "moonfly" },
  { name = "habamax" },
  { name = "slate" },
  { name = "retrobox" },
  { name = "sorbet" },
  { name = "zaibatsu" },
  { name = "wildcharm" },
  { name = "lunaperche" },
  { name = "unokai" },
}

local function announce(name)
  vim.g.user_colorscheme = name
  vim.schedule(function()
    vim.notify("Colorscheme: " .. name, vim.log.levels.INFO, { title = "Colorscheme" })
  end)
end

---@param choice ColorChoice
local function apply_choice(choice)
  vim.o.background = "dark"
  local ok, err
  if choice.apply then
    ok, err = pcall(choice.apply)
  else
    ok, err = pcall(vim.cmd.colorscheme, choice.name)
  end
  if not ok then
    vim.notify(
      ("Failed to load %s (%s); falling back to %s"):format(choice.name, err, M.default),
      vim.log.levels.WARN
    )
    pcall(vim.cmd.colorscheme, M.default)
    announce(M.default)
    return
  end
  announce(choice.name)
end

function M.choose(name)
  for _, choice in ipairs(pool) do
    if choice.name == name then
      apply_choice(choice)
      return
    end
  end
  vim.o.background = "dark"
  local ok = pcall(vim.cmd.colorscheme, name)
  if ok then
    announce(name)
  else
    apply_choice({ name = M.default })
  end
end

function M.roll(except)
  except = except or vim.g.user_colorscheme
  local choices = {}
  for _, choice in ipairs(pool) do
    if choice.name ~= except then
      choices[#choices + 1] = choice
    end
  end
  if #choices == 0 then
    choices = pool
  end
  apply_choice(choices[math.random(#choices)])
end

vim.pack.add({
  gh("folke/tokyonight.nvim"),
  { src = gh("catppuccin/nvim"), name = "catppuccin.nvim" },
  gh("rebelot/kanagawa.nvim"),
  { src = gh("rose-pine/neovim"), name = "rose-pine" },
  gh("EdenEast/nightfox.nvim"),
  gh("sainnhe/gruvbox-material"),
  gh("sainnhe/everforest"),
  gh("navarasu/onedark.nvim"),
  gh("projekt0n/github-nvim-theme"),
  gh("scottmckendry/cyberdream.nvim"),
  gh("nyoom-engineering/oxocarbon.nvim"),
  gh("Mofiqul/vscode.nvim"),
  gh("AlexvZyl/nordic.nvim"),
  gh("savq/melange-nvim"),
  gh("bluz71/vim-moonfly-colors"),
})

pcall(function()
  require("tokyonight").setup({ style = "moon" })
end)
pcall(function()
  require("catppuccin").setup({})
end)
pcall(function()
  require("kanagawa").setup({})
end)
pcall(function()
  require("rose-pine").setup({})
end)
pcall(function()
  require("nightfox").setup({})
end)
pcall(function()
  require("github-theme").setup({})
end)
pcall(function()
  require("cyberdream").setup({ variant = "default" })
end)
pcall(function()
  require("nordic").setup({})
end)

vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "material"
vim.g.everforest_background = "medium"

math.randomseed(tonumber(vim.uv.hrtime() % 2 ^ 31) or os.time())
M.roll()

vim.keymap.set("n", "<leader>uR", function()
  M.roll()
end, { desc = "Random Colorscheme" })

return M
