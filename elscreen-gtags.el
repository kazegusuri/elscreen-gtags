;;; -*- Mode: Emacs-Lisp ; Coding: utf-8 -*-

;;; elscreen-gtags.el --- ElScreen Add-On for gtags

;; Filename: elscreen-gtags.el
;; Author: Masahiro Sano <sabottenda@gmail.com>
;; Copyright (C) 2012 Masahiro Sano

(defconst elscreen-gtags-version "0.1.0 (Oct 01, 2012)")

;;; Commentary:

;; This package is ElScreen Add-On for Mew.

;;; Installation:

;; Put `elscreen-gtags.el' in the `load-path' 
;; and add the following command to your init file.
;; (require 'elscreen-gtags)

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING. If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

(require 'elscreen)
(require 'gtags)

(defun elscreen-get-gtags-stack (screen)
  (let ((screen-property (elscreen-get-screen-property screen)))
    (assoc-default 'gtags-stack screen-property)))

(defun elscreen-set-gtags-stack (screen stack)
  (let ((screen-property (elscreen-get-screen-property screen)))
    (elscreen--set-alist 'screen-property 'gtags-stack stack)
    (elscreen-set-screen-property screen screen-property)))


(defun elscreen-save-gtags-stack (&optional screen)
  "Save the gtags' state for SCREEN, or current screen"
  (elscreen-set-gtags-stack 
   (or screen (elscreen-get-current-screen))
   (list gtags-buffer-stack gtags-point-stack gtags-current-buffer))
)

(defun elscreen-load-gtags-stack (&optional screen)
  "Set global gtags' state to that of SCREEN, or current screen"
  (let ((stack (elscreen-get-gtags-stack 
                (or screen (elscreen-get-current-screen)))))
    (setq gtags-buffer-stack (nth 0 stack))
    (setq gtags-point-stack (nth 1 stack))
    (setq gtags-current-buffer (nth 2 stack)))
)

(add-hook 'elscreen-goto-hook 'elscreen-gtags-goto-hook)
(defun elscreen-gtags-goto-hook ()
  "Save and load gtags' state when screen is swiched"
  (when (elscreen-screen-live-p (elscreen-get-previous-screen))
    (elscreen-save-gtags-stack (elscreen-get-previous-screen)))
  (elscreen-load-gtags-stack (elscreen-get-current-screen))
  )

(add-hook 'elscreen-kill-hook 'elscreen-gtags-kill-hook)
(defun elscreen-gtags-kill-hook ()
  "Just load current gtags' state when screen is killed"
  (elscreen-load-gtags-stack (elscreen-get-current-screen))
  )

(defadvice elscreen-clone (after hogehoge activate)
  "Cloning scleen also copy the gtags' state."
  (let ((stack (elscreen-get-gtags-stack (elscreen-get-previous-screen))))
    (elscreen-set-gtags-stack (elscreen-get-current-screen) stack)
    (elscreen-load-gtags-stack (elscreen-get-current-screen)))
  )


(provide 'elscreen-gtags)

;;; elscreen-gtags.el ends here
