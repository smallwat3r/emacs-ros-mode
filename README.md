# emacs-ros-mode

Emacs support for [ROS](https://www.ros.org/) (Robot Operating System) files.

## Features

**`ros-msg-mode`** - a major mode for ROS interface definition files with
syntax highlighting for:

- Built-in types (`bool`, `int32`, `float64`, `string`, `Header`, etc.)
- Custom message types (`geometry_msgs/Pose`, `PascalCaseType`)
- Array notation (`float64[]`, `string[<=10]`)
- Field names
- Constants (`uint8 FOO=1`)
- `---` section separators (used in `.srv` and `.action` files)
- `#` comments

**Launch files** - `.launch` files are registered to open in `nxml-mode`.

## Supported file types

| Extension  | Description        | Mode           |
|------------|--------------------|----------------|
| `.msg`     | Message definition  | `ros-msg-mode` |
| `.srv`     | Service definition  | `ros-msg-mode` |
| `.action`  | Action definition   | `ros-msg-mode` |
| `.launch`  | Launch file (XML)   | `nxml-mode`    |

## Installation

Requires Emacs 27.1 or later.

### use-package + elpaca

```elisp
(use-package ros-mode
  :ensure (:host github :repo "smallwat3r/emacs-ros-mode")
  :mode (("\\.msg\\'" "\\.srv\\'" "\\.action\\'") . ros-msg-mode))
```

### use-package + straight.el

```elisp
(use-package ros-mode
  :straight (:host github :repo "smallwat3r/emacs-ros-mode")
  :mode (("\\.msg\\'" "\\.srv\\'" "\\.action\\'") . ros-msg-mode))
```

### Manual

Clone this repository and add it to your `load-path`:

```elisp
(add-to-list 'load-path "/path/to/emacs-ros-mode")
(require 'ros-mode)
```

## License

GPL-3.0
