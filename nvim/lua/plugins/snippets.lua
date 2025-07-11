return {
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
    updateevents = "TextChanged,TextChangedI",
  },
  keys = {
    {
      "<tab>",
      function()
        return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
      end,
      expr = true,
      silent = true,
      mode = "i",
    },
    {
      "<tab>",
      function()
        require("luasnip").jump(1)
      end,
      mode = "s",
    },
    {
      "<s-tab>",
      function()
        require("luasnip").jump(-1)
      end,
      mode = { "i", "s" },
    },
  },
  config = function(_, opts)
    local ls = require("luasnip")
    
    -- Setup LuaSnip
    ls.setup(opts)
    
    -- Load snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    
    -- Custom snippets for debugging
    local s = ls.snippet
    local i = ls.insert_node
    local f = ls.function_node
    local fmt = require("luasnip.extras.fmt").fmt
    local rep = require("luasnip.extras").rep
    
    -- Helper function to get filename
    local function filename()
      return vim.fn.expand("%:t:r")
    end
    
    -- Debug snippets for multiple languages
    local debug_snippets = {
      s("cl", fmt("console.log('DEBUG [{}]: {}', {})", {
        f(filename),
        i(1, "message"),
        i(2, "variable"),
      })),
      s("cll", fmt("console.log('{}:', {})", { i(1, "label"), rep(1) })),
    }
    
    -- Add snippets to JavaScript/TypeScript files
    for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
      ls.add_snippets(ft, debug_snippets)
    end
    
    -- Apex debug snippets
    ls.add_snippets("apex", {
      s("sys", fmt("System.debug('DEBUG [{}]: {}');", {
        f(filename),
        i(1, "message"),
      })),
    })
  end,
}
