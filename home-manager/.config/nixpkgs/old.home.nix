{ config, pkgs, ... }:
let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in
{
  nixpkgs.overlays = [
    (import ./overlays/extrapkgs.nix)
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    nur-no-pkgs.repos.rycee.hmModules.emacs-init
    ~/.config/nixpkgs/dconf.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "conor";
  home.homeDirectory = "/home/conor";

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "spotify-unwrapped"
    ];

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    gnome3.gnome-tweak-tool
    spotify
    dconf2nix
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    fd
    fzf
    ripgrep
    unzip
  ];

  # Bash Config
  programs.bash = {
    enable = true;
    shellAliases = {
      emacs = "emacs -nw";
      code = "codium";
    };
  };

  # Git Config
  programs.git = {
    enable = true;
    userName = "Conor Fleming";
    userEmail = "conorfleming@outlook.com";
    extraConfig = {
      core.editor = "emacs";
      github.username = "conorflemingATX";
    };
  };

  # Ssh Config
  programs.ssh = {
    enable = true;
  };

  # Set terminal font
  programs.gnome-terminal.profile.Default = {
    font = "Fira Code";
  };

  # Enable Nix-direnv
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  # Emacs Config
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; with pkgs; [
      envrc
      no-littering
      elixir-ls
    ];
    init = {
      enable = true;
      recommendedGcSettings = true;
      prelude = ''
        ;; Disable Startup message
        (setq inhibit-startup-message t)

        ;; Clean up some visual cruft
        (scroll-bar-mode -1)
        (tool-bar-mode -1)
        (tooltip-mode -1)
        (set-fringe-mode 10)
        (menu-bar-mode 10)
        (column-number-mode)
        (global-display-line-numbers-mode)
        (global-visual-line-mode)
        
        (global-unset-key (kbd "C-@"))
        
        ;; Load Packages from ExtraPackages above
        (package-initialize)
        
        ;; Envrc and No-littering are set up here for control
        ;; over execution time.
        (envrc-global-mode)

        ;; Set emacs to split panes vertically by default. e.g utop.
        (setq
          split-width-threshold 0
          split-height-threshold nil)

        (add-hook 'after-init-hook #'global-flycheck-mode)
        (setq-default flycheck-global-modes '(not org-mode fsharp-mode))
      '';
      
      usePackage = {
        projectile = {
          enable = true;
        };
        
        no-littering = {
          enable = true;
          config = ''
             ;; Do not dump autosave files into dirs,
             ;; Save to dedicated cache.
             (setq auto-save-file-name-transforms
               `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
          '';
        };

        typescript-mode = {
          enable = true;
        };

        tide = {
          enable = true;
          after = [ "typscript-mode" "company" "flycheck" ];
          hook = [
            ''((typescript-mode . tide-setup)
               (typscript-mode . tide-hl-identifier-mode)
               (before-save . tide-format-before-save))''
          ];
        };
        
        swiper = {
          enable = true;
          command = [ "swiper" "swiper-all" "swiper-isearch" ];
          bind = { "C-s" = "swiper-isearch"; };
        };

        counsel = {
          enable = true;
          bind = {
            "C-x C-d" = "counsel-dired-jump";
            "C-x C-f" = "counsel-find-file";
            "C-x M-f" = "counsel-fzf";
            "C-x C-r" = "counsel-recentf";
            "C-x C-y" = "counsel-yank-pop";
            "M-x" = "counsel-M-x";
          };
          diminish = [ "counsel-mode" ];
          config = let
            fd = "${pkgs.fd}/bin/fd";
            fzf = "${pkgs.fzf}/bin/fzf";
          in
            ''
              (setq counsel-fzf-cmd "${fd} --type f | ${fzf} -f \"%s\"")
          '';
        };

        ivy = {
          enable = true;
          demand = true;
          diminish = [ "ivy-mode" ];
          command = [ "ivy-mode" ];
          config = ''
           (setq ivy-use-virtual-buffers t
                 ivy-count-format "%d/%d "
                 ivy-virtual-abbreviate 'full)
           (ivy-mode 1)
         '';
        };

        dracula-theme = {
          enable = true;
          config = ''
            (load-theme 'dracula t)
          '';
        };

        multiple-cursors = {
          enable = true;
          bind = {
            "C-S-c C-S-c" = "mc/edit-lines";
            "C-c m" = "mc/mark-all-like-this";
            "C->" = "mc/mark-next-like-this";
            "C-<" = "mc/mark-previous-like-this";
          };
        };

        which-key = {
          enable = true;
          command = [
            "which-key-mode"
            "which-key-add-major-mode-key-based-replacements"
          ];
          diminish = [ "which-key-mode" ];
          defer = 3;
          config = "(which-key-mode)";
        };

        nix-mode = {
          enable = true;
        };

        org = {
          enable = true;
       	  package = epkgs: epkgs.org-plus-contrib;
          config = ''
            (setq org-src-fontify-natively t
                  org-src-tab-acts-natively t
                  org-confirm-babel-evaluate nil
                  org-edit-src-content-indentation 0)
            (org-babel-do-load-languages
               'org-babel-load-languages
                 '((haskell . t)))
          '';
        };
        
        lsp-ivy = {
          enable = true;
          after = [ "lsp-mode" ];
          command = [ "lsp-ivy-workspace-symbol" ];
        };

        lsp-haskell = {
          enable = true;
          defer = true;
          hook = [''
            (haskell-mode . (lambda ()
                              (lsp)))
          ''];
        };

        lsp-ui = {
          enable = true;
          command = [ "lsp-ui-mode" ];
          bindLocal = {
            lsp-mode-map = {
              "C-c r d" = "lsp-ui-doc-glance";
              "C-c f s" = "lsp-ui-find-workspace-symbol";
            };
          };
          config = ''
            (setq lsp-ui-sideline-enable t
                  lsp-ui-sideline-show-symbol t
                  lsp-ui-sideline-show-hover t
                  lsp-ui-sideline-show-code-actions nil
                  lsp-ui-sideline-update-mode 'point)
            (setq lsp-ui-doc-enable nil
                  lsp-ui-doc-position 'at-point
                  lsp-ui-doc-max-width 120
                  lsp-doc-max-height 15)
          '';
        };

        lsp-ui-flycheck = {
          enable = true;
          after = [ "flycheck" "lsp-ui" ];
        };

        lsp-completion = {
          enable = true;
          after = [ "lsp-mode" ];
          config = ''
            (setq lsp-completion-enable-additional-text-edit nil)
          '';
        };

        lsp-diagnostics = {
          enable = true;
          after = [ "lsp-mode" ];
        };

        lsp-mode = {
          enable = true;
          command = [ "lsp" ];
          after = [ "company" "flycheck" ]; 
          hook = [
            "(lsp-mode . lsp-enable-which-key-integration)"
          ];
          bindLocal = {
            lsp-mode-map = {
              "C-c r r" = "lsp-rename";
              "C-c r f" = "lsp-format-buffer";
              "C-c r g" = "lsp-format-region";
              "C-c r a" = "lsp-execute-code-action";
              "C-c f r" = "lsp-find-references";
            };
          };
          init = let
            elixirLsReleasePath = "${pkgs.elixir-ls}";
          in ''
            (setq lsp-keymap-prefix "C-c l")
            (add-to-list 'exec-path "${elixirLsReleasePath}")
          '';
          config = ''
            (setq lsp-diagnostics-provider :flycheck
                  lsp-eldoc-render-all nil
                  lsp-headerline-breadcrumb-enable nil
                  lsp-modeline-code-actions-enable nil
                  lsp-modeline-diagnostics-enable nil
                  lsp-modeline-workspace-status-enable nil)
            (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
          '';
        };

        elixir-mode = {
          enable = true;
          defer = true;
          after = [ "lsp" "flycheck" ];
          hook = [
            ''(elixir-mode . (lambda () (add-hook 'before-save-hook 'elixir-format nil t)))''
            ''(elixir-mode . lsp)''
          ];
        };

        tuareg = {
          enable = true;
          # I am not at all sure about this...
          init = ''
            (defun in-nix-shell-p ()
              (string-equal (getenv "IN_NIX_SHELL") "1"))

            (setq conor/merlin-site-eslisp (getenv "MERLIN_SITE_LISP"))
            (setq conor/utop-site-elisp (getenv "UTOP_SITE_LISP"))
            (setq conor/ocp-site-elisp (getenv "OCP_INDENT_SITE_LISP"))
          '';
          # I am calling these inline in the tuareg entry
          # instead of giving them their own entries
          # because the usePackage thing does not have if or loadPath
          # It's difficult to get it to use emacs start-time env vars.
          hook = [ ''(tuareg-mode . lsp)'' ];
        };

        utop = {
          enable = true;
          hook = [ ''(tuareg-mode . utop-minor-mode)'' ];
          config = ''
            (setq utop-command "utop -emacs")
          '';
        };

        merlin = {
          enable = true;
          hook = [
            ''(tuareg-mode . merlin-mode)''
            ''(merlin-mode . company-mode)''
          ];
          config = ''
            (customize-set-variable 'merlin-command "ocamlmerlin")
          '';
        };

        ocp-indent = {
          enable = true;
        };

        haskell-mode = {
          enable = true;
          mode = [
            ''("\\.hs\\'" . haskell-mode)''
            ''("\\.hsc\\'" . haskell-mode)''
            ''("\\.c2hs\\'" . haskell-mode)''
            ''("\\.cpphs\\'" . haskell-mode)''
            ''("\\.lhs\\'" . haskell-literate-mode)''
          ];
          hook = [
            ''(haskell-mode . (lambda ()
                                ;; Key bindings for Haskell Process
                                (define-key haskell-mode-map [?\C-c ?\C-l] 'haskell-process-load-file)
                                (define-key haskell-mode-map [f5] 'haskell-process-load-file)
                                ;; Switch to REPL
                                (define-key haskell-mode-map [?\C-c ?\C-z] 'haskell-interactive-switch)
                                (define-key haskell-mode-map (kbd "C-@") 'haskell-interactive-bring)
                                ;; Set formatting on Save
                                (setq haskell-stylish-on-save t)
                                (setq haskell-mode-stylish-haskell-path "brittany")
                                (subword-mode)))''
          ];
          config = ''
            (setq tab-width 2)
            (setq haskell-process-log t
                  haskell-notify-p t)
          '';
        };

        haskell-cabal = {
          enable = true;
          mode = [ ''("\\.cabal\\'" . haskell-cabal-mode)'' ];
          bindLocal = {
            haskell-cabal-mode-map = {
              "C-c C-c" = "haskell-process-cabal-build";
              "C-c c" = "haskell-process-cabal";
              "C-c C-b" = "haskell-interactive-bring";
            };
          };
        };

        haskell-doc = {
          enable = true;
          command = [ "haskell-doc-current-info" ];
        };

        flymake-diagnostic-at-point = {
          enable = true;
          after = [ "flymake" ];
          config = ''
            (add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode)
          '';
        };

        flycheck = {
          enable = true;
          diminish = [ "flycheck-mode" ];
          command = [ "global-flycheck-mode" ];
          defer = 1;
          bind = {
            "M-n" = "flycheck-next-error";
            "M-p" = "flycheck-previous-error";
          };
          config = ''
            ;; Enable flycheck in all eligible buffers.
            (global-flycheck-mode)
          '';
        };

        flycheck-inline = {
          enable = true;
          after = [ "quick-peek" "flycheck" ];
          config = ''
            (setq flycheck-inline-display-function
              (lambda (msg pos err)
                (let* ((ov (quick-peek-overlay-ensure-at pos))
                      (contents (quick-peek-overlay-contents ov)))
                  (setf (quick-peek-overlay-contents ov)
                        (concat contents (when contents "\n") msg))
                  (quick-peek-update ov)))
              flycheck-inline-clear-function #'quick-peek-hide)
          '';
        };

        company = {
          enable = true;
          diminish = [ "company-mode" ];
          command = [ "company-mode" "company-doc-buffer" "global-company-mode" ];
          defer = 1;
          extraConfig = ''
            :bind (:map company-mode-map
                        ([remap completion-at-point] . company-complete-common)
                        ([remap complete-symbol] . company-complete-common))
          '';
          config = ''
            (setq company-idle-delay 0.3
                  company-show-numbers t
                  company-tooltip-maxumum-width 100
                  company-tooltip-minumum-width 20
                  ; Allow me to keep typing even if company disapproves.
                  company-require-match nil)

            (global-company-mode)
          '';
        };

        company-cabal = {
          enable = true;
          after = [ "company" ];
          command = [ "company-cabal" ];
          config = ''
            (add-to-list 'company-backends 'company-cabal)
          '';
        };

        eglot = {
          enable = true;
        };

        eglot-fsharp = {
          after = [ "eglot" "fsharp-mode" ];
          enable = true;
        };

        dotnet = {
          enable = true;
        };

        quick-peek = {
          enable = true;
        };

        fsharp-mode = {
          enable = true;
          after = [ "eglot" "flycheck" "flycheck-inline" ];
          hook = [ ''(fsharp-mode . eglot-ensure)'' ];
          init = ''
            (add-hook 'fsharp-mode-hook 'dotnet-mode)
            (add-hook 'fsharp-mode-hook 'company-mode)
            (setq inferior-fsharp-program "dotnet fsi --readline-")

            (defun fsharp-enable-prettify-symbols ()
              (let ((alist '(("->" . ?→)
                 ("<-" . ?←)
                 ("|>" . ?⊳)
                 ("<|" . ?⊲))))
              (setq-local prettify-symbols-alist alist)))

            (add-hook 'fsharp-mode-hook
              (lambda ()
                (fsharp-enable-prettify-symbols)))
          ''; 
        };
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = (with pkgs.vscode-extensions; [
      bbenoist.Nix
      ms-python.python
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.47.2";
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      }
      {
        name = "vscode-emacs-friendly";
        publisher = "lfs";
        version = "0.9.0";
        sha256 = "1j4cy77m1077wdl2vvpmzi98y3jkycvf8z84pscs3lkkk1mvcsv1";
      }
      {
        name = "csharp";
        publisher = "ms-dotnettools";
        version = "1.23.11";
        sha256 = "0i099xvwls2y18bwn9wc0nsq62xb8ynmz6wh4nc8yxmb62x25k59";
      }
      {
        name = "Ionide-fsharp";
        publisher = "Ionide";
        version = "5.5.5";
        sha256 = "0nyi07xs7izynp2llhkqgz4i5j8gkpxy0gs934n9sm6rhs44vc66";
      }
    ];
  };

  programs.htop.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
