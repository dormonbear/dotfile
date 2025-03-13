-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- ~/.config/nvim/lua/config/keymaps.lua

-- 禁用方向键
vim.keymap.set({ "n", "v" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v" }, "<Right>", "<Nop>")

-- 插入模式下禁用方向键
vim.keymap.set("i", "<Up>", "<Nop>")
vim.keymap.set("i", "<Down>", "<Nop>")
vim.keymap.set("i", "<Left>", "<Nop>")
vim.keymap.set("i", "<Right>", "<Nop>")

-- 设置 jj, jk 或 kk 退出插入模式
vim.keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
vim.keymap.set("i", "kk", "<ESC>", { desc = "Exit insert mode with kk" })

vim.keymap.set("n", "<leader>fp", function()
  require("telescope").extensions.project.project({})
end, { desc = "Find Project" })

vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })

vim.keymap.set("n", "<leader>fs", function()
  require("telescope.builtin").lsp_document_symbols({
    symbols = {
      "Class",
      "Function",
      "Method",
      "Constructor",
      "Interface",
      "Module",
      "Struct",
      "Trait",
      "Field",
      "Property",
    },
  })
end, { desc = "Find Document Symbols" })
-- Visual mode sort mappings
vim.keymap.set("v", "<leader>s", ":sort<CR>", { desc = "Sort lines alphabetically", silent = true })
vim.keymap.set("v", "<leader>sr", ":sort!<CR>", { desc = "Sort lines in reverse", silent = true })
vim.keymap.set("v", "<leader>si", ":sort i<CR>", { desc = "Sort lines ignoring case", silent = true })
vim.keymap.set("v", "<leader>sn", ":sort n<CR>", { desc = "Sort lines numerically", silent = true })
vim.keymap.set("v", "<leader>su", ":sort u<CR>", { desc = "Sort lines and remove duplicates", silent = true })

-- Set sort options
vim.opt.smartcase = true -- Smart case sensitivity for sorting
