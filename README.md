# ros-face

Syntax highlighting for [ROS](https://www.ros.org/) (Robot Operating
System) files in Emacs.

For ROS tooling (build, workspace management, topic/node exploration),
see [ros.el](https://github.com/DerBeutlin/ros.el).

## Features

### `ros-face-msg-mode`

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

### `ros-face-idl-mode`

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

| Extension  | Description        | Mode                |
|------------|--------------------|---------------------|
| `.msg`     | Message definition  | `ros-face-msg-mode` |
| `.srv`     | Service definition  | `ros-face-msg-mode` |
| `.action`  | Action definition   | `ros-face-msg-mode` |
| `.idl`     | IDL definition      | `ros-face-idl-mode` |
| `.launch`  | Launch file (XML)   | `nxml-mode`         |

## Installation

Requires Emacs 27.1 or later.

### use-package + elpaca

```elisp
(use-package ros-face
  :ensure (:host github :repo "smallwat3r/emacs-ros-face"))
```

### Manual

Clone this repository and add it to your `load-path`:

```elisp
(add-to-list 'load-path "/path/to/emacs-ros-face")
(require 'ros-face)
```

## License

GPL-3.0
