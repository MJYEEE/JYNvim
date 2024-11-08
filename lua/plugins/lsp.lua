return {
    -- mason.nvim 插件配置
    {
      "williamboman/mason.nvim",
      config = function()
        require('mason').setup({
          -- 定义 package 的安装状态的图标
          ui = {
            icons = {
              package_installed = "✓", -- 已安装
              package_pending = "➜",   -- 安装中
              package_uninstalled = "✗"  -- 未安装
            }
          }
        })
      end
    },
  
    -- mason-lspconfig 插件配置
    {
      "williamboman/mason-lspconfig.nvim", -- mason-lspconfig 插件，用于自动安装和配置 LSP 服务器
      dependencies = { "williamboman/mason.nvim" },  -- 指定依赖关系
      after = "mason.nvim",  -- 确保在 mason.nvim 之后加载
      config = function()
        -- 配置 mason-lspconfig 插件，确保所需的 LSP 服务器已安装
        require('mason-lspconfig').setup({
          -- 在这里列出你希望自动安装的 LSP 服务器
          ensure_installed = { 'pyright', 'lua_ls', 'rust_analyzer' },
        })
      end
    },
  
    -- nvim-lspconfig 插件配置
    {
      "neovim/nvim-lspconfig",
      config = function()
        -- LSP 配置部分
        local lspconfig = require('lspconfig')

        -- 设置一些常用的快捷键
        local opts = { noremap = true, silent = true }
        -- 显示诊断信息的快捷键（跳转、查看诊断信息）
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
  
        -- 定义一个 `on_attach` 函数，在 LSP 服务器附加到缓冲区时执行
        local on_attach = function(client, bufnr)
          -- 设置 omnifunc（用于代码补全）
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- 为缓冲区定义一些快捷键，简化常用 LSP 功能的调用
          local bufopts = { noremap = true, silent = true, buffer = bufnr }
          -- 跳转到声明、定义、查看信息等
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)

          -- 工作区文件夹操作
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, bufopts)

          -- 代码重命名、引用、类型定义等操作
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
          vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

           -- 格式化代码
          vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
          end, bufopts)
        end
        
        -- 配置 lspcapabilities（用于代码补全的能力）
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- 其他语言服务器同理
        -- 配置 Pyright 语言服务器，关联 on_attach 和 capabilities
        lspconfig.pyright.setup({
            on_attach = on_attach,
            capabilities = capabilities, 
        })
        
        -- 配置rust 语言服务器
        lspconfig.rust_analyzer.setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
      end
    }
  }
