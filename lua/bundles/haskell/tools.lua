local gh = require("util").gh

-- Must be set before the plugin initialises (no setup() — it is a
-- filetype plugin). Do not put this in after/ftplugin/.
vim.g.haskell_tools = {
  hls = {
    -- blink already wrote capabilities onto vim.lsp.config['*'] via the
    -- completion bundle (pulled in by lsp, which this bundle depends on).
    capabilities = vim.lsp.config["*"] and vim.lsp.config["*"].capabilities or nil,
    -- Discover Stack/Cabal GHC from the buffer's project file, not PATH.
    cmd = require("bundles.haskell.hls").cmd,
  },
}

local function is_haskell_ft(ft)
  return ft == "haskell" or ft == "lhaskell" or ft == "cabal" or ft == "cabalproject"
end

vim.pack.add({
  {
    src = gh("mrcjkb/haskell-tools.nvim"),
    version = vim.version.range("^10"),
  },
})

-- haskell-tools evaluates hls.cmd with no file argument and never sets
-- cmd_cwd. Pin both to the buffer being attached so the wrapper cannot
-- fall back to GHCup/Mason's default GHC.
do
  local Hls = require("haskell-tools.lsp")
  local orig_start = Hls.start
  Hls.start = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local hls = require("bundles.haskell.hls")
    local file = vim.api.nvim_buf_get_name(bufnr)
    hls._file = file
    local root = hls.project_root(file)
    if root then
      vim.lsp.config("haskell-tools.nvim", { cmd_cwd = root })
    end
    local ok, result = pcall(orig_start, bufnr)
    hls._file = nil
    if not ok then
      error(result)
    end
    return result
  end

  -- Drop a Mason/lspconfig `hls` client if one already attached this session.
  for _, client in ipairs(vim.lsp.get_clients({ name = "hls" })) do
    client:stop(true)
  end

  -- pack.add after FileType has already fired, so haskell-tools' ftplugin
  -- may not run. Start (or attach) for the current Haskell buffer ourselves.
  local bufnr = vim.api.nvim_get_current_buf()
  if is_haskell_ft(vim.bo[bufnr].filetype) then
    Hls.start(bufnr)
  end
end

vim.api.nvim_create_user_command("HlsInfo", function()
  local clients = vim.lsp.get_clients({ name = "haskell-tools.nvim" })
  if #clients == 0 then
    vim.notify(
      "No haskell-tools.nvim client. Open a .hs file and wait a moment, then :HlsInfo again. "
        .. "`:checkhealth vim.lsp` will not list `hls` — that name is Mason/lspconfig only.",
      vim.log.levels.WARN,
      { title = "haskell-tools" }
    )
    return
  end
  local lines = { "haskell-tools HLS client(s):" }
  for _, client in ipairs(clients) do
    lines[#lines + 1] = vim.inspect({
      id = client.id,
      cmd = client.config.cmd,
      cmd_cwd = client.config.cmd_cwd,
      root_dir = client.config.root_dir,
    })
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "haskell-tools" })
end, { desc = "Show haskell-tools HLS command and root" })

---@param bufnr integer
local function buf_maps(bufnr)
  local ht = require("haskell-tools")
  local function opts(desc)
    return { silent = true, buffer = bufnr, desc = desc }
  end

  -- Direct call: vim.cmd.Haskell({ "hover" }) does not set args, so :Haskell
  -- runs with no subcommand. Generic LspAttach also sets K to vim.lsp.buf.hover.
  vim.keymap.set("n", "K", function()
    require("haskell-tools.lsp.hover").hover_actions()
  end, opts("Hover Actions"))
  vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts("Code Lens"))
  vim.keymap.set("n", "<leader>ce", ht.lsp.buf_eval_all, opts("Eval All Snippets"))
  vim.keymap.set("n", "<leader>hs", require("bundles.haskell.hoogle").signature, opts("Hoogle Signature"))
  -- vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, opts("Hoogle Signature"))
  vim.keymap.set("n", "<leader>hr", ht.repl.toggle, opts("GHCi Repl (package)"))
  vim.keymap.set("n", "<leader>hf", function()
    ht.repl.toggle(vim.api.nvim_buf_get_name(bufnr))
  end, opts("GHCi Repl (file)"))
  vim.keymap.set("n", "<leader>hq", ht.repl.quit, opts("GHCi Repl Quit"))
end

-- Re-apply after generic LspAttach (which sets K to vim.lsp.buf.hover).
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserHaskell", { clear = true }),
  callback = function(ev)
    if is_haskell_ft(vim.bo[ev.buf].filetype) then
      buf_maps(ev.buf)
    end
  end,
})

buf_maps(vim.api.nvim_get_current_buf())

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserHaskellMaps", { clear = true }),
  pattern = { "haskell", "lhaskell", "cabal", "cabalproject" },
  callback = function(ev)
    buf_maps(ev.buf)
  end,
})
