return {
  {
    "nvim-neotest/neotest",
    -- 确保所有依赖都正确声明
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "marilari88/neotest-vitest",
      "haydenmeade/neotest-jest",
    },
    -- 确保插件在需要时加载
    event = "BufReadPost",
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run file",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle summary",
      },
    },
    opts = {
      -- 确保适配器配置正确
      adapters = {},
      status = {
        virtual_text = true,
        signs = true,
      },
      output = {
        enabled = true,
        open_on_run = true,
      },
      quickfix = {
        enabled = true,
        open = false,
      },
    },
    config = function(_, opts)
      -- 确保在配置之前所有组件都已加载
      local async = require("neotest.async")

      -- 加载适配器
      opts.adapters = {
        require("neotest-vitest")({
          vitestCommand = "npx vitest",
        }),
        require("neotest-jest")({
          jestCommand = "npx jest",
        }),
      }

      -- 设置 neotest
      require("neotest").setup(opts)
    end,
  },
}
