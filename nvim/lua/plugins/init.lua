local function bootstrap_pckr()
  local pckr_path = vim.fn.stdpath("data") .. "/pckr/pckr.nvim"

  if not (vim.uv or vim.loop).fs_stat(pckr_path) then
    vim.fn.system({
      'git',
      'clone',
      "--filter=blob:none",
      'https://github.com/lewis6991/pckr.nvim',
      pckr_path
    })
  end

  vim.opt.rtp:prepend(pckr_path)
end

bootstrap_pckr()

require('pckr').add{
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    run = ':TSUpdate'
  };
  {
    "neovim/nvim-lspconfig"
  };
  
  -- 自动安装 LSP 服务器
  'williamboman/mason.nvim';
  'williamboman/mason-lspconfig.nvim';
  
  -- 自动补全
  'hrsh7th/nvim-cmp';
  'hrsh7th/cmp-nvim-lsp';
  'hrsh7th/cmp-buffer';
  'hrsh7th/cmp-path';
  'hrsh7th/cmp-cmdline';
  
  -- 代码片段
  'L3MON4D3/LuaSnip';
  'saadparwaiz1/cmp_luasnip';
  'rafamadriz/friendly-snippets';
  
  -- TypeScript 增强
  'jose-elias-alvarez/typescript.nvim';
  
  
  -- 状态栏（可选）
  'nvim-lualine/lualine.nvim';  
}        


-- LSP 配置
local function setup_lsp()
  -- Mason 配置
  require('mason').setup()
  require('mason-lspconfig').setup({
    ensure_installed = {
      'tsserver',          -- TypeScript/JavaScript
      'html',              -- HTML
      'cssls',             -- CSS
      'tailwindcss',       -- TailwindCSS (如果使用)
      'emmet_ls',          -- Emmet
      'eslint',            -- ESLint
    }
  })

  -- 补全配置
  local cmp = require('cmp')
  local luasnip = require('luasnip')

  -- 加载友好的代码片段
  require('luasnip.loaders.from_vscode').lazy_load()

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
    })
  })

  -- LSP 服务器配置
  local lspconfig = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- TypeScript/JavaScript 服务器
  require('typescript').setup({
    server = {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- 键位映射
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
      end,
      settings = {
        typescript = {
          preferences = {
            importModuleSpecifier = "relative"
          }
        }
      }
    }
  })

  -- HTML 服务器
  lspconfig.html.setup({
    capabilities = capabilities,
    filetypes = { 'html', 'htmldjango', 'tsx', 'jsx' }
  })

  -- CSS 服务器
  lspconfig.cssls.setup({
    capabilities = capabilities,
  })

  -- TailwindCSS 服务器（如果使用 TailwindCSS）
  lspconfig.tailwindcss.setup({
    capabilities = capabilities,
    filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
  })

  -- Emmet 服务器
  lspconfig.emmet_ls.setup({
    capabilities = capabilities,
    filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
  })

  -- ESLint 服务器
  lspconfig.eslint.setup({
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "EslintFixAll",
      })
    end,
  })
end


-- Treesitter 配置
local function setup_treesitter()
  require('nvim-treesitter.configs').setup({
    ensure_installed = {
      'javascript',
      'typescript',
      'tsx',
      'jsx',
      'html',
      'css',
      'json',
      'lua',
      'vim',
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  })
end


-- 状态栏配置（可选）
local function setup_lualine()
  require('lualine').setup({
    options = {
      theme = 'auto',
      component_separators = '|',
      section_separators = '',
    },
  })
end

-- 在插件加载后设置
vim.api.nvim_create_autocmd('User', {
  pattern = 'PckrComplete',
  callback = function()
    setup_lsp()
    setup_treesitter()
    setup_lualine()
  end,
})

