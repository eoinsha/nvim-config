---@type LazySpec
local excludes = { "**/cdk.out", "**/node_modules", "**/.venv", "**/.idea" }

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
      dashboard = { enabled = true },
      explorer = {
        enabled = true,
        exclude = excludes,
      },
      indent = { enabled = true },
      input = { enabled = true },
      grep = { enabled = true, exclude = excludes },
      picker = { enabled = true, exclude = excludes },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
    },
  },

  -- -- LSP server stuff --
  -- {
  --   "neovim/nvim-lspconfig",
  --   dependencies = {
  --     "williamboman/mason.nvim",
  --     "williamboman/mason-lspconfig.nvim"
  --   },
  --   config = function()
  --     local capabilities = vim.lsp.protocol.make_client_capabilities()
  --     capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
  --
  --   require('mason').setup()
  --     local mason_lspconfig = require 'mason-lspconfig'
  --     mason_lspconfig.setup {
  --       ensure_installed = { "pyright" }
  --     }
  --     require("lspconfig").pyright.setup {
  --       capabilities = capabilities,
  --     }
  --   end
  -- },
  --
  -- -- Autocompletion --
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --   },
  --   config = function()
  --     local has_words_before = function()
  --       unpack = unpack or table.unpack
  --       local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  --       return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  --     end
  --
  --     local cmp = require('cmp')
  --
  --     cmp.setup({
  --       completion = {
  --         autocomplete = false
  --       },
  --       mapping = cmp.mapping.preset.insert ({
  --         ["<Tab>"] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_next_item()
  --           elseif has_words_before() then
  --             cmp.complete()
  --           else
  --             fallback()
  --           end
  --         end, { "i", "s" }),
  --         ["<s-Tab>"] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_prev_item()
  --           else
  --             fallback()
  --           end
  --         end, { "i", "s" }),
  --         ["<c-e>"] = cmp.mapping.abort(),
  --         ["<CR>"] = cmp.mapping.confirm({ select=true }),
  --       }),
  --       sources = {
  --         { name = "nvim_lsp" },
  --       }
  --     })
  --   end
  -- },
  --
  -- -- Treesitter for code parsing --
  -- {
  --   "nvim-treesitter/nvim-treesitter", version = false,
  --   build = function()
  --     require("nvim-treesitter.install").update({ with_sync = true })
  --   end,
  --   config = function()
  --     require("nvim-treesitter.configs").setup({
  --       ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript" },
  --       auto_install = false,
  --      highlight = { enable = true, additional_vim_regex_highlighting = false },
  --       incremental_selection = {
  --         enable = true,
  --         keymaps = {
  --           init_selection = "<C-n>",
  --           node_incremental = "<C-n>",
  --           scope_incremental = "<C-s>",
  --           node_decremental = "<C-m>",
  --         }
  --       }
  --     })
  --   end
  -- },
  --
  -- -- Telescope fuzzy finding  --
  -- {
  --   "nvim-telescope/telescope.nvim", cmd = "Telescope", version = false,
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   keys = {
  --     { "<leader>sf", "<cmd>Telescope git_files<cr>", desc = "Find Files (root dir)" },
  --     { "<leader><space>", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
  --     { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Search Project" },
  --     { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Search Document Symbols" },
  --     { "<leader>sw", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Search Workspace Symbols" },
  --   },
  --   opts = {
  --     extensions = {
  --       fzf = {
  --         fuzzy = true,
  --         override_generic_sorter = true,
  --         override_file_sorter = true,
  --         case_mode = "smart_case"
  --       }
  --     }
  --   }
  -- },
  -- { "nvim-telescope/telescope-fzf-native.nvim",
  --   build = "make",
  --   config = function()
  --     require('telescope').load_extension('fzf')
  --   end
  -- },
  -- == Examples of Overriding Plugins ==

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "hello",
          }, "\n"),
        },
      },
    },
  },

  -- You can disable default plugins as follows:
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
    config = function() require("lspsaga").setup {} end,
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

  mappings = {},
}
