local util = require("util")

local gh = util.gh

-- Re-sync parsers whenever vim.pack installs/updates nvim-treesitter
-- (registered before vim.pack.add so it also fires on first install).
util.pack.build("nvim-treesitter", ":TSUpdate")

vim.pack.add({
  {
    src = gh("nvim-treesitter/nvim-treesitter"),
    version = "main",
  },
})

local treesitter = require("nvim-treesitter")
treesitter.setup({})

local ensure_installed = {
  "vim",
  "vimdoc",
  "rust",
  "c",
  "cpp",
  "go",
  "html",
  "css",
  "javascript",
  "json",
  "lua",
  "markdown",
  "python",
  "typescript",
  "vue",
  "svelte",
  "bash",
  "haskell",
  "c_sharp",
  "xml",
  "sql",
}

local config = require("nvim-treesitter.config")

local already_installed = config.get_installed()
local parsers_to_install = {}

for _, parser in ipairs(ensure_installed) do
  if not vim.tbl_contains(already_installed, parser) then
    table.insert(parsers_to_install, parser)
  end
end

if #parsers_to_install > 0 then
  treesitter.install(parsers_to_install)
end

local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    if vim.list_contains(config.get_installed(), vim.treesitter.language.get_lang(args.match)) then
      vim.treesitter.start(args.buf)
    end
  end,
})
