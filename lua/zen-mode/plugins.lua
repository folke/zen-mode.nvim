local util = require("zen-mode.util")
local zconfig = require("zen-mode.config")

local M = {}

function M.gitsigns(state, event_type)
  local gs = require("gitsigns")
  local config = require("gitsigns.config").config
  if event_type == zconfig.event_type.OPEN then
    state.signcolumn = config.signcolumn
    state.numhl = config.numhl
    state.linehl = config.linehl
    config.signcolumn = false
    config.numhl = false
    config.linehl = false
  elseif event_type == zconfig.event_type.CLOSE then
    config.signcolumn = state.signcolumn
    config.numhl = state.numhl
    config.linehl = state.linehl
  end
  gs.refresh()
end

function M.options(state, event_type, opts)
  for key, value in pairs(opts) do
    if key ~= "enabled" then
      if event_type == zconfig.event_type.OPEN then
        state[key] = vim.o[key]
        vim.o[key] = value
      elseif event_type == zconfig.event_type.CLOSE then
        vim.o[key] = state[key]
      end
    end
  end
end

-- changes the kitty font size
-- it's a bit glitchy, but it works
function M.kitty(_, event_type, opts)
  if not vim.fn.executable("kitty") then
    return
  end
  local cmd = "kitty @ --to %s set-font-size %s"
  local socket = vim.fn.expand("$KITTY_LISTEN_ON")
  if event_type == zconfig.event_type.OPEN then
    vim.fn.system(cmd:format(socket, opts.font))
  elseif event_type == zconfig.event_type.CLOSE then
    vim.fn.system(cmd:format(socket, "0"))
  end
  vim.cmd([[redraw]])
end

-- changes the alacritty font size
function M.alacritty(state, event_type, opts)
  if not vim.fn.executable("alacritty") then
    return
  end
  local cmd = "alacritty msg config -w %s font.size=%s"
  local reset_cmd = "alacritty msg config -w %s --reset"
  local win_id = vim.fn.expand("$ALACRITTY_WINDOW_ID")
  if event_type == zconfig.event_type.OPEN then
    vim.fn.system(cmd:format(win_id, opts.font))
  elseif event_type == zconfig.event_type.CLOSE then
    vim.fn.system(reset_cmd:format(win_id))
  end
  vim.cmd([[redraw]])
end

-- changes the wezterm font size
function M.wezterm(state, event_type, opts)
  local stdout = vim.loop.new_tty(1, false)
  if event_type == zconfig.event_type.OPEN then
    -- Requires tmux setting or no effect: set-option -g allow-passthrough on
    stdout:write(
      ("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\"):format(
        "ZEN_MODE",
        vim.fn.system({ "base64" }, tostring(opts.font))
      )
    )
  elseif event_type == zconfig.event_type.CLOSE then
    stdout:write(
      ("\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\"):format("ZEN_MODE", vim.fn.system({ "base64" }, "-1"))
    )
  end
  vim.cmd([[redraw]])
end

function M.twilight(state, event_type)
  if event_type == zconfig.event_type.OPEN then
    state.enabled = require("twilight.view").enabled
    require("twilight").enable()
  elseif event_type == zconfig.event_type.CLOSE then
    if not state.enabled then
      require("twilight").disable()
    end
  end
end

function M.tmux(state, event_type, _)
  if not vim.env.TMUX then
    return
  end
  if event_type == zconfig.event_type.OPEN then
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
  elseif event_type == zconfig.event_type.CLOSE then
    if type(state.pane) == "string" then
      vim.fn.system(string.format([[tmux set -w pane-border-status %s]], state.pane))
    else
      vim.fn.system([[tmux set -uw pane-border-status]])
    end
    vim.fn.system(string.format([[tmux set status %s]], state.status))
    vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z]])
  end
end

function M.neovide(state, event_type, opts)
  if not vim.g.neovide then
    return
  end
  if event_type == zconfig.event_type.OPEN then
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
  elseif event_type == zconfig.event_type.CLOSE then
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

function M.diagnostics(state, event_type)
  if event_type == zconfig.event_type.OPEN then
    vim.diagnostic.enable(false)
  elseif event_type == zconfig.event_type.CLOSE then
    vim.diagnostic.enable(true)
  end
end

function M.todo(state, event_type)
  if event_type == zconfig.event_type.OPEN then
    state.todo = require("todo-comments.highlight").enabled
    require("todo-comments").disable()
  elseif event_type == zconfig.event_type.CLOSE then
    if state.todo then
      require("todo-comments").enable()
    end
  end
end

---@param state table - arbitrary map to store state in between events;
---@param event_type ZenEvents - event to react on;
---@param opts table - plugin options defined in the config;
---@param sidecar ZenSidecar - side view which can be used to display plugin specific data;
function M.undotree(state, event_type, opts, sidecar)
  local function calc_tree_height(absolute, origin_tree_height, origin_diff_height)
    local relative = origin_tree_height / (origin_diff_height + origin_tree_height)
    return util.round(absolute * relative)
  end

  local function calc_diff_height(absolute, origin_tree_height, origin_diff_height)
    local relative = origin_diff_height / (origin_diff_height + origin_tree_height)
    return util.round(absolute * relative)
  end

  -- if undotree was open at the moment of zen activation, then show it, otherwise don't
  if event_type == zconfig.event_type.OPEN then
    local win_count = 0
    for bufnr = 1, vim.fn.bufnr("$") do
      if win_count == 2 then
        break
      end
      if vim.fn.getbufvar(bufnr, "isUndotreeBuffer") == 1 then
        local filetype = vim.fn.getbufvar(bufnr, "&filetype")

        for _, win_id in pairs(vim.fn.win_findbuf(bufnr)) do
          -- check that this is the one, it shouldn't happen, but just in case
          if filetype == "undotree" then
            -- main undotree window has been found
            state.undotree_win = win_id
            state.undotree_win_cfg = vim.api.nvim_win_get_config(win_id)
            win_count = win_count + 1
            state.undotree_win_height = vim.api.nvim_win_get_height(win_id)
          elseif filetype == "diff" then
            -- diff window
            state.undodiff_win = win_id
            state.undodiff_win_cfg = vim.api.nvim_win_get_config(win_id)
            win_count = win_count + 1
            state.undodiff_win_height = vim.api.nvim_win_get_height(win_id)
          end
        end
      end
    end

    if win_count > 0 then
      sidecar.registered = true
      local relative_width = 0.2
      local position = "right"
      if opts.width_relative and opts.width_relative > 0 and opts.width_relative < 1 then
        relative_width = opts.width_relative
      end
      if opts.position and opts.position == "left" then
        position = "left"
      end
      sidecar.width_relative = relative_width
      sidecar.position = position
    end
  elseif event_type == zconfig.event_type.READY or event_type == zconfig.event_type.LAYOUT_UPDATE then
    local sidecar_win = sidecar.win
    if not sidecar_win then
      util.error("sidecar window is not set by zen view, undotree plugin can't bootstrap")
      return
    end
    local sidecar_win_conf = vim.api.nvim_win_get_config(sidecar_win)

    local new_tree_height =
      calc_tree_height(sidecar_win_conf.height, state.undotree_win_height, state.undodiff_win_height)
    local new_diff_height =
      calc_diff_height(sidecar_win_conf.height, state.undotree_win_height, state.undodiff_win_height)
    if state.undotree_win and vim.api.nvim_win_is_valid(state.undotree_win) then
      local cfg = {
        relative = "win",
        win = sidecar_win,
        zindex = sidecar_win_conf.zindex + 10,
        width = sidecar_win_conf.width,
        height = new_tree_height - 1,
        row = 0,
        col = 0,
        style = "minimal",
        border = "none",
      }
      if event_type == zconfig.event_type.READY then
        local undotree_win_buf = vim.api.nvim_win_get_buf(state.undotree_win)
        state.new_undotree_win = vim.api.nvim_open_win(undotree_win_buf, false, cfg)
        sidecar.childs[#sidecar.childs + 1] = state.new_undotree_win
      else
        if vim.api.nvim_win_is_valid(state.new_undotree_win) then
          vim.api.nvim_win_set_config(state.new_undotree_win, cfg)
        else
          state.new_undotree_win = nil
          state.undotree_win = nil
        end
      end
    end

    if state.undodiff_win and vim.api.nvim_win_is_valid(state.undodiff_win) then
      local cfg = {
        relative = "win",
        win = sidecar_win,
        zindex = sidecar_win_conf.zindex + 10,
        width = sidecar_win_conf.width,
        height = new_diff_height,
        row = new_tree_height,
        col = 0,
        style = "minimal",
        border = "none",
      }
      if event_type == zconfig.event_type.READY then
        local undodiff_win_buf = vim.api.nvim_win_get_buf(state.undodiff_win)
        state.new_undodiff_win = vim.api.nvim_open_win(undodiff_win_buf, false, cfg)
        sidecar.childs[#sidecar.childs + 1] = state.new_undodiff_win
      else
        if vim.api.nvim_win_is_valid(state.new_undodiff_win) then
          vim.api.nvim_win_set_config(state.new_undodiff_win, cfg)
        else
          state.new_undodiff_win = nil
          state.undodiff_win = nil
        end
      end
    end
  elseif event_type == zconfig.event_type.CLOSE then
    if state.new_undotree_win and vim.api.nvim_win_is_valid(state.new_undotree_win) then
      vim.api.nvim_win_close(state.new_undotree_win, true)
      if state.undotree_win then
        vim.api.nvim_win_set_height(state.undotree_win, state.undotree_win_height)
      end
    end
    if state.new_undodiff_win and vim.api.nvim_win_is_valid(state.new_undodiff_win) then
      vim.api.nvim_win_close(state.new_undodiff_win, true)
      if state.undodiff_win then
        -- HACK: weird off by 1 issue causing diff to shrink
        vim.api.nvim_win_set_height(state.undodiff_win, state.undodiff_win_height)
      end
    end
  end
end

return M
