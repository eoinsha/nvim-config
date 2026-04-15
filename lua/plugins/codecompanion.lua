-- Copilot chat and AI coding assistant via codecompanion.nvim
-- Uses the existing copilot.lua (zbirenbaum/copilot.lua) auth.
--
-- Key mappings:
--   <Leader>ac  - Toggle chat panel
--   <Leader>aa  - Open actions palette (also lists workflows)
--   <Leader>ai  - Inline assistant (also works in visual mode)
--   <Leader>aA  - Add current buffer to chat
--
-- Workflows (via Action Palette):
--   "Run pytest"      - run uv run pytest, fix failures, repeat until green
--   "Run prek"        - run uv run prek -a, fix remaining lint errors, verify

---@type LazySpec
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "zbirenbaum/copilot.lua",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<Leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "Toggle CodeCompanion chat" },
      { "<Leader>aa", "<cmd>CodeCompanionActions<cr>",     mode = { "n", "v" }, desc = "CodeCompanion actions" },
      { "<Leader>ai", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" }, desc = "CodeCompanion inline" },
      { "<Leader>aA", "<cmd>CodeCompanionChat Add<cr>",    mode = "v",          desc = "Add selection to chat" },
    },
    opts = {
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-sonnet-4-5",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "copilot",
          keymaps = {
            send = { modes = { n = "<CR>", i = "<C-s>" } },
            close = { modes = { n = "q" } },
          },
        },
        inline = { adapter = "copilot" },
        agent = { adapter = "copilot" },
      },
      prompt_library = {
        ["Run pytest"] = {
          strategy = "workflow",
          description = "Run uv run pytest, fix failures, repeat until all tests pass",
          opts = {
            short_name = "pytest",
          },
          prompts = {
            {
              {
                name = "Setup",
                role = "user",
                opts = { auto_submit = false },
                content = function()
                  local approvals = require("codecompanion.interactions.chat.tools.approvals")
                  approvals:toggle_yolo_mode()
                  return [[You are an expert Python developer. Your task is to fix all failing tests.

### Steps to follow exactly:

1. Use the @{insert_edit_into_file} tool to fix code in #{buffer}{watch}
2. Use the @{run_command} tool to run: `uv run pytest`
3. Trigger both tools in the same response

We will repeat until all tests pass.]]
                end,
              },
            },
            {
              {
                name = "Repeat on failure",
                role = "user",
                opts = { auto_submit = true },
                condition = function()
                  return _G.codecompanion_current_tool == "run_command"
                end,
                repeat_until = function(chat)
                  return chat.tool_registry.flags.testing == true
                end,
                content = "Tests are still failing. Fix the code and run `uv run pytest` again.",
              },
            },
          },
        },

        ["Run prek"] = {
          strategy = "workflow",
          description = "Run uv run prek -a to lint/format, fix remaining errors, verify clean",
          opts = {
            short_name = "prek",
          },
          prompts = {
            {
              {
                name = "Setup",
                role = "user",
                opts = { auto_submit = false },
                content = function()
                  local approvals = require("codecompanion.interactions.chat.tools.approvals")
                  approvals:toggle_yolo_mode()
                  return [[You are an expert Python developer. Your task is to fix all lint and formatting errors.

### Steps to follow exactly:

1. Use the @{run_command} tool to run: `uv run prek -a`
   - prek will auto-fix what it can; the output will show any remaining errors it could not fix
2. If there are remaining errors, use @{insert_edit_into_file} to fix them in #{buffer}{watch}
3. Run `uv run prek -a` again to verify everything is clean (exit code 0, no errors)
4. Stop only when prek exits cleanly with no errors reported.]]
                end,
              },
            },
            {
              {
                name = "Repeat on errors",
                role = "user",
                opts = { auto_submit = true },
                condition = function()
                  return _G.codecompanion_current_tool == "run_command"
                end,
                repeat_until = function(chat)
                  -- prek is not a test runner so flags.testing won't be set;
                  -- rely on the LLM stopping once it sees a clean exit.
                  -- This prompt fires once after each run_command invocation.
                  return chat.tool_registry.flags.testing == true
                end,
                content = "There are still lint/format errors. Fix them with @{insert_edit_into_file} and run `uv run prek -a` again.",
              },
            },
          },
        },
      },

      display = {
        chat = {
          window = {
            layout = "vertical",
            width = 0.35,
          },
        },
        diff = {
          provider = "mini_diff",
        },
      },
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>ac"] = { desc = "Toggle CodeCompanion chat" },
              ["<Leader>aa"] = { desc = "CodeCompanion actions" },
              ["<Leader>ai"] = { desc = "CodeCompanion inline" },
            },
            v = {
              ["<Leader>ac"] = { desc = "Toggle CodeCompanion chat" },
              ["<Leader>aa"] = { desc = "CodeCompanion actions" },
              ["<Leader>ai"] = { desc = "CodeCompanion inline" },
              ["<Leader>aA"] = { desc = "Add selection to chat" },
            },
          },
        },
      },
    },
  },
}
