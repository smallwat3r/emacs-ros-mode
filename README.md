# emacs-ros-mode

Emacs support for [ROS](https://www.ros.org/) (Robot Operating System).

## Features

### Syntax highlighting

#### `ros-msg-mode`

Major mode for ROS interface definition files (`.msg`, `.srv`,
`.action`) with font-lock support for:

| Element               | Example                          |
|-----------------------|----------------------------------|
| Built-in types        | `bool`, `int32`, `float64`, `string`, `Header` |
| Custom message types  | `geometry_msgs/Pose`, `PascalCaseType` |
| Array notation        | `float64[]`, `string[<=10]`      |
| Field names           | `linear_velocity`                |
| Constants             | `uint8 FOO=1`                    |
| Section separators    | `---`                            |
| Comments              | `# ...`                          |

`.msg`

![msg](images/msg.png)

`.srv`

![srv](images/srv.png)

`.action`

![action](images/action.png)

#### `ros-idl-mode`

Major mode for ROS 2 IDL interface files (`.idl`) with font-lock
support for:

| Element               | Example                          |
|-----------------------|----------------------------------|
| IDL keywords          | `module`, `struct`, `enum`, `typedef` |
| Built-in types        | `boolean`, `float`, `string`, `wstring` |
| ROS shorthand types   | `bool`, `int32`, `float64`       |
| Annotations           | `@key`, `@default`, `@verbatim`  |
| Preprocessor          | `#include`, `#ifndef`            |
| Qualified types       | `geometry_msgs::msg::Point`      |
| Constants             | `TRUE`, `FALSE`                  |
| Comments              | `//`, `/* ... */`                |

![idl](images/idl.png)

### File associations

| Extension  | Description        | Mode           |
|------------|--------------------|----------------|
| `.msg`     | Message definition  | `ros-msg-mode` |
| `.srv`     | Service definition  | `ros-msg-mode` |
| `.action`  | Action definition   | `ros-msg-mode` |
| `.idl`     | IDL definition      | `ros-idl-mode` |
| `.launch`  | Launch file (XML)   | `nxml-mode`    |

### Build integration

Compile ROS workspaces from Emacs with `ros-compile` (full
workspace) and `ros-compile-package` (current package only).

Both commands use Emacs' built-in `compile`, so you get error
navigation and highlighting out of the box. Supports colcon
(ROS2), catkin build, and catkin_make.

| Command               | Description                      |
|-----------------------|----------------------------------|
| `ros-compile`         | Build the entire workspace       |
| `ros-compile-package` | Build only the current package   |

#### Configuration

| Variable             | Description                                       | Default  |
|----------------------|---------------------------------------------------|----------|
| `ros-build-tool`     | Build tool (`colcon`, `catkin-tools`, `catkin-make`) | `colcon` |
| `ros-build-args`     | Extra arguments passed to the build command        | `""`     |
| `ros-workspace-root` | Explicit workspace path (`nil` for auto-detect)   | `nil`    |

All three are safe as dir-local variables, so they can be set
per-workspace in `.dir-locals.el`.

#### Workspace detection

The workspace root is auto-detected by walking up from the current
buffer looking for ROS-specific markers (`.catkin_workspace`,
`.catkin_tools/`, or `src/` alongside `build/`, `install/`, or
`log/`). Set `ros-workspace-root` to skip detection.

The current package is identified by the nearest `package.xml`.

#### TRAMP

Build commands work over TRAMP (they run on the remote host).
Auto-detection will be slow due to remote file checks on every
parent directory. Set `ros-workspace-root` in `.dir-locals.el` to
skip detection:

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
         ("\\.action\\'" . ros-msg-mode)
         ("\\.idl\\'" . ros-idl-mode)))
```

### Manual

Clone this repository and add it to your `load-path`:

```elisp
(add-to-list 'load-path "/path/to/emacs-ros-mode")
(require 'ros-mode)
```

### Example configuration

```elisp
(use-package ros-mode
  :ensure (:host github :repo "smallwat3r/emacs-ros-mode")
  :mode (("\\.msg\\'" . ros-msg-mode)
         ("\\.srv\\'" . ros-msg-mode)
         ("\\.action\\'" . ros-msg-mode)
         ("\\.idl\\'" . ros-idl-mode))
  :custom
  (ros-build-tool 'colcon)
  (ros-build-args "--symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release")
  (ros-workspace-root "~/ros2_ws")
  :bind
  (("C-c r w" . ros-compile)
   ("C-c r p" . ros-compile-package)))
```

Per-workspace settings via `.dir-locals.el`:

```elisp
((nil . ((ros-build-tool . colcon)
         (ros-build-args . "--symlink-install --parallel-workers 4")
         (ros-workspace-root . "/home/user/ros2_ws"))))
```

## License

GPL-3.0
