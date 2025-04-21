return {
  'hrsh7th/nvim-cmp',
  opts = function(_, opts)
    table.insert(opts.formatters_by_ft, 'hlint')
  end,
}
