return {
  "xixiaofinland/sf.nvim",

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },

  config = function()
    require("sf").setup() -- Important to call setup() to initialize the plugin!
  end,
}
