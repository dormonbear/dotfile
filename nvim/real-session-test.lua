-- Test script to verify plugin loading and keymaps in a real neovim session
print("=== Real Session Plugin Test ===")

-- Test if the keymaps are properly set
local function test_keymaps()
  print("Testing keymaps...")
  local keymaps = vim.api.nvim_get_keymap('n')
  local sobject_keymaps = {}
  
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs:find('<leader>k') then
      table.insert(sobject_keymaps, {
        lhs = keymap.lhs,
        desc = keymap.desc or "No description"
      })
    end
  end
  
  print("Found SObject keymaps:")
  for _, keymap in ipairs(sobject_keymaps) do
    print("  " .. keymap.lhs .. " - " .. keymap.desc)
  end
  
  return #sobject_keymaps > 0
end

-- Test if user commands are available
local function test_commands()
  print("\nTesting user commands...")
  local commands = vim.api.nvim_get_commands({})
  local sobject_commands = {}
  
  for name, _ in pairs(commands) do
    if name:match("^SObject") then
      table.insert(sobject_commands, name)
    end
  end
  
  print("Found SObject commands:")
  for _, cmd in ipairs(sobject_commands) do
    print("  :" .. cmd)
  end
  
  return #sobject_commands > 0
end

-- Test if sf.nvim is actually loaded
local function test_sf_loaded()
  print("\nTesting sf.nvim loading...")
  local ok, sf = pcall(require, "sf")
  print("sf.nvim require successful: " .. tostring(ok))
  
  if ok then
    print("sf.nvim type: " .. type(sf))
    if type(sf) == "table" then
      local functions = {}
      for k, v in pairs(sf) do
        if type(v) == "function" then
          table.insert(functions, k)
        end
      end
      print("sf.nvim functions: " .. table.concat(functions, ", "))
    end
  end
  
  return ok
end

-- Run tests
local keymap_success = test_keymaps()
local command_success = test_commands()
local sf_success = test_sf_loaded()

print("\n=== Test Results ===")
print("Keymaps working: " .. tostring(keymap_success))
print("Commands working: " .. tostring(command_success))
print("sf.nvim working: " .. tostring(sf_success))

if not keymap_success or not command_success then
  print("\n=== Debugging Info ===")
  print("Check :Lazy to see if plugin is loaded")
  print("Check :messages for any errors")
  print("Plugin should be loaded automatically since lazy = false")
end