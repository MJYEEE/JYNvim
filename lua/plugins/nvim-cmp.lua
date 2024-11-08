return {
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        -- "lspkind.nvim",  -- 提供 LSP 类型图标
        "hrsh7th/cmp-nvim-lsp", -- LSP 自动补全
        "hrsh7th/cmp-buffer", -- 缓冲区自动补全
        "hrsh7th/cmp-path", -- 路径自动补全
        "hrsh7th/cmp-cmdline", -- 命令行自动补全
      	"L3MON4D3/LuaSnip", -- 添加 LuaSnip 作为依赖项  snippets引擎，不装这个自动补全会出问题
      },
      config = function() -- 配置
        local has_words_before = function() --  用来判断光标前是否有单词。如果没有单词（比如光标在行首），则不会触发补全。
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local luasnip = require("luasnip") 
        local cmp = require("cmp")

        cmp.setup({
            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) --设置了 luasnip 作为代码片段引擎
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- Use <C-b/f> to scroll the docs
                ['<C-b>'] = cmp.mapping.scroll_docs( -4), -- 向上滚动文档
                ['<C-f>'] = cmp.mapping.scroll_docs(4), -- 向下滚动文档
                -- Use <C-k/j> to switch in items
                ['<C-k>'] = cmp.mapping.select_prev_item(), -- 上一个补全项
                ['<C-j>'] = cmp.mapping.select_next_item(), -- 下一个补全项
                -- Use <CR>(Enter) to confirm selection
                -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 确认选择项

                -- A super tab
                -- sourc: https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
                ["<Tab>"] = cmp.mapping(function(fallback) 
                    -- Hint: if the completion menu is visible select next one
                    if cmp.visible() then
                        cmp.select_next_item() -- 如果补全菜单可见，选择下一个项
                    elseif has_words_before() then
                        cmp.complete()  -- 如果光标前有单词，触发补全
                    else
                        fallback() -- 否则调用默认行为
                    end
                end, { "i", "s" }), -- i - insert mode; s - select mode
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item() -- 如果补全菜单可见，选择上一个项
                    elseif luasnip.jumpable( -1) then
                        luasnip.jump( -1)  -- 跳转到前一个代码片段
                    else
                        fallback() -- 否则调用默认行为
                    end
                end, { "i", "s" }),
            }),

          -- Let's configure the item's appearance
          -- source: https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
          formatting = {
              -- Set order from left to right
              -- kind: single letter indicating the type of completion
              -- abbr: abbreviation of "word"; when not empty it is used in the menu instead of "word"
              -- menu: extra text for the popup menu, displayed after "word" or "abbr"
              fields = { 'abbr', 'menu' }, -- 在菜单中展示补全项的简称和来源

              -- customize the appearance of the completion menu
              format = function(entry, vim_item)
                  vim_item.menu = ({
                      nvim_lsp = '[Lsp]',
                      luasnip = '[Luasnip]',
                      buffer = '[File]',
                      path = '[Path]',
                  })[entry.source.name]
                  return vim_item
              end,
          },

          -- Set source precedence
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },    -- LSP 补全
            { name = 'luasnip' },     -- 代码片段补全
            { name = 'buffer' },      -- 缓冲区补全
            { name = 'path' },        -- 路径补全
	    { name = 'LuaSnip' },
          })
        })
    end,    
    }
}
