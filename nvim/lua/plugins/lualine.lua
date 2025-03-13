-- ~/.config/nvim/lua/plugins/lualine.lua
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      return {
        options = {
          theme = "catppuccin",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
      }
    end,
  },
}
