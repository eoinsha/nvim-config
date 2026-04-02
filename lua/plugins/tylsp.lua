---@type LazySpec
return {
  "aekasitt/tylsp.nvim",
  dependencies = { "neovim/nvim-lspconfig" },
  ft = "python",
  config = function() require("tylsp").setup() end,
}
