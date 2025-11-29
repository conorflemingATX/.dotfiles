;; -*- lexical-binding: t; -*-

(use-package no-littering
  :ensure t
  :config
  (setq no-littering-etc-directory
          (expand-file-name "config/" user-emacs-directory))
  (setq no-littering-var-directory
          (expand-file-name "data/" user-emacs-directory)))

(provide 'no-littering-config)
