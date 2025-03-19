return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "prettier")
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        lua = { "stylua" },
      },
      -- 设置格式化时的行为
      format_on_save = {
        -- 这些配置意味着：
        -- 1. 默认开启格式化
        -- 2. 允许使用快捷键临时关闭格式化
        -- 3. 支持 timeout
        lsp_fallback = true,
        async = false,
        timeout_ms = 500,
      },
    },
    -- 快捷键配置
    keys = {
      -- 手动格式化
      {
        "<leader>mp",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format with Prettier",
      },
      -- toggle 格式化开关
      {
        "<leader>mF",
        function()
          require("conform").format_on_save = not require("conform").format_on_save
          vim.notify("Format on save: " .. tostring(require("conform").format_on_save), vim.log.levels.INFO)
        end,
        desc = "Toggle format on save",
      },
    },
  },
}
