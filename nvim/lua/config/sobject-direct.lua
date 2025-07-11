-- 真正的 SObject 功能实现
-- 直接加载以避免插件加载时机问题

local function setup_sobject_functionality()
  -- 检查是否已经设置过
  local keymaps = vim.api.nvim_get_keymap('n')
  for _, keymap in ipairs(keymaps) do
    if keymap.lhs == '<leader>so' then
      return -- 已经设置过了
    end
  end
  
  -- 获取当前光标下的单词
  local function get_current_word()
    return vim.fn.expand("<cword>")
  end
  
  -- 检查是否在 Salesforce 项目中
  local function is_salesforce_project()
    local sfdx_project = vim.fn.findfile("sfdx-project.json", vim.fn.getcwd() .. ";")
    return sfdx_project ~= ""
  end
  
  -- 执行 SFDX 命令
  local function exec_sfdx_command(cmd)
    if not is_salesforce_project() then
      return nil
    end
    
    local handle = io.popen(cmd .. " 2>/dev/null")
    if not handle then
      return nil
    end
    
    local result = handle:read("*a")
    local success = handle:close()
    
    if not success then
      return nil
    end
    
    return result
  end
  
  -- 完整的演示数据（当不在 Salesforce 项目中时使用）
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
          { name = "BillingAddress", type = "address", label = "Billing Address" },
          { name = "Website", type = "url", label = "Website" },
          { name = "AnnualRevenue", type = "currency", label = "Annual Revenue", precision = 18, scale = 2 },
          { name = "NumberOfEmployees", type = "int", label = "Employees" },
          { name = "Description", type = "textarea", label = "Description", length = 32000 },
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
          { name = "Title", type = "string", label = "Title", length = 128 },
          { name = "Department", type = "string", label = "Department", length = 80 },
          { name = "LeadSource", type = "picklist", label = "Lead Source",
            picklistValues = {
              { value = "Web", active = true, defaultValue = false },
              { value = "Email", active = true, defaultValue = false },
              { value = "Phone Inquiry", active = true, defaultValue = false },
              { value = "Partner Referral", active = true, defaultValue = false },
            }
          },
          { name = "Birthdate", type = "date", label = "Birthdate" },
          { name = "MailingAddress", type = "address", label = "Mailing Address" },
        }
      },
      Opportunity = {
        name = "Opportunity",
        label = "Opportunity",
        queryable = true,
        createable = true,
        updateable = true,
        deletable = true,
        fields = {
          { name = "Id", type = "id", label = "Opportunity ID", required = false },
          { name = "Name", type = "string", label = "Opportunity Name", required = true, length = 120 },
          { name = "AccountId", type = "reference", label = "Account ID", referenceTo = {"Account"} },
          { name = "StageName", type = "picklist", label = "Stage", required = true,
            picklistValues = {
              { value = "Prospecting", active = true, defaultValue = true },
              { value = "Qualification", active = true, defaultValue = false },
              { value = "Needs Analysis", active = true, defaultValue = false },
              { value = "Value Proposition", active = true, defaultValue = false },
              { value = "Proposal/Price Quote", active = true, defaultValue = false },
              { value = "Negotiation/Review", active = true, defaultValue = false },
              { value = "Closed Won", active = true, defaultValue = false },
              { value = "Closed Lost", active = true, defaultValue = false },
            }
          },
          { name = "CloseDate", type = "date", label = "Close Date", required = true },
          { name = "Amount", type = "currency", label = "Amount", precision = 18, scale = 2 },
          { name = "Probability", type = "percent", label = "Probability" },
          { name = "Type", type = "picklist", label = "Type",
            picklistValues = {
              { value = "Existing Customer - Upgrade", active = true, defaultValue = false },
              { value = "Existing Customer - Replacement", active = true, defaultValue = false },
              { value = "New Customer", active = true, defaultValue = false },
            }
          },
          { name = "LeadSource", type = "picklist", label = "Lead Source",
            picklistValues = {
              { value = "Web", active = true, defaultValue = false },
              { value = "Email", active = true, defaultValue = false },
              { value = "Partner Referral", active = true, defaultValue = false },
            }
          },
          { name = "Description", type = "textarea", label = "Description", length = 32000 },
        }
      },
      Lead = {
        name = "Lead",
        label = "Lead",
        queryable = true,
        createable = true,
        updateable = true,
        deletable = true,
        fields = {
          { name = "Id", type = "id", label = "Lead ID", required = false },
          { name = "FirstName", type = "string", label = "First Name", length = 40 },
          { name = "LastName", type = "string", label = "Last Name", required = true, length = 80 },
          { name = "Company", type = "string", label = "Company", required = true, length = 255 },
          { name = "Email", type = "email", label = "Email", length = 80 },
          { name = "Phone", type = "phone", label = "Phone", length = 40 },
          { name = "Status", type = "picklist", label = "Lead Status", required = true,
            picklistValues = {
              { value = "Open - Not Contacted", active = true, defaultValue = true },
              { value = "Working - Contacted", active = true, defaultValue = false },
              { value = "Closed - Converted", active = true, defaultValue = false },
              { value = "Closed - Not Converted", active = true, defaultValue = false },
            }
          },
          { name = "LeadSource", type = "picklist", label = "Lead Source",
            picklistValues = {
              { value = "Web", active = true, defaultValue = false },
              { value = "Email", active = true, defaultValue = false },
              { value = "Phone Inquiry", active = true, defaultValue = false },
            }
          },
          { name = "Industry", type = "picklist", label = "Industry",
            picklistValues = {
              { value = "Technology", active = true, defaultValue = false },
              { value = "Healthcare", active = true, defaultValue = false },
              { value = "Financial Services", active = true, defaultValue = false },
            }
          },
          { name = "Title", type = "string", label = "Title", length = 128 },
          { name = "Address", type = "address", label = "Address" },
          { name = "Description", type = "textarea", label = "Description", length = 32000 },
        }
      },
      Case = {
        name = "Case",
        label = "Case",
        queryable = true,
        createable = true,
        updateable = true,
        deletable = true,
        fields = {
          { name = "Id", type = "id", label = "Case ID", required = false },
          { name = "CaseNumber", type = "string", label = "Case Number", required = false },
          { name = "Subject", type = "string", label = "Subject", length = 255 },
          { name = "Status", type = "picklist", label = "Status", required = true,
            picklistValues = {
              { value = "New", active = true, defaultValue = true },
              { value = "Working", active = true, defaultValue = false },
              { value = "Escalated", active = true, defaultValue = false },
              { value = "Closed", active = true, defaultValue = false },
            }
          },
          { name = "Priority", type = "picklist", label = "Priority", required = true,
            picklistValues = {
              { value = "High", active = true, defaultValue = false },
              { value = "Medium", active = true, defaultValue = true },
              { value = "Low", active = true, defaultValue = false },
            }
          },
          { name = "Origin", type = "picklist", label = "Case Origin",
            picklistValues = {
              { value = "Email", active = true, defaultValue = false },
              { value = "Phone", active = true, defaultValue = false },
              { value = "Web", active = true, defaultValue = false },
            }
          },
          { name = "AccountId", type = "reference", label = "Account ID", referenceTo = {"Account"} },
          { name = "ContactId", type = "reference", label = "Contact ID", referenceTo = {"Contact"} },
          { name = "Description", type = "textarea", label = "Description", length = 32000 },
        }
      }
    }
    
    -- 处理自定义对象模式
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
  
  -- 格式化字段详细信息
  local function format_field_details(field)
    local details = {}
    
    -- 基本字段信息
    local basic_info = string.format("%-25s %-12s %s", 
      field.name or "N/A",
      field.type or "N/A", 
      field.label or "N/A"
    )
    table.insert(details, basic_info)
    
    -- 附加字段属性
    local props = {}
    if field.required then table.insert(props, "Required") end
    if field.unique then table.insert(props, "Unique") end
    if field.externalId then table.insert(props, "External ID") end
    if field.encrypted then table.insert(props, "Encrypted") end
    
    if #props > 0 then
      table.insert(details, string.format("  Properties: %s", table.concat(props, ", ")))
    end
    
    -- 查找字段详细信息
    if field.type == "reference" and field.referenceTo then
      local lookup_targets = table.concat(field.referenceTo, ", ")
      table.insert(details, string.format("  → Lookup to: %s", lookup_targets))
    end
    
    -- 选择列表值
    if field.type == "picklist" or field.type == "multipicklist" then
      if field.picklistValues and #field.picklistValues > 0 then
        table.insert(details, "  Values:")
        for i, picklistValue in ipairs(field.picklistValues) do
          if i <= 8 then -- 限制显示前8个值
            local active_mark = picklistValue.active and "✓" or "✗"
            local default_mark = picklistValue.defaultValue and " (default)" or ""
            table.insert(details, string.format("    %s %s%s", 
              active_mark, picklistValue.value, default_mark))
          elseif i == 9 then
            table.insert(details, string.format("    ... and %d more values", #field.picklistValues - 8))
            break
          end
        end
      end
    end
    
    -- 长度/精度信息
    if field.length and field.length > 0 then
      table.insert(details, string.format("  Max Length: %d", field.length))
    end
    if field.precision and field.precision > 0 then
      local scale_info = field.scale and field.scale > 0 and string.format(",%d", field.scale) or ""
      table.insert(details, string.format("  Precision: %d%s", field.precision, scale_info))
    end
    
    -- 帮助文本
    if field.inlineHelpText and field.inlineHelpText ~= "" then
      table.insert(details, string.format("  Help: %s", field.inlineHelpText))
    end
    
    return details
  end
  
  -- 显示 SObject 定义的浮动窗口
  local function show_sobject_definition(sobject_name, target_field)
    local sobject = nil
    
    -- 首先尝试获取真实数据
    if is_salesforce_project() then
      local cmd = string.format("sf sobject describe --sobject %s --json", sobject_name)
      local result = exec_sfdx_command(cmd)
      
      if result then
        local success, data = pcall(vim.json.decode, result)
        if success and data.status == 0 then
          sobject = data.result
        end
      end
    end
    
    -- 回退到演示数据
    if not sobject then
      sobject = get_demo_sobject_data(sobject_name)
      if not sobject then
        vim.notify("SObject not found: " .. sobject_name, vim.log.levels.WARN)
        return
      end
      if not is_salesforce_project() then
        vim.notify("Using demo data for " .. sobject_name, vim.log.levels.INFO)
      end
    end
    
    -- 创建缓冲区内容
    local lines = {}
    local field_line_map = {} -- 跟踪每个字段的行号
    
    -- 头部信息
    table.insert(lines, "╭─ SObject Definition ─────────────────────────────────────────────────╮")
    table.insert(lines, string.format("│ %-68s │", "SObject: " .. sobject.name))
    table.insert(lines, string.format("│ %-68s │", "Label: " .. (sobject.label or "N/A")))
    table.insert(lines, string.format("│ %-68s │", "API Name: " .. (sobject.name or "N/A")))
    
    -- 权限信息
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
    
    -- 字段详细信息
    if sobject.fields then
      for _, field in ipairs(sobject.fields) do
        local field_start_line = #lines + 1
        field_line_map[field.name] = field_start_line
        
        local field_details = format_field_details(field)
        for _, detail_line in ipairs(field_details) do
          table.insert(lines, detail_line)
        end
        table.insert(lines, "") -- 字段之间的空行
      end
    end
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'salesforce-object')
    
    -- 窗口选项 - 使用大部分屏幕以获得更好的可读性
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
    
    -- 跳转到特定字段
    if target_field and field_line_map[target_field] then
      vim.api.nvim_win_set_cursor(win, {field_line_map[target_field], 0})
      -- 高亮目标字段行
      vim.api.nvim_buf_add_highlight(buf, -1, "Search", field_line_map[target_field] - 1, 0, -1)
    end
    
    -- 增强的键映射
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
  end
  
  -- 解析上下文以确定是否查看对象或字段
  local function parse_sobject_context()
    local word = get_current_word()
    if not word or word == "" then
      return nil, nil
    end
    
    -- 获取当前行上下文
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    
    -- SObject.Field 引用的常见模式
    local patterns = {
      -- 直接字段访问：Account.Name, Contact.Email
      "(%w+)%.(%w+)",
      -- SOQL 查询：SELECT Name FROM Account, WHERE Account.Name
      "FROM%s+(%w+)",
      "(%w+)%.(%w+)%s*[,=<>!]",
      -- 变量声明：Account acc, Contact con
      "(%w+)%s+%w+%s*[=;]",
      -- 构造函数调用：new Account(), new Contact()
      "new%s+(%w+)%s*%(",
    }
    
    -- 首先尝试查找 SObject.Field 模式
    for _, pattern in ipairs(patterns) do
      for sobject, field in line:gmatch(pattern) do
        -- 检查光标是在 sobject 还是 field 部分
        local sobject_start, sobject_end = line:find(sobject, 1, true)
        local field_start, field_end = nil, nil
        
        if field then
          field_start, field_end = line:find(field, sobject_end + 1, true)
        end
        
        -- 确定光标在什么上面
        if sobject_start and sobject_end and col >= sobject_start - 1 and col <= sobject_end then
          -- 光标在 SObject 名称上
          return sobject, nil
        elseif field_start and field_end and col >= field_start - 1 and col <= field_end then
          -- 光标在字段名称上
          return sobject, field
        end
      end
    end
    
    -- 检查光标下的单词是否看起来像已知的 SObject
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
    
    -- 检查是否为自定义对象（以 __c 结尾）
    if word:match("__c$") then
      return word, nil
    end
    
    -- 回退：将单词视为潜在的 SObject
    return word, nil
  end
  
  -- 带上下文感知的增强查找
  local function smart_sobject_lookup()
    local sobject, field = parse_sobject_context()
    
    if not sobject then
      vim.notify("No SObject found under cursor", vim.log.levels.WARN)
      return
    end
    
    if field then
      show_sobject_definition(sobject, field)
    else
      show_sobject_definition(sobject)
    end
  end
  
  -- Telescope 集成（如果可用）
  local function telescope_sobject_picker()
    local telescope_ok, telescope = pcall(require, "telescope")
    if not telescope_ok then
      vim.notify("Telescope not available", vim.log.levels.WARN)
      return
    end
    
    local sobjects = {}
    
    -- 尝试从真实 SF 组织获取 SObject 列表
    if is_salesforce_project() then
      local cmd = "sf sobject list --json"
      local result = exec_sfdx_command(cmd)
      
      if result then
        local success, data = pcall(vim.json.decode, result)
        if success and data.status == 0 and data.result then
          for _, sobject in ipairs(data.result) do
            table.insert(sobjects, sobject.name)
          end
        end
      end
    end
    
    -- 回退到演示列表
    if #sobjects == 0 then
      sobjects = { 
        "Account", "Contact", "Opportunity", "Lead", "Case", "User", "Task", "Event", "Product2"
      }
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
  
  -- 设置键映射
  vim.keymap.set("n", "<leader>so", smart_sobject_lookup, { desc = "Smart SObject/Field lookup" })
  vim.keymap.set("n", "<leader>sO", telescope_sobject_picker, { desc = "Browse all SObjects" })
  vim.keymap.set("n", "<leader>sl", function()
    vim.ui.input({ prompt = "SObject name: " }, function(input)
      if input and input ~= "" then
        show_sobject_definition(input)
      end
    end)
  end, { desc = "Lookup SObject by name" })
  
  -- 创建用户命令
  vim.api.nvim_create_user_command("SObjectDescribe", function(opts)
    local args = vim.split(opts.args, "%s+")
    local sobject_name = args[1]
    local field_name = args[2]
    
    if sobject_name == "" then
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
  })
  
  vim.api.nvim_create_user_command("SObjectList", telescope_sobject_picker, {
    desc = "Browse all SObjects with Telescope"
  })
  
  vim.api.nvim_create_user_command("SObjectHelp", function()
    local help_lines = {
      "🏗️  Salesforce SObject Commands:",
      "",
      "📖 Main Commands:",
      "  :SObjectDescribe [SObject] [Field]  - Show detailed SObject definition",
      "  :SObjectList                       - Browse all SObjects",
      "",
      "⌨️  Key Mappings:",
      "  <leader>so  - Smart SObject/Field lookup (cursor context)",
      "  <leader>sO  - Browse all SObjects",
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
      "🌐 Data Sources:",
      "  • In Salesforce project: Live data from your org",
      "  • Outside SF project: Demo data for common objects",
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
end

-- 延迟设置，确保 nvim 完全启动
vim.defer_fn(setup_sobject_functionality, 100)

return {}