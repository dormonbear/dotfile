return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP Servers
        "lua-language-server",
        "typescript-language-server",
        "eslint-lsp",
        "json-lsp",
        "html-lsp",
        "css-lsp",
        
        -- Formatters
        "prettier",
        "stylua",
        
        -- Linters
        "eslint_d", -- Faster ESLint daemon
        
        -- Debug Adapters
        "node-debug2-adapter",
        
        -- Salesforce (manual install)
        -- apex-language-server (installed manually)
      },
    },
  },
  
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        -- ESLint daemon (faster than regular ESLint)
        "eslint_d",
        "prettier",
        "stylua",
        "typescript-language-server",
        "eslint-lsp",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
} 