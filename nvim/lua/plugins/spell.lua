return {
  {
    "kamykn/spelunker.vim",
    event = "BufRead",
    config = function()
      vim.g.spelunker_check_type = 2
      vim.g.spelunker_highlight_type = 2
      vim.g.spelunker_disable_uri_checking = 1
      vim.g.spelunker_disable_email_checking = 1
      vim.g.spelunker_disable_account_name_checking = 1
      vim.g.spelunker_disable_backquoted_checking = 1
    end,
  },
}
