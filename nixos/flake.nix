{
  description = "System configuration for NixOS.";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
    };
    # ... Local Packages
    python-package-template = {
      url = "git+file:///home/conor/packages/python/python-package-template";
    };
    emacs-package-template = {
      url = "git+file:///home/conor/packages/emacs/emacs-package-template";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    emacs-overlay,
    python-package-template,
    emacs-package-template,  
    ...
  }@inputs:
    let
      system = "x86_64-linux";
      eo     = import emacs-overlay;
      otherPackages = final: prev: {
        python-package-template = python-package-template.packages.${system}.default;
        emacs-package-template = emacs-package-template.packages.default;
      };
      pkgs   = (import nixpkgs {
        inherit system;
        overlays = [ eo otherPackages ];
      });
    in
      {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
          specialArgs = { inherit home-manager; };
          modules = [
            ./configuration.nix
          ];
        };
      };
}
