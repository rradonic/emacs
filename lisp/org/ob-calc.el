;;; ob-calc.el --- org-babel functions for calc code evaluation

;; Copyright (C) 2010  Free Software Foundation, Inc.

;; Author: Eric Schulte
;; Keywords: literate programming, reproducible research
;; Homepage: http://orgmode.org
;; Version: 7.3

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating calc code

;;; Code:
(require 'ob)
(require 'calc)
(require 'calc-trail)
(eval-when-compile (require 'ob-comint))

(defvar org-babel-default-header-args:calc nil
  "Default arguments for evaluating an calc source block.")

(defun org-babel-expand-body:calc (body params)
  "Expand BODY according to PARAMS, return the expanded body." body)

(defun org-babel-execute:calc (body params)
  "Execute a block of calc code with Babel."
  (mapcar
   (lambda (line)
     (when (> (length line) 0)
       (if (string= "'" (substring line 0 1))
	   (funcall (lookup-key calc-mode-map (substring line 1)) nil)
	 (calc-push-list
	  (list ((lambda (res)
		   (cond
		    ((numberp res) res)
		    ((listp res) (error "calc error \"%s\" on input \"%s\""
					(cadr res) line))
		    (t res))
		   (if (numberp res) res (math-read-number res)))
		 (calc-eval line)))))))
   (mapcar #'org-babel-trim
	   (split-string (org-babel-expand-body:calc body params) "[\n\r]")))
  (save-excursion
    (set-buffer (get-buffer "*Calculator*"))
    (calc-eval (calc-top 1))))

(provide 'ob-calc)

;; arch-tag: 5c57a3b7-5818-4c6c-acda-7a94831a6449

;;; ob-calc.el ends here