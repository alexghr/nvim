local Lint = require('lint')

Lint.linters_by_ft = {}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    Lint.try_lint()
  end,
})
