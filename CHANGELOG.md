# Changelog

## [1.4.0](https://github.com/folke/zen-mode.nvim/compare/v1.3.0...v1.4.0) (2024-07-06)


### Features

* **border:** add border to main window ([#80](https://github.com/folke/zen-mode.nvim/issues/80)) ([a256eda](https://github.com/folke/zen-mode.nvim/commit/a256edafd56347896cdcbaca989335dcf6aed111))
* **plugins:** add the ability to disable todo-comments.nvim in zen-mode ([#114](https://github.com/folke/zen-mode.nvim/issues/114)) ([c952f60](https://github.com/folke/zen-mode.nvim/commit/c952f607139a3c7bfd50ed091c8e5526dd057f63))
* **plugins:** implement Neovide plugin ([#131](https://github.com/folke/zen-mode.nvim/issues/131)) ([e6e83f6](https://github.com/folke/zen-mode.nvim/commit/e6e83f61ca40c730b7a852c807139f8c8a292316))


### Bug Fixes

* add default to ZenBg to allow customization ([#108](https://github.com/folke/zen-mode.nvim/issues/108)) ([c1dea35](https://github.com/folke/zen-mode.nvim/commit/c1dea35af945b08ad50a2e70cc734a9a14640078))
* assign filetype to background buffer ([#91](https://github.com/folke/zen-mode.nvim/issues/91)) ([7175e4d](https://github.com/folke/zen-mode.nvim/commit/7175e4d39f3ee66cf191340b65c1f8687b27d420))
* fixed opts.window.backdrop. Fixes [#115](https://github.com/folke/zen-mode.nvim/issues/115), Closes [#119](https://github.com/folke/zen-mode.nvim/issues/119) ([6b4acad](https://github.com/folke/zen-mode.nvim/commit/6b4acad4064fa37fbd8953d2d45b83b77174d524))
* tmux+wezterm plugin ([#103](https://github.com/folke/zen-mode.nvim/issues/103)) ([3506220](https://github.com/folke/zen-mode.nvim/commit/35062207ae1db4265e734e2a838689c9f5cf0fb0))

## [1.3.0](https://github.com/folke/zen-mode.nvim/compare/v1.2.0...v1.3.0) (2023-10-05)


### Features

* **statusline:** turn on/off statusline in zen mode ([#101](https://github.com/folke/zen-mode.nvim/issues/101)) ([6c5777c](https://github.com/folke/zen-mode.nvim/commit/6c5777cf9964c0db1dfde96c9a68b066722b84f0))

## [1.2.0](https://github.com/folke/zen-mode.nvim/compare/v1.1.1...v1.2.0) (2023-04-17)


### Features

* **plugins:** wezterm integration ([#61](https://github.com/folke/zen-mode.nvim/issues/61)) ([6b9c522](https://github.com/folke/zen-mode.nvim/commit/6b9c522b5f74706a46309b83d561ae5cac0f67f5))

## [1.1.1](https://github.com/folke/zen-mode.nvim/compare/v1.1.0...v1.1.1) (2023-03-19)


### Bug Fixes

* Make fold and vertical fcs zen ([#85](https://github.com/folke/zen-mode.nvim/issues/85)) ([fc7f1fb](https://github.com/folke/zen-mode.nvim/commit/fc7f1fb40a7d13ea34dd27e645e64c8b431a5269))

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
