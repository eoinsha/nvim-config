---@type LazySpec
local excludes =
  { "**/cdk.out", "**/node_modules", "**/.venv", "**/.idea", "**/.kiro", "**/.pytest_cache", "**/.uv-cache" }

return {
  -- == Examples of Adding Plugins ==

  "nvim-tree/nvim-web-devicons",
  { "catppuccin/nvim", lazy = true, name = "catppuccin", priority = 1000 },
  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    -- opts = function(_, opts)
    --   if not opts.mappings then
    --     opts.mapping = {}
    --   end
    --   opts.mapping["<leader>Ss"] = function() require("persistence").load() end
    -- end
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = "hello",
        },
      },
      explorer = {
        enabled = true,
        exclude = excludes,
      },
      indent = { enabled = true },
      input = { enabled = true },
      grep = { enabled = true, exclude = excludes, hidden = false, ignored = false },
      picker = {
        enabled = true,
        exclude = excludes,
        sources = {
          grep = { hidden = false, ignored = false },
          grep_word = { hidden = false, ignored = false },
          files = { hidden = false, ignored = false },
        },
      },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>gg"] = { function() Snacks.lazygit() end, desc = "Lazygit" },
          ["<Leader>tl"] = { function() Snacks.lazygit() end, desc = "ToggleTerm lazygit" },
        },
      },
    },
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
    },
  },

  { "max397574/better-escape.nvim", enabled = false },

  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },
  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  {
    "topaxi/pipeline.nvim",
    keys = {
      { "<leader>ci", "<cmd>Pipeline<cr>", desc = "Open pipeline.nvim" },
    },
    -- optional, you can also install and use `yq` instead.
    build = "make",
    ---@type pipeline.Config
    opts = {},
  },
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function() require("lspsaga").setup {} end,
    keys = {
      { "gd", "<cmd>Lspsaga goto_definition<cr>", desc = "Go to definition (Saga)" },
      { "gp", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition (Saga)" },
      { "gP", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek type definition (Saga)" },
      { "gf", "<cmd>Lspsaga finder<cr>", desc = "LSP finder (Saga)" },
      { "K", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover (Saga)" },
      { "<Leader>lo", "<cmd>Lspsaga outline<cr>", desc = "Symbol outline (Saga)" },
      { "<Leader>la", "<cmd>Lspsaga code_action<cr>", mode = { "n", "v" }, desc = "Code action (Saga)" },
      { "<Leader>lR", "<cmd>Lspsaga rename<cr>", desc = "Rename (Saga)" },
      { "[e", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Prev diagnostic (Saga)" },
      { "]e", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next diagnostic (Saga)" },
      { "<Leader>ld", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Line diagnostics (Saga)" },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>xd"] = {
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer diagnostics (Trouble)",
              },
              ["<Leader>xD"] = {
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Workspace diagnostics (Trouble)",
              },
            },
          },
        },
      },
    },
  },
  -- {
  --   "akinsho/toggleterm.nvim",
  --   version = "*",
  --   config = function()
  --     require("toggleterm").setup {
  --       direction = "horizontal",
  --       size = 15,
  --       open_mapping = [[<C-t>]],
  --       shade_terminals = true,
  --       start_in_insert = true,
  --     }
  --   end,
  -- },
}
