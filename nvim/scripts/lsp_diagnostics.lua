-- LSP Diagnostic Script for Neovim
-- This script helps diagnose LSP issues, particularly the "textDocument/definition is not supported" error

local M = {}

-- Color codes for terminal output
local colors = {
  reset = "\27[0m",
  red = "\27[31m",
  green = "\27[32m",
  yellow = "\27[33m",
  blue = "\27[34m",
  magenta = "\27[35m",
  cyan = "\27[36m",
  white = "\27[37m",
  bold = "\27[1m",
}

-- Helper function to print colored output
local function colored_print(color, text)
  print(color .. text .. colors.reset)
end

-- Print section header
local function print_header(title)
  print("\n" .. colors.bold .. colors.cyan .. "═══ " .. title .. " ═══" .. colors.reset)
end

-- Print subsection
local function print_subsection(title)
  print("\n" .. colors.bold .. colors.yellow .. "─── " .. title .. " ───" .. colors.reset)
end

-- Check if a command exists in PATH
local function command_exists(cmd)
  local handle = io.popen("which " .. cmd .. " 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result and result:match("%S") ~= nil
  end
  return false
end

-- Get currently active LSP clients
local function get_active_lsp_clients()
  local clients = {}
  local active_clients = vim.lsp.get_active_clients()
  
  for _, client in ipairs(active_clients) do
    table.insert(clients, {
      id = client.id,
      name = client.name,
      filetypes = client.config.filetypes or {},
      root_dir = client.config.root_dir,
      cmd = client.config.cmd,
      capabilities = client.server_capabilities,
      attached_buffers = vim.lsp.get_buffers_by_client_id(client.id)
    })
  end
  
  return clients
end

-- Check Mason installed packages
local function get_mason_packages()
  local mason_ok, mason_registry = pcall(require, "mason-registry")
  if not mason_ok then
    return nil, "Mason not available"
  end
  
  local installed = {}
  local all_packages = mason_registry.get_installed_packages()
  
  for _, pkg in ipairs(all_packages) do
    table.insert(installed, {
      name = pkg.name,
      version = pkg:get_installed_version(),
      spec = pkg.spec
    })
  end
  
  return installed, nil
end

-- Check file type and associated LSP servers
local function get_current_filetype_info()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype
  local filename = vim.api.nvim_buf_get_name(buf)
  
  return {
    filetype = filetype,
    filename = filename,
    buf_id = buf,
    is_salesforce = filename:match("%.cls$") or filename:match("%.trigger$") or filename:match("%.apex$") or filetype == "apex"
  }
end

-- Check LSP capabilities for a specific method
local function check_lsp_capability(client, method)
  if not client.server_capabilities then
    return false, "No server capabilities"
  end
  
  -- Map method names to capability paths
  local capability_map = {
    ["textDocument/definition"] = "definitionProvider",
    ["textDocument/references"] = "referencesProvider", 
    ["textDocument/hover"] = "hoverProvider",
    ["textDocument/completion"] = "completionProvider",
    ["textDocument/signatureHelp"] = "signatureHelpProvider",
    ["textDocument/formatting"] = "documentFormattingProvider",
    ["textDocument/rangeFormatting"] = "documentRangeFormattingProvider",
    ["textDocument/rename"] = "renameProvider",
    ["textDocument/codeAction"] = "codeActionProvider",
    ["textDocument/inlayHint"] = "inlayHintProvider"
  }
  
  local capability_path = capability_map[method]
  if not capability_path then
    return false, "Unknown method"
  end
  
  local capability = client.server_capabilities[capability_path]
  if capability == nil then
    return false, "Capability not present"
  elseif capability == false then
    return false, "Capability explicitly disabled"
  elseif capability == true then
    return true, "Capability enabled"
  elseif type(capability) == "table" then
    return true, "Capability enabled (with options)"
  else
    return false, "Capability in unknown state"
  end
end

-- Main diagnostic function
function M.run_diagnostics()
  print_header("LSP DIAGNOSTIC REPORT")
  colored_print(colors.white, "Generated at: " .. os.date("%Y-%m-%d %H:%M:%S"))
  
  -- 1. System Information
  print_header("SYSTEM INFORMATION")
  colored_print(colors.white, "Neovim version: " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch)
  colored_print(colors.white, "OS: " .. vim.loop.os_uname().sysname .. " " .. vim.loop.os_uname().release)
  colored_print(colors.white, "Working directory: " .. vim.fn.getcwd())
  
  -- Check for Salesforce project
  local sfdx_exists = vim.fn.filereadable("sfdx-project.json") == 1
  if sfdx_exists then
    colored_print(colors.green, "✓ Salesforce project detected (sfdx-project.json found)")
  else
    colored_print(colors.yellow, "⚠ Not in a Salesforce project directory")
  end
  
  -- 2. Current File Information
  print_header("CURRENT FILE INFORMATION")
  local file_info = get_current_filetype_info()
  colored_print(colors.white, "Filename: " .. (file_info.filename ~= "" and file_info.filename or "No file"))
  colored_print(colors.white, "Filetype: " .. (file_info.filetype ~= "" and file_info.filetype or "No filetype"))
  colored_print(colors.white, "Buffer ID: " .. file_info.buf_id)
  
  if file_info.is_salesforce then
    colored_print(colors.green, "✓ Salesforce file detected")
  else
    colored_print(colors.yellow, "⚠ Not a Salesforce file")
  end
  
  -- 3. Command Availability
  print_header("EXTERNAL COMMANDS")
  local commands = {
    "java", "sf", "sfdx", "node", "npm", "apex-jorje-lsp.jar"
  }
  
  for _, cmd in ipairs(commands) do
    if cmd == "apex-jorje-lsp.jar" then
      -- Special check for Apex LSP jar
      local jar_path = "/Users/dormonzhou/apex-jorje-lsp.jar"
      if vim.fn.filereadable(jar_path) == 1 then
        colored_print(colors.green, "✓ " .. cmd .. " found at " .. jar_path)
      else
        colored_print(colors.red, "✗ " .. cmd .. " not found at " .. jar_path)
      end
    else
      if command_exists(cmd) then
        colored_print(colors.green, "✓ " .. cmd .. " available")
      else
        colored_print(colors.red, "✗ " .. cmd .. " not found")
      end
    end
  end
  
  -- 4. Mason Package Status
  print_header("MASON PACKAGES")
  local mason_packages, mason_error = get_mason_packages()
  
  if mason_error then
    colored_print(colors.red, "✗ " .. mason_error)
  else
    colored_print(colors.green, "✓ Mason available, " .. #mason_packages .. " packages installed")
    
    -- Show relevant LSP servers
    local lsp_servers = {}
    for _, pkg in ipairs(mason_packages) do
      if pkg.spec.categories and vim.tbl_contains(pkg.spec.categories, "LSP") then
        table.insert(lsp_servers, pkg)
      end
    end
    
    if #lsp_servers > 0 then
      print_subsection("Installed LSP Servers")
      for _, server in ipairs(lsp_servers) do
        colored_print(colors.white, "  • " .. server.name .. " (" .. (server.version or "unknown version") .. ")")
      end
    else
      colored_print(colors.yellow, "⚠ No LSP servers found in Mason")
    end
  end
  
  -- 5. Active LSP Clients
  print_header("ACTIVE LSP CLIENTS")
  local clients = get_active_lsp_clients()
  
  if #clients == 0 then
    colored_print(colors.red, "✗ No active LSP clients")
    colored_print(colors.yellow, "💡 Try opening a file and running :LspInfo")
  else
    colored_print(colors.green, "✓ " .. #clients .. " active LSP client(s)")
    
    for _, client in ipairs(clients) do
      print_subsection("Client: " .. client.name .. " (ID: " .. client.id .. ")")
      
      -- Basic info
      colored_print(colors.white, "  Filetypes: " .. (client.filetypes and table.concat(client.filetypes, ", ") or "None"))
      colored_print(colors.white, "  Root dir: " .. (client.root_dir or "None"))
      colored_print(colors.white, "  Command: " .. (client.cmd and table.concat(client.cmd, " ") or "None"))
      colored_print(colors.white, "  Attached buffers: " .. #client.attached_buffers)
      
      -- Check critical capabilities
      local critical_methods = {
        "textDocument/definition",
        "textDocument/references", 
        "textDocument/hover",
        "textDocument/completion"
      }
      
      colored_print(colors.white, "  Capabilities:")
      for _, method in ipairs(critical_methods) do
        local supported, reason = check_lsp_capability(client, method)
        if supported then
          colored_print(colors.green, "    ✓ " .. method)
        else
          colored_print(colors.red, "    ✗ " .. method .. " (" .. reason .. ")")
        end
      end
      
      -- Special check for current buffer
      local current_buf = vim.api.nvim_get_current_buf()
      if vim.tbl_contains(client.attached_buffers, current_buf) then
        colored_print(colors.green, "  ✓ Attached to current buffer")
      else
        colored_print(colors.yellow, "  ⚠ Not attached to current buffer")
      end
    end
  end
  
  -- 6. LSP Configuration Check
  print_header("LSP CONFIGURATION")
  
  -- Check if lspconfig is available
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if not lspconfig_ok then
    colored_print(colors.red, "✗ lspconfig not available")
  else
    colored_print(colors.green, "✓ lspconfig available")
    
    -- Check specific server configurations
    local servers_to_check = {"apex_ls", "lua_ls", "eslint", "tsserver"}
    
    for _, server_name in ipairs(servers_to_check) do
      local server_config = lspconfig[server_name]
      if server_config then
        colored_print(colors.white, "  • " .. server_name .. " configuration found")
      else
        colored_print(colors.yellow, "  ⚠ " .. server_name .. " configuration not found")
      end
    end
  end
  
  -- 7. Recommendations
  print_header("RECOMMENDATIONS")
  
  local recommendations = {}
  
  -- Check if we have no active clients
  if #clients == 0 then
    table.insert(recommendations, "No LSP clients active. Check if the correct LSP server is installed and configured.")
  end
  
  -- Check for Apex-specific issues
  if file_info.is_salesforce then
    local has_apex_client = false
    for _, client in ipairs(clients) do
      if client.name == "apex_ls" then
        has_apex_client = true
        break
      end
    end
    
    if not has_apex_client then
      table.insert(recommendations, "Salesforce file detected but no Apex LSP client active. Check apex_ls configuration.")
    end
    
    -- Check Java availability for Apex LSP
    if not command_exists("java") then
      table.insert(recommendations, "Java not found. Apex LSP requires Java to run.")
    end
    
    -- Check jar file
    if vim.fn.filereadable("/Users/dormonzhou/apex-jorje-lsp.jar") ~= 1 then
      table.insert(recommendations, "Apex LSP jar file not found. Download from Salesforce.")
    end
  end
  
  -- Check for definition capability specifically
  local has_definition_support = false
  for _, client in ipairs(clients) do
    local supported, _ = check_lsp_capability(client, "textDocument/definition")
    if supported then
      has_definition_support = true
      break
    end
  end
  
  if not has_definition_support and #clients > 0 then
    table.insert(recommendations, "No active LSP client supports 'go to definition'. Check server capabilities.")
  end
  
  if #recommendations == 0 then
    colored_print(colors.green, "✓ No obvious issues detected")
  else
    for i, rec in ipairs(recommendations) do
      colored_print(colors.yellow, tostring(i) .. ". " .. rec)
    end
  end
  
  -- 8. Useful Commands
  print_header("USEFUL COMMANDS")
  colored_print(colors.white, ":LspInfo          - Show detailed LSP client information")
  colored_print(colors.white, ":LspLog           - Show LSP client logs")
  colored_print(colors.white, ":LspRestart       - Restart LSP clients")
  colored_print(colors.white, ":Mason            - Open Mason package manager")
  colored_print(colors.white, ":checkhealth lsp  - Run Neovim LSP health check")
  colored_print(colors.white, ":lua vim.lsp.buf.definition() - Test go to definition")
  
  print_header("DIAGNOSTIC COMPLETE")
end

-- Command to run a quick capability check
function M.check_current_buffer_capabilities()
  local clients = vim.lsp.buf_get_clients()
  local buf = vim.api.nvim_get_current_buf()
  
  print("Current buffer LSP capabilities:")
  
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
    return
  end
  
  for _, client in ipairs(clients) do
    print("\nClient: " .. client.name)
    local methods = {
      "textDocument/definition",
      "textDocument/references",
      "textDocument/hover",
      "textDocument/completion"
    }
    
    for _, method in ipairs(methods) do
      local supported, reason = check_lsp_capability(client, method)
      print(string.format("  %s: %s %s", method, supported and "✓" or "✗", reason))
    end
  end
end

-- Quick fix function for common issues
function M.quick_fix()
  print_header("LSP QUICK FIX")
  
  local file_info = get_current_filetype_info()
  
  -- Restart LSP if clients exist
  local clients = get_active_lsp_clients()
  if #clients > 0 then
    colored_print(colors.yellow, "Restarting LSP clients...")
    vim.cmd("LspRestart")
    vim.defer_fn(function()
      colored_print(colors.green, "LSP clients restarted")
    end, 2000)
  end
  
  -- For Apex files, try to start apex_ls manually
  if file_info.is_salesforce then
    colored_print(colors.yellow, "Attempting to start Apex LSP for Salesforce file...")
    local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
    if lspconfig_ok and lspconfig.apex_ls then
      lspconfig.apex_ls.setup{}
      colored_print(colors.green, "Apex LSP setup attempted")
    end
  end
end

return M