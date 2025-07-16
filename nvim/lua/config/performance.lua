-- Performance optimizations for large files and smooth cursor movement
-- This module automatically detects large files and disables expensive features

local M = {}

-- Configuration thresholds
local config = {
  max_filesize = 1024 * 1024, -- 1MB
  max_lines = 10000,
  disable_syntax = true,
  disable_treesitter = true,
  disable_lsp = false, -- Keep LSP but with reduced features
  disable_diagnostics = true,
  disable_folding = true,
  disable_cursorline = true,
}

-- Track which buffers have been optimized
local optimized_buffers = {}

-- Disable expensive features for large files
local function optimize_large_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  if optimized_buffers[bufnr] then
    return -- Already optimized
  end
  
  optimized_buffers[bufnr] = true
  
  -- Disable syntax highlighting
  if config.disable_syntax then
    vim.bo[bufnr].syntax = "off"
  end
  
  -- Disable treesitter
  if config.disable_treesitter then
    local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
    if ok then
      vim.b[bufnr].ts_highlight_disabled = true
    end
  end
  
  -- Buffer-local performance settings
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].undolevels = -1
  vim.wo.foldenable = not config.disable_folding
  vim.wo.foldmethod = "manual"
  vim.wo.cursorline = not config.disable_cursorline
  vim.wo.cursorcolumn = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  
  -- Disable diagnostics
  if config.disable_diagnostics then
    vim.diagnostic.disable(bufnr)
  end
  
  -- LSP optimizations (reduce features but keep basic functionality)
  if not config.disable_lsp then
    -- Disable semantic tokens for better performance
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    for _, client in ipairs(clients) do
      if client.server_capabilities.semanticTokensProvider then
        client.server_capabilities.semanticTokensProvider = nil
      end
    end
  end
  
  vim.notify(string.format("Large file detected - performance mode enabled for buffer %d", bufnr), vim.log.levels.INFO)
end

-- Check if file is large
local function is_large_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  -- Check file size
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath and filepath ~= "" then
    local stat = vim.loop.fs_stat(filepath)
    if stat and stat.size > config.max_filesize then
      return true, "filesize"
    end
  end
  
  -- Check line count
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count > config.max_lines then
    return true, "lines"
  end
  
  return false, nil
end

-- Setup automatic large file detection
function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})
  
  -- Set global performance options
  vim.opt.lazyredraw = true      -- Don't redraw during macros
  vim.opt.updatetime = 300       -- Faster completion
  vim.opt.timeoutlen = 300       -- Faster key sequence timeout
  vim.opt.redrawtime = 10000     -- Allow more time for syntax highlighting
  vim.opt.maxmempattern = 5000   -- Increase memory for pattern matching
  
  -- Auto-detect large files on buffer read
  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("LargeFileOptimization", { clear = true }),
    callback = function(args)
      local is_large, reason = is_large_file(args.buf)
      if is_large then
        optimize_large_file(args.buf)
      end
    end,
  })
  
  -- Additional optimization for insert mode
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = vim.api.nvim_create_augroup("InsertOptimization", { clear = true }),
    callback = function()
      if optimized_buffers[vim.api.nvim_get_current_buf()] then
        vim.wo.cursorline = false
        vim.wo.cursorcolumn = false
      end
    end,
  })
  
  -- Re-enable cursor line when leaving insert mode (optional)
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = vim.api.nvim_create_augroup("InsertOptimizationLeave", { clear = true }),
    callback = function()
      if not config.disable_cursorline and not optimized_buffers[vim.api.nvim_get_current_buf()] then
        vim.wo.cursorline = true
      end
    end,
  })
end

-- Manual optimization toggle
function M.toggle_optimization(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  if optimized_buffers[bufnr] then
    -- Re-enable features
    optimized_buffers[bufnr] = nil
    vim.bo[bufnr].syntax = "on"
    vim.wo.foldenable = true
    vim.wo.cursorline = true
    vim.wo.relativenumber = true
    vim.wo.signcolumn = "yes"
    vim.diagnostic.enable(bufnr)
    vim.notify("Performance mode disabled", vim.log.levels.INFO)
  else
    optimize_large_file(bufnr)
  end
end

-- Check current optimization status
function M.is_optimized(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return optimized_buffers[bufnr] ~= nil
end

-- Update configuration
function M.update_config(new_config)
  config = vim.tbl_extend("force", config, new_config)
end

return M