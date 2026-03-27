;;; ros-face.el --- Syntax highlighting for ROS files -*- lexical-binding: t -*-

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

;; Syntax highlighting for ROS (Robot Operating System) files.
;;
;; Provides `ros-face-msg-mode', a major mode with syntax
;; highlighting for ROS interface definition files:
;;
;; - `.msg' - message definitions
;; - `.srv' - service definitions
;; - `.action' - action definitions
;;
;; Provides `ros-face-idl-mode', a major mode with syntax
;; highlighting for ROS 2 IDL interface files (`.idl').
;;
;; Also registers `.launch' files to open in `nxml-mode'.

;;; Code:

(defgroup ros-face nil
  "Syntax highlighting for ROS files."
  :group 'languages
  :prefix "ros-face-")

(defconst ros-face-msg-builtin-types
  '("bool"
    "byte" "char"
    "int8" "uint8" "int16" "uint16"
    "int32" "uint32" "int64" "uint64"
    "float32" "float64"
    "string"
    "time" "duration"
    "Header")
  "ROS built-in primitive and utility types.")

(defconst ros-face-msg-font-lock-keywords
  (let ((type-re
         (regexp-opt ros-face-msg-builtin-types 'symbols)))
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
                "\\(\\[<?=?[0-9]*\\]\\)?")
       (1 font-lock-type-face)
       (2 font-lock-type-face nil t))
      ;; Custom types: pkg/Type or just PascalType
      (,(concat "^\\s-*"
                "\\([a-zA-Z_][a-zA-Z0-9_]*/\\)?"
                "\\([A-Z][A-Za-z0-9_]*\\)"
                "\\(\\[<?=?[0-9]*\\]\\)?"
                "\\s-+[a-zA-Z_]")
       (1 font-lock-type-face nil t)
       (2 font-lock-type-face)
       (3 font-lock-type-face nil t))
      ;; Field name
      ("^\\s-*[a-zA-Z_].*\\s-+\
\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*$"
       (1 font-lock-variable-name-face))))
  "Font-lock keywords for `ros-face-msg-mode'.")

(defvar ros-face-msg-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?# "<" st)
    (modify-syntax-entry ?\n ">" st)
    (modify-syntax-entry ?_ "w" st)
    st)
  "Syntax table for `ros-face-msg-mode'.")

;;;###autoload
(define-derived-mode ros-face-msg-mode prog-mode "ROS-Msg"
  "Major mode for ROS message, service, and action files.

Provides syntax highlighting for ROS interface definitions
including built-in types, custom message types, field names,
constants, array notation, and section separators (---)."
  :syntax-table ros-face-msg-mode-syntax-table
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local font-lock-defaults
              '(ros-face-msg-font-lock-keywords)))

(defconst ros-face-idl-keywords
  '("module" "struct" "enum" "union" "switch" "case"
    "default" "const" "typedef" "sequence" "map"
    "abstract" "interface")
  "IDL keywords for `ros-face-idl-mode'.")

(defconst ros-face-idl-types
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
  "IDL built-in types for `ros-face-idl-mode'.")

(defconst ros-face-idl-constants
  '("TRUE" "FALSE")
  "IDL constant values for `ros-face-idl-mode'.")

(defconst ros-face-idl-font-lock-keywords
  (let ((kw-re (regexp-opt ros-face-idl-keywords 'symbols))
        (type-re (regexp-opt ros-face-idl-types 'symbols))
        (const-re
         (regexp-opt ros-face-idl-constants 'symbols)))
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
  "Font-lock keywords for `ros-face-idl-mode'.")

(defvar ros-face-idl-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?\" "\"" st)
    st)
  "Syntax table for `ros-face-idl-mode'.")

;;;###autoload
(define-derived-mode ros-face-idl-mode prog-mode "ROS-IDL"
  "Major mode for ROS IDL interface files.

Provides syntax highlighting for OMG IDL definitions used
in ROS 2, including modules, structs, enums, built-in and
ROS-specific types, annotations, and preprocessor directives."
  :syntax-table ros-face-idl-mode-syntax-table
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local font-lock-defaults
              '(ros-face-idl-font-lock-keywords)))

;;;###autoload
(dolist (ext '("\\.msg\\'" "\\.srv\\'" "\\.action\\'"))
  (add-to-list
   'auto-mode-alist (cons ext 'ros-face-msg-mode)))

;;;###autoload
(add-to-list
 'auto-mode-alist '("\\.idl\\'" . ros-face-idl-mode))

;;;###autoload
(add-to-list
 'auto-mode-alist '("\\.launch\\'" . nxml-mode))

(provide 'ros-face)
;;; ros-face.el ends here
