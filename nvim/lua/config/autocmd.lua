-- ~/.config/nvim/lua/config/autocmds.lua
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.cls", "*.trigger", "*.page", "*.component" },
  callback = function()
    -- 检查是否在 Salesforce 项目中
    local is_sf_project = vim.fn.filereadable(vim.fn.getcwd() .. "/sfdx-project.json") == 1
    if is_sf_project then
      -- 启用 Salesforce 相关功能
      vim.b.is_salesforce_project = true
      -- 可以在这里添加项目特定的配置
    end
  end,
})
