local M = {}

function M.gitsigns(state, disable)
  local gs = require("gitsigns")
  local config = require("gitsigns.config").config
  if disable then
    state.signcolumn = config.signcolumn
    state.numhl = config.numhl
    state.linehl = config.linehl
    config.signcolumn = false
    config.numhl = false
    config.linehl = false
  else
    config.signcolumn = state.signcolumn
    config.numhl = state.numhl
    config.linehl = state.linehl
  end
  gs.refresh()
end

function M.options(state, disable, opts)
  for key, value in pairs(opts) do
    if key ~= "enabled" then
      if disable then
        state[key] = vim.o[key]
        vim.o[key] = value
      else
        vim.o[key] = state[key]
      end
    end
  end
end

-- changes the kitty font size
-- it's a bit glitchy, but it works
function M.kitty(state, disable, opts)
  if not vim.fn.executable("kitty") then
    return
  end
  local cmd = "kitty @ --to %s set-font-size %s"
  local socket = vim.fn.expand("$KITTY_LISTEN_ON")
  if disable then
    vim.fn.system(cmd:format(socket, opts.font))
  else
    vim.fn.system(cmd:format(socket, "0"))
  end
  vim.cmd([[redraw]])
end

-- changes the alacritty font size
function M.alacritty(state, disable, opts)
  if not vim.fn.executable("alacritty") then
    return
  end
  local cmd = "alacritty msg config -w %s font.size=%s"
  local reset_cmd = "alacritty msg config -w %s --reset"
  local win_id = vim.fn.expand("$ALACRITTY_WINDOW_ID")
  if disable then
    vim.fn.system(cmd:format(win_id, opts.font))
  else
    vim.fn.system(reset_cmd:format(win_id))
  end
  vim.cmd([[redraw]])
end

-- changes the wezterm font size
function M.wezterm(state, disable, opts)
  local stdout = vim.loop.new_tty(1, false)
  if disable then
    -- Requires tmux setting or no effect: set-option -g allow-passthrough on
    stdout:write(
      ("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\"):format(
        "ZEN_MODE",
        vim.fn.system({ "base64" }, tostring(opts.font))
      )
    )
  else
    stdout:write(
      ("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\"):format("ZEN_MODE", vim.fn.system({ "base64" }, "-1"))
    )
  end
  vim.cmd([[redraw]])
end

function M.twilight(state, disable)
  if disable then
    state.enabled = require("twilight.view").enabled
    require("twilight").enable()
  else
    if not state.enabled then
      require("twilight").disable()
    end
  end
end

function M.tmux(state, disable, opts)
  if not vim.env.TMUX then
    return
  end
  if disable then
    local function get_tmux_opt(option)
      local option_raw = vim.fn.system([[tmux show -w ]] .. option)
      if option_raw == "" then
        option_raw = vim.fn.system([[tmux show -g ]] .. option)
      end
      local opt = vim.split(vim.trim(option_raw), " ")[2]
      return opt
    end
    state.status = get_tmux_opt("status")
    state.pane = get_tmux_opt("pane-border-status")

    vim.fn.system([[tmux set -w pane-border-status off]])
    vim.fn.system([[tmux set status off]])
    vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z]])
  else
    if type(state.pane) == "string" then
      vim.fn.system(string.format([[tmux set -w pane-border-status %s]], state.pane))
    else
      vim.fn.system([[tmux set -uw pane-border-status]])
    end
    vim.fn.system(string.format([[tmux set status %s]], state.status))
    vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z]])
  end
end

function M.neovide(state, disable, opts)
  if not vim.g.neovide then
    return
  end
  if disable then
    if opts.scale ~= 1 then
      state.scale = vim.g.neovide_scale_factor
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * opts.scale
    end
    if opts.disable_animations then
      for key, value in pairs(opts.disable_animations) do
        state[key] = vim.g[key]
        vim.g[key] = value
      end
    end
  else
    if opts.scale ~= 1 then
      vim.g.neovide_scale_factor = state.scale
    end
    if opts.disable_animations then
      for key, _ in pairs(opts.disable_animations) do
        vim.g[key] = state[key]
      end
    end
  end
end

function M.diagnostics(state, disable)
  if disable then
    vim.diagnostic.disable(0)
  else
    vim.diagnostic.enable(0)
  end
end

function M.todo(state, disable)
  if disable then
    state.todo = require("todo-comments.highlight").enabled
    require("todo-comments").disable()
  else
    if state.todo then
      require("todo-comments").enable()
    end
  end
end

return M
