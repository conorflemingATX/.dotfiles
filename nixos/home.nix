{ pkgs }:
{
    home.username = "conor";
    home.homeDirectory = "/home/conor";

    home.packages = with pkgs; [
      plantuml
      python-package-template
    ];

    home.sessionVariables = {};
    
    # This values determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.05"; # Please read the comment before changing.

    # Services
    services.emacs.enable = true;

    # Test python service.
    services.python-example-webapp.enable = true;
    
    # Programs
    programs.home-manager.enable = true;
    programs.emacs = {
      enable = true;
      package = import ../emacs/emacs.nix { inherit pkgs; };
    };
}
