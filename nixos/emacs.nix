{ pkgs }:
with pkgs;
emacsWithPackagesFromUsePackage {
  config = ./init.el;
  defaultInitFile = true;
  package = emacs-git;
  extraEmacsPackages = epkgs: [
    sqlite
    epkgs.emacs-package-template
  ];
  override = final: prev: {
    emacs-package-template = emacs-package-template;
  };
}
