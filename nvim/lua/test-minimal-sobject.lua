-- Minimal test to isolate salesforce-objects.lua loading issues
-- Run this with :lua require('test-minimal-sobject')

local M = {}

function M.test_minimal_loading()
  print("=== Minimal SObject Plugin Test ===")
  
  -- Test 1: Check if the plugin file exists
  local plugin_path = vim.fn.expand("~/.config/nvim/lua/plugins/salesforce-objects.lua")
  print("Plugin path:", plugin_path)
  print("File exists:", vim.fn.filereadable(plugin_path) == 1)
  
  -- Test 2: Try to load the plugin file directly
  local success, result = pcall(dofile, plugin_path)
  if success then
    print("✓ Plugin file loads without syntax errors")
    print("  Type:", type(result))
    if type(result) == "table" and #result > 0 then
      print("  Plugin spec:", result[1][1] or "Unknown")
    end
  else
    print("✗ Plugin file has errors:", result)
    return false
  end
  
  -- Test 3: Check if sf.nvim dependency is available
  local sf_ok, sf_err = pcall(require, "sf")
  if sf_ok then
    print("✓ sf.nvim dependency is available")
  else
    print("✗ sf.nvim dependency error:", sf_err)
  end
  
  -- Test 4: Check if telescope is available
  local telescope_ok, telescope_err = pcall(require, "telescope")
  if telescope_ok then
    print("✓ telescope dependency is available")
  else
    print("✗ telescope dependency error:", telescope_err)
  end
  
  -- Test 5: Check if plenary is available
  local plenary_ok, plenary_err = pcall(require, "plenary")
  if plenary_ok then
    print("✓ plenary dependency is available")
  else
    print("✗ plenary dependency error:", plenary_err)
  end
  
  -- Test 6: Try to manually execute the config function
  if success and type(result) == "table" and result[1] and result[1].config then
    print("✓ Plugin has config function")
    print("Attempting to run config function...")
    
    local config_ok, config_err = pcall(result[1].config)
    if config_ok then
      print("✓ Config function executed successfully")
      
      -- Check if keymaps were created
      local keymaps = vim.api.nvim_get_keymap('n')
      local ko_found = false
      for _, keymap in ipairs(keymaps) do
        if keymap.lhs == '<leader>ko' then
          ko_found = true
          break
        end
      end
      
      if ko_found then
        print("✓ Keymaps created successfully")
      else
        print("✗ Keymaps not found after config")
      end
      
    else
      print("✗ Config function failed:", config_err)
    end
  else
    print("✗ Plugin config function not found or invalid")
  end
  
  -- Test 7: Check if user commands were created
  local commands = vim.api.nvim_get_commands({})
  local sobject_commands = {}
  for name, _ in pairs(commands) do
    if name:match("^SObject") then
      table.insert(sobject_commands, name)
    end
  end
  
  if #sobject_commands > 0 then
    print("✓ User commands created:", table.concat(sobject_commands, ", "))
  else
    print("✗ No SObject user commands found")
  end
  
  return true
end

-- Auto-run the test
M.test_minimal_loading()

return M