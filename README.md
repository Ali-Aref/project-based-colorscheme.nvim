# Project Based Colorscheme

A Neovim plugin that automatically applies colorschemes based on project-specific configuration files.

## Features

- 🎨 Automatically detect and apply project-specific colorschemes
- 📁 Supports multiple config file formats (`.nvimrc.lua`, `.nvim.lua`, etc.)
- 🔍 Smart project root detection
- ⚙️ Configurable default colorscheme
- 💫 Commands to create and manage project configs

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "ali-aref/project-based-colorscheme.nvim",
  config = function()
    require("project-based-colorscheme").setup({
      default_colorscheme = "catppuccin-mocha", -- Your default colorscheme
    })
  end,
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "ali-aref/project-based-colorscheme.nvim",
  config = function()
    require("project-based-colorscheme").setup({
      default_colorscheme = "catppuccin-mocha",
    })
  end,
}
```

## Configuration

```lua
require("project-based-colorscheme").setup({
  default_colorscheme = "catppuccin-mocha", -- Default colorscheme to use
  config_files = {                          -- Files to look for in project root
    ".nvimrc.lua",
    ".nvim.lua",
    "nvim-config.lua",
    ".vimrc.lua"
  },
  project_root_indicators = {               -- Files/dirs that indicate project root
    ".git",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "pyproject.toml",
    "requirements.txt",
    "Makefile",
    "CMakeLists.txt",
    ".project-root"
  },
  auto_setup = false,                       -- Automatically setup on plugin load (disabled by default)
})
```

## Usage

### Project Configuration File

Create a `.nvimrc.lua` (or any of the supported config file names) in your project root:

```lua
-- .nvimrc.lua
return {
  colorscheme = "gruvbox-material"
}
```

The plugin will automatically detect and apply this colorscheme when you open files in that project.

### Commands

#### `:ProjectColorscheme <colorscheme>`

Set a colorscheme for the current project. This will create a `.nvimrc.lua` file in the project root.

```vim
:ProjectColorscheme gruvbox-material
```

#### `:ProjectInfo`

Show information about the current project, including the configured colorscheme.

```vim
:ProjectInfo
```

## How It Works

1. When Neovim starts or you change directories, the plugin detects the project root by looking for common indicators (`.git`, `package.json`, etc.)
2. It then searches for configuration files (`.nvimrc.lua`, `.nvim.lua`, etc.) in the project root
3. If a config file is found with a `colorscheme` field, it applies that colorscheme
4. If no project config is found, it falls back to the default colorscheme

## License

MIT

