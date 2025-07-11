return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      -- LSP diagnostics commands
      {
        "<leader>li",
        function()
          local clients = vim.lsp.get_active_clients()
          print("=== Active LSP Clients ===")
          for _, client in ipairs(clients) do
            print(string.format("- %s (ID: %d)", client.name, client.id))
          end
          
          print("\n=== Current Buffer Info ===")
          local bufnr = vim.api.nvim_get_current_buf()
          local filetype = vim.bo[bufnr].filetype
          local filename = vim.api.nvim_buf_get_name(bufnr)
          print(string.format("Filetype: %s", filetype))
          print(string.format("Filename: %s", filename))
          
          print("\n=== LSP Capabilities ===")
          local buf_clients = vim.lsp.get_active_clients({ bufnr = bufnr })
          for _, client in ipairs(buf_clients) do
            print(string.format("Client: %s", client.name))
            if client.server_capabilities.definitionProvider then
              print("  ✓ Supports go to definition")
            else
              print("  ✗ Does NOT support go to definition")
            end
            if client.server_capabilities.hoverProvider then
              print("  ✓ Supports hover")
            else
              print("  ✗ Does NOT support hover")
            end
          end
        end,
        desc = "LSP Info"
      },
      {
        "<leader>lc",
        function()
          -- Check apex jar file
          local jar_path = "/Users/dormonzhou/apex-jorje-lsp.jar"
          local stat = vim.loop.fs_stat(jar_path)
          
          print("=== Apex LSP Diagnostics ===")
          if stat then
            print(string.format("✓ Apex JAR found: %s", jar_path))
            print(string.format("  Size: %d bytes", stat.size))
          else
            print(string.format("✗ Apex JAR NOT found: %s", jar_path))
            print("  You need to download the apex-jorje-lsp.jar file")
          end
          
          -- Check Java
          local java_version = vim.fn.system("java -version 2>&1")
          if vim.v.shell_error == 0 then
            print("✓ Java is available")
            print(string.format("  Version: %s", java_version:match("([^\r\n]*)")))
          else
            print("✗ Java is NOT available")
            print("  Apex LSP requires Java to run")
          end
          
          -- Check lspconfig setup
          local lspconfig = require("lspconfig")
          local apex_config = lspconfig.util.available_servers()
          local has_apex = false
          for _, server in ipairs(apex_config) do
            if server == "apex_ls" then
              has_apex = true
              break
            end
          end
          
          if has_apex then
            print("✓ apex_ls is available in lspconfig")
          else
            print("✗ apex_ls is NOT available in lspconfig")
          end
        end,
        desc = "Check Apex LSP"
      },
      {
        "<leader>lr",
        function()
          -- Restart LSP for current buffer
          local bufnr = vim.api.nvim_get_current_buf()
          local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
          
          print("=== Restarting LSP Clients ===")
          for _, client in ipairs(clients) do
            print(string.format("Restarting: %s", client.name))
            vim.lsp.stop_client(client.id)
          end
          
          vim.defer_fn(function()
            vim.cmd("edit")  -- Reopen buffer to trigger LSP attach
            print("LSP clients restarted")
          end, 1000)
        end,
        desc = "Restart LSP"
      }
    }
  }
} 