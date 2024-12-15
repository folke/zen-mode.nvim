local M = {}
local ns_id = vim.api.nvim_create_namespace("zenmode_key")
local listening = false

---@class ZenNavKey
M.nav_key = { WIN = "wincmd", LEFT = "left", UP = "up", RIGHT = "right", DOWN = "down" }

-- last known recorded nav key
---@type string
M.last_nav_key_rec = nil

-- detects moves across windows
-- TODO: consider custom mappings support in config
function M.listen()
  if listening then
    return ns_id
  else
    listening = true
    vim.on_key(function(_, typed)
      if typed and #typed > 0 then
        local key = vim.fn.keytrans(typed)
        local mod = key:match("^<([CMAD])%-.+>$")
        if mod == "C" then
          local move = key:match("^<.-%-.*(.)>$")
          if move == "W" then
            M.last_nav_key_rec = M.nav_key.WIN
          end
        else
          if M.last_nav_key_rec == M.nav_key.WIN then
            local move = key
            if move == "h" then
              M.last_nav_key_rec = M.nav_key.LEFT
            elseif move == "j" then
              M.last_nav_key_rec = M.nav_key.DOWN
            elseif move == "k" then
              M.last_nav_key_rec = M.nav_key.UP
            elseif move == "l" then
              M.last_nav_key_rec = M.nav_key.RIGHT
            end
          end
        end
      end
    end, ns_id)
  end
end

function M.stop_listen()
  vim.on_key(nil, ns_id)
  listening = false
end

return M
