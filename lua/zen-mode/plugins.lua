local M = {}

function M.gitsigns(state, disable)
  local gs = require("gitsigns")
  local config = gs._get_config()
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

function M.tmux(state, disable, opts)
  if not vim.env.TMUX then
    return
  end
  if disable then
    vim.fn.system([[tmux set -g status off]])
  else
    vim.fn.system([[tmux set -g status on]])
  end
end

return M
