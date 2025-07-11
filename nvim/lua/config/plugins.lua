-- Plugin categories and organization
-- This file provides an overview of all plugins and their purposes

return {
  -- Core functionality (always loaded)
  core = {
    "lazy.nvim",           -- Plugin manager
    "LazyVim",            -- Base configuration
    "plenary.nvim",       -- Lua utilities
  },

  -- UI & Appearance
  ui = {
    "catppuccin",         -- Colorscheme
    "lualine.nvim",       -- Status line
    "bufferline.nvim",    -- Buffer tabs
    "neo-tree.nvim",      -- File explorer (from LazyVim)
    "noice.nvim",         -- Better UI messages (from LazyVim)
  },

  -- Editor Enhancement
  editor = {
    "flash.nvim",         -- Better navigation (from LazyVim)
    "mini.surround",      -- Surround text objects
    "mini.ai",            -- Better text objects
    "dial.nvim",          -- Enhanced increment/decrement
    "inc-rename.nvim",    -- Incremental rename
    "vim-visual-multi",   -- Multiple cursors
    "ufo.nvim",           -- Better folding
  },

  -- Code Intelligence
  lsp = {
    "nvim-lspconfig",     -- LSP configuration
    "mason.nvim",         -- LSP/tools installer
    "mason-lspconfig.nvim", -- Mason LSP integration
    "aerial.nvim",        -- Code outline (keeping this one)
    "debug-lsp.lua",      -- Custom LSP debugging
  },

  -- Completion & Snippets
  completion = {
    "nvim-cmp",           -- Completion engine (from LazyVim blink.cmp)
    "LuaSnip",            -- Snippet engine
    "friendly-snippets",  -- Snippet collection
  },

  -- Language Support
  languages = {
    "nvim-treesitter",    -- Syntax highlighting
    "sf.nvim",            -- Salesforce support
  },

  -- Development Tools
  dev_tools = {
    "lazygit.nvim",       -- Git integration
    "neotest",            -- Testing framework
    "nvim-dap",           -- Debug adapter
    "conform.nvim",       -- Formatting (includes prettier)
  },

  -- File Management
  files = {
    "telescope.nvim",     -- Fuzzy finder
    "yazi.nvim",          -- File manager
    "neovim-project",     -- Project management
  },

  -- Terminal & System
  terminal = {
    "toggleterm.nvim",    -- Terminal management
  },

  -- Utilities
  utils = {
    "spell.lua",          -- Spell checking config
  },

  -- Deprecated/To Remove
  deprecated = {
    "symbols-outline.lua", -- Replaced by aerial.nvim
  },
} 