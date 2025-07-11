-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- ============================================================================
-- BASIC MOVEMENT & EDITING
-- ============================================================================

-- Disable arrow keys to enforce hjkl usage
map({ "n", "v", "i" }, "<Up>", "<Nop>", { desc = "Disabled arrow key" })
map({ "n", "v", "i" }, "<Down>", "<Nop>", { desc = "Disabled arrow key" })
map({ "n", "v", "i" }, "<Left>", "<Nop>", { desc = "Disabled arrow key" })
map({ "n", "v", "i" }, "<Right>", "<Nop>", { desc = "Disabled arrow key" })

-- Better escape sequences
map("i", "jj", "<ESC>", { desc = "Exit insert mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("i", "kj", "<ESC>", { desc = "Exit insert mode" })

-- ============================================================================
-- TEXT MANIPULATION
-- ============================================================================

-- Visual mode sorting
map("v", "<leader>s", ":sort<CR>", { desc = "Sort lines alphabetically", silent = true })
map("v", "<leader>sr", ":sort!<CR>", { desc = "Sort lines in reverse", silent = true })

-- ============================================================================
-- LSP & CODE NAVIGATION  
-- ============================================================================

-- Enhanced LSP keymaps (supplement LazyVim defaults)
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })

-- ============================================================================
-- FILE & PROJECT MANAGEMENT
-- ============================================================================

-- Project management
map("n", "<leader>fp", function()
  require("telescope").extensions.project.project({})
end, { desc = "Find Project" })

-- Document symbols with filtering
map("n", "<leader>fs", function()
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

-- ============================================================================
-- TERMINAL & SYSTEM
-- ============================================================================

-- Terminal shortcuts (supplementing toggleterm config)
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to bottom window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to top window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- ============================================================================
-- CUSTOM UTILITIES
-- ============================================================================

-- Quick save with formatting
map("n", "<leader>w", function()
  vim.cmd("w")
  vim.notify("File saved", vim.log.levels.INFO)
end, { desc = "Save file" })

-- Clear search highlights
map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Toggle word wrap
map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Word wrap: " .. (vim.wo.wrap and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle word wrap" })

-- Show current file path
map("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied to clipboard: " .. path, vim.log.levels.INFO)
end, { desc = "Copy file path" })

-- ============================================================================
-- BUFFER MANAGEMENT
-- ============================================================================

-- Better buffer navigation (supplement LazyVim defaults)
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>ba", ":%bd|e#<CR>", { desc = "Delete all buffers except current" })

-- ============================================================================
-- QUICK FIXES & DIAGNOSTICS
-- ============================================================================

-- Quick diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- ============================================================================
-- APEX & SALESFORCE DEVELOPMENT
-- ============================================================================

-- Salesforce SObject Management (defined in plugins/salesforce-objects.lua)
-- map("n", "<leader>so", function() -- SObject definition for word under cursor
-- map("n", "<leader>sO", function() -- Browse all SObjects with Telescope picker  
-- map("n", "<leader>sf", function() -- Open SObject TypeScript definition file
-- map("n", "<leader>sl", function() -- Lookup SObject by name with input prompt

-- Original sf.nvim shortcuts
-- map("n", "<leader>ms", -- SF set target org
-- map("n", "<leader>mS", -- SF set global target org
-- map("n", "<leader>mp", -- SF save and push
-- map("n", "<leader>mr", -- SF retrieve

-- ============================================================================
-- QUALITY OF LIFE
-- ============================================================================

-- Better indenting in visual mode
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered during navigation
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result and center" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center" })
