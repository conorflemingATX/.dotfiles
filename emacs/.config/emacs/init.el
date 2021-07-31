;;; package --- summary

;;; Commentary:

;;; Code:

;; Basic UI Configuration ------------------------------------------------------

(setq inhibit-startup-message t)

(set-fringe-mode 10)        ; Give some breathing room

;; Set up the visible bell
(setq visible-bell t)

;; Font Configuration ----------------------------------------------------------

(set-face-attribute 'default nil :font "Fira Code Retina")

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina")

;; Package Manager Configuration -----------------------------------------------

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(column-number-mode)
(global-display-line-numbers-mode t)

(use-package afternoon-theme)
(load-theme 'afternoon t)

;; lsp-mode --------------------------------------------------------------------
(use-package lsp-mode
  :ensure t)

(use-package lsp-ui
  :ensure t
  :hook
  ((web-mode . lsp-mode)
   (lsp-mode . lsp-enable-which-key-integration))
  :config
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-sideline-show-hover t)
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-restart 'auto-restart))

;; Ivy Configuration -----------------------------------------------------------

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package lsp-ivy
  :ensure t)

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; Projectile Configuration ----------------------------------------------------

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :init)

(use-package counsel-projectile
  :config (counsel-projectile-mode))

;; Magit Configuration ---------------------------------------------------------

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(defun efs/org-mode-setup ()
  "Setup variables for 'org-mode'."
  (variable-pitch-mode 1)
  (visual-line-mode 1))

;; Company ---------------------------------------------------------------------
(setq company-minimum-prefix-length 1
      company-idle-delay 0.0)
(use-package company
  :config (add-hook 'after-init-hook 'global-company-mode))

;; Flycheck --------------------------------------------------------------------
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package flycheck-inline
  :ensure t
  :after flycheck
  :hook (flycheck-mode . flycheck-inline-mode))

;; Org Mode Configuration ------------------------------------------------------
(use-package jupyter
  :defer t
  :init
  (setq org-babel-default-header-args:jupyter-python '((:async . "yes")
                                                       (:session . "py"))))

(use-package org
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-confirm-babel-evaluate nil)
  (org-babel-do-load-languages
    'org-babel-load-languages
    '((jupyter . t))))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flycheck-checker-error-threshold 600)
 '(package-selected-packages
   '(lsp-ui jupyter magit counsel-projectile counsel ivy-rich ivy with-editor use-package tide slime sass-mode rjsx-mode rainbow-mode rainbow-delimiters pug-mode projectile prettier-js parinfer-rust-mode org-bullets olivetti ob-ipython ob-elixir nix-mode neotree markdown-mode lavenderless-theme lavender-theme json-mode indium helpful fsharp-mode elixir-mode dracula-theme afternoon-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; JSON ------------------------------------------------------------------------
(defun cf/format-json-on-save ()
  "Format json on save."
  (add-hook 'before-save-hook #'json-pretty-print-buffer))

(add-hook 'json-mode #'cf/format-json-on-save)

;; web-mode --------------------------------------------------------------------
(use-package add-node-modules-path
  :ensure t
  :after flycheck
  :hook
  (flycheck-mode . add-node-modules-path))

(defun web-mode-init-prettier ()
  "Configure prettier for use with 'web-mode'."
  (add-node-modules-path)
  (prettier-js-mode))

(setq-default flycheck-disabled-checkers
	      (append flycheck-disabled-checkers
		      '(javascript-jshint json-jsonlint)))
(setq web-mode-markup-indent-offset 2)
(setq web-mode-code-indent-offset 2)
(setq web-mode-css-indent-offset 2)
(use-package web-mode
  :ensure t
  :after '(lsp flycheck add-node-modules-path prettier-js)
  :hook (web-mode . web-mode-init-prettier)
  :mode (("\\.js\\'" . web-mode)
	 ("\\.jsx\\'" . web-mode)
	 ("\\.ts\\'" . web-mode)
	 ("\\.tsx\\'" . web-mode)
	 ("\\.html\\'" . web-mode))
  :commands web-mode
  :config
  ((flycheck-add-mode 'javascript-eslint 'web-mode)
   (setq lsp-eslint-enable t)))

;; Typescript ------------------------------------------------------------------
(use-package prettier-js
  :ensure t)

(provide 'init)
;;; init.el ends here
