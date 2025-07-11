return {
  {
    "xixiaofinland/sf.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local M = {}

      local function is_salesforce_project()
        local sfdx_project = vim.fn.findfile("sfdx-project.json", vim.fn.getcwd() .. ";")
        return sfdx_project ~= ""
      end

      local function exec_sfdx_command(cmd)
        if not is_salesforce_project() then
          vim.notify("Not in a Salesforce project", vim.log.levels.ERROR)
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

      local function execute_soql_query(query, output_format)
        output_format = output_format or "json"
        
        local escaped_query = query:gsub('"', '\\"')
        local cmd = string.format('sf data query --query "%s" --json', escaped_query)
        local result = exec_sfdx_command(cmd)
        
        if not result then
          return nil
        end
        
        local success, data = pcall(vim.json.decode, result)
        if not success then
          vim.notify("Failed to parse query result", vim.log.levels.ERROR)
          return nil
        end
        
        if data.status ~= 0 then
          local error_msg = data.message or "Unknown error executing query"
          vim.notify("Query failed: " .. error_msg, vim.log.levels.ERROR)
          return nil
        end
        
        return data.result
      end

      local function format_query_result(result)
        if not result or not result.records then
          return {"No records found"}
        end
        
        local lines = {}
        local records = result.records
        
        if #records == 0 then
          return {"No records found"}
        end
        
        local keys = {}
        for key, _ in pairs(records[1]) do
          if key ~= "attributes" then
            table.insert(keys, key)
          end
        end
        table.sort(keys)
        
        local header = "│ " .. table.concat(keys, " │ ") .. " │"
        local separator = "├" .. string.rep("─", #header - 2) .. "┤"
        
        table.insert(lines, "┌" .. string.rep("─", #header - 2) .. "┐")
        table.insert(lines, header)
        table.insert(lines, separator)
        
        for _, record in ipairs(records) do
          local values = {}
          for _, key in ipairs(keys) do
            local value = record[key]
            if value == nil then
              value = ""
            elseif type(value) == "table" then
              value = vim.inspect(value)
            else
              value = tostring(value)
            end
            table.insert(values, value)
          end
          local row = "│ " .. table.concat(values, " │ ") .. " │"
          table.insert(lines, row)
        end
        
        table.insert(lines, "└" .. string.rep("─", #header - 2) .. "┘")
        table.insert(lines, "")
        table.insert(lines, string.format("Total records: %d", #records))
        
        return lines
      end

      local function show_query_result(query, result)
        local lines = format_query_result(result)
        
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
        vim.api.nvim_buf_set_option(buf, 'filetype', 'soql-result')
        
        local width = math.min(150, vim.api.nvim_get_option("columns") - 10)
        local height = math.min(#lines + 4, vim.api.nvim_get_option("lines") - 8)
        
        local opts = {
          relative = "editor",
          width = width,
          height = height,
          col = (vim.api.nvim_get_option("columns") - width) / 2,
          row = (vim.api.nvim_get_option("lines") - height) / 2,
          style = "minimal",
          border = "rounded",
          title = " SOQL Query Result (Press 'q' to close) ",
          title_pos = "center",
        }
        
        local win = vim.api.nvim_open_win(buf, true, opts)
        
        vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<cr>', { noremap = true, silent = true })
        
        vim.api.nvim_buf_set_keymap(buf, 'n', '/', function()
          vim.cmd("normal! /")
        end, { noremap = true, silent = true })
        
        vim.api.nvim_buf_set_keymap(buf, 'n', 'n', '<cmd>normal! n<cr>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(buf, 'n', 'N', '<cmd>normal! N<cr>', { noremap = true, silent = true })
      end

      local function get_current_query()
        local current_line = vim.api.nvim_get_current_line()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local line_num = cursor_pos[1]
        
        local query_lines = {}
        local start_line = line_num
        local end_line = line_num
        
        for i = line_num, 1, -1 do
          local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
          if line:match("^%s*SELECT") then
            start_line = i
            break
          end
        end
        
        for i = line_num, vim.api.nvim_buf_line_count(0) do
          local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
          if line:match(";%s*$") then
            end_line = i
            break
          end
        end
        
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        local query = table.concat(lines, " ")
        
        query = query:gsub(";%s*$", "")
        query = query:gsub("%s+", " ")
        query = vim.trim(query)
        
        return query
      end

      local function execute_current_query()
        local query = get_current_query()
        
        if not query or query == "" then
          vim.notify("No SOQL query found", vim.log.levels.WARN)
          return
        end
        
        vim.notify("Executing query: " .. query, vim.log.levels.INFO)
        
        local result = execute_soql_query(query)
        if result then
          show_query_result(query, result)
        end
      end

      local function execute_selected_query()
        local mode = vim.api.nvim_get_mode().mode
        if mode ~= "v" and mode ~= "V" then
          vim.notify("Please select a query first", vim.log.levels.WARN)
          return
        end
        
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        
        local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
        
        if #lines == 1 then
          lines[1] = lines[1]:sub(start_pos[3], end_pos[3])
        else
          lines[1] = lines[1]:sub(start_pos[3])
          lines[#lines] = lines[#lines]:sub(1, end_pos[3])
        end
        
        local query = table.concat(lines, " ")
        query = query:gsub(";%s*$", "")
        query = query:gsub("%s+", " ")
        query = vim.trim(query)
        
        if not query or query == "" then
          vim.notify("No SOQL query selected", vim.log.levels.WARN)
          return
        end
        
        vim.notify("Executing selected query: " .. query, vim.log.levels.INFO)
        
        local result = execute_soql_query(query)
        if result then
          show_query_result(query, result)
        end
      end

      local function soql_query_prompt()
        vim.ui.input({ prompt = "SOQL Query: " }, function(query)
          if query and query ~= "" then
            vim.notify("Executing query: " .. query, vim.log.levels.INFO)
            local result = execute_soql_query(query)
            if result then
              show_query_result(query, result)
            end
          end
        end)
      end

      local function create_query_scratch_buffer()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_option(buf, 'swapfile', false)
        vim.api.nvim_buf_set_option(buf, 'filetype', 'sql')
        
        local sample_queries = {
          "-- SOQL Query Scratch Buffer",
          "-- Execute queries with <leader>sq or visual selection with <leader>sv",
          "",
          "-- Sample queries:",
          "SELECT Id, Name FROM Account LIMIT 10;",
          "",
          "SELECT Id, Name, Email FROM Contact WHERE Account.Name LIKE '%Acme%';",
          "",
          "SELECT Id, Name, StageName, Amount FROM Opportunity WHERE CloseDate = THIS_MONTH;",
          "",
          "-- Write your queries here:",
          "",
        }
        
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, sample_queries)
        vim.api.nvim_set_current_buf(buf)
      end

      local function get_sobject_fields_for_completion(sobject_name)
        local cmd = string.format("sf sobject describe --sobject %s --json", sobject_name)
        local result = exec_sfdx_command(cmd)
        
        if not result then
          return {}
        end
        
        local success, data = pcall(vim.json.decode, result)
        if not success or data.status ~= 0 then
          return {}
        end
        
        local fields = {}
        if data.result and data.result.fields then
          for _, field in ipairs(data.result.fields) do
            table.insert(fields, field.name)
          end
        end
        
        return fields
      end

      local function setup_soql_completion()
        local cmp = require('cmp')
        local source = {}
        
        source.new = function()
          return setmetatable({}, { __index = source })
        end
        
        source.get_trigger_characters = function()
          return { '.', ' ' }
        end
        
        source.complete = function(self, params, callback)
          local line = params.context.cursor_before_line
          local items = {}
          
          local soql_keywords = {
            "SELECT", "FROM", "WHERE", "ORDER BY", "GROUP BY", "HAVING", "LIMIT",
            "OFFSET", "AND", "OR", "NOT", "IN", "NOT IN", "LIKE", "INCLUDES",
            "EXCLUDES", "ASC", "DESC", "NULLS FIRST", "NULLS LAST", "COUNT",
            "AVG", "SUM", "MIN", "MAX", "COUNT_DISTINCT", "CALENDAR_MONTH",
            "CALENDAR_QUARTER", "CALENDAR_YEAR", "DAY_IN_MONTH", "DAY_IN_WEEK",
            "DAY_IN_YEAR", "DAY_ONLY", "FISCAL_MONTH", "FISCAL_QUARTER",
            "FISCAL_YEAR", "HOUR_IN_DAY", "WEEK_IN_MONTH", "WEEK_IN_YEAR",
            "THIS_MONTH", "LAST_MONTH", "NEXT_MONTH", "THIS_QUARTER",
            "LAST_QUARTER", "NEXT_QUARTER", "THIS_YEAR", "LAST_YEAR",
            "NEXT_YEAR", "THIS_WEEK", "LAST_WEEK", "NEXT_WEEK", "TODAY",
            "YESTERDAY", "TOMORROW", "LAST_N_DAYS", "NEXT_N_DAYS",
            "LAST_N_WEEKS", "NEXT_N_WEEKS", "LAST_N_MONTHS", "NEXT_N_MONTHS",
            "LAST_N_QUARTERS", "NEXT_N_QUARTERS", "LAST_N_YEARS", "NEXT_N_YEARS"
          }
          
          for _, keyword in ipairs(soql_keywords) do
            table.insert(items, {
              label = keyword,
              kind = cmp.lsp.CompletionItemKind.Keyword,
              detail = "SOQL Keyword"
            })
          end
          
          local sobject_match = line:match("FROM%s+([%w_]+)%s*$")
          if sobject_match then
            local known_sobjects = {
              "Account", "Contact", "Opportunity", "Lead", "Case", "User", "Task", "Event"
            }
            
            for _, sobject in ipairs(known_sobjects) do
              if sobject:lower():find(sobject_match:lower(), 1, true) then
                table.insert(items, {
                  label = sobject,
                  kind = cmp.lsp.CompletionItemKind.Class,
                  detail = "SObject"
                })
              end
            end
          end
          
          callback({ items = items, isIncomplete = false })
        end
        
        cmp.register_source('soql', source)
      end

      vim.keymap.set("n", "<leader>sq", execute_current_query, { desc = "Execute SOQL query under cursor" })
      vim.keymap.set("v", "<leader>sv", execute_selected_query, { desc = "Execute selected SOQL query" })
      vim.keymap.set("n", "<leader>si", soql_query_prompt, { desc = "Input and execute SOQL query" })
      vim.keymap.set("n", "<leader>ss", create_query_scratch_buffer, { desc = "Create SOQL scratch buffer" })

      vim.api.nvim_create_user_command("SOQLQuery", function(opts)
        local query = opts.args
        if query and query ~= "" then
          local result = execute_soql_query(query)
          if result then
            show_query_result(query, result)
          end
        else
          soql_query_prompt()
        end
      end, {
        nargs = "*",
        desc = "Execute SOQL query"
      })

      vim.api.nvim_create_user_command("SOQLScratch", create_query_scratch_buffer, {
        desc = "Create SOQL scratch buffer"
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "soql-result",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          
          vim.cmd("syntax clear")
          vim.cmd("syntax match SOQLResultBorder /[│├└╯╰┌┐┤]/")
          vim.cmd("syntax match SOQLResultSeparator /[─]/")
          vim.cmd("syntax match SOQLResultTotal /Total records:/")
          
          vim.cmd("highlight SOQLResultBorder ctermfg=blue guifg=#74c7ec")
          vim.cmd("highlight SOQLResultSeparator ctermfg=blue guifg=#74c7ec")
          vim.cmd("highlight SOQLResultTotal ctermfg=green guifg=#a6e3a1 cterm=bold gui=bold")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sql",
        callback = function()
          if is_salesforce_project() then
            vim.keymap.set("n", "<leader>sq", execute_current_query, { desc = "Execute SOQL query under cursor", buffer = true })
            vim.keymap.set("v", "<leader>sv", execute_selected_query, { desc = "Execute selected SOQL query", buffer = true })
          end
        end,
      })

      if pcall(require, 'cmp') then
        setup_soql_completion()
      end
    end,
  }
}