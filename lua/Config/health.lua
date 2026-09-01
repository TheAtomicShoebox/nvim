---Config sanity checks, surfaced via `:checkhealth Config`.
---Discovered automatically by Neovim because this file is `lua/Config/health.lua`.
---The capitalized module name is deliberate: `:checkhealth` runs modules in
---alphabetical order and uppercase sorts before lowercase, so this runs first.
local M = {}

local health = vim.health

---Plugins that bundle files are expected to have added via vim.pack.
local expected_plugins = {
  "snacks.nvim",
  "which-key.nvim",
  "bufferline.nvim",
  "lualine.nvim",
  "tokyonight.nvim",
  "catppuccin.nvim",
  "kanagawa.nvim",
  "rose-pine",
  "nightfox.nvim",
  "gruvbox-material",
  "everforest",
  "onedark.nvim",
  "github-nvim-theme",
  "cyberdream.nvim",
  "oxocarbon.nvim",
  "vscode.nvim",
  "nordic.nvim",
  "melange-nvim",
  "vim-moonfly-colors",
  "mini.nvim",
  "nui.nvim",
  "noice.nvim",
  "mason.nvim",
  "mason-lspconfig.nvim",
  "conform.nvim",
  "nvim-lspconfig",
  "SchemaStore.nvim",
  "nvim-treesitter",
  "blink.cmp",
  "blink.lib",
  "LuaSnip",
  "lazydev.nvim",
  "persistence.nvim",
  "flash.nvim",
  "trouble.nvim",
  "todo-comments.nvim",
  "haskell-tools.nvim",
  "easy-dotnet.nvim",
  "plenary.nvim",
  "neotest",
  "nvim-dap",
  "nvim-dap-ui",
  "nvim-nio",
  "nvim-dap-virtual-text",
}

---External executables the config relies on.
---`bundle` = mason-owned tools that are only on PATH after that bundle's setup.
local expected_tools = {
  { cmd = "git", required = true, why = "vim.pack and mini.git" },
  { cmd = "rg", required = true, why = "snacks picker grep" },
  { cmd = "fd", required = false, why = "faster file finding in snacks picker" },
  { cmd = "lua-language-server", required = false, why = "vim.lsp.enable('lua_ls')", bundle = "lsp" },
  { cmd = "stylua", required = false, why = "lua formatting via conform", bundle = "lsp" },
  { cmd = "shfmt", required = false, why = "shell formatting via conform", bundle = "lsp" },
  { cmd = "lazygit", required = false, why = "<leader>gg / <leader>gG via Snacks.lazygit" },
  { cmd = "bash-language-server", required = false, why = "bashls", bundle = "lsp" },
  { cmd = "gopls", required = false, why = "gopls", bundle = "lsp" },
  { cmd = "clangd", required = false, why = "clangd", bundle = "lsp" },
  { cmd = "vtsls", required = false, why = "vtsls (TypeScript/JavaScript)", bundle = "lsp" },
  { cmd = "vscode-html-language-server", required = false, why = "html", bundle = "lsp" },
  { cmd = "vscode-css-language-server", required = false, why = "cssls", bundle = "lsp" },
  { cmd = "vscode-json-language-server", required = false, why = "jsonls", bundle = "lsp" },
  { cmd = "haskell-language-server-wrapper", required = false, why = "haskell-tools HLS", bundle = "haskell" },
  { cmd = "stack", required = false, why = "Stack project GHC for HLS", bundle = "haskell" },
  { cmd = "cabal", required = false, why = "Cabal project GHC for HLS", bundle = "haskell" },
  { cmd = "hoogle", required = false, why = "haskell-tools signature search", bundle = "haskell" },
  { cmd = "dotnet", required = false, why = ".NET SDK for easy-dotnet", bundle = "dotnet" },
  {
    cmd = "dotnet-easydotnet",
    required = false,
    why = "EasyDotnet server (`dotnet tool install -g EasyDotnet`)",
    bundle = "dotnet",
  },
}

---Normal-mode keymaps that should exist after startup (leader-based only,
---to keep lhs comparison simple).
local expected_maps = {
  "<leader>ff",
  "<leader>fg",
  "<leader>fe",
  "<leader>?",
  "<leader>bd",
  "<leader>n",
  "<leader>uC",
  "<leader>uR",
  "<leader>cf",
  "<leader>xl",
  "<leader>ghs",
  "<leader>qq",
  "]h",
  "]d",
  "]t",
  "<leader>st",
  "<leader>p",
  "<leader>Nb",
  "<leader>db",
  "<leader>tr",
}

---Treesitter parsers that bundles/syntax/treesitter.lua ensures.
local expected_parsers = { "lua", "vim", "vimdoc", "markdown" }

local expected_commands = { "Pack", "PackUpdate", "PackStatus", "PackClean", "PackLock", "PackSync" }
local expected_bundles =
  { "ui", "editing", "syntax", "lsp", "completion", "git", "tools", "debug", "test", "haskell", "dotnet" }

---Owning bundle for each plugin. If that bundle has not been setup() yet,
---a missing/inactive plugin is deferred, not an error.
local plugin_bundle = {
  ["snacks.nvim"] = "ui",
  ["which-key.nvim"] = "ui",
  ["bufferline.nvim"] = "ui",
  ["lualine.nvim"] = "ui",
  ["tokyonight.nvim"] = "ui",
  ["catppuccin.nvim"] = "ui",
  ["kanagawa.nvim"] = "ui",
  ["rose-pine"] = "ui",
  ["nightfox.nvim"] = "ui",
  ["gruvbox-material"] = "ui",
  ["everforest"] = "ui",
  ["onedark.nvim"] = "ui",
  ["github-nvim-theme"] = "ui",
  ["cyberdream.nvim"] = "ui",
  ["oxocarbon.nvim"] = "ui",
  ["vscode.nvim"] = "ui",
  ["nordic.nvim"] = "ui",
  ["melange-nvim"] = "ui",
  ["vim-moonfly-colors"] = "ui",
  ["mini.nvim"] = "ui",
  ["nui.nvim"] = "ui",
  ["noice.nvim"] = "ui",
  ["flash.nvim"] = "editing",
  ["mason.nvim"] = "lsp",
  ["mason-lspconfig.nvim"] = "lsp",
  ["conform.nvim"] = "lsp",
  ["nvim-lspconfig"] = "lsp",
  ["SchemaStore.nvim"] = "lsp",
  ["lazydev.nvim"] = "lsp",
  ["nvim-treesitter"] = "syntax",
  ["blink.cmp"] = "completion",
  ["blink.lib"] = "completion",
  ["LuaSnip"] = "completion",
  ["persistence.nvim"] = "tools",
  ["trouble.nvim"] = "tools",
  ["todo-comments.nvim"] = "tools",
  ["haskell-tools.nvim"] = "haskell",
  ["easy-dotnet.nvim"] = "dotnet",
  ["plenary.nvim"] = "dotnet",
  ["neotest"] = "test",
  ["nvim-dap"] = "debug",
  ["nvim-dap-ui"] = "debug",
  ["nvim-nio"] = "debug",
  ["nvim-dap-virtual-text"] = "debug",
}

---Owning bundle for each expected keymap. Maps from init.lua have no owner
---and are always required.
local map_bundle = {
  ["<leader>ff"] = "tools",
  ["<leader>fg"] = "tools",
  ["<leader>fe"] = "ui",
  ["<leader>?"] = "ui",
  ["<leader>bd"] = "ui",
  ["<leader>n"] = "ui",
  ["<leader>uC"] = "ui",
  ["<leader>uR"] = "ui",
  ["<leader>cf"] = "lsp",
  ["<leader>xl"] = "lsp",
  ["<leader>ghs"] = "git",
  ["]h"] = "git",
  ["]d"] = "lsp",
  ["]t"] = "tools",
  ["<leader>st"] = "tools",
  ["<leader>p"] = "tools",
  ["<leader>Nb"] = "dotnet",
  ["<leader>db"] = "debug",
  ["<leader>tr"] = "test",
}

---@param load Bundle.Load
---@return string
local function load_label(load)
  if load == "eager" then
    return "eager"
  end
  if type(load) == "string" then
    return load
  end
  local event = load.event
  if type(event) == "table" then
    event = table.concat(event, ",")
  end
  return tostring(event)
end

local function check_bundles()
  health.start("Bundles")
  local status = require("bundles").status()
  local by_name = {} ---@type table<string, Bundle.Status>
  for _, s in ipairs(status) do
    by_name[s.name] = s
  end
  for _, name in ipairs(expected_bundles) do
    local s = by_name[name]
    if s == nil then
      health.error(("`%s` was not discovered (missing lua/bundles/%s/init.lua?)"):format(name, name))
    elseif s.loaded then
      health.ok(("`%s` loaded (%s)"):format(name, load_label(s.load)))
    else
      health.ok(("`%s` deferred (waits for %s)"):format(name, load_label(s.load)))
    end
  end
  return by_name
end

local function check_plugins(by_name)
  health.start("Plugins (vim.pack)")
  local installed = {} ---@type table<string, boolean> name -> active
  for _, p in ipairs(vim.pack.get()) do
    installed[p.spec.name] = p.active
  end
  for _, name in ipairs(expected_plugins) do
    local owner = plugin_bundle[name]
    local deferred = owner ~= nil and by_name[owner] ~= nil and not by_name[owner].loaded
    if installed[name] == nil then
      if deferred then
        health.info(("`%s` not added yet (deferred with `%s`)"):format(name, owner))
      else
        health.error(("`%s` is not installed"):format(name), "Restart nvim so vim.pack.add() can install it")
      end
    elseif installed[name] == false then
      if deferred then
        health.info(("`%s` installed but not active (deferred with `%s`)"):format(name, owner))
      else
        health.warn(("`%s` is installed but not active"):format(name))
      end
    else
      health.ok(("`%s` installed and active"):format(name))
    end
  end
  for name, _ in pairs(installed) do
    if not vim.tbl_contains(expected_plugins, name) then
      health.info(("`%s` is installed but not in the expected list (add it to Config.health?)"):format(name))
    end
  end
end

local function check_tools(by_name)
  health.start("External tools")
  for _, tool in ipairs(expected_tools) do
    if vim.fn.executable(tool.cmd) == 1 then
      health.ok(("`%s` found (%s)"):format(tool.cmd, tool.why))
    else
      local deferred = tool.bundle ~= nil and by_name[tool.bundle] ~= nil and not by_name[tool.bundle].loaded
      if deferred then
        health.info(("`%s` not on PATH yet (deferred with `%s`: %s)"):format(tool.cmd, tool.bundle, tool.why))
      elseif tool.required then
        health.error(("`%s` not found: %s"):format(tool.cmd, tool.why))
      else
        health.warn(("`%s` not found: %s"):format(tool.cmd, tool.why))
      end
    end
  end
end

local function check_keymaps(by_name)
  health.start("Keymaps")
  local leader = vim.g.mapleader or "\\"
  local lhs_by_map = {} ---@type table<string, boolean>
  for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
    lhs_by_map[m.lhs] = true
  end
  for _, lhs in ipairs(expected_maps) do
    local raw = lhs:gsub("<leader>", leader)
    local owner = map_bundle[lhs]
    local deferred = owner ~= nil and by_name[owner] ~= nil and not by_name[owner].loaded
    if lhs_by_map[raw] then
      health.ok(("`%s` is mapped"):format(lhs))
    elseif deferred then
      health.info(("`%s` not mapped yet (deferred with `%s`)"):format(lhs, owner))
    else
      health.error(("`%s` is not mapped"):format(lhs))
    end
  end
end

local function check_globals()
  health.start("Globals and modules")
  if _G.Snacks ~= nil then
    health.ok("`Snacks` global is set (snacks.nvim setup ran)")
  else
    health.error("`Snacks` global is missing: snacks setup did not run")
  end
  local ok, root = pcall(function() return require("util").root() end)
  if ok and type(root) == "string" then
    health.ok(("`util.root()` works (current: %s)"):format(root))
  else
    health.error("`util.root()` failed: " .. tostring(root))
  end
  for _, cmd in ipairs(expected_commands) do
    if vim.fn.exists(":" .. cmd) == 2 then
      health.ok(("`:%s` is defined"):format(cmd))
    else
      health.error(("`:%s` is not defined"):format(cmd))
    end
  end
end

local function check_treesitter(by_name)
  health.start("Treesitter parsers")
  if by_name.syntax ~= nil and not by_name.syntax.loaded then
    health.info("syntax bundle not loaded yet (waits for FileType); skipping parser check")
    return
  end
  local ok, ts_config = pcall(require, "nvim-treesitter.config")
  if not ok then
    health.error("nvim-treesitter.config not available")
    return
  end
  local installed = ts_config.get_installed()
  for _, parser in ipairs(expected_parsers) do
    if vim.tbl_contains(installed, parser) then
      health.ok(("`%s` parser installed"):format(parser))
    else
      health.warn(
        ("`%s` parser missing (bundles/syntax/treesitter.lua should install it on next start)"):format(parser)
      )
    end
  end
end

function M.check()
  health.start("Neovim")
  if vim.fn.has("nvim-0.12") == 1 then
    health.ok("Neovim >= 0.12 (vim.pack available)")
  else
    health.error("Neovim < 0.12: vim.pack is not available")
  end

  local by_name = check_bundles()
  check_plugins(by_name)
  check_tools(by_name)
  check_keymaps(by_name)
  check_globals()
  check_treesitter(by_name)
end

return M
