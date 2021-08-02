;;; ement-bufler.el --- Bufler integration for Ement  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Adam Porter

;; Author: Adam Porter <adam@alphapapa.net>
;; Keywords:

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

;;

;;; Code:

;;;; Requirements

(require 'bufler)

;;;; Variables


;;;; Customization


;;;; Commands

(defun ement-bufler-list ()
  "List room buffers with `bufler'.
Only rooms which have a live buffer are shown."
  (interactive)
  (let ((buffer (get-buffer "*Ement Bufler List*")))
    (unless buffer
      (with-current-buffer (setf buffer (get-buffer-create "*Ement Bufler List*"))
        (setq-local bufler-groups
                    (bufler-defgroups
                      (group (group-or "Ement"
                                       (mode-match "Rooms" "ement-room-mode")
                                       (name-match "Other" (rx bos "*Ement")))
                             (group
                              (group-and "unread"
                                         #'buffer-modified-p))
                             (group (lambda (buffer)
                                      (when (buffer-local-value 'ement-room buffer)
                                        (when (ement-room--direct-p (buffer-local-value 'ement-room buffer)
                                                                    (buffer-local-value 'ement-session buffer))
                                          "Direct"))))
                             (lambda (buffer)
                               (when (buffer-local-value 'ement-room buffer)
                                 (let ((test-against (replace-regexp-in-string
                                                      (rx ":" (1+ (not (any ":"))) eos) ""
                                                      (or (ement-room-canonical-alias (buffer-local-value 'ement-room buffer))
                                                          (ement-room-id (buffer-local-value 'ement-room buffer))))))
                                   (cl-flet ((matches (pattern) (string-match-p pattern test-against)))
                                     (cond ((matches (rx (or "emacs" "org-mode" "ement.el")))
                                            "Emacs")
                                           ((matches "matrix")
                                            "Matrix")))))))))
        (setq-local bufler-use-cache nil)
        (setq-local bufler-filter-buffer-fns
                    (list (lambda (buffer)
                            (not (eq 'ement-room-mode (buffer-local-value 'major-mode buffer))))))))
    (with-current-buffer buffer
      (bufler-list :list-buffer buffer))))

;;;; Functions


;;;; Footer

(provide 'ement-bufler)

;;; ement-bufler.el ends here
