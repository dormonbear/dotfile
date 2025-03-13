return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = function()
      return {}
    end,
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local d = ls.dynamic_node
      local fmt = require("luasnip.extras.fmt").fmt
      local fmta = require("luasnip.extras.fmt").fmta
      local rep = require("luasnip.extras").rep

      -- 扩展配置
      ls.config.set_config({
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
        update_events = "TextChanged,TextChangedI",
      })

      -- 获取文件信息的辅助函数
      local function get_file_info()
        local filename = vim.fn.expand("%:t") -- 获取文件名
        local basename = filename:match("(.+)%..+$") or filename -- 不带扩展名
        local path = vim.fn.expand("%:p:~:.") -- 相对路径
        return {
          filename = filename,
          basename = basename,
          path = path,
        }
      end

      -- 定义snippets
      local javascript_snippets = {
        -- 基础日志
        s(
          "logi",
          fmt([[console.log('***dormon{}', {})]], {
            f(function()
              return get_file_info().basename
            end),
            i(1),
          })
        ),

        -- 带文件路径的日志
        s(
          "logip",
          fmt([[console.log('***dormon{} ({})', {})]], {
            f(function()
              return get_file_info().basename
            end),
            f(function()
              return get_file_info().path
            end),
            i(1),
          })
        ),

        -- 带变量名的日志
        s(
          "logiv",
          fmt([[console.log('***dormon{} - {}: ', {})]], {
            f(function()
              return get_file_info().basename
            end),
            i(1),
            rep(1),
          })
        ),
      }

      -- 为不同文件类型添加snippets
      local filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
      }

      for _, ft in ipairs(filetypes) do
        ls.add_snippets(ft, javascript_snippets)
      end

      -- 键位映射
      vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, { silent = true })

      vim.keymap.set("i", "<C-l>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end)
    end,
  },

  -- 可选：添加 friendly-snippets 支持
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
