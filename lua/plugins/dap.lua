---@type LazySpec
return {
  -- Core DAP
  {
    "mfussenegger/nvim-dap",
  },

  -- JS/TS adapter based on vscode-js-debug
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require "dap"

      require("dap-vscode-js").setup {
        -- Mason provides this executable when you install "js-debug-adapter"
        debugger_cmd = { "js-debug-adapter" },

        -- pick the adapters you want available
        adapters = { "pwa-node", "node-terminal", "pwa-chrome", "pwa-msedge" },
      }

      -- Hard override: ensures port is valid (number token), avoiding stdout parsing issues
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }

      -- DAP configurations for TS/JS
      for _, language in ipairs { "typescript", "javascript", "typescriptreact", "javascriptreact" } do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch TS file (tsx)",
            cwd = "${workspaceFolder}",
            program = "${file}",
            runtimeExecutable = "node",
            runtimeArgs = { "--import", "tsx" },
            sourceMaps = true,
            protocol = "inspector",
            console = "integratedTerminal",
            skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
        }
      end
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dapui.setup()

      -- auto-open/close
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },

  { "nvim-neotest/nvim-nio" },
}
