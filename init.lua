vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig',      version = 'v2.9.0' },
  { src = 'https://github.com/stevearc/oil.nvim',          version = 'v2.16.0' },
  { src = 'https://github.com/tpope/vim-fugitive',         version = '3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0' },
  { src = 'https://github.com/ibhagwan/fzf-lua',           version = 'e3a71496027f2e3c4a60340170c04d66053d5c4c' },
  { src = 'https://github.com/loctvl842/monokai-pro.nvim', version = 'v2.1.4' },
  { src = 'https://github.com/nvim-mini/mini.icons',       version = '520995f1d75da0e4cc901ee95080b1ff2bc46b94' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim',    version = 'v2.1.0' },
  { src = 'https://github.com/folke/which-key.nvim',       version = '3aab2147e74890957785941f0c1ad87d0a44c15a' },
  { src = 'https://github.com/towolf/vim-helm',            version = '2c8525fd98e57472769d137317bca83e477858ce' },
}

-- clean up old packages that were removed from vim.pack.add
local function pack_clean_inactive()
  local inactive = {}

  for _, plugin in ipairs(vim.pack.get(nil, { info = false })) do
    if not plugin.active then
      table.insert(inactive, plugin.spec.name)
    end
  end

  if #inactive == 0 then
    vim.notify('No inactive vim.pack packages to remove', vim.log.levels.INFO)
    return
  end

  vim.pack.del(inactive)
  vim.notify('Removed inactive vim.pack packages: ' .. table.concat(inactive, ', '), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('PackCleanInactive', pack_clean_inactive, {
  desc = 'Remove vim.pack packages that are not active in this session',
})

require('monokai-pro').setup({
  filter = "machine",
})
vim.cmd([[colorscheme monokai-pro]])

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

vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'popup' }

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.highlight.on_yank()
  end,
})

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

local fzf = require('fzf-lua')
fzf.setup({
  fzf_colors = true
})
fzf.register_ui_select()

require('mini.icons').setup({})
require('gitsigns').setup({})

require('which-key').setup({
  plugins = {
    registers = true,
  },
})

require('filetype_config')
require('lsp_config')

vim.keymap.set('n', '-', ':Oil<CR>', { desc = 'Open parent directory' })

vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = '[F]ormat buffer' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('i', '<C-space>', vim.lsp.completion.get, { desc = 'Autocomplete' })
vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Show function signature' })

vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [f]iles' })
vim.keymap.set('n', '<leader>sv', fzf.vcs_files, { desc = '[S]earch [v]cs files' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep_native, { desc = '[S]earch [g]rep' })
vim.keymap.set('n', '<leader>r', fzf.resume, { desc = '[R]esume' })
vim.keymap.set('n', '<leader><leader>', fzf.history, { desc = 'Open history' })

vim.keymap.set('n', 'gd', fzf.lsp_definitions, { desc = '[G]o to [d]efinition' })
vim.keymap.set('n', 'gD', fzf.lsp_typedefs, { desc = '[G]o to type [d]efinition' })
vim.keymap.set('n', 'gi', fzf.lsp_implementations, { desc = '[G]o to [i]implementation' })
vim.keymap.set('n', 'gr', fzf.lsp_references, { desc = '[G]o to [r]eferences' })

vim.keymap.set('n', '<leader>q', fzf.lsp_document_diagnostics, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>ds', fzf.lsp_document_symbols, { desc = '[D]ocument [s]ymbols' })
vim.keymap.set('n', '<leader>ws', fzf.lsp_live_workspace_symbols, { desc = '[W]orkspace [s]ymbols' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
vim.keymap.set('n', '<leader>oi', function()
  vim.lsp.buf.code_action({
    context = { only = { 'source.organizeImports' }, diagnostics = {} },
    apply = true,
  })
end, { desc = '[O]rganize [I]mports' })

-- Enable LSP complete
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
  end
})

local Snippets = require('snippets_config')
vim.keymap.set('n', '<leader>sn', Snippets.pick_snippet, { desc = '[S]nippets' })
vim.keymap.set('i', '<C-e>', Snippets.expand_leading_snippet, { desc = '[S]nippets' })

-- fugitive helpers

---@param title string
---@return integer|nil
local function get_window_by_name(title)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    if name:match(title) then
      return win
    end
  end

  return nil
end

local function toggle_fugitive()
  local win = get_window_by_name("^fugitive://")
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd([[ normal gq ]])
  else
    vim.cmd([[ Git ]])
  end
end

local function toggle_fugitive_blame()
  local win = get_window_by_name(".fugitiveblame$")
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd([[ quit ]])
  else
    vim.cmd([[ Git blame ]])
  end
end

vim.keymap.set('n', '<leader>gs', toggle_fugitive, { desc = '[G]it [s]status' })
vim.keymap.set('n', '<leader>gb', toggle_fugitive_blame, { desc = '[G]it [b]lame' })
