-- Simple test for salesforce-objects.lua plugin
print("Testing salesforce-objects.lua loading...")

local plugin_file = vim.fn.stdpath("config") .. "/lua/plugins/salesforce-objects.lua"
print("Plugin file: " .. plugin_file)
print("File exists: " .. tostring(vim.fn.filereadable(plugin_file) == 1))

-- Test loading the plugin spec
local ok, result = pcall(dofile, plugin_file)
print("Load successful: " .. tostring(ok))

if not ok then
  print("Error: " .. tostring(result))
else
  print("Plugin spec type: " .. type(result))
  if type(result) == "table" then
    print("Plugin spec has entries: " .. tostring(#result))
    if result[1] then
      print("Plugin name: " .. tostring(result[1][1] or result[1].name))
      print("Has config: " .. tostring(result[1].config ~= nil))
      print("Lazy setting: " .. tostring(result[1].lazy))
    end
  end
end

-- Test if sf.nvim can be required
print("\nTesting sf.nvim dependency...")
local sf_ok, sf_err = pcall(require, "sf")
print("sf.nvim loadable: " .. tostring(sf_ok))
if not sf_ok then
  print("sf.nvim error: " .. tostring(sf_err))
end

-- Test telescope
print("\nTesting telescope dependency...")
local telescope_ok, telescope_err = pcall(require, "telescope")
print("telescope loadable: " .. tostring(telescope_ok))
if not telescope_ok then
  print("telescope error: " .. tostring(telescope_err))
end

-- Test plenary
print("\nTesting plenary dependency...")
local plenary_ok, plenary_err = pcall(require, "plenary")
print("plenary loadable: " .. tostring(plenary_ok))
if not plenary_ok then
  print("plenary error: " .. tostring(plenary_err))
end

print("\nTest complete!")