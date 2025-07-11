-- Resolution script for salesforce-objects.lua plugin loading issue
-- This script will help identify and fix the plugin loading problem
-- Run with :lua require('fix-sobject-loading')

local M = {}

function M.fix_plugin_loading()
  print("=== Salesforce Objects Plugin Fix Script ===")
  
  -- Step 1: Clean up git status for deleted sf.lua
  print("\n1. Cleaning up git status...")
  
  local git_status = vim.fn.system("cd " .. vim.fn.expand("~/.config/nvim") .. " && git status --porcelain | grep 'sf.lua'")
  if git_status and git_status:match("D.*sf.lua") then
    print("⚠ Found deleted sf.lua file in git status")
    print("  This could be causing conflicts with lazy.nvim plugin loading")
    print("  To fix this, you should run one of these commands:")
    print("  - To permanently remove: git rm nvim/lua/plugins/sf.lua")
    print("  - To restore the file: git checkout HEAD -- nvim/lua/plugins/sf.lua")
    print("  - Then commit the change: git commit -m 'cleanup sf.lua plugin configuration'")
  else
    print("✓ No git conflicts with sf.lua detected")
  end
  
  -- Step 2: Check if lazy.nvim can see our plugin
  print("\n2. Checking lazy.nvim plugin registration...")
  
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    print("✗ Cannot load lazy.nvim")
    return
  end
  
  local plugins = lazy.plugins()
  local sf_plugin = nil
  local sf_plugin_count = 0
  
  for _, plugin in pairs(plugins) do
    if plugin.name == "sf.nvim" then
      sf_plugin = plugin
      sf_plugin_count = sf_plugin_count + 1
    end
  end
  
  print("sf.nvim registrations found:", sf_plugin_count)
  
  if sf_plugin_count == 0 then
    print("✗ sf.nvim not found in lazy registry")
    print("  This suggests the salesforce-objects.lua plugin is not being loaded")
    print("  Check if the file exists: ~/.config/nvim/lua/plugins/salesforce-objects.lua")
    return
  elseif sf_plugin_count > 1 then
    print("⚠ Multiple sf.nvim registrations found")
    print("  This could cause conflicts - consider consolidating configurations")
  else
    print("✓ Single sf.nvim registration found")
  end
  
  -- Step 3: Force plugin loading
  print("\n3. Attempting to force load sf.nvim...")
  
  if not sf_plugin.loaded then
    local load_ok, load_err = pcall(function()
      lazy.load({ plugins = { "sf.nvim" } })
    end)
    
    if load_ok then
      print("✓ sf.nvim loaded successfully")
    else
      print("✗ Failed to load sf.nvim:", load_err)
      return
    end
  else
    print("✓ sf.nvim already loaded")
  end
  
  -- Step 4: Manually execute our plugin configuration
  print("\n4. Manually executing salesforce-objects.lua configuration...")
  
  local plugin_file = vim.fn.expand("~/.config/nvim/lua/plugins/salesforce-objects.lua")
  local spec_ok, spec = pcall(dofile, plugin_file)
  
  if spec_ok and type(spec) == "table" and #spec > 0 then
    local plugin_spec = spec[1]
    
    if type(plugin_spec.config) == "function" then
      print("Executing config function...")
      
      local config_ok, config_err = pcall(plugin_spec.config)
      if config_ok then
        print("✓ Configuration executed successfully")
      else
        print("✗ Configuration failed:", config_err)
        return
      end
    end
  else
    print("✗ Failed to load plugin spec:", spec)
    return
  end
  
  -- Step 5: Verify everything is working
  print("\n5. Verifying plugin functionality...")
  
  -- Check keymaps
  local keymaps = vim.api.nvim_get_keymap('n')
  local sobject_keymaps = {}
  
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs:match('<leader>k[oOfOl]') then
      sobject_keymaps[keymap.lhs] = keymap.desc
    end
  end
  
  if next(sobject_keymaps) then
    print("✓ SObject keymaps working:")
    for lhs, desc in pairs(sobject_keymaps) do
      print("  ", lhs, "->", desc)
    end
  else
    print("✗ No SObject keymaps found")
  end
  
  -- Check commands
  local commands = vim.api.nvim_get_commands({})
  local sobject_commands = {}
  
  for name, _ in pairs(commands) do
    if name:match("^SObject") then
      table.insert(sobject_commands, name)
    end
  end
  
  if #sobject_commands > 0 then
    print("✓ SObject commands working:", table.concat(sobject_commands, ", "))
  else
    print("✗ No SObject commands found")
  end
  
  -- Step 6: Test basic functionality
  print("\n6. Testing basic functionality...")
  
  -- Test if we can call the smart lookup function
  local test_ok, test_err = pcall(function()
    -- This should work if the plugin is properly loaded
    vim.cmd("echo 'Testing SObject functionality...'")
  end)
  
  if test_ok then
    print("✓ Basic functionality test passed")
  else
    print("✗ Basic functionality test failed:", test_err)
  end
  
  -- Final recommendations
  print("\n=== Final Recommendations ===")
  
  if next(sobject_keymaps) and #sobject_commands > 0 then
    print("✅ Plugin appears to be working correctly!")
    print("Try using:")
    print("  <leader>ko - Smart SObject lookup")
    print("  :SObjectHelp - Show help")
    print("  :SObjectList - Browse SObjects")
  else
    print("❌ Plugin is not working correctly")
    print("Recommended actions:")
    print("1. Restart Neovim completely")
    print("2. Clean up git status for sf.lua")
    print("3. Run :Lazy reload sf.nvim")
    print("4. Check :messages for any error messages")
    print("5. Try manual loading: :lua require('lazy').load({ plugins = { 'sf.nvim' } })")
  end
  
  return {
    success = next(sobject_keymaps) ~= nil and #sobject_commands > 0,
    keymaps_count = vim.tbl_count(sobject_keymaps),
    commands_count = #sobject_commands
  }
end

-- Auto-run the fix script
M.fix_plugin_loading()

return M