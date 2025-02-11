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
