-- Test script for debugging salesforce-objects.lua plugin loading
-- Run this with :luafile test-salesforce-plugin.lua

local function test_plugin_loading()
  print("=== Salesforce Objects Plugin Debug Test ===")
  
  -- Test 1: Check if LazyVim is loaded
  local lazy_ok, lazy = pcall(require, "lazy")
  print("1. LazyVim loaded:", lazy_ok)
  
  -- Test 2: Check if sf.nvim is installed and loaded
  local sf_ok, sf = pcall(require, "sf")
  print("2. sf.nvim loaded:", sf_ok)
  if not sf_ok then
    print("   Error:", sf)
  end
  
  -- Test 3: Check if telescope is available
  local telescope_ok, telescope = pcall(require, "telescope")
  print("3. Telescope loaded:", telescope_ok)
  
  -- Test 4: Check if plenary is available
  local plenary_ok, plenary = pcall(require, "plenary")
  print("4. Plenary loaded:", plenary_ok)
  
  -- Test 5: Try to load the salesforce-objects plugin file directly
  print("\n5. Loading salesforce-objects.lua directly...")
  local plugin_file = vim.fn.stdpath("config") .. "/lua/plugins/salesforce-objects.lua"
  print("   Plugin file path:", plugin_file)
  print("   File exists:", vim.fn.filereadable(plugin_file) == 1)
  
  -- Test 6: Try to execute the plugin config
  local config_ok, config_error = pcall(function()
    local plugin_spec = dofile(plugin_file)
    print("   Plugin spec loaded:", plugin_spec ~= nil)
    if plugin_spec and plugin_spec[1] and plugin_spec[1].config then
      print("   Plugin has config function:", type(plugin_spec[1].config) == "function")
    end
  end)
  print("   Config execution successful:", config_ok)
  if not config_ok then
    print("   Config error:", config_error)
  end
  
  -- Test 7: Check if keymaps are set
  print("\n7. Checking keymaps...")
  local keymaps = vim.api.nvim_get_keymap('n')
  local found_keymaps = {}
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs:match('<leader>k[oOfOl]') then
      table.insert(found_keymaps, keymap.lhs)
    end
  end
  print("   SObject keymaps found:", vim.inspect(found_keymaps))
  
  -- Test 8: Check if user commands are defined
  print("\n8. Checking user commands...")
  local commands = {
    "SObjectDescribe",
    "SObjectList", 
    "SObjectFile",
    "SObjectHelp"
  }
  for _, cmd in ipairs(commands) do
    local exists = pcall(function()
      vim.api.nvim_get_commands({})[cmd]
    end)
    print("   " .. cmd .. " command exists:", exists)
  end
  
  -- Test 9: Check Lazy plugin status
  if lazy_ok then
    print("\n9. Lazy plugin status...")
    local plugins = lazy.plugins()
    for name, plugin in pairs(plugins) do
      if name == "xixiaofinland/sf.nvim" then
        print("   sf.nvim plugin status:")
        print("     Loaded:", plugin._.loaded ~= nil)
        print("     Lazy:", plugin.lazy)
        if plugin._ and plugin._.loaded then
          print("     Load time:", plugin._.loaded.time)
        end
        break
      end
    end
  end
  
  -- Test 10: Check for any Lua errors in the nvim log
  print("\n10. Recent notifications (look for errors):")
  -- This will show recent notifications which might include loading errors
  vim.defer_fn(function()
    print("   Check :messages for any loading errors")
  end, 100)
  
  print("\n=== Test Complete ===")
  print("If plugin is not working:")
  print("1. Check :messages for errors")
  print("2. Try :Lazy reload xixiaofinland/sf.nvim")
  print("3. Restart Neovim")
  print("4. Check if the file is being loaded with :Lazy")
end

-- Run the test
test_plugin_loading()