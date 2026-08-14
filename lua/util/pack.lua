---Very thin helpers around `vim.pack`, mostly to ease porting plugins whose
---docs describe configuration as lazy.nvim specs. Plugin setup itself stays
---as explicit `require(...).setup(...)` calls so lua_ls types the opts.
---@class util.pack
local M = {}

---Build commands per plugin name, run via PackChanged on install/update.
---@type table<string, string>
local build_cmds = {}

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("UtilPackBuild", { clear = true }),
  callback = function(ev)
    local cmd = ev.data.spec and build_cmds[ev.data.spec.name]
    if cmd and ev.data.kind ~= "delete" then
      vim.schedule(function()
        vim.cmd(cmd:gsub("^:", ""))
      end)
    end
  end,
})

---Register an Ex command to run whenever vim.pack installs or updates a
---plugin (lazy.nvim's `build`). Call this *before* the `vim.pack.add` that
---adds the plugin so it also fires on first install.
---@param name string Plugin name as vim.pack knows it (repo basename, e.g. "nvim-treesitter")
---@param cmd string Ex command, e.g. ":TSUpdate"
function M.build(name, cmd)
  build_cmds[name] = cmd
end

---A lazy.nvim-style key spec: positional lhs and rhs, everything else is
---`vim.keymap.set` opts (desc, remap, expr, ...), plus optional `mode`.
---@class util.pack.Key: vim.keymap.set.Opts
---@field [1] string lhs
---@field [2] string|fun() rhs
---@field mode? string|string[] Defaults to "n"

---Apply lazy.nvim-style key specs (a `keys = { ... }` table can be pasted
---here as-is, minus lazy-only fields like `ft`).
---@param keys util.pack.Key[]
function M.keys(keys)
  for _, key in ipairs(keys) do
    local opts = {} ---@type vim.keymap.set.Opts
    for k, v in pairs(key) do
      if type(k) == "string" and k ~= "mode" then
        opts[k] = v
      end
    end
    vim.keymap.set(key.mode or "n", key[1], key[2], opts)
  end
end

return M
