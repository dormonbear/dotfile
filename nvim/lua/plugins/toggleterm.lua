return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    -- 大小配置
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.3) -- 屏幕高度的 30%
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4) -- 屏幕宽度的 40%
      end
    end,

    -- 外观配置
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell,

    -- 终端窗口配置
    winbar = {
      enabled = false,
      name_formatter = function(term)
        return term.name
      end,
    },

    -- 浮动终端配置
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  },

  -- 快捷键配置
  keys = {
    { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    { "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<cr>", desc = "Horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm size=60 direction=vertical<cr>", desc = "Vertical terminal" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
  },

  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- 终端模式下的快捷键
    function _G.set_terminal_keymaps()
      local options = { buffer = 0 }
      vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], options)
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], options)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], options)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], options)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], options)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], options)
    end

    -- 为终端缓冲区设置快捷键
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

    -- 自定义终端行为
    local terminal = require("toggleterm.terminal").Terminal

    -- 创建自定义终端实例
    local lazygit = terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      float_opts = {
        border = "double",
      },
    })

    -- 注册自定义命令
    vim.api.nvim_create_user_command("Lazygit", function()
      lazygit:toggle()
    end, {})
  end,
}
