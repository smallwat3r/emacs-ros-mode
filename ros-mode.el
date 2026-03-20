;;; ros-mode.el --- Emacs support for ROS files -*- lexical-binding: t -*-

;; Copyright (C) 2026 Matthieu Petiteau

;; Author: Matthieu Petiteau <mpetiteau.pro@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: languages, ros, robotics
;; URL: https://github.com/smallwat3r/emacs-ros-mode

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public
;; License along with this program. If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Emacs support for ROS (Robot Operating System).
;;
;; Provides `ros-msg-mode', a major mode with syntax highlighting
;; for ROS interface definition files:
;;
;; - `.msg' - message definitions
;; - `.srv' - service definitions
;; - `.action' - action definitions
;;
;; Provides `ros-idl-mode', a major mode with syntax highlighting
;; for ROS 2 IDL interface files (`.idl').
;;
;; Also registers `.launch' files to open in `nxml-mode'.
;;
;; Build integration via `ros-compile' and `ros-compile-package'
;; supports colcon (ROS2), catkin build, and catkin_make.

;;; Code:

(require 'cl-lib)

(defgroup ros nil
  "Emacs support for ROS files."
  :group 'languages
  :prefix "ros-")

(defcustom ros-build-tool 'colcon
  "Build tool to use for ROS workspace compilation.
Supported values are `colcon', `catkin-tools', and `catkin-make'."
  :type '(choice (const :tag "colcon build" colcon)
                 (const :tag "catkin build" catkin-tools)
                 (const :tag "catkin_make" catkin-make))
  :group 'ros)

(defcustom ros-build-args ""
  "Additional arguments passed to the build command."
  :type 'string
  :group 'ros)

(defcustom ros-workspace-root nil
  "Explicit path to the ROS workspace root.
When nil, `ros--find-workspace-root' uses heuristics."
  :type '(choice (const :tag "Auto-detect" nil)
                 (directory :tag "Workspace path"))
  :group 'ros)

(put 'ros-build-tool 'safe-local-variable
     (lambda (v) (memq v '(colcon catkin-tools catkin-make))))
(put 'ros-build-args 'safe-local-variable #'stringp)
(put 'ros-workspace-root 'safe-local-variable
     (lambda (v) (or (null v) (stringp v))))

(defun ros--ros-workspace-p (dir)
  "Return non-nil if DIR looks like a ROS workspace."
  (or (file-exists-p
       (expand-file-name ".catkin_workspace" dir))
      (file-directory-p
       (expand-file-name ".catkin_tools" dir))
      (and (file-directory-p
            (expand-file-name "src" dir))
           (cl-some
            (lambda (marker)
              (file-directory-p
               (expand-file-name marker dir)))
            '("build" "install" "log")))))

(defun ros--find-workspace-root ()
  "Find the ROS workspace root.
Uses `ros-workspace-root' if set, otherwise walks up from
`default-directory' looking for ROS-specific markers."
  (or (and ros-workspace-root
           (expand-file-name ros-workspace-root))
      (let ((dir (locate-dominating-file
                  default-directory
                  #'ros--ros-workspace-p)))
        (when dir (expand-file-name dir)))))

(defun ros--find-package-root ()
  "Find the nearest ROS package root by locating package.xml."
  (let ((dir (locate-dominating-file
              default-directory "package.xml")))
    (when dir (expand-file-name dir))))

(defun ros--package-name ()
  "Return the name of the current ROS package, or nil."
  (let ((root (ros--find-package-root)))
    (when root
      (let ((pkg-xml (expand-file-name "package.xml" root)))
        (with-temp-buffer
          (insert-file-contents pkg-xml)
          (when (re-search-forward
                 "<name>\\(.+?\\)</name>" nil t)
            (match-string 1)))))))

(defun ros--build-command (&optional package)
  "Return the build command string.
When PACKAGE is non-nil, build only that package."
  (let ((pkg-flag
         (when package
           (pcase ros-build-tool
             ('colcon
              (format " --packages-select %s" package))
             ('catkin-tools
              (format " --no-deps %s" package))
             ('catkin-make
              (format " --pkg %s" package))))))
    (concat
     (pcase ros-build-tool
       ('colcon "colcon build")
       ('catkin-tools "catkin build")
       ('catkin-make "catkin_make"))
     (or pkg-flag "")
     (if (string-empty-p ros-build-args)
         ""
       (concat " " ros-build-args)))))

;;;###autoload
(defun ros-compile ()
  "Compile the entire ROS workspace."
  (interactive)
  (let ((ws (ros--find-workspace-root)))
    (unless ws
      (user-error "No ROS workspace found"))
    (let ((default-directory ws))
      (compile (ros--build-command)))))

;;;###autoload
(defun ros-compile-package ()
  "Compile only the current ROS package."
  (interactive)
  (let ((ws (ros--find-workspace-root))
        (pkg (ros--package-name)))
    (unless ws
      (user-error "No ROS workspace found"))
    (unless pkg
      (user-error
       "No package.xml found for current buffer"))
    (let ((default-directory ws))
      (compile (ros--build-command pkg)))))

(defconst ros-msg-builtin-types
  '("bool"
    "byte" "char"
    "int8" "uint8" "int16" "uint16"
    "int32" "uint32" "int64" "uint64"
    "float32" "float64"
    "string"
    "time" "duration"
    "Header")
  "ROS built-in primitive and utility types.")

(defconst ros-msg-font-lock-keywords
  (let ((type-re (regexp-opt ros-msg-builtin-types 'symbols)))
    `(;; Section separator
      ("^---$" . font-lock-preprocessor-face)
      ;; Constant assignment: TYPE NAME=VALUE
      (,(concat "^\\s-*" type-re
                "\\(\\[\\]\\)?\\s-+"
                "\\([A-Za-z_][A-Za-z0-9_]*\\)"
                "\\s-*=\\s-*\\(.*\\)$")
       (1 font-lock-type-face)
       (2 font-lock-type-face nil t)
       (3 font-lock-constant-face)
       (4 font-lock-string-face))
      ;; Built-in type with optional array brackets
      (,(concat "^\\s-*" type-re
                "\\(\\[\\<=?[0-9]*\\]\\)?")
       (1 font-lock-type-face)
       (2 font-lock-type-face nil t))
      ;; Custom types: pkg/Type or just PascalType
      (,(concat "^\\s-*"
                "\\([a-zA-Z_][a-zA-Z0-9_]*/\\)?"
                "\\([A-Z][A-Za-z0-9_]*\\)"
                "\\(\\[\\<=?[0-9]*\\]\\)?"
                "\\s-+[a-zA-Z_]")
       (1 font-lock-type-face nil t)
       (2 font-lock-type-face)
       (3 font-lock-type-face nil t))
      ;; Field name
      ("^\\s-*[a-zA-Z_].*\\s-+\
\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*$"
       (1 font-lock-variable-name-face))))
  "Font-lock keywords for `ros-msg-mode'.")

(defvar ros-msg-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?# "<" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?_ "w" st)
    st)
  "Syntax table for `ros-msg-mode'.")

;;;###autoload
(define-derived-mode ros-msg-mode prog-mode "ROS-Msg"
  "Major mode for editing ROS message, service, and action files.

Provides syntax highlighting for ROS interface definitions
including built-in types, custom message types, field names,
constants, array notation, and section separators (---)."
  :syntax-table ros-msg-mode-syntax-table
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local font-lock-defaults
              '(ros-msg-font-lock-keywords)))

(defconst ros-idl-keywords
  '("module" "struct" "enum" "union" "switch" "case"
    "default" "const" "typedef" "sequence" "map"
    "abstract" "interface")
  "IDL keywords for `ros-idl-mode'.")

(defconst ros-idl-types
  '(;; OMG IDL types
    "boolean" "octet"
    "char" "wchar"
    "short" "long" "float" "double"
    "unsigned" "signed"
    "string" "wstring"
    "any" "void"
    ;; ROS shorthand types
    "bool" "byte"
    "int8" "uint8" "int16" "uint16"
    "int32" "uint32" "int64" "uint64"
    "float32" "float64")
  "IDL built-in types for `ros-idl-mode'.")

(defconst ros-idl-constants
  '("TRUE" "FALSE")
  "IDL constant values for `ros-idl-mode'.")

(defconst ros-idl-font-lock-keywords
  (let ((kw-re (regexp-opt ros-idl-keywords 'symbols))
        (type-re (regexp-opt ros-idl-types 'symbols))
        (const-re (regexp-opt ros-idl-constants 'symbols)))
    `(;; Preprocessor directives
      (,(concat "^\\s-*#\\s-*"
                "\\(include\\|ifndef\\|define\\|"
                "endif\\|ifdef\\|pragma\\)\\b")
       (0 font-lock-preprocessor-face))
      ;; #include filename
      (,(concat "^\\s-*#\\s-*include\\s-+"
                "\\(\"[^\"]+\"\\|<[^>]+>\\)")
       (1 font-lock-string-face t))
      ;; Annotations
      ("@[a-zA-Z_][a-zA-Z0-9_]*"
       . font-lock-preprocessor-face)
      ;; Keywords
      (,kw-re . font-lock-keyword-face)
      ;; Constants
      (,const-re . font-lock-constant-face)
      ;; Module/struct/enum/union name
      (,(concat
         "\\<\\(module\\|struct\\|enum\\|union\\)"
         "\\s-+\\([a-zA-Z_][a-zA-Z0-9_]*\\)")
       (2 font-lock-function-name-face))
      ;; Types
      (,type-re . font-lock-type-face)
      ;; Namespace-qualified types: foo::bar::Baz
      (,(concat
         "\\<[a-zA-Z_][a-zA-Z0-9_]*"
         "\\(::[a-zA-Z_][a-zA-Z0-9_]*\\)+")
       . font-lock-type-face)))
  "Font-lock keywords for `ros-idl-mode'.")

(defvar ros-idl-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?\" "\"" st)
    st)
  "Syntax table for `ros-idl-mode'.")

;;;###autoload
(define-derived-mode ros-idl-mode prog-mode "ROS-IDL"
  "Major mode for editing ROS IDL interface files.

Provides syntax highlighting for OMG IDL definitions used
in ROS 2, including modules, structs, enums, built-in and
ROS-specific types, annotations, and preprocessor directives."
  :syntax-table ros-idl-mode-syntax-table
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local font-lock-defaults
              '(ros-idl-font-lock-keywords)))

;;;###autoload
(dolist (ext '("\\.msg\\'" "\\.srv\\'" "\\.action\\'"))
  (add-to-list 'auto-mode-alist (cons ext 'ros-msg-mode)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.idl\\'" . ros-idl-mode))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.launch\\'" . nxml-mode))

(provide 'ros-mode)
;;; ros-mode.el ends here
