-- Lazy passes opts to require("astrotheme").setup(); AstroUI selects the theme.
---@type LazySpec
return {
  "AstroNvim/astrotheme",
  ---@type AstroThemeOpts
  opts = {
    background = { dark = "astrodark", light = "astrolight" },
    style = {
      transparent = false,
      italic_comments = false,
      simple_syntax_colors = false,
    },
    palettes = {
      astrodark = {
        syntax = {
          text = "#e6dfcf",
          comment = "#c1c5ae",
          mute = "#acb9cb",
          red = "#f08d98",
          orange = "#efb287",
          yellow = "#e8c783",
          green = "#add08c",
          cyan = "#83cec6",
          blue = "#90bff0",
          purple = "#cfabed",
        },
        ui = {
          -- Ivory on deep blue, with readable secondary text instead of dim gray.
          base = "#242b38",
          inactive_base = "#202633",
          tabline = "#1d2330",
          tool = "#202633",
          float = "#293243",
          prompt = "#303b4c",
          text = "#d7d4c8",
          text_active = "#e6dfcf",
          text_inactive = "#acb9cb",
          none_text = "#acb9cb",
          winbar = "#c1c5ae",
          border = "#819bb3",
          split = "#819bb3",
          current_line = "#303b4c",
          selection = "#455b72",
          menu_selection = "#455b72",
          highlight = "#354357",
          statusline = "#303b4c",
          text_match = "#e8c783",
          accent = "#90bff0",
        },
        -- Palette overrides do not recompute derived terminal colors.
        term = {
          foreground = "#e6dfcf",
          background = "#141b28",
          black = "#202633",
          bright_black = "#acb9cb",
          white = "#d7d4c8",
          bright_white = "#e6dfcf",
          red = "#f08d98",
          bright_red = "#f08d98",
          green = "#add08c",
          bright_green = "#add08c",
          yellow = "#e8c783",
          bright_yellow = "#e8c783",
          blue = "#90bff0",
          bright_blue = "#90bff0",
          purple = "#cfabed",
          bright_purple = "#cfabed",
          cyan = "#83cec6",
          bright_cyan = "#83cec6",
        },
      },
      astrolight = {
        syntax = {
          text = "#252b35",
          comment = "#596574",
          mute = "#626d7c",
        },
        ui = {
          text = "#354050",
          text_active = "#202630",
          text_inactive = "#596574",
          none_text = "#626d7c",
          winbar = "#596574",
          border = "#707c8e",
          split = "#8793a4",
          current_line = "#e8ecf2",
          selection = "#cbd9ec",
          menu_selection = "#cbd9ec",
        },
        term = { foreground = "#252b35", white = "#354050" },
      },
    },
    highlights = {
      global = {
        modify_hl_groups = function(hl, c)
          -- Terminal fonts control actual weight; remove theme-applied bold.
          for _, spec in pairs(hl) do
            if type(spec) == "table" and spec.bold then spec.bold = false end
          end
          hl.StatusLineNC = { fg = c.ui.text_inactive, bg = c.ui.inactive_base }
          hl.SignColumn = { fg = c.ui.text, bg = c.none }
          hl.CursorLineNr = { fg = c.ui.accent, bg = c.none, bold = false }
        end,
      },
    },
  },
}
