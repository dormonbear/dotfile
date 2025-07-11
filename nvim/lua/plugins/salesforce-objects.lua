return {
  {
    "xixiaofinland/sf.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    lazy = false, -- Load immediately
    priority = 1000, -- High priority to load early
    config = function()
      -- Original sf.nvim configuration
      require("sf").setup({
        enable_hotkeys = false,
        fetch_org_list_at_nvim_start = true,
        types_to_retrieve = {
          "ApexClass",
          "ApexTrigger", 
          "StaticResource",
          "LightningComponentBundle",
        },
        term_config = {
          blend = 10,
          dimensions = {
            height = 0.4,
            width = 0.8,
            x = 0.5,
            y = 0.9,
          },
        },
        default_dir = "/force-app/main/default/",
        plugin_folder_name = "/sf_cache/",
        auto_display_code_sign = true,
        code_sign_highlight = {
          covered = { fg = "#b7f071" },
          uncovered = { fg = "#f07178" },
        },
      })

      -- Salesforce Object Definition Functions
      local M = {}

      -- Get current word under cursor
      local function get_current_word()
        return vim.fn.expand("<cword>")
      end

      -- Check if we're in a Salesforce project
      local function is_salesforce_project()
        local sfdx_project = vim.fn.findfile("sfdx-project.json", vim.fn.getcwd() .. ";")
        return sfdx_project ~= ""
      end

      -- Execute SFDX command and return result
      local function exec_sfdx_command(cmd)
        if not is_salesforce_project() then
          vim.notify("Not in a Salesforce project - using demo mode", vim.log.levels.WARN)
          return nil
        end
        
        local handle = io.popen(cmd .. " 2>/dev/null")
        if not handle then
          vim.notify("Failed to execute command: " .. cmd, vim.log.levels.ERROR)
          return nil
        end
        
        local result = handle:read("*a")
        local success = handle:close()
        
        if not success then
          vim.notify("Command failed: " .. cmd, vim.log.levels.ERROR)
          return nil
        end
        
        return result
      end

      -- Demo SObject data for testing when not in a Salesforce project
      local function get_demo_sobject_data(sobject_name)
        local demo_data = {
          Account = {
            name = "Account",
            label = "Account", 
            queryable = true,
            createable = true,
            updateable = true,
            deletable = true,
            fields = {
              { name = "Id", type = "id", label = "Account ID", required = false },
              { name = "Name", type = "string", label = "Account Name", required = true, length = 255 },
              { name = "Type", type = "picklist", label = "Account Type", 
                picklistValues = {
                  { value = "Prospect", active = true, defaultValue = true },
                  { value = "Customer - Direct", active = true, defaultValue = false },
                  { value = "Customer - Channel", active = true, defaultValue = false },
                  { value = "Installation Partner", active = false, defaultValue = false },
                }
              },
              { name = "ParentId", type = "reference", label = "Parent Account", referenceTo = {"Account"} },
              { name = "Phone", type = "phone", label = "Account Phone", length = 40 },
              { name = "Industry", type = "picklist", label = "Industry",
                picklistValues = {
                  { value = "Technology", active = true, defaultValue = false },
                  { value = "Healthcare", active = true, defaultValue = false },
                  { value = "Financial Services", active = true, defaultValue = false },
                }
              },
            }
          },
          Contact = {
            name = "Contact",
            label = "Contact",
            queryable = true,
            createable = true,
            updateable = true,
            deletable = true,
            fields = {
              { name = "Id", type = "id", label = "Contact ID", required = false },
              { name = "FirstName", type = "string", label = "First Name", length = 40 },
              { name = "LastName", type = "string", label = "Last Name", required = true, length = 80 },
              { name = "Email", type = "email", label = "Email", length = 80, unique = true },
              { name = "AccountId", type = "reference", label = "Account ID", referenceTo = {"Account"} },
              { name = "Phone", type = "phone", label = "Business Phone", length = 40 },
              { name = "MobilePhone", type = "phone", label = "Mobile Phone", length = 40 },
            }
          },
          -- Custom Objects Examples
          ["CustomProject__c"] = {
            name = "CustomProject__c",
            label = "Custom Project",
            queryable = true,
            createable = true,
            updateable = true,
            deletable = true,
            fields = {
              { name = "Id", type = "id", label = "Custom Project ID", required = false },
              { name = "Name", type = "string", label = "Project Name", required = true, length = 80 },
              { name = "Status__c", type = "picklist", label = "Project Status",
                picklistValues = {
                  { value = "Planning", active = true, defaultValue = true },
                  { value = "In Progress", active = true, defaultValue = false },
                  { value = "Completed", active = true, defaultValue = false },
                  { value = "On Hold", active = true, defaultValue = false },
                }
              },
              { name = "Account__c", type = "reference", label = "Related Account", referenceTo = {"Account"} },
              { name = "Start_Date__c", type = "date", label = "Start Date" },
              { name = "End_Date__c", type = "date", label = "End Date" },
              { name = "Budget__c", type = "currency", label = "Budget", precision = 18, scale = 2 },
              { name = "Description__c", type = "textarea", label = "Description", length = 32768 },
              { name = "Priority__c", type = "picklist", label = "Priority",
                picklistValues = {
                  { value = "Low", active = true, defaultValue = false },
                  { value = "Medium", active = true, defaultValue = true },
                  { value = "High", active = true, defaultValue = false },
                  { value = "Critical", active = true, defaultValue = false },
                }
              },
            }
          },
          ["Employee__c"] = {
            name = "Employee__c",
            label = "Employee",
            queryable = true,
            createable = true,
            updateable = true,
            deletable = true,
            fields = {
              { name = "Id", type = "id", label = "Employee ID", required = false },
              { name = "Name", type = "string", label = "Employee Name", required = true, length = 80 },
              { name = "Employee_ID__c", type = "string", label = "Employee ID", required = true, unique = true, externalId = true, length = 20 },
              { name = "Department__c", type = "picklist", label = "Department",
                picklistValues = {
                  { value = "Engineering", active = true, defaultValue = false },
                  { value = "Sales", active = true, defaultValue = false },
                  { value = "Marketing", active = true, defaultValue = false },
                  { value = "HR", active = true, defaultValue = false },
                  { value = "Finance", active = true, defaultValue = false },
                }
              },
              { name = "Manager__c", type = "reference", label = "Manager", referenceTo = {"Employee__c"} },
              { name = "Hire_Date__c", type = "date", label = "Hire Date", required = true },
              { name = "Salary__c", type = "currency", label = "Salary", precision = 10, scale = 2 },
              { name = "Email__c", type = "email", label = "Work Email", required = true, unique = true, length = 80 },
              { name = "Phone__c", type = "phone", label = "Work Phone", length = 40 },
              { name = "Active__c", type = "checkbox", label = "Active Employee" },
            }
          },
          ["Product_Review__c"] = {
            name = "Product_Review__c", 
            label = "Product Review",
            queryable = true,
            createable = true,
            updateable = true,
            deletable = true,
            fields = {
              { name = "Id", type = "id", label = "Review ID", required = false },
              { name = "Name", type = "string", label = "Review Title", required = true, length = 80 },
              { name = "Product__c", type = "reference", label = "Product", referenceTo = {"Product2"} },
              { name = "Reviewer__c", type = "reference", label = "Reviewer", referenceTo = {"Contact"} },
              { name = "Rating__c", type = "number", label = "Rating (1-5)", precision = 2, scale = 1 },
              { name = "Review_Text__c", type = "textarea", label = "Review", length = 32768 },
              { name = "Verified_Purchase__c", type = "checkbox", label = "Verified Purchase" },
              { name = "Review_Date__c", type = "datetime", label = "Review Date" },
              { name = "Helpful_Votes__c", type = "number", label = "Helpful Votes", precision = 18, scale = 0 },
            }
          }
        }
        
        -- Handle any custom object pattern
        if not demo_data[sobject_name] and sobject_name:match("__c$") then
          return {
            name = sobject_name,
            label = sobject_name:gsub("__c$", ""):gsub("_", " "),
            queryable = true,
            createable = true,
            updateable = true,
            deletable = true,
            fields = {
              { name = "Id", type = "id", label = "Record ID", required = false },
              { name = "Name", type = "string", label = "Name", required = true, length = 80 },
              { name = "CreatedDate", type = "datetime", label = "Created Date", required = false },
              { name = "LastModifiedDate", type = "datetime", label = "Last Modified Date", required = false },
              { name = "Custom_Field__c", type = "string", label = "Custom Field", length = 255 },
              { name = "Status__c", type = "picklist", label = "Status",
                picklistValues = {
                  { value = "Active", active = true, defaultValue = true },
                  { value = "Inactive", active = true, defaultValue = false },
                }
              },
            }
          }
        end
        
        return demo_data[sobject_name]
      end

      -- Format field details with enhanced information
      local function format_field_details(field)
        local details = {}
        
        -- Basic field info
        local basic_info = string.format("%-25s %-12s %s", 
          field.name or "N/A",
          field.type or "N/A", 
          field.label or "N/A"
        )
        table.insert(details, basic_info)
        
        -- Additional field properties
        local props = {}
        if field.required then table.insert(props, "Required") end
        if field.unique then table.insert(props, "Unique") end
        if field.externalId then table.insert(props, "External ID") end
        if field.encrypted then table.insert(props, "Encrypted") end
        
        if #props > 0 then
          table.insert(details, string.format("  Properties: %s", table.concat(props, ", ")))
        end
        
        -- Lookup field details
        if field.type == "reference" and field.referenceTo then
          local lookup_targets = table.concat(field.referenceTo, ", ")
          table.insert(details, string.format("  → Lookup to: %s", lookup_targets))
        end
        
        -- Picklist values
        if field.type == "picklist" or field.type == "multipicklist" then
          if field.picklistValues and #field.picklistValues > 0 then
            table.insert(details, "  Values:")
            for i, picklistValue in ipairs(field.picklistValues) do
              if i <= 10 then -- Limit to first 10 values
                local active_mark = picklistValue.active and "✓" or "✗"
                local default_mark = picklistValue.defaultValue and " (default)" or ""
                table.insert(details, string.format("    %s %s%s", 
                  active_mark, picklistValue.value, default_mark))
              elseif i == 11 then
                table.insert(details, string.format("    ... and %d more values", #field.picklistValues - 10))
                break
              end
            end
          end
        end
        
        -- Length/precision for text/number fields
        if field.length and field.length > 0 then
          table.insert(details, string.format("  Max Length: %d", field.length))
        end
        if field.precision and field.precision > 0 then
          local scale_info = field.scale and field.scale > 0 and string.format(",%d", field.scale) or ""
          table.insert(details, string.format("  Precision: %d%s", field.precision, scale_info))
        end
        
        -- Help text
        if field.inlineHelpText and field.inlineHelpText ~= "" then
          table.insert(details, string.format("  Help: %s", field.inlineHelpText))
        end
        
        return details
      end

      -- Show SObject fields in a floating window with enhanced details
      local function show_sobject_definition(sobject_name, target_field)
        local sobject = nil
        
        -- Try to get real data first
        local cmd = string.format("sf sobject describe --sobject %s --json", sobject_name)
        local result = exec_sfdx_command(cmd)
        
        if result then
          local success, data = pcall(vim.json.decode, result)
          if success and data.status == 0 then
            sobject = data.result
          end
        end
        
        -- Fallback to demo data
        if not sobject then
          sobject = get_demo_sobject_data(sobject_name)
          if not sobject then
            vim.notify("SObject not found: " .. sobject_name .. " (demo mode - only Account/Contact available)", vim.log.levels.WARN)
            return
          end
          vim.notify("Using demo data for " .. sobject_name, vim.log.levels.INFO)
        end
        
        -- Create buffer content
        local lines = {}
        local field_line_map = {} -- Track line numbers for each field
        
        -- Header
        table.insert(lines, "╭─ SObject Definition ─────────────────────────────────────────────────╮")
        table.insert(lines, string.format("│ %-68s │", "SObject: " .. sobject.name))
        table.insert(lines, string.format("│ %-68s │", "Label: " .. (sobject.label or "N/A")))
        table.insert(lines, string.format("│ %-68s │", "API Name: " .. (sobject.name or "N/A")))
        
        -- Permissions in a compact format
        local perms = {}
        if sobject.queryable then table.insert(perms, "Query") end
        if sobject.createable then table.insert(perms, "Create") end
        if sobject.updateable then table.insert(perms, "Update") end
        if sobject.deletable then table.insert(perms, "Delete") end
        table.insert(lines, string.format("│ %-68s │", "Permissions: " .. table.concat(perms, ", ")))
        
        table.insert(lines, "╰──────────────────────────────────────────────────────────────────────╯")
        table.insert(lines, "")
        table.insert(lines, "Fields (" .. (#sobject.fields or 0) .. " total) - Use / to search:")
        table.insert(lines, string.rep("─", 85))
        
        -- Fields with enhanced details
        if sobject.fields then
          for _, field in ipairs(sobject.fields) do
            local field_start_line = #lines + 1
            field_line_map[field.name] = field_start_line
            
            local field_details = format_field_details(field)
            for _, detail_line in ipairs(field_details) do
              table.insert(lines, detail_line)
            end
            table.insert(lines, "") -- Empty line between fields
          end
        end
        
        -- Create floating window
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(buf, 'filetype', 'salesforce-object')
        
        -- Window options - use most of the screen for better readability
        local width = math.min(120, vim.api.nvim_get_option("columns") - 10)
        local height = math.min(#lines + 4, vim.api.nvim_get_option("lines") - 8)
        
        local opts = {
          relative = "editor",
          width = width,
          height = height,
          col = (vim.api.nvim_get_option("columns") - width) / 2,
          row = (vim.api.nvim_get_option("lines") - height) / 2,
          style = "minimal",
          border = "rounded",
          title = " SObject: " .. sobject_name .. " (Press '/' to search, 'q' to close) ",
          title_pos = "center",
        }
        
        local win = vim.api.nvim_open_win(buf, true, opts)
        
        -- Jump to specific field if requested
        if target_field and field_line_map[target_field] then
          vim.api.nvim_win_set_cursor(win, {field_line_map[target_field], 0})
          -- Highlight the target field line
          vim.api.nvim_buf_add_highlight(buf, -1, "Search", field_line_map[target_field] - 1, 0, -1)
        end
        
        -- Enhanced keymaps for the floating window
        local keymaps = {
          ["q"] = "<cmd>close<cr>",
          ["<Esc>"] = "<cmd>close<cr>",
          ["/"] = function()
            vim.cmd("normal! /")
          end,
          ["?"] = function()
            vim.cmd("normal! ?")
          end,
          ["n"] = "<cmd>normal! n<cr>",
          ["N"] = "<cmd>normal! N<cr>",
          ["*"] = "<cmd>normal! *<cr>",
          ["#"] = "<cmd>normal! #<cr>",
          ["gg"] = "<cmd>normal! gg<cr>",
          ["G"] = "<cmd>normal! G<cr>",
        }
        
        for key, action in pairs(keymaps) do
          if type(action) == "function" then
            vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
              noremap = true, 
              silent = true,
              callback = action
            })
          else
            vim.api.nvim_buf_set_keymap(buf, 'n', key, action, { noremap = true, silent = true })
          end
        end
        
        -- Enable syntax highlighting for better readability
        vim.api.nvim_buf_set_option(buf, 'syntax', 'on')
      end

      -- Get list of all SObjects in the org
      local function get_sobject_list()
        local cmd = "sf sobject list --json"
        local result = exec_sfdx_command(cmd)
        
        if result then
          local success, data = pcall(vim.json.decode, result)
          if success and data.status == 0 then
            local sobjects = {}
            if data.result then
              for _, sobject in ipairs(data.result) do
                table.insert(sobjects, sobject.name)
              end
            end
            return sobjects
          end
        end
        
        -- Fallback to demo list
        vim.notify("Using demo SObject list (includes custom objects)", vim.log.levels.INFO)
        return { 
          -- Standard Objects
          "Account", "Contact", "Opportunity", "Lead", "Case", "User", "Task", "Event", "Product2",
          -- Custom Objects  
          "CustomProject__c", "Employee__c", "Product_Review__c"
        }
      end

      -- Telescope picker for SObjects
      local function telescope_sobject_picker()
        local sobjects = get_sobject_list()
        
        if #sobjects == 0 then
          vim.notify("No SObjects found or failed to retrieve list", vim.log.levels.WARN)
          return
        end
        
        require("telescope.pickers").new({}, {
          prompt_title = "Salesforce SObjects",
          finder = require("telescope.finders").new_table({
            results = sobjects,
          }),
          sorter = require("telescope.config").values.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            require("telescope.actions").select_default:replace(function()
              require("telescope.actions").close(prompt_bufnr)
              local selection = require("telescope.actions.state").get_selected_entry()
              if selection then
                show_sobject_definition(selection[1])
              end
            end)
            return true
          end,
        }):find()
      end

      -- Find SObject definition file in .sfdx/typings
      local function find_sobject_definition_file(sobject_name)
        local patterns = {
          ".sfdx/typings/lwc/sobjects/" .. sobject_name .. ".d.ts",
          ".sfdx/typings/lwc/sobjects/" .. sobject_name:lower() .. ".d.ts",
          ".sfdx/typings/lwc/sobjects/" .. sobject_name:upper() .. ".d.ts",
        }
        
        for _, pattern in ipairs(patterns) do
          local file = vim.fn.findfile(pattern, vim.fn.getcwd() .. ";")
          if file ~= "" then
            return file
          end
        end
        
        return nil
      end

      -- Open SObject TypeScript definition file
      local function open_sobject_ts_definition(sobject_name)
        local file = find_sobject_definition_file(sobject_name)
        if file then
          vim.cmd("edit " .. file)
        else
          vim.notify("TypeScript definition file not found for: " .. sobject_name, vim.log.levels.WARN)
          -- Fallback to showing definition via SFDX
          show_sobject_definition(sobject_name)
        end
      end

      -- Parse context to determine if we're looking at an object or field
      local function parse_sobject_context()
        local word = get_current_word()
        if not word or word == "" then
          return nil, nil
        end
        
        -- Get current line context
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        
        -- Common patterns for SObject.Field references
        local patterns = {
          -- Direct field access: Account.Name, Contact.Email
          "(%w+)%.(%w+)",
          -- SOQL queries: SELECT Name FROM Account, WHERE Account.Name
          "FROM%s+(%w+)",
          "(%w+)%.(%w+)%s*[,=<>!]",
          -- Variable declarations: Account acc, Contact con
          "(%w+)%s+%w+%s*[=;]",
          -- Constructor calls: new Account(), new Contact()
          "new%s+(%w+)%s*%(",
        }
        
        -- Try to find SObject.Field pattern first
        for _, pattern in ipairs(patterns) do
          for sobject, field in line:gmatch(pattern) do
            -- Check if cursor is on the sobject or field part
            local sobject_start, sobject_end = line:find(sobject, 1, true)
            local field_start, field_end = nil, nil
            
            if field then
              field_start, field_end = line:find(field, sobject_end + 1, true)
            end
            
            -- Determine what cursor is on
            if sobject_start and sobject_end and col >= sobject_start - 1 and col <= sobject_end then
              -- Cursor is on SObject name
              return sobject, nil
            elseif field_start and field_end and col >= field_start - 1 and col <= field_end then
              -- Cursor is on field name
              return sobject, field
            end
          end
        end
        
        -- Check if word under cursor looks like a known SObject
        local known_sobjects = {
          "Account", "Contact", "Opportunity", "Lead", "Case", "User", "Profile",
          "Task", "Event", "Attachment", "Document", "Note", "ContentVersion",
          "Campaign", "CampaignMember", "Product2", "PricebookEntry", "Quote",
          "Contract", "Order", "OrderItem", "Asset", "Solution", "Article"
        }
        
        for _, sobject in ipairs(known_sobjects) do
          if word:lower() == sobject:lower() then
            return sobject, nil
          end
        end
        
        -- Check if it's a custom object (ends with __c)
        if word:match("__c$") then
          return word, nil
        end
        
        -- Fallback: treat word as potential SObject
        return word, nil
      end

      -- Enhanced lookup with context awareness
      local function smart_sobject_lookup()
        local sobject, field = parse_sobject_context()
        
        if not sobject then
          vim.notify("No SObject found under cursor", vim.log.levels.WARN)
          return
        end
        
        if field then
          vim.notify(string.format("Looking up %s.%s", sobject, field), vim.log.levels.INFO)
          show_sobject_definition(sobject, field)
        else
          vim.notify(string.format("Looking up %s", sobject), vim.log.levels.INFO)
          show_sobject_definition(sobject)
        end
      end

      -- SObject definition keymaps (always available)
      vim.notify("Setting up SObject keymaps...", vim.log.levels.INFO)
      vim.keymap.set("n", "<leader>so", smart_sobject_lookup, { desc = "Smart SObject/Field lookup" })
      vim.keymap.set("n", "<leader>sO", telescope_sobject_picker, { desc = "Browse all SObjects" })
      vim.keymap.set("n", "<leader>sf", function()
        local word = get_current_word()
        open_sobject_ts_definition(word)
      end, { desc = "SObject TypeScript definition" })
      vim.keymap.set("n", "<leader>sl", function()
        vim.ui.input({ prompt = "SObject name: " }, function(input)
          if input and input ~= "" then
            show_sobject_definition(input)
          end
        end)
      end, { desc = "Lookup SObject by name" })
      vim.notify("SObject keymaps configured", vim.log.levels.INFO)

      -- Original sf.nvim keymaps (safe loading)
      local sf_ok, Sf = pcall(require, "sf")
      if sf_ok then
        vim.keymap.set("n", "<leader>ms", Sf.set_target_org, { desc = "SF set local org" })
        vim.keymap.set("n", "<leader>mS", Sf.set_global_target_org, { desc = "SF set global org" })
        vim.keymap.set("n", "<leader>mp", Sf.save_and_push, { desc = "SF save and push" })
        vim.keymap.set("n", "<leader>mr", Sf.retrieve, { desc = "SF retrieve" })
        vim.notify("sf.nvim loaded successfully", vim.log.levels.INFO)
      else
        vim.notify("sf.nvim not available, SObject features will work independently", vim.log.levels.WARN)
      end
      
      -- Debug: Verify keymaps are set
      vim.defer_fn(function()
        local keymaps = vim.api.nvim_get_keymap('n')
        local so_keymap = nil
        for _, keymap in ipairs(keymaps) do
          if keymap.lhs == '<leader>so' then
            so_keymap = keymap
            break
          end
        end
        if so_keymap then
          vim.notify("✓ SObject keymap <leader>so is active", vim.log.levels.INFO)
        else
          vim.notify("✗ SObject keymap <leader>so not found", vim.log.levels.ERROR)
        end
      end, 1000)
      
      -- Create user commands with enhanced functionality
      vim.api.nvim_create_user_command("SObjectDescribe", function(opts)
        local args = vim.split(opts.args, "%s+")
        local sobject_name = args[1]
        local field_name = args[2]
        
        if sobject_name == "" then
          -- Use smart context parsing
          local parsed_sobject, parsed_field = parse_sobject_context()
          sobject_name = parsed_sobject
          field_name = parsed_field
        end
        
        if sobject_name then
          show_sobject_definition(sobject_name, field_name)
        else
          vim.notify("No SObject specified or found under cursor", vim.log.levels.WARN)
        end
      end, {
        nargs = "*",
        desc = "Describe SObject [field] - e.g., :SObjectDescribe Account Name",
        complete = function(arg_lead, cmd_line, cursor_pos)
          -- Basic SObject name completion
          local known_sobjects = {
            "Account", "Contact", "Opportunity", "Lead", "Case", "User", "Profile",
            "Task", "Event", "Attachment", "Document", "Note", "ContentVersion",
            "Campaign", "CampaignMember", "Product2", "PricebookEntry", "Quote",
            "Contract", "Order", "OrderItem", "Asset", "Solution", "Article"
          }
          
          local matches = {}
          for _, sobject in ipairs(known_sobjects) do
            if sobject:lower():find(arg_lead:lower(), 1, true) == 1 then
              table.insert(matches, sobject)
            end
          end
          return matches
        end
      })
      
      vim.api.nvim_create_user_command("SObjectList", telescope_sobject_picker, {
        desc = "Browse all SObjects with Telescope"
      })
      
      vim.api.nvim_create_user_command("SObjectFile", function(opts)
        local sobject_name = opts.args
        if sobject_name == "" then
          local parsed_sobject, _ = parse_sobject_context()
          sobject_name = parsed_sobject
        end
        
        if sobject_name then
          open_sobject_ts_definition(sobject_name)
        else
          vim.notify("No SObject specified or found under cursor", vim.log.levels.WARN)
        end
      end, {
        nargs = "?",
        desc = "Open SObject TypeScript definition file"
      })
      
      -- Additional utility commands
      vim.api.nvim_create_user_command("SObjectHelp", function()
        local help_lines = {
          "🏗️  Salesforce SObject Commands:",
          "",
          "📖 Main Commands:",
          "  :SObjectDescribe [SObject] [Field]  - Show detailed SObject definition",
          "  :SObjectList                       - Browse all SObjects",
          "  :SObjectFile [SObject]             - Open TypeScript definition",
          "",
          "⌨️  Key Mappings:",
          "  <leader>so  - Smart SObject/Field lookup (cursor context)",
          "  <leader>sO  - Browse all SObjects",
          "  <leader>sf  - Open TypeScript definition file",
          "  <leader>sl  - Manual SObject name input",
          "",
          "💡 Examples:",
          "  :SObjectDescribe Account           - Show Account definition",
          "  :SObjectDescribe Account Name      - Show Account definition, jump to Name field",
          "  :SObjectDescribe CustomObject__c   - Show custom object definition",
          "",
          "🔍 In Definition Window:",
          "  /           - Search fields",
          "  n / N       - Next/previous search result",
          "  * / #       - Search word under cursor",
          "  q / Esc     - Close window",
          "",
          "📝 Context-Aware Features:",
          "  • Place cursor on 'Account' → shows Account definition",
          "  • Place cursor on 'Name' in 'Account.Name' → shows Account with Name field highlighted",
          "  • Recognizes SOQL patterns, variable declarations, constructor calls",
          "",
          "For detailed documentation: ~/.config/nvim/doc/salesforce-sobject-guide.md"
        }
        
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(buf, 'filetype', 'help')
        
        local width = 80
        local height = #help_lines + 4
        
        local opts = {
          relative = "editor",
          width = width,
          height = height,
          col = (vim.api.nvim_get_option("columns") - width) / 2,
          row = (vim.api.nvim_get_option("lines") - height) / 2,
          style = "minimal",
          border = "rounded",
          title = " SObject Help ",
          title_pos = "center",
        }
        
        local win = vim.api.nvim_open_win(buf, true, opts)
        vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { noremap = true, silent = true })
      end, {
        desc = "Show SObject help and usage examples"
      })

      -- Notify successful loading
      vim.notify("Enhanced SObject plugin loaded! Try :SObjectHelp or <leader>so", vim.log.levels.INFO)
    end,
  }
} 