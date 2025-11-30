;;  -*- lexical-binding: t; -*-
;; functions

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
(scroll-bar-mode -1)              ; Disable visible scrollbar
(tool-bar-mode -1)                ; Disable toolbar
(tooltip-mode -1)                 ; Disable tooltips
(set-fringe-mode 15)              ; Add some margin to buffer
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
(require 'package)

(setq package-archives '(("melpa"        . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("elpa"         . "https://elpa.gnu.org/packages/")))

;; Refresh package list
(when (not package-archive-contents)
  (package-refresh-contents))

;; Init use-package on non-linux platforms.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-require t)

(use-package emacsql :ensure t)
(use-package emacsql-sqlite :ensure t)

(use-package all-the-icons
  :ensure t)

;; (use-package doom-themes
  ;; :ensure t
  ;; :custom
  ;; (doom-themes-enable-bold t)
  ;; (doom-themes-enable-italic t)
  ;; :config
  ;; (setq doom-font (font-spec :family "Iosevka" :size 12))
  ;; (load-theme 'doom-dracula t)
  ;; (doom-themes-visual-bell-config)
  ;; (doom-themes-org-config))

(use-package dracula-theme
  :ensure t
  :config (load-theme 'dracula t))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package envrc
  :ensure t
  :config
  (envrc-global-mode))

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

(use-package exec-path-from-shell
  :ensure t
  :config (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "NIX_PATH"))

;; Git
(use-package magit
  :ensure t)

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
     (fsharp   . t)))
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
;; (use-package parinfer-rust-mode
  ;; :ensure t
  ;; :hook ((emacs-lisp-mode . parinfer-rust-mode)
         ;; (racket-mode     . parinfer-rust-mode)))

(use-package racket-mode :ensure t)

(use-package ob-powershell
  :ensure t
  :custom (ob-powershell-powershell-command "pwsh"))

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

(use-package yaml-mode
  :ensure t
  :mode (("\\.yaml\\'" . yaml-mode)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-url-browser-function 'browse-url-firefox)
 '(package-selected-packages
   '(add-node-modules-path all-the-icons apheleia company-ghci
                           counsel-projectile csv-mode dap-mode
                           doom-modeline doom-themes emmet-mode envrc
                           exec-path-from-shell flycheck-inline
                           helpful ivy-prescient ivy-rich jest
                           json-mode lsp-haskell lsp-ivy lsp-rescript
                           lsp-ui mocha nix-mode no-littering
                           ob-fsharp ob-powershell org-auto-tangle
                           org-bullets org-fancy-priorities
                           org-pretty-tags org-roam parinfer-rust-mode
                           plantuml-mode powershell prettier-js
                           python-black quelpa-use-package racket-mode
                           rainbow-delimiters repl-toggle ruff-format
                           rustic skewer-mode topspace
                           treemacs-icons-dired treemacs-magit
                           treemacs-projectile treesit-auto ts-comint
                           typescript-mode web-mode which-key
                           yaml-mode yasnippet-snippets)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Source - https://stackoverflow.com/a
;; Posted by user355252, modified by community. See post 'Timeline' for change history
; Retrieved 2025-11-27, License - CC BY-SA 3.0
(setq-default flycheck-emacs-lisp-load-path 'inherit)
(require 'emacs-package-template)
