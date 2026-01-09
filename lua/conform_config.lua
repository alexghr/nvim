local Conform = require('conform')

Conform.setup({
  formatters_by_ft = {}
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = "*",
  callback = function(args)
    Conform.format({ bufnr = args.buf })
  end,
})
