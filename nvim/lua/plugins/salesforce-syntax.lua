return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Define custom syntax highlighting for Salesforce object definitions
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "salesforce-object",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          
          -- Clear existing syntax
          vim.cmd("syntax clear")
          
          -- Define syntax groups
          vim.cmd("syntax match SalesforceObjectHeader /╭.*╮/")
          vim.cmd("syntax match SalesforceObjectBorder /[│├└╯╰]/")
          vim.cmd("syntax match SalesforceObjectTitle /SObject:/")
          vim.cmd("syntax match SalesforceObjectLabel /Label:/")
          vim.cmd("syntax match SalesforceObjectAPI /API Name:/")
          vim.cmd("syntax match SalesforceObjectPerms /Permissions:/")
          
          -- Field syntax
          vim.cmd("syntax match SalesforceFieldName /^[A-Za-z][A-Za-z0-9_]*\\s\\+/")
          vim.cmd("syntax match SalesforceFieldType /\\s\\+\\w\\+\\s\\+/")
          vim.cmd("syntax match SalesforceFieldProperty /Properties:/")
          vim.cmd("syntax match SalesforceFieldLookup /→ Lookup to:/")
          vim.cmd("syntax match SalesforceFieldValues /Values:/")
          vim.cmd("syntax match SalesforceFieldLength /Max Length:/")
          vim.cmd("syntax match SalesforceFieldPrecision /Precision:/")
          vim.cmd("syntax match SalesforceFieldHelp /Help:/")
          
          -- Picklist values
          vim.cmd("syntax match SalesforcePicklistActive /✓/")
          vim.cmd("syntax match SalesforcePicklistInactive /✗/")
          vim.cmd("syntax match SalesforcePicklistDefault /(default)/")
          
          -- Properties
          vim.cmd("syntax keyword SalesforceRequired Required")
          vim.cmd("syntax keyword SalesforceUnique Unique")
          vim.cmd("syntax keyword SalesforceExternal External")
          vim.cmd("syntax keyword SalesforceEncrypted Encrypted")
          
          -- Permissions
          vim.cmd("syntax keyword SalesforcePermQuery Query")
          vim.cmd("syntax keyword SalesforcePermCreate Create")
          vim.cmd("syntax keyword SalesforcePermUpdate Update")
          vim.cmd("syntax keyword SalesforcePermDelete Delete")
          
          -- Apply highlighting
          vim.cmd("highlight SalesforceObjectHeader ctermfg=cyan guifg=#89b4fa")
          vim.cmd("highlight SalesforceObjectBorder ctermfg=blue guifg=#74c7ec")
          vim.cmd("highlight SalesforceObjectTitle ctermfg=yellow guifg=#f9e2af cterm=bold gui=bold")
          vim.cmd("highlight SalesforceObjectLabel ctermfg=green guifg=#a6e3a1")
          vim.cmd("highlight SalesforceObjectAPI ctermfg=magenta guifg=#cba6f7")
          vim.cmd("highlight SalesforceObjectPerms ctermfg=cyan guifg=#94e2d5")
          
          vim.cmd("highlight SalesforceFieldName ctermfg=white guifg=#cdd6f4 cterm=bold gui=bold")
          vim.cmd("highlight SalesforceFieldType ctermfg=blue guifg=#89b4fa")
          vim.cmd("highlight SalesforceFieldProperty ctermfg=yellow guifg=#f9e2af")
          vim.cmd("highlight SalesforceFieldLookup ctermfg=magenta guifg=#cba6f7")
          vim.cmd("highlight SalesforceFieldValues ctermfg=green guifg=#a6e3a1")
          vim.cmd("highlight SalesforceFieldLength ctermfg=cyan guifg=#94e2d5")
          vim.cmd("highlight SalesforceFieldPrecision ctermfg=cyan guifg=#94e2d5")
          vim.cmd("highlight SalesforceFieldHelp ctermfg=gray guifg=#6c7086")
          
          vim.cmd("highlight SalesforcePicklistActive ctermfg=green guifg=#a6e3a1")
          vim.cmd("highlight SalesforcePicklistInactive ctermfg=red guifg=#f38ba8")
          vim.cmd("highlight SalesforcePicklistDefault ctermfg=yellow guifg=#f9e2af")
          
          vim.cmd("highlight SalesforceRequired ctermfg=red guifg=#f38ba8 cterm=bold gui=bold")
          vim.cmd("highlight SalesforceUnique ctermfg=blue guifg=#89b4fa cterm=bold gui=bold")
          vim.cmd("highlight SalesforceExternal ctermfg=magenta guifg=#cba6f7 cterm=bold gui=bold")
          vim.cmd("highlight SalesforceEncrypted ctermfg=yellow guifg=#f9e2af cterm=bold gui=bold")
          
          vim.cmd("highlight SalesforcePermQuery ctermfg=green guifg=#a6e3a1")
          vim.cmd("highlight SalesforcePermCreate ctermfg=blue guifg=#89b4fa")
          vim.cmd("highlight SalesforcePermUpdate ctermfg=yellow guifg=#f9e2af")
          vim.cmd("highlight SalesforcePermDelete ctermfg=red guifg=#f38ba8")
        end,
      })
    end,
  }
} 