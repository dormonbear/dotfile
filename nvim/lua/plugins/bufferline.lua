return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    options = {
      numbers = "none", -- 显示缓冲区编号
      close_command = "bdelete! %d", -- 关闭缓冲区命令
      right_mouse_command = "bdelete! %d", -- 右键关闭缓冲区命令
      left_mouse_command = "buffer %d", -- 左键切换缓冲区命令
      middle_mouse_command = nil, -- 中键命令
      max_name_length = 18, -- 最大名称长度
      max_prefix_length = 15, -- 最大前缀长度
      tab_size = 18, -- 标签大小
      diagnostics = "nvim_lsp", -- 显示诊断
      diagnostics_update_in_insert = false, -- 插入模式下更新诊断
      offsets = { -- 偏移量配置
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
      show_buffer_icons = true, -- 显示缓冲区图标
      show_buffer_close_icons = true, -- 显示缓冲区关闭图标
      show_close_icon = false, -- 显示关闭图标
      show_tab_indicators = true, -- 显示标签指示器
      persist_buffer_sort = true, -- 持久化缓冲区排序
      separator_style = "thin", -- 分隔符样式
      enforce_regular_tabs = false, -- 强制常规标签
      always_show_bufferline = true, -- 始终显示缓冲区线
      sort_by = "id", -- 根据 ID 排序
      multirow = true, -- 启用多行显示
    },
  },
}
