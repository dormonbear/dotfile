-- File type detection for Salesforce files
vim.filetype.add({
  extension = {
    cls = 'apex',
    trigger = 'apex',
    page = 'visualforce',
    component = 'visualforce',
    app = 'xml',
    object = 'xml',
    workflow = 'xml',
    approvalProcess = 'xml',
    soql = 'soql',
    sosl = 'sosl',
  },
  filename = {
    ['sfdx-project.json'] = 'json',
    ['.forceignore'] = 'gitignore',
  },
  pattern = {
    ['.*%.soql$'] = 'soql',
    ['.*%.sosl$'] = 'sosl',
  },
})

-- Auto commands for Salesforce development
vim.api.nvim_create_augroup('SalesforceFileType', { clear = true })

-- Set specific options for Apex files
vim.api.nvim_create_autocmd('FileType', {
  group = 'SalesforceFileType',
  pattern = 'apex',
  callback = function()
    vim.bo.commentstring = '// %s'
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = true
  end,
})

-- Set specific options for SOQL/SOSL files
vim.api.nvim_create_autocmd('FileType', {
  group = 'SalesforceFileType',
  pattern = { 'soql', 'sosl' },
  callback = function()
    vim.bo.commentstring = '-- %s'
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})

-- Set specific options for Visualforce files
vim.api.nvim_create_autocmd('FileType', {
  group = 'SalesforceFileType',
  pattern = 'visualforce',
  callback = function()
    vim.bo.commentstring = '<!-- %s -->'
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
    -- Ensure treesitter highlighting is enabled
    vim.cmd([[TSBufEnable highlight]])
  end,
}) 