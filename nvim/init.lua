-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load Salesforce file type detection
require("config.filetype")

-- Load SObject functionality directly (as backup)
require("config.sobject-direct")

-- Load simple Apex LSP fix
require("config.apex-lsp-simple")
