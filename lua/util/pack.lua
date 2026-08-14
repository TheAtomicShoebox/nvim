---Helpers around `vim.pack`: a PackChanged build hook (lazy.nvim's `build`)
---and user commands for update / status / clean / lockfile.
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

function M.lockfile_path()
  return vim.fs.joinpath(vim.fn.stdpath("config"), "nvim-pack-lock.json")
end

---Installed plugins (no per-plugin git queries).
function M.list()
  return vim.pack.get(nil, { info = false })
end

---@param names? string[]
---@param opts? { force?: boolean, offline?: boolean, target?: string }
function M.update(names, opts)
  vim.pack.update(names, opts)
end

---Names installed on disk but not `vim.pack.add`ed this session.
---Loads every bundle first so deferred plugins (blink, mason) count as used.
function M.unused()
  require("bundles").ensure_all()
  local names = {} ---@type string[]
  for _, p in ipairs(M.list()) do
    if not p.active then
      names[#names + 1] = p.spec.name
    end
  end
  return names
end

function M.clean()
  local names = M.unused()
  if #names == 0 then
    vim.notify("No unused plugins", vim.log.levels.INFO)
    return
  end
  local msg = "Remove unused plugins?\n" .. table.concat(names, ", ")
  if vim.fn.confirm(msg, "&Yes\n&No", 2) ~= 1 then
    return
  end
  vim.pack.del(names)
end

---@param names string[]
function M.del(names)
  if #names == 0 then
    return
  end
  local msg = "Delete plugins?\n" .. table.concat(names, ", ")
  if vim.fn.confirm(msg, "&Yes\n&No", 2) ~= 1 then
    return
  end
  vim.pack.del(names)
end

function M.open_lock()
  vim.cmd.edit(M.lockfile_path())
end

function M.sync()
  vim.pack.update(nil, { target = "lockfile" })
end

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  M.update(nil, { force = opts.bang })
end, { bang = true, desc = "Update vim.pack plugins (review buffer; bang: apply immediately)" })

vim.api.nvim_create_user_command("PackStatus", function()
  M.update(nil, { offline = true })
end, { desc = "Browse installed plugins / pending updates (offline)" })

vim.api.nvim_create_user_command("PackClean", function()
  M.clean()
end, { desc = "Delete plugins not declared by any bundle (loads all bundles first)" })

vim.api.nvim_create_user_command("PackLock", function()
  M.open_lock()
end, { desc = "Open nvim-pack-lock.json" })

vim.api.nvim_create_user_command("PackSync", function()
  M.sync()
end, { desc = "Checkout plugins to lockfile revisions (confirm buffer)" })

vim.api.nvim_create_user_command("Pack", function()
  require("bundles.tools.pack").open()
end, { desc = "Manage vim.pack plugins" })

return M
