{
  description = "Configuration of NixOS for Conor Fleming";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
      managementDependencies = { pkgs }: with pkgs; [
        git
        git-crypt
        age
        ssh-to-age
        sops
      ];
    in
      {
        devShells = forAllSystems (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
            {
              default = pkgs.mkShell {
                packages = managementDependencies { inherit pkgs; };
                env = {};
                shellHook = '''';
              };
            }
        );

        # Default package is script to call `nixos-rebuild` using the
        # configuration.
        packages = forAllSystems (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            deps = managementDependencies { inherit pkgs; };
            stowed-config-location = ./nixos/flake.nix;
            rebuild-script = pkgs.writeText "rebuild-system.sh" ''
              sudo nixos-rebuild switch -I nixos-config=${stowed-config-location}
            ''; 
          in
            {
              default = pkgs.runCommandLocal "rebuild-system" {
                nativeBuildInputs = with pkgs; [ makeWrapper ];
                buildInputs = deps;
              } ''
                install -Dm 755 ${rebuild-script} $out/bin/rebuild-system
                wrapProgram $out/bin/rebuild-system \
                  --prefix PATH : ${pkgs.lib.makeBinPath deps}
                '';
            });
      };
}
