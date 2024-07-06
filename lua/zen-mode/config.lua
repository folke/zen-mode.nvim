local util = require("zen-mode.util")
local M = {}

---@class ZenOptions
local defaults = {
  border = "none",
  zindex = 40, -- zindex of the zen window. Should be less than 50, which is the float default
  window = {
    backdrop = 0.95, -- shade the backdrop of the zen window. Set to 1 to keep the same as Normal
    -- height and width can be:
    -- * an asbolute number of cells when > 1
    -- * a percentage of the width / height of the editor when <= 1
    width = 120, -- width of the zen window
    height = 1, -- height of the zen window
    -- by default, no options are changed in for the zen window
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
    diagnostics = { enabled = false }, -- disables diagnostics
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
      scale = 1.2,
      -- disable the Neovide animations while in Zen mode
      disable_animations = {
        neovide_animation_length = 0,
        neovide_cursor_animate_command_line = false,
        neovide_scroll_animation_length = 0,
        neovide_position_animation_length = 0,
        neovide_cursor_animation_length = 0,
        neovide_cursor_vfx_mode = "",
      },
    },
  },
  -- callback where you can add custom code when the zen window opens
  on_open = function(_win) end,
  -- callback where you can add custom code when the zen window closes
  on_close = function() end,
}

---@type ZenOptions
M.options = nil

function M.colors(options)
  options = options or M.options
  local normal = util.get_hl("Normal")
  if normal then
    if normal.background then
      local bg = util.darken(normal.background, options.window.backdrop)
      vim.cmd(("highlight default ZenBg guibg=%s guifg=%s"):format(bg, bg))
    else
      vim.cmd("highlight default link ZenBg Normal")
    end
  end
end

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  M.colors()
  vim.cmd([[autocmd ColorScheme * lua require("zen-mode.config").colors()]])
  for plugin, plugin_opts in pairs(M.options.plugins) do
    if type(plugin_opts) == "boolean" then
      M.options.plugins[plugin] = { enabled = plugin_opts }
    end
    if M.options.plugins[plugin].enabled == nil then
      M.options.plugins[plugin].enabled = true
    end
  end
end

return setmetatable(M, {
  __index = function(_, k)
    if k == "options" then
      M.setup()
    end
    return rawget(M, k)
  end,
})
