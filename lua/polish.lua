local opts = { noremap = true, silent = true }

local function quickfix()
  vim.lsp.buf.code_action {
    filter = function(a) return a.isPreferred end,
    apply = true,
  }
end

vim.keymap.set("n", "M-.", quickfix, opts)

-- easier terminal mode exit
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- DAP keys
local dap = require "dap"

vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "DAP continue" })
vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "DAP step over" })
vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "DAP step into" })
vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "DAP step out" })
vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
vim.keymap.set(
  "n",
  "<leader>dB",
  function() dap.set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
  { desc = "DAP conditional breakpoint" }
)
vim.keymap.set("n", "<leader>dr", function() dap.repl.open() end, { desc = "DAP REPL" })
