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
    local status_raw = vim.fn.system([[tmux show status]])
    local window_pane_border_raw = vim.fn.system([[tmux show -w pane-border-status]])
    state.status = vim.split(vim.trim(status_raw), " ")[2]
    state.pane = vim.split(vim.trim(window_pane_border_raw), " ")[2]

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

return M
