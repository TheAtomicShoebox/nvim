if vim.g.vscode then
  return {}
end

return {
  'saghen/blink.cmp',
  ---@module 'blink.cmp'
  ---@param opts blink.cmp.Config | { sources: {compat: string[] } }
  config = function(_, opts)
    local enabled = opts.sources.default
    opts.fuzzy = { implementation = 'prefer_rust_with_warning' }
    if type(enabled) == 'table' then
      if not vim.tbl_contains(enabled, 'easy-dotnet') then
        table.insert(enabled, 'easy-dotnet')
      end
      if not vim.tbl_contains(enabled, 'lsp') then
        table.insert(enabled, 'lsp')
      end
      if not vim.tbl_contains(enabled, 'path') then
        table.insert(enabled, 'path')
      end
    end
    ---@type blink.cmp.SourceProviderConfigPartial
    local providers = opts.sources.providers
    if providers ~= nil then
      providers['easy-dotnet'] = {

        name = 'easy-dotnet',
        enabled = true,
        module = 'easy-dotnet.completion.blink',
        score_offset = 10000,
        async = true,
        kind = nil,
      }
    end
    -- Unset custom prop to pass blink.cmp validation
    opts.sources.compat = nil
    require('blink.cmp').setup(opts)
  end,
}
