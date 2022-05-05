{ config, pkgs, ... }:

with pkgs;

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { };
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };
in
  {
    nixpkgs.overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      }))
      (import ./extrapkgs.nix)
    ];

    imports = [
      nur-no-pkgs.repos.rycee.hmModules.emacs-init
    ];

    nixpkgs.config.packageOverrides = super : let self = super.pkgs; in {
      jupyterlab-widgets = super.jupyterlab-widgets.overridePythonAttrs (p: {
        propagatedBuildInputs = p.propagatedBuildInputs ++ [ super.jupyter-packaging ];
      });
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "conor";
    home.homeDirectory = "/home/conor";

    home.sessionVariables = {
      ELS_INSTALL_PREFIX = "${builtins.dirOf pkgs.elixir-ls}";
    };

    # NixDirenv values
    programs.direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
      "vscode"
      "spotify"
      "spotify-unwrapped"
      "google-chrome-dev"
    ];

    fonts.fontconfig.enable = true;
    
    # Bash Config
    programs.bash = {
      enable = true;
      initExtra = ''
        DIR=~/.nix-profile/etc/profile.d
        [[ -f "$DIR/nix.sh" ]] && . "$DIR/nix.sh"
        [[ -f "$DIR/hm-session-vars.sh" ]] && . "$DIR/hm-session-vars.sh"
      '';
      shellAliases = {
        emacs = "emacs -nw";
        ls = "lsd";
        l = "ls -l";
        la = "ls -a";
        lla = "ls -la";
        lt = "ls --tree";
      };
      bashrcExtra = ''
      eval "$(starship init bash)"
      '';
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
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          identityFile = "/home/conor/.ssh/conorflemingATXgh";
        };
        
        "ssh.dev.azure.com" = {
          hostname = "ssh.dev.azure.com";
          identityFile = "/home/conor/.ssh/nitco-devops";
        };
      };
    };

    # Set terminal font
    programs.gnome-terminal.profile.Default = {
      font = "Fira Code";
    };
    
    # Emacs
    programs.emacs = {
      enable = true;
      package = (emacsWithPackagesFromUsePackage {
        alwaysEnsure = true;
        config = /home/conor/.config/emacs/init.el;
      });
      extraPackages = (epkgs : [
        epkgs.jupyter
        fira-code
        elixir-ls
        rust-analyzer
        nodePackages.eslint
        nodePackages.prettier
      ]);
    };
    services.emacs.enable = true;

    # VsCode
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        haskell.haskell
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vscode";
          publisher = "dbaeumer";
          version = "2.1.14";
          sha256 = "113w2iis4zi4z3sqc3vd2apyrh52hbh2gvmxjr5yvjpmrsksclbd";
        }
      ];
    };
    
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "21.03";

    home.packages = [
      lsd
      stow
      starship
      spotify
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      fd
      fzf
      ripgrep
      unzip
      nodejs
      (callPackage ./default.nix { }).shell.nodeDependencies
      (python39.withPackages (pyPkgs: with pyPkgs; [
        jupyter
        ipython
        jupyter_client
        jupyter_console
      ]))
      poetry
      neofetch
      google-chrome-dev
      remmina
    ];
  }
