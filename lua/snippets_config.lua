local M = {}

---@class Snippet
---@field filetypes string[]
---@field trig string
---@field name string
---@field body string

---@type Snippet[]
M.items = {
  {
    filetypes = { 'go' },
    trig = 'ife',
    name = 'if err != nil',
    body = 'if err != nil {\n\t${1:return err}\n}\n$0',
  },
}

---@param ft string
---@return Snippet[]
function M.for_filetype(ft)
  local items = {}

  for _, item in ipairs(M.items) do
    if vim.tbl_contains(item.filetypes, ft) then
      table.insert(items, item)
    end
  end

  return items
end

function M.pick_snippet()
  local snippets = M.for_filetype(vim.bo.filetype)
  if #snippets == 0 then
    vim.notify('No snippets for ' .. vim.bo.filetype, vim.log.levels.INFO)
    return
  end

  vim.ui.select(snippets, {
    prompt = 'Snippets',
    kind = 'snippet',
    ---@param item Snippet
    format_item = function(item)
      return item.trig .. '  ' .. item.name
    end,
  }, function(item)
    if item then
      vim.snippet.expand(item.body)
    end
  end)
end

function M.expand_leading_snippet()
  local snippets = M.for_filetype(vim.bo.filetype)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local trig = line:sub(1, col):match('([%w_]+)$')

  if trig then
    for _, item in ipairs(snippets) do
      if item.trig == trig then
        vim.api.nvim_buf_set_text(0, row - 1, col - #trig, row - 1, col, { '' })
        vim.snippet.expand(item.body)
        return
      end
    end
  end
end

return M
