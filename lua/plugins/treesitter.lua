-- Customize Treesitter

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      -- Treesitter's Markdown parser can visibly clear/reapply highlights while
      -- reparsing during insert mode. Use Vim syntax for Markdown instead.
      highlight = function(lang) return lang ~= "markdown" and lang ~= "markdown_inline" end,
    },
  },
}
