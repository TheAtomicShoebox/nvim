local gh = require("util").gh

vim.pack.add({
  gh("nvim-lua/plenary.nvim"),
  gh("GustavEikaas/easy-dotnet.nvim"),
})

local dotnet = require("easy-dotnet")

local lualine = require("lualine")
local lualine_opts = lualine.get_config() ---@type table

local current_sections = lualine_opts.sections

local cs_extension = {
  sections = vim.tbl_deep_extend("force", current_sections, {
    lualine_y = {
      dotnet.lualine.jobs,
      {
        dotnet.lualine.run_status,
        color = dotnet.lualine.run_status_color,
        on_click = dotnet.lualine.run_status_click,
      },
    },
  }),
  filetypes = { "cs", "csproj", "fsproj", "props", "targets", "sln", "slnx" },
}

lualine_opts = vim.tbl_deep_extend("force", lualine_opts, { extensions = { cs_extension } })

lualine.setup(lualine_opts)

-- Plugin enable_filetypes sets props=xml; re-assert project filetypes after
-- setup so FileType-based loading and blink sources stay consistent.
local project_filetypes = {
  extension = {
    csproj = "csproj",
    fsproj = "fsproj",
    sln = "solution",
    slnx = "solution",
    props = "props",
    targets = "targets",
  },
}

local external_terminal = {
  command = "kitty", --"wt",
  args = { "--hold", "--" }, --{ "-w", "-1", "nt", "--" },
}

dotnet.setup({
  external_terminal = external_terminal,
  picker = "snacks",
  lsp = {
    enabled = true,
    restart_roslyn_on_branch_change = true,
    roslynator_enabled = true,
    easy_dotnet_analyzer_enabled = true,
    easy_dotnet_extension_enabled = true,
    enhanced_rename = true,
    create_type_from_usage = true,
    auto_refresh_codelens = true,
    suggest_updates = true,
  },
  debugger = {
    auto_register_dap = true,
    console = "externalTerminal",
  },
  auto_bootstrap_namespace = {
    type = "file_scoped",
    enabled = true,
  },
  -- Buffer signs/keymaps are left to neotest (`neotest_integration`).
  -- Runner-window maps keep the same lhs as the neotest group.
  test_runner = {
    neotest_integration = true,
    mappings = {
      run = { lhs = "<leader>tr", desc = "Run test" },
      run_all = { lhs = "<leader>tR", desc = "Run all tests" },
      debug_test = { lhs = "<leader>dT", desc = "Debug test" },
      peek_stacktrace = { lhs = "<leader>to", desc = "Peek stacktrace of failed test" },
    },
  },
  csproj_mappings = true,
  fsproj_mappings = true,
  outdated = {
    mappings = {
      upgrade = { lhs = "<leader>Nu", desc = "Upgrade package under cursor" },
      upgrade_all = { lhs = "<leader>Na", desc = "Upgrade all outdated packages" },
    },
  },
})

vim.filetype.add(project_filetypes)

-- Package completion in project files. Registered here so blink.lua does
-- not need to know about this bundle; blink lazy-loads the provider module.
-- Source module only enables itself for csproj/fsproj/xml; override so
-- Directory.*.props (filetype props) still gets package completion.
require("blink.cmp").add_source_provider("easy-dotnet", {
  name = "easy-dotnet",
  module = "easy-dotnet.completion.blink",
  async = true,
  score_offset = 10000,
  enabled = function() return vim.tbl_contains({ "csproj", "fsproj", "props", "xml" }, vim.bo.filetype) end,
})
for _, ft in ipairs({ "csproj", "fsproj", "props" }) do
  require("blink.cmp").add_filetype_source(ft, "easy-dotnet")
end

-- Project commands are session-global once this bundle has loaded (they
-- are not buffer-scoped). Health checks nvim_get_keymap, which only sees
-- these if they are not buffer-local.
local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc }) end

map("<leader>Nb", function() dotnet.build_default() end, "Build default project")
map("<leader>Nr", function() dotnet.run_default() end, "Run default project")
map("<leader>Nw", function() dotnet.watch_default() end, "Watch default project")
map("<leader>dD", function() dotnet.debug_default() end, "Debug default project")
map("<leader>No", function() dotnet.outdated() end, "Outdated packages")
map("<leader>Np", function()
  -- Plugin no longer exposes project_view(); :Dotnet with no args is the picker.
  vim.cmd.Dotnet()
end, "Dotnet commands")
map("<leader>tT", function() dotnet.testrunner() end, "Toggle EasyDotnet test runner")
map("<leader>Nt", function() require("easy-dotnet.terminal").toggle() end, "Toggle EasyDotnet terminal")

-- After neotest.setup() (this bundle depends on `test`).
require("bundles.test").add_adapter(require("easy-dotnet.neotest"))

local function is_dotnet_code_ft(ft) return ft == "cs" or ft == "fsharp" or ft == "razor" or ft == "cshtml" end

---@param bufnr integer
local function buf_maps(bufnr)
  vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, {
    silent = true,
    buffer = bufnr,
    desc = "Code Lens",
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserDotnet", { clear = true }),
  callback = function(ev)
    if is_dotnet_code_ft(vim.bo[ev.buf].filetype) then
      buf_maps(ev.buf)
    end
  end,
})

local bufnr = vim.api.nvim_get_current_buf()
if is_dotnet_code_ft(vim.bo[bufnr].filetype) then
  buf_maps(bufnr)
end
