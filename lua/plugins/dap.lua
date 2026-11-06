---@type LazySpec
return {
  -- Core DAP
  -- Rust adapter (CodeLLDB from Mason). The adapter name `lldb` matches the
  -- `type` in .vscode/launch.json.
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"
      dap.adapters.lldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }
      dap.configurations.rust = {
        {
          type = "lldb",
          request = "launch",
          name = "Launch binary",
          program = function() return vim.fn.input("Binary: ", vim.fn.getcwd() .. "/target/debug/", "file") end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      -- Cap lldb memory reads so Rust formatters can't hang on garbage lengths
      -- (see lldb/cap_read.py). Applies to every lldb config, incl. launch.json.
      dap.listeners.on_config["lldb_cap_read"] = function(config)
        if config.type == "lldb" then
          local cmds = vim.deepcopy(config.preRunCommands or {})
          table.insert(cmds, "command script import " .. vim.fn.stdpath "config" .. "/lldb/cap_read.py")
          config = vim.tbl_extend("force", config, { preRunCommands = cmds })
        end
        return config
      end
      -- Picks up the `lldb` entries of the project launch.json.
      require("dap.ext.vscode").load_launchjs(nil, { lldb = { "rust" } })
    end,
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

      dap.defaults["pwa-node"].focus_terminal = true
      dap.defaults["pwa-node"].terminal_win_cmd = function()
        vim.cmd "belowright new"
        local bufnr = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()

        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
            vim.cmd "startinsert"
          end
        end)

        return bufnr, win
      end

      local prompt_args = function() return vim.split(vim.fn.input "Args: ", " ", { trimempty = true }) end

      -- DAP configurations for JS
      for _, language in ipairs { "javascript", "javascriptreact" } do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch JS file",
            cwd = "${fileDirname}",
            program = "${file}",
            runtimeExecutable = "node",
            args = prompt_args,
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

      -- DAP configurations for TS
      for _, language in ipairs { "typescript", "typescriptreact" } do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch TS file (tsx)",
            cwd = "${workspaceFolder}",
            program = "${file}",
            runtimeExecutable = "node",
            runtimeArgs = { "--import", "tsx" },
            args = prompt_args,
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

  -- Persist breakpoints between sessions
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "BufReadPost",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      load_breakpoints_event = { "BufReadPost" },
    },
    keys = {
      { "<Leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<Leader>dC", function() require("persistent-breakpoints.api").set_conditional_breakpoint() end, desc = "Conditional Breakpoint" },
      { "<Leader>dX", function() require("persistent-breakpoints.api").clear_all_breakpoints() end, desc = "Clear All Breakpoints" },
    },
  },

  -- Python adapter (debugpy)
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
    config = function()
      local dap = require "dap"
      local venv_py = vim.fn.getcwd() .. "/.venv/bin/python"
      local py = vim.fn.executable(venv_py) == 1 and venv_py or "python3"
      require("dap-python").setup(py)

      local focus_terminal_win_cmd = function()
        vim.cmd "belowright new"
        local bufnr = vim.api.nvim_get_current_buf()
        local win = vim.api.nvim_get_current_win()

        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_current_win(win)
            vim.cmd "startinsert"
          end
        end)

        return bufnr, win
      end

      dap.defaults.python.focus_terminal = true
      dap.defaults.python.terminal_win_cmd = focus_terminal_win_cmd
      dap.defaults.debugpy.focus_terminal = true
      dap.defaults.debugpy.terminal_win_cmd = focus_terminal_win_cmd

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "ts-worker (local)",
          module = "ts_worker",
          cwd = "${workspaceFolder}/ts-worker",
          console = "integratedTerminal",
          env = {
            ADAPTER_MODE = "local",
            REDIS_URL = "redis://localhost:6379/0",
            QUEUE_SLOT_IDS = '["0"]',
            QUEUE_SLOT_ID = "0",
            BLOB_STORE_PATH = vim.fn.expand "~/.turbo-runner/blob-store",
            LOG_LEVEL = "DEBUG",
          },
        },
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          args = function() return vim.split(vim.fn.input "Args: ", " ", { trimempty = true }) end,
        },
      }
    end,
  },
}
