# Neovim Configuration

A modern Neovim setup based on [AstroNvim v5](https://github.com/AstroNvim/AstroNvim), featuring a polished development environment with AI-powered autocomplete capabilities.

## What's Included

### Core Features
- **AstroNvim v5** - Modern Neovim distribution with plugin management via Lazy.nvim
- **Blink.cmp** - High-performance completion engine (replaces nvim-cmp)
- **Copilot.lua** - GitHub Copilot integration for inline AI suggestions
- **Minuet AI** - Multi-provider LLM completions (OpenAI, Claude, Ollama, LM Studio, Codestral, Gemini)
- **LSP Support** - Language Server Protocol with TypeScript (basedpyright) and Lua
- **DAP** - Debug Adapter Protocol for debugging code
- **Treesitter** - Syntax highlighting and parsing
- **null-ls** - Formatters and linters

### UI/UX
- **astrodark** colorscheme
- **snacks.nvim** - Dashboard, file explorer, picker, and more
- **nvim-ufo** - Modern fold integration
- **lspsaga.nvim** - LSP UI enhancements (hover, diagnostic windows)
- **nvim-web-devicons** - File icons
- **pipeline.nvim** - CI/CD pipeline viewer

### Keybindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `,` | Local leader key |
| `M-.` | Quick fix (preferred LSP code action) |
| `<Esc>` (terminal) | Exit terminal mode |
| `<F5>` | DAP continue |
| `<F10>` | DAP step over |
| `<F11>` | DAP step into |
| `<F12>` | DAP step out |
| `<Leader>db` | DAP toggle breakpoint |
| `<Leader>dB` | DAP conditional breakpoint |
| `<Leader>dr` | DAP REPL |
| `]b` / `[b` | Next/Previous buffer |
| `<Leader>bd` | Close buffer |

## Installation

1. **Backup existing config** (optional):
```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

2. **Clone this repository**:
```bash
git clone <your-repo> ~/.config/nvim
```

3. **Start Neovim**:
```bash
nvim
```

The first run will install all plugins automatically via Lazy.nvim.

## Updating Plugins

```bash
:Lazy
```

Then press `U` to update all plugins, then `R` to reload.

## Managing Language Servers

Install language servers via Mason:
```bash
:Mason
```

Then check the box for desired servers (lua_ls, basedpyright, ts_ls, etc.) and click "Install".

## AI Autocomplete Setup

This configuration has two AI completion systems that work side-by-side:

1. **GitHub Copilot** (`copilot.lua`) -- inline ghost-text suggestions via `<Tab>`
2. **Minuet AI** (`minuet-ai.nvim`) -- multi-provider LLM completions in the blink.cmp menu

### Supported LLM Providers (via Minuet)

| Provider | Type | Mode | API Key Env Var |
|----------|------|------|-----------------|
| **Ollama** | Local | FIM (default) | None needed (`TERM` placeholder) |
| **LM Studio** | Local | Chat | None needed (`TERM` placeholder) |
| **OpenAI** | Cloud | Chat | `OPENAI_API_KEY` |
| **Claude** | Cloud | Chat | `ANTHROPIC_API_KEY` |
| **Codestral** | Cloud | FIM | `CODESTRAL_API_KEY` |
| **Gemini** | Cloud | Chat | `GEMINI_API_KEY` |

### Quick Start -- Local Models (Ollama)

1. Install [Ollama](https://ollama.com/)
2. Pull a code model:
   ```bash
   ollama pull qwen2.5-coder:7b
   ```
3. Start Neovim -- completions appear in the blink.cmp menu automatically

### Quick Start -- Cloud Providers

Set the API key for your provider in your shell profile:
```bash
# ~/.zshrc or ~/.bashrc
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export CODESTRAL_API_KEY="..."
export GEMINI_API_KEY="..."
```

Then switch provider inside Neovim:
```vim
:Minuet change_provider
```

### Switching Providers at Runtime

```vim
:Minuet change_provider       " interactive picker
:Minuet change_model          " change model within current provider
```

### Virtual Text (Ghost Text) Mode

Minuet also supports Copilot-style inline suggestions. To enable auto-trigger
for specific filetypes, edit `lua/plugins/llm.lua`:

```lua
virtualtext = {
  auto_trigger_ft = { "python", "lua", "typescript", "go" },
}
```

Virtual text keybindings:

| Key | Action |
|-----|--------|
| `Alt-A` | Accept whole suggestion |
| `Alt-a` | Accept one line |
| `Alt-]` | Next suggestion |
| `Alt-[` | Previous suggestion |
| `Alt-e` | Dismiss |

### GitHub Copilot

Copilot runs separately and provides inline suggestions via `<Tab>`:
```vim
:Copilot auth        " first-time authentication
:Copilot             " check status
```

### Configuration

Edit `lua/plugins/llm.lua` to customize:
- Default provider and model
- API endpoints for local servers
- Throttle/debounce timing
- Virtual text filetypes and keybindings

## Customization

### Adding Plugins

Edit `lua/plugins/user.lua` to add new plugins. Use this pattern:

```lua
{
  "owner/repo",
  event = "BufRead",
  config = function() require("pluginname").setup() end,
}
```

### Adding LSP Servers

Edit `lua/plugins/astrolsp.lua` in the `servers` section:

```lua
servers = {
  "pyright",
  "ts_ls",
}
```

### Adding Formatters

Edit `lua/plugins/none-ls.lua` in the `sources` section.

## File Structure

```
nvim/
├── init.lua              # Entry point, bootstraps Lazy.nvim
├── lazy_setup.lua        # Plugin loader configuration
├── polish.lua            # User keybindings
├── lua/
│   ├── plugins/          # Plugin configurations
│   │   ├── astrocore.lua
│   │   ├── astroui.lua
│   │   ├── astrolsp.lua
│   │   ├── cmp_ai.lua   # Blink.cmp AI integration
│   │   ├── copilot.lua  # GitHub Copilot
│   │   ├── dap.lua
│   │   ├── llm.lua      # Minuet AI multi-provider LLM config
│   │   ├── mason.lua
│   │   ├── none-ls.lua
│   │   ├── treesitter.lua
│   │   └── user.lua     # User plugins
│   └── community.lua    # Community plugins (disabled)
└── README.md
```

## Troubleshooting

### Copilot Not Working
```bash
:Copilot auth
```

### Reload Config
```bash
:source ~/.config/nvim/init.lua
```

### Check Plugin Status
```bash
:Lazy
```

## Requirements

- **Neovim 0.10+**
- **Git**
- **Node.js** (for TypeScript language server)
- **Python** (for basedpyright, debugpy)
- **curl** (used by Minuet AI for LLM requests)
- **Nerd Font** (recommended for icons)

## Resources

- [AstroNvim Docs](https://docs.astronvim.com/)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Blink.cmp](https://cmp.saghen.dev/)
- [Minuet AI](https://github.com/milanglacier/minuet-ai.nvim)
- [Copilot.lua](https://github.com/zbirenbaum/copilot.lua)
