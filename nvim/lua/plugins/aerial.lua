-- ~/.config/nvim/lua/plugins/aerial.lua
return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
    },
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" },
    },
    opts = {
      -- 配置选项
      attach_mode = "global",
      layout = {
        -- 以下是推荐的布局配置
        default_direction = "prefer_right",
        max_width = { 40, 0.2 },
        min_width = 20,

        -- 你可以自定义窗口的外观
        win_opts = {
          winblend = 10,
        },
      },

      -- 显示图标
      show_guides = true,
      guides = {
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },

      -- 过滤显示的符号
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Method",
        "Struct",
        "Variable",
      },

      -- 自定义图标
      icons = {
        Class = "󰠱 ",
        Function = "󰊕 ",
        Method = " ",
        Constructor = " ",
        Variable = "󰆧 ",
        Interface = " ",
        Struct = "󰌗 ",
        Enum = " ",
      },

      -- 启用 LSP 和 Treesitter 支持
      backends = { "lsp", "treesitter", "markdown", "man" },
    },
  },
}
