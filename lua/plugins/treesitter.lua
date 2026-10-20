-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      -- add more arguments for adding more treesitter parsers
    },
    highlight = {
      -- Treesitter's Markdown parser can visibly clear/reapply highlights while
      -- reparsing during insert mode. Use Vim syntax for Markdown instead.
      disable = { "markdown", "markdown_inline" },
    },
  },
}
