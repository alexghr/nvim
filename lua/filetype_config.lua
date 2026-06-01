vim.filetype.add({
  extension = {
    gotmpl = 'gotmpl',
  },
  pattern = {
    ['.*/templates/.*%.tpl'] = 'helm',
    ['.*/templates/.*%.ya?ml'] = 'helm',
    ['helmfile.*%.ya?ml'] = 'helm',
    ['.*/values.*%.ya?ml'] = function(path)
      local dir = vim.fs.dirname(path)
      local chart = dir and vim.fs.find('Chart.yaml', { path = dir, upward = true })[1]
      return chart and 'yaml.helm-values' or 'yaml'
    end,
  },
})
