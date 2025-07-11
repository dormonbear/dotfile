-- Apex LSP 自动连接配置
local M = {}
local apex_lsp_configured = false

function M.setup_apex_lsp()
  if apex_lsp_configured then
    return true
  end
  
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if not lspconfig_ok then
    return false
  end
  
  local jar_path = "/Users/dormonzhou/apex-jorje-lsp.jar"
  if vim.fn.filereadable(jar_path) == 0 then
    return false
  end
  
  if vim.fn.executable("java") == 0 then
    return false
  end
  
  local apex_config = {
    cmd = { "java", "-jar", jar_path },
    filetypes = { "apex" },
    root_dir = lspconfig.util.root_pattern("sfdx-project.json", ".git"),
    settings = {},
    single_file_support = true,
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end,
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  }
  
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  local has_blink, blink = pcall(require, "blink.cmp")
  
  if has_cmp then
    apex_config.capabilities = cmp_nvim_lsp.default_capabilities()
  elseif has_blink then
    apex_config.capabilities = blink.get_lsp_capabilities()
  end
  
  lspconfig.apex_ls.setup(apex_config)
  apex_lsp_configured = true
  
  return true
end

function M.auto_connect_apex_lsp()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  
  if filetype ~= "apex" then
    return
  end
  
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #clients > 0 then
    return
  end
  
  if not apex_lsp_configured then
    M.setup_apex_lsp()
  end
  
  vim.defer_fn(function()
    local clients_after = vim.lsp.get_active_clients({ bufnr = bufnr })
    if #clients_after == 0 then
      local root_dir = vim.lsp.util.root_pattern("sfdx-project.json", ".git")(vim.fn.expand("%:p:h"))
      
      vim.lsp.start({
        cmd = { "java", "-jar", "/Users/dormonzhou/apex-jorje-lsp.jar" },
        filetypes = { "apex" },
        root_dir = root_dir or vim.fn.getcwd(),
        name = "apex_ls",
        single_file_support = true,
        on_attach = function(client, buf)
          local opts = { noremap = true, silent = true, buffer = buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end
  end, 1000)
end

-- 自动连接 LSP 当打开 .cls 文件时
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = "*.cls",
  callback = function()
    vim.defer_fn(function()
      M.auto_connect_apex_lsp()
    end, 100)
  end,
  desc = "Auto connect Apex LSP when opening .cls files"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "apex",
  callback = function()
    vim.defer_fn(function()
      M.auto_connect_apex_lsp()
    end, 100)
  end,
  desc = "Auto connect Apex LSP for apex filetype"
})

-- 立即设置 LSP 配置
M.setup_apex_lsp()

return M