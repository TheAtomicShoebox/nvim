---Start HLS against the buffer's Stack/Cabal GHC, not whatever `ghc` is on PATH.
---The wrapper picks a binary from its *cwd*. Opening nvim from a parent of
---`stack.yaml` makes it see GHCup's GHC (e.g. 9.10.3) while hie-bios later
---loads the Stack session (e.g. 9.10.2) — "ghcide compiled against X but
---currently using Y". `--cwd` at the project root plus the versioned binary
---keeps those in lockstep.

local M = {}

---Set by the Hls.start wrapper so cmd() sees the buffer being attached,
---not whatever happens to be current when the function is evaluated.
M._file = nil

---@param file? string
---@return string|nil
function M.project_root(file)
  file = file or M._file or vim.api.nvim_buf_get_name(0)
  if file == "" then
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name:find("%.l?hs$") then
        file = name
        break
      end
    end
  end
  if file == "" then
    return nil
  end
  return vim.fs.root(file, "hie.yaml")
    or vim.fs.root(file, "cabal.project")
    or vim.fs.root(file, "stack.yaml")
    or vim.fs.root(file, "package.yaml")
    or vim.fs.root(file, function(name)
      return name:sub(-6) == ".cabal"
    end)
end

---@param name string
---@return string|nil
local function ghcup_bin(name)
  local path = vim.fs.joinpath(vim.fn.expand("~/.ghcup/bin"), name)
  if vim.fn.executable(path) == 1 then
    return path
  end
end

---@param root string
local function project_ghc_version(root)
  local wrapper = ghcup_bin("haskell-language-server-wrapper")
    or (vim.fn.executable("haskell-language-server-wrapper") == 1 and "haskell-language-server-wrapper")
  if not wrapper then
    return nil
  end
  local obj = vim
    .system({
      wrapper,
      "--project-ghc-version",
      "--cwd",
      root,
    }, { text = true })
    :wait()
  if not obj or obj.code ~= 0 then
    return nil
  end
  return (obj.stdout or ""):match("(%d+%.%d+%.%d+)%s*$")
end

---GHCup `set hls` only exposes one release's binaries on PATH. Older
---releases stay under ~/.ghcup/hls/<ver>/bin/ (e.g. 2.11 ships 9.10.2).
---@param ghc string
---@return string|nil
local function hls_for_ghc(ghc)
  local name = "haskell-language-server-" .. ghc
  -- GHCup first: Mason's HLS is on nvim's PATH and has no 9.10.2 binary.
  local matches = vim.fn.glob(vim.fs.joinpath(vim.fn.expand("~/.ghcup/hls"), "*", "bin", name), true, true)
  table.sort(matches, function(a, b)
    return a > b
  end)
  for _, path in ipairs(matches) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  return ghcup_bin(name) or (vim.fn.executable(name) == 1 and name) or nil
end

---@return string[]
function M.cmd()
  local wrapper = ghcup_bin("haskell-language-server-wrapper")
    or (vim.fn.executable("haskell-language-server-wrapper") == 1 and "haskell-language-server-wrapper")
    or "haskell-language-server"
  local cmd = { wrapper, "--lsp" }
  local root = M.project_root()
  if not root then
    return cmd
  end

  vim.list_extend(cmd, { "--cwd", root })

  local ghc = project_ghc_version(root)
  if not ghc then
    return cmd
  end

  local versioned = hls_for_ghc(ghc)
  if versioned then
    return { versioned, "--lsp", "--cwd", root }
  end

  vim.schedule(function()
    vim.notify(
      (
        "HLS has no binary for GHC %s (from %s). ghcide must match the project GHC. "
        .. "Install a bindist that still ships that compiler (9.10.2: `ghcup install hls 2.11.0.0`) "
        .. "or `ghcup compile hls --ghc %s`. GHCup `set hls` only puts one release on PATH; "
        .. "this config also looks under ~/.ghcup/hls/*/bin/."
      ):format(ghc, root, ghc),
      vim.log.levels.ERROR,
      { title = "haskell-tools" }
    )
  end)
  return cmd
end

return M
