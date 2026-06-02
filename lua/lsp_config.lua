local tsgo_capabilities = vim.lsp.protocol.make_client_capabilities()
tsgo_capabilities.textDocument.completion.completionList.itemDefaults = {}

local function add_tsgo_keyword_triggers(client)
  local completion_provider = client.server_capabilities.completionProvider
  if not completion_provider then
    return
  end

  local triggers = completion_provider.triggerCharacters or {}
  local seen = {}
  for _, trigger in ipairs(triggers) do
    seen[trigger] = true
  end

  for trigger in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$'):gmatch('.') do
    if not seen[trigger] then
      table.insert(triggers, trigger)
    end
  end

  completion_provider.triggerCharacters = triggers
end

local function patch_tsgo_completion_boundary()
  if vim.g.tsgo_completion_boundary_patched then
    return
  end

  local convert_results = vim.lsp.completion._convert_results
  if not convert_results then
    return
  end
  vim.g.tsgo_completion_boundary_patched = true

  -- tsgo can return property-access text edits that start on the dot.
  -- Keep builtin completion anchored after the dot so selection does not delete it.
  vim.lsp.completion._convert_results = function(
    line,
    lnum,
    cursor_col,
    client_id,
    client_start_boundary,
    server_start_boundary,
    result,
    encoding
  )
    local client = vim.lsp.get_client_by_id(client_id)
    if
      client
      and client.name == 'tsgo'
      and client_start_boundary > 0
      and line:sub(client_start_boundary, client_start_boundary) == '.'
    then
      server_start_boundary = client_start_boundary
    end

    return convert_results(
      line,
      lnum,
      cursor_col,
      client_id,
      client_start_boundary,
      server_start_boundary,
      result,
      encoding
    )
  end
end

patch_tsgo_completion_boundary()

local servers = {
  -- lua config for neovim taken from https://github.com/neovim/nvim-lspconfig/blob/92ee7d42320edfbb81f3cad851314ab197fa324a/lua/lspconfig/configs/lua_ls.lua#L31
  lua_ls = {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc')) then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
            -- Depending on the usage, you might want to add additional paths here.
            -- "${3rd}/luv/library"
            -- "${3rd}/busted/library",
          }
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
          -- library = vim.api.nvim_get_runtime_file("", true)
        }
      })
    end,
    settings = {
      Lua = {}
    }
  },

  helm_ls = {},
  yamlls = {
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        format = { enable = true },
      },
    },
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = true
    end,
  },

  ols = {},
  rust_analyzer = {},
  clangd = {},
  gopls = {},
  tsgo = {
    capabilities = tsgo_capabilities,
    on_attach = add_tsgo_keyword_triggers,
  }
}

for server, config in pairs(servers) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end
