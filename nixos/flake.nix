{
  description = "System configuration for NixOS.";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };
  outputs = { self, nixpkgs, home-manager, emacs-overlay, ... }:
    let
      system = "x86_64-linux";
      eo     = import emacs-overlay;
      # pkgs   = (nixpkgs.legacyPackages.${system}.extend eo);
      pkgs = (import nixpkgs { inherit system; config.allowUnfree = true; }).extend eo;
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
