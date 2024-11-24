local config = require("zen-mode.config")
local key = require("zen-mode.key")
local plugins = require("zen-mode.plugins")
local util = require("zen-mode.util")
local M = {}

---@class ZenSidecar
---@field win integer|nil - container window handle to use as the root for childs windows;
---@field buf integer|nil - container throw away buffer;
---@field registered boolean - indicates that at least 1 plugin registered a sidecar window;
---@field position string|nil - sidecar position in related to main window 'left' or 'right';
---@field childs table<integer> - array of child window handles;
---@field child_ring_index integer - index of the last focused `childs` window
local sidecar_default = {
  win = nil,
  buf = nil,
  registered = false,
  width_relative = 0.0,
  position = nil,
  childs = {},
  child_ring_index = 1,
}

M.bg_win = nil
M.bg_buf = nil
M.parent = nil
M.win = nil
---@type ZenSidecar
M.sidecar = vim.deepcopy(sidecar_default, true)
M.last_active_zen_win = nil
--- @type ZenOptions
M.opts = nil
M.state = {}
M.closed = false

function M.is_open()
  return M.win and vim.api.nvim_win_is_valid(M.win)
end

function M.plugins_on_open()
  for name, opts in pairs(M.opts.plugins) do
    if opts and opts.enabled then
      local plugin = plugins[name]
      M.state[name] = {}
      pcall(plugin, M.state[name], config.event_type.OPEN, opts, M.sidecar)
    end
  end
end

function M.plugins_on_ready()
  for name, opts in pairs(M.opts.plugins) do
    if opts and opts.enabled then
      local plugin = plugins[name]
      pcall(plugin, M.state[name], config.event_type.READY, opts, M.sidecar)
    end
  end
end

function M.plugins_on_layout_update()
  for name, opts in pairs(M.opts.plugins) do
    if opts and opts.enabled then
      local plugin = plugins[name]
      pcall(plugin, M.state[name], config.event_type.LAYOUT_UPDATE, opts, M.sidecar)
    end
  end
end

function M.plugins_on_close()
  for name, opts in pairs(M.opts.plugins) do
    if opts and opts.enabled then
      local plugin = plugins[name]
      pcall(plugin, M.state[name], config.event_type.CLOSE, opts, M.sidecar)
    end
  end
end

function M.close()
  pcall(vim.cmd, [[autocmd! Zen]])
  pcall(vim.cmd, [[augroup! Zen]])
  key.stop_listen()

  -- Change the parent window's cursor position to match
  -- the cursor position in the zen-mode window.
  if M.parent and M.win then
    -- Ensure that the parent window has the same buffer
    -- as the zen-mode window.
    if vim.api.nvim_win_get_buf(M.parent) == vim.api.nvim_win_get_buf(M.win) then
      -- Then, update the parent window's cursor position.
      vim.api.nvim_win_set_cursor(M.parent, vim.api.nvim_win_get_cursor(M.win))
    end
  end

  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
  if M.bg_win and vim.api.nvim_win_is_valid(M.bg_win) then
    vim.api.nvim_win_close(M.bg_win, true)
    M.bg_win = nil
  end
  if M.bg_buf and vim.api.nvim_buf_is_valid(M.bg_buf) then
    vim.api.nvim_buf_delete(M.bg_buf, { force = true })
    M.bg_buf = nil
  end

  if M.opts then
    M.close_sidecar()
    M.plugins_on_close()
    M.opts.on_close()
    M.opts = nil
    M.last_active_zen_win = nil
    key.last_nav_key_rec = nil
    if M.parent and vim.api.nvim_win_is_valid(M.parent) then
      vim.api.nvim_set_current_win(M.parent)
    end
  end
end

function M.close_sidecar()
  if M.sidecar.registered then
    if M.sidecar.win and vim.api.nvim_win_is_valid(M.sidecar.win) then
      vim.api.nvim_win_close(M.sidecar.win, true)
    end
    if M.sidecar.buf and vim.api.nvim_buf_is_valid(M.sidecar.buf) then
      vim.api.nvim_buf_delete(M.sidecar.buf, { force = true })
    end
    M.sidecar = vim.deepcopy(sidecar_default, true)
  end
end

function M.open(opts)
  if not M.is_open() then
    -- close any possible remnants from a previous session
    -- shouldn't happen, but just in case
    M.close()
    M.create(opts)
  end
end

function M.toggle(opts)
  if M.is_open() then
    M.close()
  else
    M.open(opts)
  end
end

function M.height()
  local height = vim.o.lines - vim.o.cmdheight
  return (vim.o.laststatus == 3) and height - 1 or height
end

function M.resolve(max, value)
  local ret = max
  if type(value) == "function" then
    ret = value()
  elseif value > 1 then
    ret = value
  else
    ret = ret * value
  end
  return math.min(ret, max)
end

--- @param opts ZenOptions
function M.layout(opts, sidecar_width_relative, sidecar_position, is_sidecar)
  local col_delta = 0
  local width_delta = 0

  local width = M.resolve(vim.o.columns, opts.window.width)
  local height = M.resolve(M.height(), opts.window.height)

  if sidecar_width_relative and sidecar_width_relative > 0 and sidecar_width_relative < 1 then
    width_delta = util.round(sidecar_width_relative * width)
  end

  if is_sidecar then
    if sidecar_position == "right" then
      col_delta = util.round(width) - width_delta
    end
    return {
      width = width_delta,
      height = util.round(height),
      col = util.round((vim.o.columns - width) / 2) + col_delta,
      row = util.round((M.height() - height) / 2),
    }
  else
    if sidecar_position == "left" then
      col_delta = width_delta
    end
    return {
      width = util.round(width) - width_delta,
      height = util.round(height),
      col = util.round((vim.o.columns - width) / 2) + col_delta,
      row = util.round((M.height() - height) / 2),
    }
  end
end

-- adjusts col/row if window was resized
function M.fix_layout(win_resized)
  if M.is_open() then
    local win_layout
    local side_layout
    if
      M.sidecar.registered
      and M.sidecar.win
      and vim.api.nvim_win_is_valid(M.sidecar.win)
      and #M.sidecar.childs ~= 0
    then
      side_layout = M.layout(M.opts, M.sidecar.width_relative, M.sidecar.position, true)
      win_layout = M.layout(M.opts, M.sidecar.width_relative, M.sidecar.position, false)
    else
      win_layout = M.layout(M.opts)
    end

    if win_resized then
      vim.api.nvim_win_set_config(M.win, { width = win_layout.width, height = win_layout.height })
      vim.api.nvim_win_set_config(M.bg_win, { width = vim.o.columns, height = M.height() })
      if side_layout then
        vim.api.nvim_win_set_config(M.sidecar.win, { width = side_layout.width, height = side_layout.height })
      end
    end

    local function update_col_row_if_needed(win, col, row)
      local cfg = vim.api.nvim_win_get_config(win)
      -- HACK: col is an array?
      local wcol = type(cfg.col) == "number" and cfg.col or cfg.col[false]
      local wrow = type(cfg.row) == "number" and cfg.row or cfg.row[false]
      if wrow ~= row or wcol ~= col then
        vim.api.nvim_win_set_config(win, { col = col, row = row, relative = "editor" })
      end
    end

    update_col_row_if_needed(M.win, win_layout.col, win_layout.row)
    if side_layout then
      update_col_row_if_needed(M.sidecar.win, side_layout.col, side_layout.row)
      M.plugins_on_layout_update()
    end
  end
end

--- @param opts ZenOptions
function M.create(opts)
  opts = vim.tbl_deep_extend("force", {}, config.options, opts or {})
  config.colors(opts)
  M.opts = opts
  M.state = {}
  M.parent = vim.api.nvim_get_current_win()
  -- should apply before calculate window's height to be able handle 'laststatus' option
  M.plugins_on_open()

  M.bg_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(M.bg_buf, "filetype", "zenmode-bg")
  local ok
  ok, M.bg_win = pcall(vim.api.nvim_open_win, M.bg_buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = M.height(),
    focusable = false,
    row = 0,
    col = 0,
    style = "minimal",
    zindex = opts.zindex - 10,
  })
  if not ok then
    M.plugins_on_close()
    util.error("could not open floating window. You need a Neovim build that supports zindex (May 15 2021 or newer)")
    M.bg_win = nil
    return
  end
  M.fix_hl(M.bg_win, "ZenBg")

  local win_layout
  -- check if any plugin has registered a sidecar
  if M.sidecar.registered == true then
    local sidecar_win_opts = vim.tbl_extend("keep", {
      relative = "editor",
      style = "minimal",
      border = "none",
      zindex = opts.zindex - 10,
      focusable = false,
    }, M.layout(opts, M.sidecar.width_relative, M.sidecar.position, true))
    M.sidecar.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.sidecar.buf, "filetype", "zenmode-sidecar")
    M.sidecar.win = vim.api.nvim_open_win(M.sidecar.buf, false, sidecar_win_opts)
    M.fix_hl(M.sidecar.win, "ZenSidecarBg")

    win_layout = M.layout(opts, M.sidecar.width_relative, M.sidecar.position, false)
  else
    win_layout = M.layout(opts)
  end

  local win_opts = vim.tbl_extend("keep", {
    relative = "editor",
    zindex = opts.zindex,
    border = opts.border,
  }, win_layout)

  local buf = vim.api.nvim_get_current_buf()
  M.win = vim.api.nvim_open_win(buf, true, win_opts)
  vim.cmd([[norm! zz]])
  M.fix_hl(M.win)

  for k, v in pairs(opts.window.options or {}) do
    vim.api.nvim_win_set_option(M.win, k, v)
  end

  -- allow to render inside sidecar
  M.plugins_on_ready()
  if M.sidecar.registered then
    for _, win_id in ipairs(M.sidecar.childs) do
      M.fix_hl(win_id)
    end
  end

  if type(opts.on_open) == "function" then
    opts.on_open(M.win)
  end
  -- fix layout since some plugins might have altered the window
  M.fix_layout()

  -- NOTE: listen for WinNew and BufEnter. When a new window, or bufenter in a new window, close zen mode
  -- unless it's in a float or sidecar
  -- NOTE: when the cursor leaves the window, we close zen mode, or prevent leaving the window
  local augroup = [[
    augroup Zen
      autocmd!
      autocmd WinClosed %d ++once ++nested lua require("zen-mode.view").close()
      autocmd WinClosed * lua require("zen-mode.view").on_win_close()
      autocmd WinEnter * lua require("zen-mode.view").on_win_enter()
      autocmd WinLeave * lua require("zen-mode.view").on_win_leave()
      autocmd CursorMoved * lua require("zen-mode.view").fix_layout()
      autocmd VimResized * lua require("zen-mode.view").fix_layout(true)
      autocmd CursorHold * lua require("zen-mode.view").fix_layout()
      autocmd BufWinEnter * lua require("zen-mode.view").on_buf_win_enter()
    augroup end]]

  -- FIX: It could have been an easy win, but focusable doesn't work on non-floating windows.
  -- [https://github.com/neovim/neovim/issues/29365](issue)
  -- for _, win_obj in ipairs(vim.fn.getwininfo()) do
  --   local cfg = vim.api.nvim_win_get_config(win_obj.winid)
  --   if cfg.relative and cfg.relative == "" then
  --     vim.api.nvim_win_set_config(win_obj.winid, { focusable = false })
  --   end
  -- end
  --
  -- instead custom navigation mappings implemented
  key.listen()

  vim.api.nvim_exec2(augroup:format(M.win, M.win), { output = false })
end

function M.fix_hl(win, normal)
  local cwin = vim.api.nvim_get_current_win()
  if cwin ~= win then
    vim.api.nvim_set_current_win(win)
  end
  normal = normal or "Normal"
  vim.cmd("setlocal winhl=NormalFloat:" .. normal .. ",FloatBorder:ZenBorder")
  vim.cmd("setlocal winblend=0")
  vim.cmd([[setlocal fcs=eob:\ ,fold:\ ,vert:\]])
  -- vim.api.nvim_win_set_option(win, "winhighlight", "NormalFloat:" .. normal)
  -- vim.api.nvim_win_set_option(win, "fcs", "eob: ")
  if vim.api.nvim_win_is_valid(cwin) then
    vim.api.nvim_set_current_win(cwin)
  end
end

function M.is_float(win)
  local opts = vim.api.nvim_win_get_config(win)
  return opts and opts.relative and opts.relative ~= ""
end

function M.on_buf_win_enter()
  local cwin = vim.api.nvim_get_current_win()
  if cwin == M.win or M.is_in_sidecar(cwin) then
    M.fix_hl(cwin)
  end
end

function M.on_win_leave()
  local win = vim.api.nvim_get_current_win()
  if M.is_zen_window(win) then
    M.last_active_zen_win = win
  end
end

function M.on_win_close()
  for i, win_id in ipairs(M.sidecar.childs) do
    if not vim.api.nvim_win_is_valid(win_id) then
      table.remove(M.sidecar.childs, i)
      M.sidecar.child_ring_index = 1
      if M.last_active_zen_win == win_id then
        M.last_active_zen_win = M.win
      end
      M.jump_to_win(M.win)
    end
  end
  if M.sidecar.win and #M.sidecar.childs == 0 then
    M.close_sidecar()
    M.fix_layout(true)
  end
end

function M.on_win_enter()
  local win = vim.api.nvim_get_current_win()
  if not M.is_zen_window(win) then
    if M.sidecar.registered and #M.sidecar.childs ~= 0 then
      -- HACK: when returning from a float window, vim initially enters the parent window.
      -- give 10ms to get back to the zen window before closing
      -- it also gives a nasty cursor blink when navigating across floating windows, worth
      -- to fix somehow
      vim.defer_fn(M.handle_win_jumps, 10)
    else
      M.close()
    end
  end
end

function M.handle_win_jumps()
  local win = vim.api.nvim_get_current_win()
  if not M.is_zen_window(win) and not M.is_float(win) then
    if M.sidecar.registered then
      -- jump between main and sidecar
      if M.last_active_zen_win == M.win then
        if key.last_nav_key_rec == key.nav_key.UP or key.last_nav_key_rec == key.nav_key.DOWN then
          -- get back to main window (no move)
          M.jump_to_win(M.win)
        else
          local first_child_win = M.sidecar.childs[1]
          if first_child_win then
            M.jump_to_win(first_child_win)
          end
        end
      else
        if key.last_nav_key_rec == key.nav_key.LEFT or key.last_nav_key_rec == key.nav_key.RIGHT then
          M.jump_to_win(M.win)
          M.sidecar.child_ring_index = 1
        else
          local new_index = M.sidecar.child_ring_index
          if key.last_nav_key_rec == key.nav_key.UP then
            new_index = new_index - 1
          end
          if key.last_nav_key_rec == key.nav_key.DOWN then
            new_index = new_index + 1
          end
          if new_index > #M.sidecar.childs or new_index <= 0 then
            -- get back to sidecar (no move)
            M.jump_to_win(M.sidecar.childs[M.sidecar.child_ring_index])
          else
            M.jump_to_win(M.sidecar.childs[new_index])
            M.sidecar.child_ring_index = new_index
          end
        end
      end
    else
      -- no sindecar configured, just leave
      M.close()
    end
  else
    -- HACK: Doesn't track curosr position in the main window without moving back and forth
    if M.sidecar.registered and #M.sidecar.childs > 0 then
      M.jump_to_win(M.win)
      M.jump_to_win(M.sidecar.childs[1])
    end
  end
end

function M.jump_to_win(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local cmd = ("%dwincmd w"):format(vim.api.nvim_win_get_number(win))
  vim.api.nvim_exec2(cmd, { output = false })
  key.last_nav_key_rec = nil
end

function M.is_zen_window(win)
  return win == M.win or M.is_in_sidecar(win)
end

function M.is_in_sidecar(win)
  for _, win_id in ipairs(M.sidecar.childs) do
    if win_id == win then
      return true
    end
  end
  return false
end

return M
