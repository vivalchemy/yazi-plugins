# EasierJump Yazi Plugin

A lightweight and intuitive file navigation plugin for Yazi that allows quick jumping to files using single or double-character labels.

## Important Note

This is a modified version of the original [EasyJump Yazi Plugin](https://gitee.com/DreamMaoMao/easyjump.yazi/) by DreamMaoMao. Special thanks to the original author for their innovative work!

https://github.com/user-attachments/assets/544cf416-ecfc-4a6e-b19c-24a6f6ddc2f9

## Features

- Quick file navigation using single or double-character labels
- Customizable label colors
- Simple and intuitive interface
- Works with both single and multiple file listings

## Installation

### Using ya pack

```bash
ya pack -a vivalchemy/yazi-plugins:easierjump
```

## Configuration

### Keymap Setup

Add the following to your `~/.config/yazi/keymap.toml` to set a shortcut for toggling EasierJump mode:

```toml
[[manager.prepend_keymap]]
on   = [ "i" ]
run = "plugin easierjump"
desc = "easierjump"
```

### Customization

You can customize the plugin's appearance in your Yazi `init.lua` configuration file:

```lua
require("easierjump").setup({
    icon_fg = "#ffffff",         -- Color of file labels
    first_key_fg = "#dc143c"     -- Color of first character in double-character labels
})
```

## Usage

1. Press the configured shortcut key (e.g., `i`) to activate EasierJump mode
2. Single-character labels appear for fewer files
3. Double-character labels appear for more files
4. Press the corresponding label key to jump to that file
5. Press `<Esc>` or `z` to exit EasierJump mode
6. Press `Backspace` to go up a directory
7. Press `x` to navigate without launching the file

## Original Project

- Original Repository: [EasyJump Yazi Plugin](https://gitee.com/DreamMaoMao/easyjump.yazi/)
- Original Author: DreamMaoMao

## License

This project is licensed under the [MIT License](LICENSE)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

A big thank you to DreamMaoMao for the original EasyJump plugin that inspired this modification.
