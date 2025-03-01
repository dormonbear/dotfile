return {
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      -- 基础设置
      vim.g.VM_default_mappings = 0
      vim.g.VM_theme = "ocean"
      vim.g.VM_highlight_matches = "underline"
      vim.g.VM_show_warnings = 1
      vim.g.VM_silent_exit = 1

      -- 键位映射
      vim.g.VM_maps = {
        -- 多光标操作
        ["Find Under"] = "<C-n>",
        ["Find Subword Under"] = "<C-n>",
        ["Select h"] = "<C-Left>",
        ["Select l"] = "<C-Right>",
        ["Add Cursor Up"] = "<C-Up>",
        ["Add Cursor Down"] = "<C-Down>",
        ["Add Cursor At Pos"] = "<C-x>",
        ["Add Cursor At Word"] = "<C-w>",
        ["Move Left"] = "<C-S-Left>",
        ["Move Right"] = "<C-S-Right>",

        -- 区域操作
        ["Skip Region"] = "<C-x>",
        ["Remove Region"] = "<C-p>",
        ["Invert Direction"] = "<C-r>",
        ["Find Next"] = "n",
        ["Find Prev"] = "N",

        -- 选择操作
        ["Select Cursor Down"] = "<M-Down>",
        ["Select Cursor Up"] = "<M-Up>",

        -- 其他常用操作
        ["Visual Regex"] = "\\/",
        ["Visual All"] = "\\A",
        ["Visual Add"] = "\\a",
        ["Visual Find"] = "\\f",
        ["Visual Cursors"] = "\\c",
      }

      -- 自定义高亮
      vim.cmd([[
        hi VM_Extend ctermbg=LightYellow guibg=LightYellow
        hi VM_Cursor ctermbg=DarkRed guibg=DarkRed
        hi VM_Insert ctermbg=DarkGreen guibg=DarkGreen
        hi VM_Mono ctermfg=White guifg=White
      ]])
    end,
    -- 添加快捷键
    keys = {
      {
        "<Leader>vm",
        "<Plug>(VM-Add-Cursor-At-Pos)",
        desc = "Add Virtual Cursor at Position",
      },
      {
        "<Leader>va",
        "<Plug>(VM-Select-All)",
        desc = "Select All Occurrences",
      },
    },
  },
}
