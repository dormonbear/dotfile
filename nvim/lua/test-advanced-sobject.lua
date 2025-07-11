-- Advanced debugging script for salesforce-objects.lua
-- This checks the lazy.nvim loading process in detail
-- Run with :lua require('test-advanced-sobject')

local M = {}

function M.debug_lazy_loading()
  print("=== Advanced Salesforce Objects Plugin Debug ===")
  
  -- Get lazy.nvim instance
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    print("✗ Cannot load lazy.nvim")
    return
  end
  
  -- Get all plugins
  local plugins = lazy.plugins()
  
  -- Find our plugin
  local sf_plugin = nil
  for _, plugin in pairs(plugins) do
    if plugin.name == "sf.nvim" then
      sf_plugin = plugin
      break
    end
  end
  
  if not sf_plugin then
    print("✗ sf.nvim not found in lazy registry")
    return
  end
  
  print("✓ sf.nvim found in lazy registry")
  print("  Name:", sf_plugin.name)
  print("  URL:", sf_plugin.url)
  print("  Dir:", sf_plugin.dir)
  print("  Loaded:", sf_plugin.loaded)
  print("  Lazy:", sf_plugin.lazy)
  
  -- Check if the plugin directory exists
  if sf_plugin.dir and vim.fn.isdirectory(sf_plugin.dir) == 1 then
    print("✓ Plugin directory exists")
    
    -- Check if the plugin lua files exist
    local plugin_lua = sf_plugin.dir .. "/lua/sf.lua"
    if vim.fn.filereadable(plugin_lua) == 1 then
      print("✓ Main plugin file exists:", plugin_lua)
    else
      print("✗ Main plugin file missing:", plugin_lua)
    end
  else
    print("✗ Plugin directory missing:", sf_plugin.dir)
  end
  
  -- Check plugin loading state
  if sf_plugin.loaded then
    print("✓ Plugin is marked as loaded by lazy.nvim")
  else
    print("✗ Plugin is not loaded by lazy.nvim")
    print("  Attempting to load...")
    
    local load_ok, load_err = pcall(function()
      lazy.load({ plugins = { "sf.nvim" } })
    end)
    
    if load_ok then
      print("✓ Plugin loaded successfully")
    else
      print("✗ Plugin failed to load:", load_err)
    end
  end
  
  -- Check if our salesforce-objects.lua config is being executed
  print("\n=== Checking Plugin Configuration ===")
  
  -- Try to trace if the config function is being called
  local plugin_file = vim.fn.expand("~/.config/nvim/lua/plugins/salesforce-objects.lua")
  local config_executed = false
  
  -- Check if the plugin spec is valid
  local spec_ok, spec = pcall(dofile, plugin_file)
  if spec_ok and type(spec) == "table" and #spec > 0 then
    local plugin_spec = spec[1]
    print("✓ Plugin spec is valid")
    print("  Plugin name:", plugin_spec[1])
    print("  Has config function:", type(plugin_spec.config) == "function")
    print("  Lazy setting:", plugin_spec.lazy)
    
    -- Check if dependencies are properly specified
    if plugin_spec.dependencies then
      print("  Dependencies:")
      for _, dep in ipairs(plugin_spec.dependencies) do
        print("    -", dep)
      end
    end
  else
    print("✗ Plugin spec is invalid:", spec)
  end
  
  -- Check if the config has been executed by looking for evidence
  print("\n=== Checking Config Execution Evidence ===")
  
  -- Look for our custom keymaps
  local keymaps = vim.api.nvim_get_keymap('n')
  local custom_keymaps = {}
  
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs:match('<leader>k[oOfOl]') then
      custom_keymaps[keymap.lhs] = keymap.desc
    end
  end
  
  if next(custom_keymaps) then
    print("✓ Custom keymaps found:")
    for lhs, desc in pairs(custom_keymaps) do
      print("  ", lhs, "->", desc)
    end
    config_executed = true
  else
    print("✗ No custom keymaps found")
  end
  
  -- Look for our custom commands
  local commands = vim.api.nvim_get_commands({})
  local custom_commands = {}
  
  for name, _ in pairs(commands) do
    if name:match("^SObject") then
      table.insert(custom_commands, name)
    end
  end
  
  if #custom_commands > 0 then
    print("✓ Custom commands found:", table.concat(custom_commands, ", "))
    config_executed = true
  else
    print("✗ No custom commands found")
  end
  
  -- Final assessment
  print("\n=== Final Assessment ===")
  if config_executed then
    print("✓ Plugin configuration appears to have been executed")
    print("  The plugin should be working. Try using <leader>ko or :SObjectHelp")
  else
    print("✗ Plugin configuration does not appear to have been executed")
    print("  Possible causes:")
    print("  1. Plugin loading is delayed (lazy = true)")
    print("  2. Dependencies are not available")
    print("  3. Configuration function has errors")
    print("  4. Plugin is not being included in lazy.nvim spec")
    
    -- Suggest manual loading
    print("\nTry manual loading with:")
    print("  :lua require('lazy').load({ plugins = { 'sf.nvim' } })")
  end
  
  return config_executed
end

-- Auto-run the debug
M.debug_lazy_loading()

return M