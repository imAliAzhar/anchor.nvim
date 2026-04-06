# anchor.nvim

A fast, minimal buffer switcher for Neovim with MRU (Most Recently Used) ordering.

https://github.com/user-attachments/assets/placeholder

## Features

- Buffers ordered by most recently used
- Floating window appears in the bottom-right corner
- Single key activates the switcher; pressing again cycles through buffers
- Delete buffers directly from the list
- Existing keymaps are preserved and restored on dismiss

## Requirements

- Neovim >= 0.9.0

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "aliazhar/anchor.nvim",
  config = function()
    require("anchor").setup()
  end,
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "aliazhar/anchor.nvim",
  config = function()
    require("anchor").setup()
  end,
}
```

## Configuration

Below is the default configuration. You only need to pass the values you want to override.

```lua
require("anchor").setup({
  keymaps = {
    activate = "'",        -- activate / cycle to next buffer
    hide = "<esc>",        -- close the switcher
    focus_next = "j",      -- move down in the list
    focus_previous = "k",  -- move up in the list
    confirm = "a",         -- switch to the highlighted buffer
    delete = "w",          -- delete the highlighted buffer
  },
  bg = "#1e1e2e",          -- floating window background
  fg = "#cdd6f4",          -- floating window foreground
})
```

## Usage

1. Press `'` to open the buffer switcher.
2. A floating window appears after a short delay showing your buffers in MRU order.
3. Press `'` again (or `j`/`k`) to cycle through the list.
4. Press `a` to jump to the highlighted buffer, or `w` to delete it.
5. Press `<esc>` to dismiss without switching.

### Default Keymaps

| Key     | Action                                  |
| ------- | --------------------------------------- |
| `'`     | Activate switcher / cycle to next       |
| `j`     | Focus next buffer                       |
| `k`     | Focus previous buffer                   |
| `a`     | Confirm selection                       |
| `w`     | Delete highlighted buffer               |
| `<esc>` | Close switcher                          |

## Highlight Groups

| Group            | Default                | Description              |
| ---------------- | ---------------------- | ------------------------ |
| `AnchorNormal`   | bg `#1e1e2e` fg `#cdd6f4` | Floating window text     |
| `AnchorBorder`   | fg `#1e1e2e`           | Floating window border   |

Override these in your config or colorscheme to match your theme.

## License

MIT
