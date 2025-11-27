;; functions

(defun my/use-eslint-from-node-modules ()
  "Set local eslint if available."
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

;; From orgmode.org
(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-todo-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

;; From https://github.com/emacs-lsp/lsp-mode/issues/2842#issuecomment-870807018.
(defun org-babel-edit-prep:fsharp (babel-info)
  "Setup for lsp-mode in Org Src buffer using BABEL-INFO.bb."
  (setq-local default-directory (->> babel-info caddr (alist-get :dir)))
  (setq-local buffer-file-name (->> babel-info caddr (alist-get :tangle)))
  (lsp-deferred))

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)

;; UI Modification
(setq inhibit-startup-message t)  ; Scratch buffer on startup
;;(scroll-bar-mode -1)              ; Disable visible scrollbar
(tool-bar-mode -1)                ; Disable toolbar
(tooltip-mode -1)                 ; Disable tooltips
;;(set-fringe-mode 15)              ; Add some margin to buffer
(menu-bar-mode -1)                ; Remove top menu bar
(setq visible-bell t)             ; Visual bell

;; Font
(set-face-attribute 'default nil :font "Iosevka" :height 120)
(set-face-attribute 'fixed-pitch nil :font "Iosevka" :height 120)
(set-face-attribute 'variable-pitch nil :font "Iosevka" :height 110)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

;; Line wrap
(global-visual-line-mode)
(delete-selection-mode t)

;; Extra-Config
(setq-default indent-tabs-mode nil)
(setq backup-directory-alist `(("." . ,(expand-file-name "backup-files/" user-emacs-directory))))
(setq load-prefer-newer t)

;; Disable for certain file types
(dolist
    (mode
     '(org-mode-hook
       term-mode-hook
       eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Package Management
;; Package management is actually handled in home-manager config.
;; This is just sort of a backup in case I don't feel like rebuilding.
(require 'package)

(setq package-archives '(("melpa"        . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("elpa"         . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; Refresh package list
(when (not package-archive-contents)
  (package-refresh-contents))

;; Init use-package on non-linux platforms.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Set Use-package to always ensure.
;; This works with nix home-manager set up in home.nix.
(setq use-package-always-ensure t)

(use-package emacsql :ensure t)
(use-package emacsql-sqlite)

(use-package yasnippet-snippets
  :ensure t)

(use-package yasnippet
  :ensure t
  :config (setq yas-global-mode 1))

(use-package all-the-icons
  :ensure t)

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (setq doom-font (font-spec :family "Iosevka" :size 12))
  (load-theme 'doom-dracula t)
  (doom-themes-visual-bell-config)
  (setq doom-themes-treemacs-theme "doom-atom")
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package topspace
  :ensure t)

(use-package envrc
  :ensure t
  :config
  (envrc-global-mode))

(use-package treesit-auto
  :ensure t
  :config (global-treesit-auto-mode))

;; Completion (Ivy and Counsel)
(use-package counsel
  :ensure t
  :diminish
  :bind
  (("M-x"     . counsel-M-x)
   ("C-x b"   . counsel-ibuffer)
   ("C-x C-f" . counsel-find-file))
  :config
  (setq ivy-initial-inputs-alist nil))

(use-package ivy
  :ensure t
  :diminish
  :bind (:map ivy-minibuffer-map
         ("TAB" . ivy-alt-done))
  :config (ivy-mode 1)
          (setq ivy-wrap t)
          (setq ivy-use-virtual-buffers t)
          (setq enable-recursive-minibuffers t))

(use-package ivy-rich
  :ensure t
  :init (ivy-rich-mode 1))

(use-package ivy-prescient
  :ensure t
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  (ivy-prescient-mode 1))

(use-package company
  :ensure t
  :bind (:map company-active-map ("<tab>" . company-complete-selection))
  :config (global-company-mode t))

;; Projects
(use-package projectile
  :ensure t
  :diminish
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :custom
  (projectile-completion-system 'ivy)
  :config
  (projectile-mode))

(use-package counsel-projectile
  :ensure t
  :after (counsel projectile)
  :config
  (counsel-projectile))

(use-package no-littering
  :ensure t
  :config
  ((no-littering-theme-backups)
   (setq no-littering-etc-directory
         (expand-file-name "config/" user-emacs-directory))
   (setq no-littering-var-directory
         (expand-file-name "data/" user-emacs-directory))))

(use-package exec-path-from-shell
  :ensure t
  :config (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "NIX_PATH"))

;; Git
(use-package magit
  :ensure t)

;; Dirtree
;; TODO: Configure treemacs visually to preference.
(use-package treemacs
  :ensure t)

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))

(use-package treemacs-icons-dired
  :ensure t
  :hook (dired-mode . treemacs-icons-dired-enable-once))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

(use-package lsp-treemacs
  :ensure t
  :after (lsp treemacs))

(use-package which-key
  :ensure t
  :diminish
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.5))

;; Better help messages
(use-package helpful
  :ensure t
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command]  . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key]      . helpful-key))

;; Language Configs
;; flycheck
(use-package flycheck
  :ensure t
  :diminish
  :hook ((flycheck . flycheck-inline)
         (flycheck . 'my/use-eslint-from-node-modules))
  :config
  (global-flycheck-mode))

(use-package flycheck-inline
  :ensure t
  :diminish
  :after (flycheck))

;; LSP
(use-package lsp-mode
  :ensure t
  :config
  (lsp-enable-which-key-integration t)
  (setq lsp-auto-configure t)
  :init
  (setq lsp-keymap-prefix "C-c l"))

(use-package lsp-ui
  :ensure t
  :config
  (setq lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-hover t))

(use-package lsp-ivy
  :ensure t)

(use-package project :ensure t)

(use-package eglot
  :ensure t
  :after (project projectile))

;; Org
(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :custom ((org-roam-directory "~/Documents/Notes"))
  :config (org-roam-setup))

(use-package ob-fsharp
  :ensure t
  :config
  (setq inferior-fsharp-program "dotnet fsi --readline-"))

(use-package org
  :ensure t
  :bind (("C-c l" . org-store-link)
         ("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :hook ((org-after-todo-statistics . org-summary-todo))
  :config
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1)
  (setq org-ellipsis " ▾"
        org-agenda-start-with-log-mode t
        org-log-done 'time
        org-log-into-drawer t
        org-confirm-babel-evaluate nil
        org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-src-preserve-indentation t
        org-support-shift-select nil
        org-todo-keywords
        '((sequence "TODO" "DO" "AWAIT" "|" "DONE" "NM"))
        org-agenda-files (list "~/Documents/Todo" "~/work" "~/work/daily-files"))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell    . t)
     (plantuml . t)
     (python   . t)
     (fsharp   . t))
  (add-to-list
   'org-src-lang-modes '("plantuml" . plantuml)))

(setq org-todo-keywords '((sequence "TODO" "DO" "AWAIT" "|" "DONE" "NM")))

(use-package org-auto-tangle
  :ensure t
  :defer t
  :hook (org-mode . org-auto-tangle-mode))

(use-package org-bullets
  :diminish
  :ensure t
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(use-package org-fancy-priorities
  :diminish
  :ensure t
  :hook (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("🅰" "🅱" "🅲" "🅳" "🅴")))

(use-package org-pretty-tags
  :diminish org-pretty-tags-mode
  :ensure t
  :config
  (setq org-pretty-tags-surrogate-strings
        '(("work"  . "⚒")))
  (org-pretty-tags-global-mode))

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

(use-package plantuml-mode
  :ensure t
  :mode "\\.plantuml\\'")

;; lisp
(use-package parinfer-rust-mode
  :ensure t
  :hook ((emacs-lisp-mode . parinfer-rust-mode)
         (racket-mode     . parinfer-rust-mode)))

(use-package racket-mode :ensure t)

(use-package ob-powershell
  :ensure t
  :custom (ob-powershell-powershell-command "pwsh"))

(use-package apheleia
  :ensure t
  :config ((apheleia-global-mode t)))

;; html and css
(use-package web-mode
  :ensure t
  :config ((setq web-mode-markup-indent-offset 2)
           (setq web-mode-css-indent-offset 2)
           (setq web-mode-code-indent-offset 2))
  :mode (("\\.html\\'" . web-mode)
         ("\\.css\\'" . web-mode)
         ("\\.cshtml\\'" . web-mode))
  :hook ((web-mode . emmet-mode)))

(use-package emmet-mode
  :ensure t
  :bind ("C-j" . emmet-expand-line))

(use-package json-mode
  :ensure t)

(use-package company-ghci
  :ensure t
  :after company-mode
  :config (add-to-list 'company-backends 'company-ghci))

(use-package haskell-mode
  :ensure t
  :defer t
  :hook ((haskell-mode . lsp-deferred)
         (haskell-mode . interactive-haskell-mode))
  :config (setq haskell-mode-stylish-haskell-package "brittany"
                lsp-haskell-process-path-hie "haskell-language-server-wrapper"
                lsp-haskell-process-args-hie '("-d" "-l" "/tmp/hls.log")
                haskell-process-type 'cabal-repl))

(use-package lsp-haskell
  :ensure t
  :defer t
  :config (setq lsp-haskell-server-path "haskell-language-server-wrapper"))

(use-package python-mode
  :ensure nil
  :hook ((python-mode . lsp)))

(use-package python-black
  :ensure t
  :after python
  :hook (python-mode . python-black-on-save-mode-enable-dwim))

(use-package csharp-mode
  :ensure nil
  :hook ((csharp-mode . lsp-deferred)))

(use-package fsharp-mode
  :ensure t
  :defer t)

(use-package fsharp-mode
  :ensure t
  :config (setq lsp-fsharp-use-dotnet-tool-for-fsac nil)
  :hook ((fsharp-mode . lsp-deferred)))

(use-package nxml-mode
  :ensure nil
  :hook ((nxml-mode . lsp-deferred)))

(use-package rescript-mode
  :ensure t
  :hook ((rescript-mode . lsp)))

(use-package lsp-rescript
  :ensure t
  :after rescript-mode)

(use-package powershell
  :ensure t
  :mode (("\\.ps1\\'" . powershell-mode)
         ("\\.psm1\\'" . powershell-mode)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-url-browser-function 'browse-url-firefox)
 '(css-indent-offset 2)
 '(js-indent-level 4)
 '(lsp-pyls-plugins-flake8-enabled t)
 '(package-selected-packages nil)
 '(safe-local-variable-values
   '((lsp-csharp-server-path
      . "/nix/store/2w8wkhkhd0b85fz48pnsds5msy31iyhm-omnisharp-roslyn-1.39.10/bin")
     (lsp-csharp-solution-file . "CyberArkMigrationScrips.sln")
     (lsp-csharp-server-path getenv "OMNISHARP_ROSLYN_LOCATION")))
 '(typescript-indent-level 2)
 '(warning-suppress-types '((use-package) (lsp-mode) (lsp-mode))))
(custom-set-faces)
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 
(put 'list-timers 'disabled nil)
