local view = require("zen-mode.view")
local config = require("zen-mode.config")

local M = {}

M.setup = config.setup
M.toggle = view.toggle
M.open = view.open
M.close = view.close

function M.reset()
  M.close()
  require("plenary.reload").reload_module("zen-mode")
  require("zen-mode").toggle()
end

return M
