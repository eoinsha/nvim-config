-- Multi-provider LLM code completion via minuet-ai.nvim
-- Switch providers at runtime with :Minuet change_provider
-- Toggle between minuet and Copilot with <Leader>aC (defined in copilot.lua)
--
-- Valid provider names:
--   openai_compatible  -> LM Studio (default), or any OpenAI-chat-compatible server
--   openai             -> OpenAI directly
--   claude             -> Anthropic Claude
--   openai_fim_compatible -> FIM models (Ollama, Deepseek, etc.)
--   codestral          -> Mistral Codestral
--   gemini             -> Google Gemini

---@type LazySpec
return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Only load when explicitly invoked (via :Minuet cmd or the toggle in copilot.lua).
    -- Do NOT use event = "BufReadPost" — that causes minuet to activate on
    -- every buffer even when Copilot is the active AI provider.
    cmd = "Minuet",
    config = function()
      require("minuet").setup {
        -- Default provider: LM Studio via openai_compatible
        -- Switch at runtime with :Minuet change_provider
        -- provider = "openai",
        provider = "openai_compatible",

        -- Tune these for responsiveness vs cost
        request_timeout = 3, -- seconds
        throttle = 1500, -- ms between requests
        debounce = 600, -- ms after last keystroke

        -- Number of completion candidates
        n_completions = 3,

        -- Show single-line entry alongside multi-line
        add_single_line_entry = true,

        -- Notification level: "warn", "error", "verbose", "debug", or false
        notify = "verbose",

        -- Virtual text (ghost text) mode
        virtualtext = {
          auto_trigger_ft = {}, -- add filetypes e.g. { "python", "lua", "typescript" }
          keymap = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
        },

        -- Blink.cmp integration — starts disabled.
        -- The toggle in copilot.lua runs "Minuet blink enable" when switching to minuet.
        blink = {
          enable_auto_complete = false,
        },

        provider_options = {
          -----------------------------------------------------------
          -- LM Studio (default) -- chat-based, OpenAI-compatible
          -- Start LM Studio, load a model, enable the local server
          -----------------------------------------------------------
          openai_compatible = {
            api_key = "TERM", -- any non-nil env var as placeholder
            end_point = "http://localhost:1234/v1/chat/completions",
            -- model = "qwen/qwen3.5-9b", -- must match your loaded model in LM Studio
            model = "mistralai/codestral-22b-v0.1", -- must match your loaded model in LM Studio
            name = "LM Studio",
            stream = true,
            optional = {
              max_tokens = 128,
              top_p = 0.9,
              -- Disable thinking mode for Qwen 3.5 and similar reasoning models.
              -- Without this, the model puts output into reasoning_content
              -- instead of content, and minuet sees nothing.
              chat_template_kwargs = {
                enable_thinking = false,
              },
            },
          },

          -----------------------------------------------------------
          -- OpenAI
          -----------------------------------------------------------
          openai = {
            model = "gpt-4o-mini",
            api_key = "OPENAI_API_KEY",
            stream = true,
            optional = {
              max_tokens = 128,
            },
          },

          -- -----------------------------------------------------------
          -- -- Claude (Anthropic)
          -- -----------------------------------------------------------
          -- claude = {
          --   model = "claude-haiku-4-5",
          --   max_tokens = 256,
          --   api_key = "ANTHROPIC_API_KEY",
          --   stream = true,
          -- },
          --
          -- -----------------------------------------------------------
          -- -- OpenAI FIM-compatible (fill-in-the-middle)
          -- -- For: Ollama with code models, Deepseek, etc.
          -- -- Uncomment and adjust if you install Ollama later
          -- -----------------------------------------------------------
          -- openai_fim_compatible = {
          --   api_key = "TERM",
          --   name = "Ollama",
          --   end_point = "http://localhost:11434/v1/completions",
          --   model = "qwen2.5-coder:7b",
          --   stream = true,
          --   optional = {
          --     max_tokens = 56,
          --     top_p = 0.9,
          --   },
          -- },
          --
          -- -----------------------------------------------------------
          -- -- Codestral (Mistral) -- requires CODESTRAL_API_KEY
          -- -----------------------------------------------------------
          -- codestral = {
          --   model = "codestral-latest",
          --   api_key = "CODESTRAL_API_KEY",
          --   stream = true,
          --   optional = {
          --     max_tokens = 256,
          --     stop = { "\n\n" },
          --   },
          -- },
          --
          -- -----------------------------------------------------------
          -- -- Gemini (Google AI Studio) -- requires GEMINI_API_KEY
          -- -----------------------------------------------------------
          -- gemini = {
          --   model = "gemini-2.0-flash",
          --   api_key = "GEMINI_API_KEY",
          --   stream = true,
          --   optional = {
          --     generationConfig = {
          --       maxOutputTokens = 256,
          --     },
          --   },
          -- },
        },
      }
    end,
  },

  -- Register minuet as a blink.cmp source.
  -- The provider is always registered so blink knows about it, but minuet
  -- itself won't load (and won't make requests) until something triggers
  -- the "Minuet" command — i.e. the toggle in copilot.lua.
  {
    "Saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      -- Add minuet to completion sources
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }

      if not vim.tbl_contains(opts.sources.default, "minuet") then table.insert(opts.sources.default, "minuet") end

      -- Configure the minuet provider for blink
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.minuet = {
        name = "minuet",
        module = "minuet.blink",
        async = true,
        -- Should match request_timeout * 1000
        timeout_ms = 3000,
        score_offset = 50,
      }

      -- Avoid unnecessary prefetch requests to the LLM
      opts.completion = opts.completion or {}
      opts.completion.trigger = opts.completion.trigger or {}
      opts.completion.trigger.prefetch_on_insert = false
    end,
  },
}
