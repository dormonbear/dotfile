return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      apex_ls = {
        cmd = { "apex-language-server", "--stdio" },
        filetypes = { "apex" },
        root_dir = require("lspconfig/util").find_git_ancestor,
      },
    },
  },
}
