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

;; envrc -----------------------------------------------------------------------
(use-package envrc
  :after flycheck
  :init
  (envrc-global-mode))

;; no-littering ----------------------------------------------------------------
(use-package no-littering
  :ensure t
  :config
  (setq auto-save-file-name-transforms
	`((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;; exec-path -------------------------------------------------------------------
(use-package exec-path-from-shell
  :ensure
  :init (exec-path-from-shell-initialize))

;; quick-peek ------------------------------------------------------------------
;; (use-package quick-peek
;;   :ensure t)

;; swiper ----------------------------------------------------------------------
(use-package swiper
  :ensure t)

;; multiple-cursors ------------------------------------------------------------
(use-package multiple-cursors
  :ensure t
  :bind
  (("C-S-c C-S-c" . "mc/edit-lines")
   ("C-c m" . "mc/mark-all-like-this")
   ("C->" . "mc/mark-next-like-this")
   ("C-<" . "mc/mark-previous-like-this")))

;; lsp-mode --------------------------------------------------------------------
(use-package lsp-mode
  :ensure t
  :config
  (setq lsp-diagnostics-provider :flycheck
	 lsp-eldoc-render-all nil
	 lsp-headerline-breadcrumb-enable nil
	 lsp-modeline-code-actions-enable nil
	 lsp-modeline-diagnostics-enable nil
	 lsp-modeline-workspace-status-enable nil)
  (setq lsp-rust-analyzer-cargo-watch-command "clippy"
	lsp-rust-analyzer-server-display-inlay-hints t))

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

(use-package lsp-haskell
  :ensure t
  :defer t
  :hook
  (haskell-mode . (lambda ()
		    (lsp))))

;; Eglot ----------------------------------------------------------------------
(use-package eglot
  :ensure t)

(use-package eglot-fsharp
  :ensure t
  :after '(eglot fsharp-mode))

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

(use-package company-cabal
  :ensure t
  :after company
  :config
  (add-to-list 'company-backends 'company-cabal))

;; Flycheck --------------------------------------------------------------------
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode)
  :bind
  (("M-n" . flycheck-next-error)
   ("M-p" . flycheck-previous-error))
  :config
  (setq-default flycheck-global-modes '(not org-mode fsharp-mode)))

(use-package flycheck-inline
  :ensure t
  :after flycheck
  :hook (flycheck-mode . flycheck-inline-mode))

(use-package flymake-diagnostic-at-point
  :ensure t
  :after flymake
  :hook
  (flymake-mode . flymake-diagnostic-at-point-mode))

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
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (org-babel-do-load-languages
    'org-babel-load-languages
    '((jupyter . t)
      (haskell . t))))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; JSON ------------------------------------------------------------------------
(defun cf/format-json-on-save ()
  "Format json on save."
  (add-hook 'before-save-hook #'json-pretty-print-buffer))

(add-hook 'json-mode #'cf/format-json-on-save)

;; web-mode --------------------------------------------------------------------


(use-package add-node-modules-path
  :ensure t
  :after (flycheck web-mode)
  :hook
  (web-mode . add-node-modules-path)
  :config
  (when (executable-find "eslint")
    (print "found eslint!")))


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
  :after (flycheck prettier-js)
  :hook
  (web-mode . web-mode-init-prettier)
  (web-mode . lsp)
  :mode (("\\.js\\'" . web-mode)
	 ("\\.jsx\\'" . web-mode)
	 ("\\.ts\\'" . web-mode)
	 ("\\.tsx\\'" . web-mode)
	 ("\\.html\\'" . web-mode))
  :commands web-mode)

;; Typescript ------------------------------------------------------------------
(use-package prettier-js
  :ensure t)

;; Nix -------------------------------------------------------------------------
;;(use-package nix-mode
;;  :ensure t
;;  :mode ("\\.nix\\'"))

;; Elixir ----------------------------------------------------------------------
;; (use-package elixir-mode
;;   :ensure t
;;   :defer t
;;   :after '(lsp flycheck)
;;   :hook
;;   ((elixir-mode . (lambda () (add-hook 'before-save-hook 'elixir-format nil r)))
;;    (elixir-mode . lsp)))

;; Ocaml -----------------------------------------------------------------------
;; (defun in-nix-shell-p ()
;;   "Predicate indicating if in nix-shell."
;;   (string-equal (getenv "IN_NIX_SHELL") "1"))
;; 
;; (use-package tuareg
;;   :ensure t
;;   :config
;;   ((setq conor/merlin-site-elisp (getenv "MERLIN_SITE_LISP"))
;;    (setq conor/utop-site-elisp (getenv "UTOP_SITE_LISP"))
;;    (setq conor/ocp-site-elisp (getenv "OCP_INDENT_SITE_LISP")))
;;   :hook
;;   (tuareg-mode .lsp))
;; 
;; (use-package utop
;;   :ensure t
;;   :hook
;;   (tuareg-mode . utop-minor-mode)
;;   :config
;;   (setq utop-command "utop -emacs"))
;; 
;; (use-package merlin
;;   :ensure t
;;   :hook
;;   ((tuareg-mode . merlin-mode)
;;    (merlin-mode . company-mode))
;;   :config
;;   (customize-set-variable 'merlin-command "ocamlmerlin"))
;; 
;; (use-package ocp-indent
;;   :ensure t)

;; Haskell ---------------------------------------------------------------------
;;(use-package haskell-mode
;;  :ensure t
;;  :mode
;;  (("\\.hs\\'" . haskell-mode)
;;   ("\\.hsc\\'" . haskell-mode)
;;   ("\\.c2hs\\'" . haskell-mode)
;;   ("\\.cpphs\\'" . haskell-mode)
;;   ("\\.lhs\\'" . haskell-literate-mode))
;;  :hook
;;  (haskell-mode . (lambda ()
;;		    ;; Key bindings for Haskell process
;;		    (define-key haskell-mode-map [?\C-c ?\C-l] 'haskell-process-load-file)
;;		    (define-key haskell-mode-map [f5] 'haskell-process-load-file)
;;		    ;; switch to repl
;;		    (define-key haskell-mode-map [?\C-c ?\C-z] 'haskell-interactive-switch)
;;		    (define-key haskell-mode-map (kbd "C-@") 'haskell-interactive-bring)
;;		    ;; Set formatting on save
;;		    (setq haskell-stylish-on-save t)
;;		    (setq haskell-mode-stylish-haskell-path "brittany")
;;		    (subword-mode)))
;;  :config
;;  (setq tab-width 2
;;	haskell-process-log t
;;	haskell-notify-p t))

;; F# --------------------------------------------------------------------------
;; (use-package dotnet
;;   :ensure t)
;; 
;; (use-package fsharp-mode
;;   :ensure t
;;   :after '(eglot flycheck flycheck-inline)
;;   :hook
;;   ((fsharp-mode . eglot-ensure)
;;    (fsharp-mode . dotnet-mode))
;;   :init
;;   ((setq inferior-fsharp-program "dotnet fsi --readline-")))

;; Rust ------------------------------------------------------------------------
(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
	      ("M-j" . lsp-ui-imenu)
	      ("M-?" . lsp-find-references)
	      ("C-c C-c l" . flycheck-list-errors)
	      ("C-c C-c a" . lsp-execute-code-action)
	      ("C-c C-c r" . lsp-rename)
	      ("C-c C-c q" . lsp-workspace-restart)
	      ("C-c C-c Q" . lsp-workspace-shutdown)
	      ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook))

(defun rk/rustic-mode-hook ()
  "So that run works without having to confirm."
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

;; custom variables (Do not edit) ----------------------------------------------
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

(provide 'init)
;;; init.el ends here
