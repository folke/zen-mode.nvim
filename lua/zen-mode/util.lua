local M = {}

function M.get_hl(name)
  local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
  if not ok then
    return
  end
  for _, key in pairs({ "foreground", "background", "special" }) do
    if hl[key] then
      hl[key] = string.format("#%06x", hl[key])
    end
  end
  return hl
end

function M.hex2rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

function M.rgb2hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

function M.darken(hex, amount)
  local r, g, b = M.hex2rgb(hex)
  return M.rgb2hex(r * amount, g * amount, b * amount)
end

function M.is_dark(hex)
  local r, g, b = M.hex2rgb(hex)
  local lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return lum <= 0.5
end

function M.log(msg, hl)
  vim.api.nvim_echo({ { "ZenMode: ", hl }, { msg } }, true, {})
end

function M.warn(msg)
  M.log(msg, "WarningMsg")
end

function M.error(msg)
  M.log(msg, "ErrorMsg")
end

---Need some kind of heuristics to determine if the
---target buffer is a real file or not. For now, is as follow:
function M.is_real_file()
  local bufnr = vim.api.nvim_get_current_buf()
  -- check if buf is nil or is not number which is not correct bufnr
  if not bufnr or type(bufnr) ~= "number" then
    return false
  end

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  -- Assumed, any real file has a file name
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return false
  end

  -- Also assumed, any file has some sort of file type
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  -- and should be listed(visible to users, us)
  local buflisted = vim.api.nvim_get_option_value("buflisted", { buf = bufnr })

  return filetype ~= "" and buflisted == true
end

return M
