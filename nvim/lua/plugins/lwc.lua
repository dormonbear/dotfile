return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      lwc_ls = {
        cmd = { "lwc-language-server", "--stdio" },
        filetypes = { "html", "javascript" },
        root_dir = require("lspconfig/util").find_git_ancestor,
      },
    },
  },
}
