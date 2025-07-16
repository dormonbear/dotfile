-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load Salesforce file type detection
require("config.filetype")

-- Load SObject functionality directly (as backup)
require("config.sobject-direct")

-- Load simple Apex LSP fix
require("config.apex-lsp-simple")

-- Performance optimizations for large files
local performance = require("config.performance")
performance.setup({
  disable_treesitter = false, -- Keep Treesitter syntax highlighting
  disable_lsp = false,        -- Keep LSP functionality
  disable_folding = true,     -- Disable folding for large files
  disable_cursorline = true,  -- Disable cursorline for large files
  disable_diagnostics = true, -- Disable diagnostics for large files
})
