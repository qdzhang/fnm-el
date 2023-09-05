;;; fnm.el --- Use fnm to manage node versions       -*- lexical-binding: t; -*-

;; Copyright (C) 2023  qdzhang

;; Author: qdzhang <qdzhangcn@gmail.com>
;; Maintainer: qdzhang <qdzhangcn@gmail.com>
;; Created:  5 September 2023
;; URL: https://github.com/qdzhang/fnm-el
;; Version: 0.1
;; Keywords: node
;; Package-Requires: ((cl-seq "2.0"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Manage nodejs versions using fnm.

;;; Code:

(defun fnm--node-root ()
  "Fnm installation path"
  (getenv "FNM_DIR"))

;; TODO: determine .nvmrc file
;; This function only manipulate .node-version currently
(defun fnm--read-version-file ()
  "Read .node-version or .nvmrc file to get wanted node version."
  (let ((default-directory (project-root (project-current))))
    (with-temp-buffer
      (insert-file-contents ".node-version")
      (replace-regexp-in-string "\n" "" (buffer-string)))))


(defun fnm--versions ()
  "Use `fnm list' to list all available nodejs versions"
  (let* ((versions (shell-command-to-string "fnm list"))
         (versions-str (split-string versions "\n" t)))
    versions-str))


;; TODO: Other selecting approachs to use, such as: user input or system default.
;; This function only manipulate .node-version currently
(defun fnm--version-selected ()
  "Select a node version depending on .node-version file or user input."
  ;; Currently only use the .node-version file.
  (fnm--read-version-file))


(defun fnm--node-bin-path ()
  "Concatenate the path of nodejs bins."
  (expand-file-name (concat "node-versions/"
                            (fnm--version-selected)
                            "/installation/bin")
                    (fnm--node-root)))


;;;###autoload
(defun fnm-set ()
  "Setup PATH and `exec-path' to use specific node version managed by fnm."
  (interactive)
  (let* ((bin-path (fnm--node-bin-path))
         (paths (cons
                 bin-path
                 (parse-colon-path (getenv "PATH")))))
    (setenv "PATH" (mapconcat 'identity paths path-separator))
    (setq exec-path (cons bin-path exec-path))))


(provide 'fnm)
;;; fnm.el ends here
