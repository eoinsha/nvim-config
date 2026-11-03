---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    event_handlers = {
      {
        -- neo-tree runs `git status --ignored=traditional` synchronously, which scans huge
        -- ignored dirs (e.g. rust `target/`) and blocks nvim for seconds on source switch.
        event = "before_git_status",
        handler = function(args)
          for i, a in ipairs(args.status_args) do
            if a:match "^%-%-ignored=" then args.status_args[i] = "--ignored=no" end
          end
        end,
      },
    },
  },
}
