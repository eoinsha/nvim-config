-- GitHub Copilot ghost-text suggestions
-- Toggle between Copilot and minuet with <Leader>aC
--
-- Default: Copilot ON, minuet OFF (not even loaded).
-- The toggle lazy-loads minuet on first switch and uses
-- "Minuet blink enable/disable" to control the blink source.

---@type LazySpec
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "BufReadPost",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        hide_during_completion = true,
        keymap = {
          -- Tab accepts the full suggestion (handled via cmp_ai.lua fallback)
          accept = false,
          accept_word = "<M-Right>",
          accept_line = "<M-Down>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["."] = false,
      },
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          options = {
            g = {
              -- Global flag: is copilot the active AI provider?
              copilot_enabled = true,

              -- Accept function used by Tab in cmp_ai.lua
              ai_accept = function()
                if vim.g.copilot_enabled then
                  local suggestion = require("copilot.suggestion")
                  if suggestion.is_visible() then
                    suggestion.accept()
                    return true
                  end
                end
              end,
            },
          },
          mappings = {
            n = {
              ["<Leader>aC"] = {
                function()
                  if vim.g.copilot_enabled then
                    -- Switch to minuet
                    vim.g.copilot_enabled = false
                    require("copilot.command").disable()
                    -- Lazy-load minuet if it hasn't been loaded yet, then enable its blink source
                    local lazy_ok, lazy = pcall(require, "lazy")
                    if lazy_ok then lazy.load { plugins = { "minuet-ai.nvim" } } end
                    vim.cmd("Minuet blink enable")
                    vim.notify("AI: switched to minuet", vim.log.levels.INFO)
                  else
                    -- Switch to copilot
                    vim.g.copilot_enabled = true
                    require("copilot.command").enable()
                    -- Disable minuet blink source so it stops making requests
                    local minuet_loaded = package.loaded["minuet"] ~= nil
                    if minuet_loaded then vim.cmd("Minuet blink disable") end
                    vim.notify("AI: switched to Copilot", vim.log.levels.INFO)
                  end
                end,
                desc = "Toggle Copilot / minuet",
              },
            },
          },
        },
      },
    },
  },
}
