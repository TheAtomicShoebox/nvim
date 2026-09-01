-- Cheap: required at bootstrap (no vim.pack.add). Filetype detection must
-- exist before BufRead so the FileType load spec below can fire. Neovim
-- treats .csproj / .fsproj as xml by default.
vim.filetype.add({
  extension = {
    csproj = "csproj",
    fsproj = "fsproj",
    sln = "solution",
    slnx = "solution",
    props = "props",
    targets = "targets",
  },
})

-- Register before the syntax bundle's FileType callback so highlighting
-- starts on the first project-file buffer, not only after easy.lua runs.
vim.treesitter.language.register("xml", "csproj")
vim.treesitter.language.register("xml", "fsproj")
vim.treesitter.language.register("xml", "props")
vim.treesitter.language.register("xml", "targets")

---@type Bundle
local M = {
  load = {
    event = "FileType",
    pattern = {
      "cs",
      "fsharp",
      "razor",
      "cshtml",
      "csproj",
      "fsproj",
      "solution",
      "props",
      "targets",
    },
    once = true,
  },
}

function M.deps()
  -- LspAttach keymaps + blink capabilities before Roslyn starts.
  -- nvim-dap on rtp before easy-dotnet registers the coreclr adapter.
  -- neotest setup before we register the EasyDotnet adapter.
  return { require("bundles.lsp"), require("bundles.debug"), require("bundles.test") }
end

function M.setup() require("bundles.dotnet.easy") end

return M
