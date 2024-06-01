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
  - increase [Alacritty](https://alacritty.org/) font-size
  - increase [wezterm](https://wezfurlong.org/wezterm/) font-size
  - increase [Neovide](https://neovide.dev/) scale factor and disable animations
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

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- Lua
{
  "folke/zen-mode.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
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
    -- * a function that returns the width or the height
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
      -- you may turn on/off statusline in zen mode by setting 'laststatus' 
      -- statusline will be shown only if 'laststatus' == 3
      laststatus = 0, -- turn off the statusline in zen mode
    },
    twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
    gitsigns = { enabled = false }, -- disables git signs
    tmux = { enabled = false }, -- disables the tmux statusline
    todo = { enabled = false }, -- if set to "true", todo-comments.nvim highlights will be disabled
    -- this will change the font size on kitty when in zen mode
    -- to make this work, you need to set the following kitty options:
    -- - allow_remote_control socket-only
    -- - listen_on unix:/tmp/kitty
    kitty = {
      enabled = false,
      font = "+4", -- font size increment
    },
    -- this will change the font size on alacritty when in zen mode
    -- requires  Alacritty Version 0.10.0 or higher
    -- uses `alacritty msg` subcommand to change font size
    alacritty = {
      enabled = false,
      font = "14", -- font size
    },
    -- this will change the font size on wezterm when in zen mode
    -- See alse also the Plugins/Wezterm section in this projects README
    wezterm = {
      enabled = false,
      -- can be either an absolute font size or the number of incremental steps
      font = "+4", -- (10% increase per step)
    },
    -- this will change the scale factor in Neovide when in zen mode
    -- See alse also the Plugins/Wezterm section in this projects README
    neovide = {
        enabled = false,
        -- Will multiply the current scale factor by this number
        scale = 1.2
        -- disable the Neovide animations while in Zen mode
        disable_animations = {
                neovide_animation_length = 0,
                neovide_cursor_animate_command_line = false,
                neovide_scroll_animation_length = 0,
                neovide_position_animation_length = 0,
                neovide_cursor_animation_length = 0,
                neovide_cursor_vfx_mode = "",
            }
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

## 🧩 Plugins

### Wezterm

In order to make the integration with wezterm work as intended, you need to add
the following function to your wezterm config:

```lua
wezterm.on('user-var-changed', function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    if name == "ZEN_MODE" then
        local incremental = value:find("+")
        local number_value = tonumber(value)
        if incremental ~= nil then
            while (number_value > 0) do
                window:perform_action(wezterm.action.IncreaseFontSize, pane)
                number_value = number_value - 1
            end
            overrides.enable_tab_bar = false
        elseif number_value < 0 then
            window:perform_action(wezterm.action.ResetFontSize, pane)
            overrides.font_size = nil
            overrides.enable_tab_bar = true
        else
            overrides.font_size = number_value
            overrides.enable_tab_bar = false
        end
    end
    window:set_config_overrides(overrides)
end)
```

If you need this functionality within tmux, you need to add the following option
to your tmux config:

```zsh
set-option -g allow-passthrough on
```

See also: https://github.com/wez/wezterm/discussions/2550

### Neovide

Neovide config will only be executed if vim variable `g:neovide` is set to 1, which Neovide does automatically on startup. By modifying table `plugins.neovide.disable_animations`, you can control which variables in `g:` namespace get temporarily overriden while in Zen mode. By default, all animations are disabled. See [Neovide documentation](https://neovide.dev/configuration.html) for possible values.

## Inspiration

- Visual Studio Code [Zen Mode](https://code.visualstudio.com/docs/getstarted/userinterface#_zen-mode)
- Emacs [writeroom-mode](https://github.com/joostkremers/writeroom-mode)
