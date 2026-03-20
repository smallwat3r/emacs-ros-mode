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

;; Emacs support for ROS (Robot Operating System) files.
;;
;; Provides `ros-msg-mode', a major mode with syntax highlighting
;; for ROS interface definition files:
;;
;; - `.msg' - message definitions
;; - `.srv' - service definitions (request/response separated by ---)
;; - `.action' - action definitions (goal/result/feedback separated
;;   by ---)
;;
;; Also registers `.launch' files to open in `nxml-mode'.

;;; Code:

(defgroup ros nil
  "Emacs support for ROS files."
  :group 'languages
  :prefix "ros-")

(defconst ros-msg-builtin-types
  '("bool"
    "byte" "char"
    "int8" "uint8" "int16" "uint16"
    "int32" "uint32" "int64" "uint64"
    "float32" "float64"
    "string" "wstring"
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

;;;###autoload
(dolist (ext '("\\.msg\\'" "\\.srv\\'" "\\.action\\'"))
  (add-to-list 'auto-mode-alist (cons ext 'ros-msg-mode)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.launch\\'" . nxml-mode))

(provide 'ros-mode)
;;; ros-mode.el ends here
