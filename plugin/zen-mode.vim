if !has('nvim-0.5')
  echohl WarningMsg
  echom "ZenMode needs Neovim >= 0.5"
  echohl None
  finish
endif
command! -bar ZenMode lua require("zen-mode").toggle()
