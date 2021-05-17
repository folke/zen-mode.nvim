local view = require("zen.view")
local config = require("zen.config")

local M = {}

M.setup = config.setup
M.toggle = view.toggle
M.open = view.open
M.close = view.close

function M.reset()
  M.close()
  require("plenary.reload").reload_module("zen")
  require("zen").toggle()
end

return M
