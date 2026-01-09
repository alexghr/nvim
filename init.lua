vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/nvim-mini/mini.pick' },
  { src = 'https://github.com/nvim-mini/mini.icons.git' },
  { src = 'https://github.com/mfussenegger/nvim-lint.git' },
  { src = 'https://github.com/stevearc/conform.nvim.git' }
}

vim.cmd([[colorscheme tokyonight]])

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'

vim.opt.signcolumn = 'yes'
vim.opt.winborder = 'rounded'

vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.breakindent = true
vim.opt.wrap = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'split'

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.highlight.on_yank()
  end,
})

require('mini.icons').setup()

local MiniPick = require('mini.pick')
MiniPick.setup({
  mappings = {
    execute = {
      char = '<C-e>',
      func = function() vim.cmd(vim.fn.input('Execute: ')) end,
    }
  }
})

function StartMiniPick(name, items)
  MiniPick.start({
    source = {
      name = name,
      items = items
    }
  })
end

require('oil').setup({
  default_file_explorer = true,
  columns = {
    'icon',
  },
  use_default_keymaps = true,
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
  },
})

require('lsp_config')
require('lint_config')
require('conform_config')
require('term_toggle')

vim.keymap.set('n', '<leader>`', ':lua TermToggle(20)<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader><ESC>', ':lua TermToggle(20)<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<leader>`', '<C-\\><C-n>:lua TermToggle(20)<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<leader><ESC>', '<C-\\><C-n>:lua TermToggle(20)<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '-', ':Oil<CR>', { desc = 'Open parent directory' })

vim.keymap.set('n', '<leader>sf', MiniPick.builtin.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', MiniPick.builtin.grep_live, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sr', MiniPick.builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>q',
  function() StartMiniPick('Diagnostics', vim.diagnostic.toqflist(vim.diagnostic.get())) end,
  { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader><leader>', MiniPick.builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = '[F]ormat buffer' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>ec', '<CMD>e $MYVIMRC<CR>', { desc = '[E]dit [c]onfig' })
vim.keymap.set('n', '<leader>r', ':source $MYVIMRC<CR>', { desc = '[R]eload config' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('i', '<C-space>', '<C-x><C-o>', { desc = 'Autocomplete' })

-- Taken from telescope - https://github.com/tris203/telescope.nvim/blob/d5059ecf874e54e317c2e8bab8591c82612861c3/lua/telescope/builtin/__lsp.lua#L106-L128
---@param item vim.quickfix.entry
---@return lsp.Location
local function item_to_location(item)
  local line = item.lnum - 1
  local character = item.col
  local uri = vim.uri_from_fname(item.filename)
  return {
    uri = uri,
    range = {
      start = {
        line = line,
        character = character,
      },
      ["end"] = {
        line = line,
        character = character,
      },
    },
  }
end

---@param item vim.quickfix.entry
local function choose(item)
  local loc = item_to_location(item)
  local clients = vim.lsp.get_clients({ bufnr = item.bufnr })
  if #clients > 0 then
    vim.lsp.util.show_document(loc, clients[1].offset_encoding, { focus = true, reuse_win = true })
  end
end

---@param opts vim.lsp.LocationOpts.OnList
local function on_list(opts)
  -- if there's only one item, select it
  if #opts.items == 1 then
    choose(opts.items[1])
  else
    MiniPick.start({
      source = {
        name = opts.title,
        items = opts.items,
        choose = choose
      }
    })
  end
end

local function lsp_fn(fn)
  return function() fn({ on_list = on_list }) end
end

vim.keymap.set('n', 'gd', lsp_fn(vim.lsp.buf.definition), { desc = '[G]o to [d]efinition' })
vim.keymap.set('n', 'gD', lsp_fn(vim.lsp.buf.type_definition), { desc = '[G]o to type [d]efinition' })
vim.keymap.set('n', 'gi', lsp_fn(vim.lsp.buf.implementation), { desc = '[G]o to [i]implementation' })
vim.keymap.set('n', 'gr', lsp_fn(function(cfg) vim.lsp.buf.references(nil, cfg) end), { desc = '[G]o to [r]eferences' })
vim.keymap.set('n', '<leader>ds', lsp_fn(vim.lsp.buf.document_symbol), { desc = '[D]ocument [s]ymbols' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })

-- Enable LSP complete
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end
})

vim.cmd([[ set completeopt+=noselect ]])
