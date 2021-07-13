# 🧘  Zen Mode

Distraction-free coding for Neovim >= 0.5

![image](https://user-images.githubusercontent.com/292349/118454007-b7d8c900-b6ac-11eb-8263-015a8d929644.png)

## ✨ Features

- opens the current buffer in a new full-screen floating window
- doesn't mess with existing window layouts / splits
- works correctly with other floating windows, like LSP hover, WhichKey, ...
- you can dynamically change the window size
- realigns when the editor or Zen window is resized
- optionally shade the backdrop of the Zen window
- always hides the status line
- optionally hide the number column, sign column, fold column, ...
- highly customizable with lua callbacks `on_open`, `on_close`
- plugins:
  - disable gitsigns
  - hide [tmux](https://github.com/tmux/tmux) status line
  - increase [Kitty](https://sw.kovidgoyal.net/kitty/) font-size
- **Zen Mode** is automatically closed when a new non-floating window is opened
- works well with plugins like [Telescope](https://github.com/nvim-telescope/telescope.nvim) to open a new buffer inside the Zen window
- close the Zen window with `:ZenMode`, `:close` or `:quit`

## ⚡️ Requirements

- Neovim >= 0.5.0
  - ❗ **Zen Mode** uses the new `z-index` option for floating windows
  - ❗ only builds **newer than May 15, 2021** are supported
- [Twilight](https://github.com/folke/twilight.nvim) is optional to dim inactive portions of your code

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  "folke/zen-mode.nvim",
  config = function()
    require("zen-mode").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug 'folke/zen-mode.nvim'

lua << EOF
  require("zen-mode").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF
```

## ⚙️ Configuration

**Zen Mode** comes with the following defaults:

```lua
{
  window = {
    backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
    -- height and width can be:
    -- * an absolute number of cells when > 1
    -- * a percentage of the width / height of the editor when <= 1
    width = 120, -- width of the Zen window
    height = 1, -- height of the Zen window
    -- by default, no options are changed for the Zen window
    -- uncomment any of the options below, or add other vim.wo options you want to apply
    options = {
      -- signcolumn = "no", -- disable signcolumn
      -- number = false, -- disable number column
      -- relativenumber = false, -- disable relative numbers
      -- cursorline = false, -- disable cursorline
      -- cursorcolumn = false, -- disable cursor column
      -- foldcolumn = "0", -- disable fold column
      -- list = false, -- disable whitespace characters
    },
  },
  plugins = {
    -- disable some global vim options (vim.o...)
    -- comment the lines to not apply the options
    options = {
      enabled = true,
      ruler = false, -- disables the ruler text in the cmd line area
      showcmd = false, -- disables the command in the last line of the screen
    },
    twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
    gitsigns = { enabled = false }, -- disables git signs
    tmux = { enabled = false }, -- disables the tmux statusline
    -- this will change the font size on kitty when in zen mode
    -- to make this work, you need to set the following kitty options:
    -- - allow_remote_control socket-only
    -- - listen_on unix:/tmp/kitty
    kitty = {
      enabled = false,
      font = "+4", -- font size increment
    },
  },
  -- callback where you can add custom code when the Zen window opens
  on_open = function(win)
  end,
  -- callback where you can add custom code when the Zen window closes
  on_close = function()
  end,
}
```

## 🚀 Usage

Toggle **Zen Mode** with `:ZenMode`.

Alternatively you can start **Zen Mode** with the `Lua` API and pass any additional options:

```lua
require("zen-mode").toggle({
  window = {
    width = .85 -- width will be 85% of the editor width
  }
})
```

## Inspiration

- Visual Studio Code [Zen Mode](https://code.visualstudio.com/docs/getstarted/userinterface#_zen-mode)
- Emacs [writeroom-mode](https://github.com/joostkremers/writeroom-mode)
