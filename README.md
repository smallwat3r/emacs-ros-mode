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

**Build integration** - compile ROS workspaces from Emacs using
`ros-compile` (full workspace) or `ros-compile-package` (current
package only). Supports colcon (ROS2), catkin build, and catkin_make.

## Supported file types

| Extension  | Description        | Mode           |
|------------|--------------------|----------------|
| `.msg`     | Message definition  | `ros-msg-mode` |
| `.srv`     | Service definition  | `ros-msg-mode` |
| `.action`  | Action definition   | `ros-msg-mode` |
| `.launch`  | Launch file (XML)   | `nxml-mode`    |

## Build integration

`ros-compile` and `ros-compile-package` run your ROS build tool
from the workspace root via Emacs' built-in `compile`, giving you
error navigation and highlighting out of the box.

The workspace root is auto-detected by walking up from the current
buffer looking for ROS-specific markers (`.catkin_workspace`,
`.catkin_tools/`, or `src/` alongside `build/`, `install/`,
or `log/`). You can also set it explicitly via
`ros-workspace-root`. The package name is read from the nearest
`package.xml`.

| Variable             | Description                          | Default  |
|----------------------|--------------------------------------|----------|
| `ros-build-tool`     | Build tool (`colcon`, `catkin-tools`, `catkin-make`) | `colcon` |
| `ros-build-args`     | Extra arguments passed to the build command | `""`     |
| `ros-workspace-root` | Explicit workspace path (nil for auto-detect) | `nil`    |

Example keybindings:

```elisp
(with-eval-after-load 'ros-mode
  (keymap-global-set "C-c r w" #'ros-compile)
  (keymap-global-set "C-c r p" #'ros-compile-package))
```

### TRAMP

Build commands work over TRAMP (they run on the remote host).
Auto-detection of the workspace root will be slow over TRAMP due
to remote file checks on every parent directory. Set
`ros-workspace-root` in a `.dir-locals.el` at the workspace root
to skip detection:

```elisp
((nil . ((ros-workspace-root . "/ssh:robot:/home/user/catkin_ws"))))
```

## Installation

Requires Emacs 27.1 or later.

### use-package + elpaca

```elisp
(use-package ros-mode
  :ensure (:host github :repo "smallwat3r/emacs-ros-mode")
  :mode (("\\.msg\\'" . ros-msg-mode)
         ("\\.srv\\'" . ros-msg-mode)
         ("\\.action\\'" . ros-msg-mode)))
```

### use-package + straight.el

```elisp
(use-package ros-mode
  :straight (:host github :repo "smallwat3r/emacs-ros-mode")
  :mode (("\\.msg\\'" . ros-msg-mode)
         ("\\.srv\\'" . ros-msg-mode)
         ("\\.action\\'" . ros-msg-mode)))
```

### Manual

Clone this repository and add it to your `load-path`:

```elisp
(add-to-list 'load-path "/path/to/emacs-ros-mode")
(require 'ros-mode)
```

## License

GPL-3.0
