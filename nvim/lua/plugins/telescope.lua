return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- 添加快捷键映射
      { "<leader>fo", "<cmd>Telescope aerial<cr>", desc = "Find File Symbols" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Find Document Symbols" },
    },
    dependencies = {
      "stevearc/aerial.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      require("telescope").setup({
        extensions = {
          aerial = {
            -- 显示完整上下文（可选）
            show_nesting = true,
          },
        },
      })
      require("telescope").load_extension("aerial")
    end,
  },
}
