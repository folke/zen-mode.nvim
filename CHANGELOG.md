# Changelog

## [1.1.0](https://github.com/folke/zen-mode.nvim/compare/v1.0.0...v1.1.0) (2023-02-01)


### Features

* alacritty plugin ([#68](https://github.com/folke/zen-mode.nvim/issues/68)) ([48a4269](https://github.com/folke/zen-mode.nvim/commit/48a426953205c5556924f0904c82e23a2c161f72))
* use transparent bg when Normal hl group not having bg ([#81](https://github.com/folke/zen-mode.nvim/issues/81)) ([00b0e0f](https://github.com/folke/zen-mode.nvim/commit/00b0e0f68d6b4ade6e447462533a5a6a5aa39fcb))


### Bug Fixes

* `window.backdrop` option is ignored in `.toggle()` API ([#77](https://github.com/folke/zen-mode.nvim/issues/77)) ([#78](https://github.com/folke/zen-mode.nvim/issues/78)) ([a88f1be](https://github.com/folke/zen-mode.nvim/commit/a88f1be193e904f8c08a6ab4d22e923bd44de7de))
* **tmux:** can get tmux's option value correctly now ([#71](https://github.com/folke/zen-mode.nvim/issues/71)) ([#72](https://github.com/folke/zen-mode.nvim/issues/72)) ([5d8308e](https://github.com/folke/zen-mode.nvim/commit/5d8308ef39c14ecbd6850b56959094aa932285c6))

## 1.0.0 (2023-01-04)


### Features

* added ZenMode command ([f6048c4](https://github.com/folke/zen-mode.nvim/commit/f6048c443747576d744aff18a70b3687bc9da150))
* allow the ZenMode command to be followed by a "|" and another command ([#43](https://github.com/folke/zen-mode.nvim/issues/43)) ([f1cc53d](https://github.com/folke/zen-mode.nvim/commit/f1cc53d32b49cf962fb89a2eb0a31b85bb270f7c))
* allow window.width and window.height to be a function ([809d0de](https://github.com/folke/zen-mode.nvim/commit/809d0de7adeaf85d482b2b98532ee596d7cc9921))
* **diagnostic:** integration with vim.diagnostics ([#46](https://github.com/folke/zen-mode.nvim/issues/46)) ([a337386](https://github.com/folke/zen-mode.nvim/commit/a3373862e5ef99c1a3993e0230b538bb5cae8628))
* hide other tmux panes when entering zen ([#5](https://github.com/folke/zen-mode.nvim/issues/5)) ([f2cc70e](https://github.com/folke/zen-mode.nvim/commit/f2cc70e896b3fd6ca1e9fa297e6760a2998b227a))
* improved tmux integration ([#48](https://github.com/folke/zen-mode.nvim/issues/48)) ([6f5702d](https://github.com/folke/zen-mode.nvim/commit/6f5702db4fd4a4c9a212f8de3b7b982f3d93b03c))
* initial version ([be5b6b6](https://github.com/folke/zen-mode.nvim/commit/be5b6b6be223afaf27a45cd945cb259685a73daf))
* restore cursor position when leaving zen-mode ([78226fb](https://github.com/folke/zen-mode.nvim/commit/78226fb4dba4e4e92e9f43547abf09c5216312de))
* toggle ruler and showcmd when activating zen mode [#3](https://github.com/folke/zen-mode.nvim/issues/3) ([48b9b12](https://github.com/folke/zen-mode.nvim/commit/48b9b124cb628195f88c0e09ca4ba1a98af978c4))
* twilight integration ([21ca264](https://github.com/folke/zen-mode.nvim/commit/21ca264c6ae934ceac220cf719c0ed6c0216b057))


### Bug Fixes

* adjust window size depending on cmdheight [#2](https://github.com/folke/zen-mode.nvim/issues/2) ([0d12d20](https://github.com/folke/zen-mode.nvim/commit/0d12d20499bf9b482767d221372ff9ac2e116daa))
* disable tmux status only for the active session [#8](https://github.com/folke/zen-mode.nvim/issues/8) ([67df395](https://github.com/folke/zen-mode.nvim/commit/67df395fc10af373dca6326ee22b939d5f2f6647))
* echo Todo =&gt; ZenMode ([81fcb69](https://github.com/folke/zen-mode.nvim/commit/81fcb69cdecb72e886b902f7d09455f571b17d13))
* on closing, always return to window that was current when zen mode started [#6](https://github.com/folke/zen-mode.nvim/issues/6) ([f90fd8d](https://github.com/folke/zen-mode.nvim/commit/f90fd8ddbbb0516416a372ce15f9b7cf40a6c233))
* only restore cursor when parent buffer is the same as the zen buffer ([a3c5dc2](https://github.com/folke/zen-mode.nvim/commit/a3c5dc22b280dc48e9efbb08ca17a700572fdabc))
* properly set bg of backdrop and new buffers in window ([eebd03c](https://github.com/folke/zen-mode.nvim/commit/eebd03ce83bf7001b225b7229fd211a19e5db46b))
* take gitsigns config from inner module ([#31](https://github.com/folke/zen-mode.nvim/issues/31)) ([f751c48](https://github.com/folke/zen-mode.nvim/commit/f751c48620d4921dc5cb0fe93a8bb031ba57799f))
* transparent background ([#32](https://github.com/folke/zen-mode.nvim/issues/32)) ([9ae43df](https://github.com/folke/zen-mode.nvim/commit/9ae43df6ee4d6c3d47aea057086c9e56fca58234))
* updated colors when reloading colorscheme ([935a583](https://github.com/folke/zen-mode.nvim/commit/935a58307b64ce071689ba8ee915af5b9cdfe70c))
* use setlocal to set winhl groups for the zen window. Fixes [#16](https://github.com/folke/zen-mode.nvim/issues/16) ([01adefb](https://github.com/folke/zen-mode.nvim/commit/01adefbf32360346c6951fa41fea6d3698e3280f))
