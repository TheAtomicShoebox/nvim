local root_markers1 = {
  '.emmyrc.json',
  '.luarc.json',
  '.luarc.jsonc'
}

local root_markers2 = {
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  'selene.toml',
  'selene.yml',
}

local final_rootmarkers = { root_markers1, root_markers2, { '.git' } }

print(final_rootmarkers)

return {
	---@type vim.lsp.Config
	{
	  on_init = function(client)
	   if client.workspace_folders then
	       local path = client.workspace_folders[1].name
	       if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.json')) then
	        return
	       end
	   end
	  end,
	  cmd = { 'lua-language-server' },
	  filetypes = { 'lua' },
    root_markers = final_rootmarkers,
	  --root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
	  ---@type lspconfig.settings.lua_ls
	  settings = {
	    Lua = {
        codeLens = { enable = true },
        hint = { enable = true, semicolon = 'Disable' },
	      runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
	      },
	      diagnostics = {
		      globals = { 'vim' },
	      },
	      workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            "{3rd}/luv/library",
            vim.api.nvim_get_runtime_file('lua/lspconfig', false)[1],
          },
	      },
	      telemetry = { enable = false },
	    },
	  },
	}
}
