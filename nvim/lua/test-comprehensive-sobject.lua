-- Comprehensive test to identify the exact issue with salesforce-objects.lua
-- Run with :lua require('test-comprehensive-sobject')

local M = {}

function M.comprehensive_debug()
  print("=== Comprehensive Salesforce Objects Plugin Debug ===")
  
  -- Test 1: Check if lazy.nvim can see our plugin
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    print("✗ Cannot load lazy.nvim")
    return
  end
  
  local plugins = lazy.plugins()
  local sf_plugin = nil
  local sf_plugin_count = 0
  
  -- Count how many plugins define sf.nvim
  for _, plugin in pairs(plugins) do
    if plugin.name == "sf.nvim" then
      sf_plugin = plugin
      sf_plugin_count = sf_plugin_count + 1
    end
  end
  
  print("Plugin count for sf.nvim:", sf_plugin_count)
  
  if sf_plugin_count == 0 then
    print("✗ sf.nvim not found in lazy registry")
    return
  elseif sf_plugin_count > 1 then
    print("⚠ Multiple sf.nvim configurations detected - this could cause conflicts")
  end
  
  -- Test 2: Check plugin loading state
  print("\n=== Plugin Loading State ===")
  print("sf.nvim loaded:", sf_plugin.loaded)
  print("sf.nvim lazy:", sf_plugin.lazy)
  
  -- Test 3: Check if our salesforce-objects.lua is being processed
  print("\n=== Checking salesforce-objects.lua Processing ===")
  
  local plugin_file = vim.fn.expand("~/.config/nvim/lua/plugins/salesforce-objects.lua")
  local spec_ok, spec = pcall(dofile, plugin_file)
  
  if spec_ok and type(spec) == "table" and #spec > 0 then
    local plugin_spec = spec[1]
    print("✓ Plugin spec loads successfully")
    print("  Plugin URL:", plugin_spec[1])
    print("  Has config function:", type(plugin_spec.config) == "function")
    print("  Lazy setting:", plugin_spec.lazy)
    
    -- Check if the config can be executed
    if type(plugin_spec.config) == "function" then
      print("  Attempting to execute config function...")
      
      local config_ok, config_err = pcall(plugin_spec.config)
      if config_ok then
        print("  ✓ Config function executed successfully")
      else
        print("  ✗ Config function failed:", config_err)
      end
    end
  else
    print("✗ Plugin spec failed to load:", spec)
  end
  
  -- Test 4: Check for deleted sf.lua conflict
  print("\n=== Checking for Deleted sf.lua Conflict ===")
  
  -- Check git status for deleted sf.lua
  local git_status = vim.fn.system("git status --porcelain | grep 'sf.lua'")
  if git_status and git_status:match("D.*sf.lua") then
    print("⚠ Found deleted sf.lua file in git status")
    print("  This might cause conflicts with the new salesforce-objects.lua")
    print("  Consider cleaning up git status or restoring the file")
  else
    print("✓ No deleted sf.lua file detected")
  end
  
  -- Test 5: Check if both configurations are trying to load
  print("\n=== Checking Plugin Registration ===")
  
  -- Look for any files that might be registering sf.nvim
  local plugin_files = vim.fn.glob(vim.fn.expand("~/.config/nvim/lua/plugins/*.lua"), false, true)
  local sf_registrations = {}
  
  for _, file in ipairs(plugin_files) do
    local content = vim.fn.readfile(file)
    local file_content = table.concat(content, "\n")
    
    if file_content:match("sf%.nvim") then
      table.insert(sf_registrations, vim.fn.fnamemodify(file, ":t"))
    end
  end
  
  if #sf_registrations > 0 then
    print("Files registering sf.nvim:", table.concat(sf_registrations, ", "))
    if #sf_registrations > 1 then
      print("⚠ Multiple files registering sf.nvim - this could cause conflicts")
    end
  end
  
  -- Test 6: Manual loading test
  print("\n=== Manual Loading Test ===")
  
  -- Try to manually load sf.nvim
  local manual_load_ok, manual_load_err = pcall(function()
    return require("sf")
  end)
  
  if manual_load_ok then
    print("✓ sf.nvim can be loaded manually")
  else
    print("✗ sf.nvim cannot be loaded:", manual_load_err)
  end
  
  -- Test 7: Check final state
  print("\n=== Final State Check ===")
  
  -- Check if our keymaps exist
  local keymaps = vim.api.nvim_get_keymap('n')
  local sobject_keymaps = {}
  
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs:match('<leader>k[oOfOl]') then
      sobject_keymaps[keymap.lhs] = keymap.desc
    end
  end
  
  if next(sobject_keymaps) then
    print("✓ SObject keymaps found:")
    for lhs, desc in pairs(sobject_keymaps) do
      print("  ", lhs, "->", desc)
    end
  else
    print("✗ No SObject keymaps found")
  end
  
  -- Check if our commands exist
  local commands = vim.api.nvim_get_commands({})
  local sobject_commands = {}
  
  for name, _ in pairs(commands) do
    if name:match("^SObject") then
      table.insert(sobject_commands, name)
    end
  end
  
  if #sobject_commands > 0 then
    print("✓ SObject commands found:", table.concat(sobject_commands, ", "))
  else
    print("✗ No SObject commands found")
  end
  
  -- Test 8: Provide recommendations
  print("\n=== Recommendations ===")
  
  if sf_plugin_count == 0 then
    print("1. sf.nvim is not registered - check lazy.nvim configuration")
  elseif sf_plugin_count > 1 then
    print("1. Multiple sf.nvim registrations detected - consolidate configurations")
  end
  
  if git_status and git_status:match("D.*sf.lua") then
    print("2. Clean up deleted sf.lua file: git add nvim/lua/plugins/sf.lua && git commit")
  end
  
  if #sobject_keymaps == 0 and #sobject_commands == 0 then
    print("3. Plugin configuration not executing - check for errors in config function")
    print("4. Try manual loading: :lua require('lazy').load({ plugins = { 'sf.nvim' } })")
  end
  
  print("5. Check :messages for any error messages during startup")
  print("6. Try restarting Neovim to ensure clean plugin loading")
  
  return {
    plugin_count = sf_plugin_count,
    keymaps_found = #sobject_keymaps > 0,
    commands_found = #sobject_commands > 0,
    has_git_conflict = git_status and git_status:match("D.*sf.lua") ~= nil
  }
end

-- Auto-run the comprehensive debug
M.comprehensive_debug()

return M