-- Test script to debug salesforce-objects.lua plugin loading
-- Run this with :lua require('test-sobject-loading')

local M = {}

function M.check_plugin_loading()
  print("=== Salesforce Objects Plugin Debug ===")
  
  -- Check if lazy.nvim has loaded the plugin
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugins = lazy.plugins()
    local sf_plugin = nil
    local salesforce_objects_plugin = nil
    
    for _, plugin in pairs(plugins) do
      if plugin.name == "sf.nvim" then
        sf_plugin = plugin
      elseif plugin.name == "salesforce-objects" then
        salesforce_objects_plugin = plugin
      end
    end
    
    print("✓ Lazy.nvim found")
    if sf_plugin then
      print("✓ sf.nvim plugin found in lazy registry")
      print("  - URL:", sf_plugin.url or "N/A")
      print("  - Loaded:", sf_plugin.loaded or false)
      print("  - Dir:", sf_plugin.dir or "N/A")
    else
      print("✗ sf.nvim plugin not found in lazy registry")
    end
    
    if salesforce_objects_plugin then
      print("✓ salesforce-objects plugin found in lazy registry")
      print("  - Loaded:", salesforce_objects_plugin.loaded or false)
    else
      print("✗ salesforce-objects plugin not found in lazy registry")
    end
  else
    print("✗ Could not load lazy.nvim")
  end
  
  -- Check if sf.nvim is loadable
  local sf_ok, sf = pcall(require, "sf")
  if sf_ok then
    print("✓ sf.nvim module can be loaded")
    print("  - Setup function exists:", type(sf.setup) == "function")
  else
    print("✗ sf.nvim module cannot be loaded:", sf)
  end
  
  -- Check if our keymaps are registered
  local keymaps = vim.api.nvim_get_keymap('n')
  local found_keymaps = {}
  
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs:match('<leader>k[oOfOl]') then
      found_keymaps[keymap.lhs] = keymap.desc or "No description"
    end
  end
  
  print("\n=== SObject Keymaps ===")
  local expected_keymaps = {
    '<leader>ko',
    '<leader>kO', 
    '<leader>kf',
    '<leader>kl'
  }
  
  for _, keymap in ipairs(expected_keymaps) do
    if found_keymaps[keymap] then
      print("✓", keymap, "->", found_keymaps[keymap])
    else
      print("✗", keymap, "-> NOT FOUND")
    end
  end
  
  -- Check if user commands are registered
  print("\n=== SObject Commands ===")
  local expected_commands = {
    'SObjectDescribe',
    'SObjectList',
    'SObjectFile',
    'SObjectHelp'
  }
  
  for _, cmd in ipairs(expected_commands) do
    local cmd_exists = pcall(vim.api.nvim_get_commands, {})
    if cmd_exists then
      local commands = vim.api.nvim_get_commands({})
      if commands[cmd] then
        print("✓", cmd, "-> EXISTS")
      else
        print("✗", cmd, "-> NOT FOUND")
      end
    end
  end
  
  -- Check plugin file exists and is readable
  local plugin_file = vim.fn.expand("~/.config/nvim/lua/plugins/salesforce-objects.lua")
  if vim.fn.filereadable(plugin_file) == 1 then
    print("✓ Plugin file exists and is readable:", plugin_file)
  else
    print("✗ Plugin file not found or not readable:", plugin_file)
  end
  
  -- Try to manually load the plugin configuration
  print("\n=== Manual Plugin Load Test ===")
  local manual_ok, manual_result = pcall(function()
    local plugin_config = dofile(plugin_file)
    return plugin_config
  end)
  
  if manual_ok then
    print("✓ Plugin file can be loaded manually")
    print("  - Type:", type(manual_result))
    if type(manual_result) == "table" then
      print("  - Contains", #manual_result, "plugin(s)")
      for i, plugin in ipairs(manual_result) do
        print("    Plugin", i, ":", plugin[1] or "Unknown")
      end
    end
  else
    print("✗ Plugin file has syntax errors:", manual_result)
  end
  
  -- Check dependencies
  print("\n=== Dependencies Check ===")
  local deps = {
    'telescope',
    'telescope.pickers',
    'telescope.finders',
    'telescope.actions',
    'telescope.actions.state',
    'telescope.config',
    'plenary'
  }
  
  for _, dep in ipairs(deps) do
    local dep_ok, _ = pcall(require, dep)
    if dep_ok then
      print("✓", dep)
    else
      print("✗", dep)
    end
  end
  
  print("\n=== Debug Summary ===")
  print("If keymaps and commands are missing, the plugin config function might not be running.")
  print("Check nvim startup messages with :messages")
  print("Try manually running the plugin with :lua require('plugins.salesforce-objects')")
end

-- Auto-run the check when this file is loaded
M.check_plugin_loading()

return M