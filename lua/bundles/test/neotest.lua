local gh = require("util").gh

vim.pack.add({
  gh("nvim-lua/plenary.nvim"),
  gh("nvim-neotest/nvim-nio"),
  gh("nvim-neotest/neotest"),
})

local neotest_ns = vim.api.nvim_create_namespace("neotest")
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
      return message
    end,
  },
}, neotest_ns)

require("neotest").setup({
  adapters = {},
  status = { virtual_text = true, signs = true },
  output = { open_on_run = true },
  discovery = {
    filter_dir = function(name)
      return not vim.tbl_contains({
        "bin",
        "obj",
        "node_modules",
        ".git",
        ".vs",
        ".idea",
        "packages",
      }, name)
    end,
  },
  quickfix = {
    open = function()
      local ok, trouble = pcall(require, "trouble")
      if ok then
        trouble.open({ mode = "quickfix", focus = false })
      else
        vim.cmd.copen()
      end
    end,
  },
  consumers = {
    -- Refresh Trouble after a run; close it when nothing failed.
    trouble = function(client)
      client.listeners.results = function(adapter_id, results, partial)
        if partial then
          return
        end
        local tree = assert(client:get_position(nil, { adapter = adapter_id }))
        local failed = 0
        for pos_id, result in pairs(results) do
          if result.status == "failed" and tree:get_key(pos_id) then
            failed = failed + 1
          end
        end
        vim.schedule(function()
          local ok, trouble = pcall(require, "trouble")
          if not ok or not trouble.is_open() then
            return
          end
          trouble.refresh()
          if failed == 0 then
            trouble.close()
          end
        end)
      end
    end,
  },
})

-- Language bundles register adapters and may add start actions; run /
-- summary / output stay here. Debug-nearest lives on the debug prefix.
local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc }) end

map("<leader>tr", function() require("neotest").run.run() end, "Run nearest test")
map("<leader>tR", function() require("neotest").run.run(vim.fn.expand("%")) end, "Run tests in file")
map("<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, "Run all tests")
map("<leader>tl", function() require("neotest").run.run_last() end, "Run last test")
map("<leader>ts", function() require("neotest").run.stop() end, "Stop test run")
map("<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, "Watch tests in file")
map("<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, "Test output")
map("<leader>tO", function() require("neotest").output_panel.toggle() end, "Toggle test output panel")
map("<leader>tt", function() require("neotest").summary.toggle() end, "Toggle test summary")
map("<leader>dT", function() require("neotest").run.run({ strategy = "dap" }) end, "Debug nearest test")

map("]T", function() require("neotest").jump.next({ status = "failed" }) end, "Next failed test")
map("[T", function() require("neotest").jump.prev({ status = "failed" }) end, "Prev failed test")
